from serial_com import Uart
from enum import Enum, auto
import time

# Enum to define the available commands for the board
class Command(Enum):
    LOAD = 0x4c
    EXEC = 0x43
    EXEC_BY_STEPS = 0x53
    NEXT_STEP = 0x4e

# Enum to define the execution modes
class ExecMode(Enum):
    RUN = auto()
    STEP = auto()

# Enum to define the possible responses from the board
class Response(Enum):
    END = 0x1
    LOAD_OK = 0x2
    STEP_END = 0x3
    EMPTY_PROGRAM = 0x2

# Enum to define the result types
class Result(Enum):
    ERROR = 0xff
    INFO = 0x00
    REG = 0x01
    MEM = 0x02
    PC = 0x03

# Enum to define the bit masks used for extracting response data
class Mask(Enum):
    TYPE = 0xFF000000000000
    CYCLE = 0x00FF0000000000
    ADDR = 0x0000FF00000000
    DATA = 0x000000FFFFFFFF

# Enum to define the bit shifts for response data extraction
class Shift(Enum):
    TYPE = 48
    CYCLE = 40
    ADDR = 32
    DATA = 0

# Enum to define utility constants
class Utils(Enum):
    FILL_BYTES_ZERO = 0x00
    RES_SIZE_BYTES = 7

class Interface:
    def __init__(self, uart: Uart):
        """
        Initialize the interface with a UART object and prepare internal state.
        """
        self.uart = uart
        self.step_mode_flg = False
        self.registers = []
        self.memory = []
        self.pc = 0

    def load_program(self, inst: list):
        """
        Load a program to the board by sending the instructions one by one.
        Raises LoadProgramException if there's an error during the process.
        """
        self._send_cmd(Command.LOAD.value)
        
        # Check initial response to see if loading can start
        response_type, _, _, data = self._read_response()
        if response_type is not None:
            raise LoadProgramException(f"Error loading program: {hex(data)}")
        
        print("Loading program...")
        
        # Send instructions to the board in reverse order for each 4-byte block
        for i in range(0, len(inst), 4):
            for j in range(3, -1, -1):
                if i + j < len(inst):
                    # Send each byte as big-endian (most significant byte first)
                    self.uart.write(int(inst[i + j], 16), byteorder='big')
        
        # Check if the program loaded successfully
        response_type, _, _, data = self._read_response(locked=True)
        if response_type == Result.ERROR.value:
            raise LoadProgramException(f"Error loading program: {hex(data)}")

    def _send_cmd(self, cmd: int):
        """
        Send a command to the board followed by three zero-filled bytes.
        """
        # Command format: [CMD] + [0x00] + [0x00] + [0x00]
        self.uart.write(cmd)
        for _ in range(3):
            self.uart.write(Utils.FILL_BYTES_ZERO.value)
        time.sleep(0.1)  # Short delay to allow the board to process the command

    def _read_response(self, locked=False):
        """
        Read the board's response and extract relevant fields using bit masks.
        Returns a tuple of (response type, cycle, address, data).
        If no data is available and locked is False, returns (None, None, None, None).
        """
        if self.uart.check_data_available(Utils.RES_SIZE_BYTES.value) or locked:
            res = self.uart.read(Utils.RES_SIZE_BYTES.value)

            # Extract different parts of the response using bit masks and shifts
            res_type = (res & Mask.TYPE.value) >> Shift.TYPE.value
            res_cycle = (res & Mask.CYCLE.value) >> Shift.CYCLE.value
            res_addr = (res & Mask.ADDR.value) >> Shift.ADDR.value
            res_data = (res & Mask.DATA.value) >> Shift.DATA.value

            return res_type, res_cycle, res_addr, res_data
        else:
            return None, None, None, None

    def _read_result(self) -> bool:
        """
        Continuously read and process results from the board.
        Handles different result types: register data, memory data, program end, and errors.
        Returns True if the program has ended, False if in step mode and a step has completed.
        """
        while True:
            res_type, res_cycle, res_addr, res_data = self._read_response()

            if res_type == Result.ERROR.value:
                # Handle specific error cases
                if res_data == Response.EMPTY_PROGRAM.value:
                    print("Empty program.")
                else:
                    raise ValueError(f"Error: {hex(res_data)}")

            elif res_type == Result.INFO.value:
                # Handle program or step end
                if res_data == Response.END.value:
                    print("Program ended.")
                    return True
                elif res_data == Response.STEP_END.value:
                    print("Step ended.")
                    return False

            elif res_type == Result.REG.value:
                # Append register data to list
                self.registers.append({'cycle': res_cycle, 'addr': res_addr, 'data': res_data})
            elif res_type == Result.MEM.value:
                # Append memory data to list
                self.memory.append({'cycle': res_cycle, 'addr': res_addr, 'data': res_data})
            elif res_type == Result.PC.value:
                # Update program counter (PC)
                self.pc = res_data
            else:
                time.sleep(0.1)  # Short delay to avoid busy waiting

    def run_program(self, mode: ExecMode):
        """
        Start the execution of the program in the specified mode (RUN or STEP).
        Resets registers and memory before execution.
        """
        # Reset the state
        self.registers = []
        self.memory = []

        self.step_mode_flg = False

        if mode == ExecMode.RUN:
            self._send_cmd(Command.EXEC.value)
        elif mode == ExecMode.STEP:
            self._send_cmd(Command.EXEC_BY_STEPS.value)
            self.step_mode_flg = True
        else:
            raise ValueError("Invalid execution mode.")
        
        return self._read_result()

    def run_next_step(self) -> bool:
        """
        Execute the next step in step mode. Raises an error if not in step mode.
        Returns True if the program ends after this step, otherwise False.
        """
        if not self.step_mode_flg:
            raise ValueError("Not in step mode.")
        
        print("Running next step...")
        self._send_cmd(Command.NEXT_STEP.value)
        return self._read_result()

    def reg_summary(self):
        """
        Print a summary of the registers' content after execution.
        """
        print("Registers:")
        for reg in self.registers:
            print(f"Cycle: {reg['cycle']} Addr: {reg['addr']} Data: {reg['data']}")

    def mem_summary(self):
        """
        Print a summary of the memory's content after execution.
        """
        print("Memory:")
        for mem in self.memory:
            print(f"Cycle: {mem['cycle']} Addr: {mem['addr']} Data: {mem['data']}")

    def get_reg_by_cycle(self, cycle: int):
        """
        Return a list of registers filtered by a specific cycle.
        """
        return [reg for reg in self.registers if reg['cycle'] == cycle]

    def get_mem_by_cycle(self, cycle: int):
        """
        Return a list of memory entries filtered by a specific cycle.
        """
        return [mem for mem in self.memory if mem['cycle'] == cycle]

    def get_pc(self):
        """
        Return the current value of the program counter (PC).
        """
        return self.pc

    def get_reg_last_cycle(self):
        """
        Return the registers from the last cycle that was executed.
        """
        if not self.registers:
            return None
        last_cycle = self.registers[-1]['cycle']
        return self.get_reg_by_cycle(last_cycle)

    def get_mem_last_cycle(self):
        """
        Return the memory entries from the last cycle that was executed.
        """
        if not self.memory:
            return None
        last_cycle = self.memory[-1]['cycle']
        return self.get_mem_by_cycle(last_cycle)

# Custom exception for errors when loading the program
class LoadProgramException(Exception):
    pass
