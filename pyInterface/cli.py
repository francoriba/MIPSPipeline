import shutil
import os
from mipsAssambler import mipsAssambler
import serial_com
from serial_com import Uart
from interface import Interface, ExecMode
from colorama import Fore, Style, init
init(autoreset=True)

class UI():
    def __init__(self):
        uart = None
        interface = None
        self.set_up()

    def set_up(self):
        clear_screen()
        self.uart = self.uart_init()
        self.interface = self.Interface_init(self.uart)
        self.main_menu()

    def main_menu(self):
        clear_screen()
        terminal_size = shutil.get_terminal_size((80, 20))  # Valores por defecto si no se puede obtener el tamaño
        width = terminal_size.columns
        title = " MIPS32 CLI "
        total_dashes = width - len(title)
        left_dashes = total_dashes // 2
        right_dashes = total_dashes - left_dashes
        print("-" * left_dashes + title + "-" * right_dashes + "\n")

        print("1) Compile and Load")
        print("2) Run program")
        print("3) Step by step program")
        print("4) Exit\n")

        input_option = input("Select an option: ")

        if input_option == "1":
            self.compile_and_load()
            input("\nPress Enter to continue...")
            self.main_menu()

        elif input_option == "2":
            self.run_program()

        elif input_option == "3":
            self.step_program()

        elif input_option == "4":
            clear_screen()
            exit(0)

    # Compile and load program
    def compile_and_load(self):
        clear_screen()
        assembler = mipsAssambler()

        input_file = input("Enter the file path: ")
        file = self.input_file(input_file)
        try:
            if assembler.validate_asm_code(file):
                print("Syntaxis OK!\n")
                assembler.assamble(file)
        except Exception as e:
            print(e)
            print("\nCompilation failed...")
            exit(1)
        code = self.prepare_code(assembler.get_compiled_code())
        self.interface.load_program(code)
        print("\nProgram loaded successfully.")
        input("\nPress Enter to continue...")
        self.main_menu()

    # Normal execution
    def run_program(self):
        clear_screen()
        print("Running program...\n")
        self.interface.run_program(ExecMode.RUN)
        reg = self.interface.registers
        mem = self.interface.memory
        pc = self.interface.get_pc()
        self.print_table(reg, mem, pc, False)
        input("\nPress Enter to continue...")
        self.main_menu()

    # Step by step execution
    def step_program(self):
        try:
            program_state = self.interface.run_program(ExecMode.STEP)
            while not program_state:
                clear_screen()
                print("Stepping program...\n")
                reg = self.interface.get_reg_last_cycle()
                mem = self.interface.get_reg_last_cycle()
                pc = self.interface.get_pc()
                print("Printing table...\n")
                self.print_table(reg, mem, pc, True)

                while usr_input := input("N to next step: "):
                    if usr_input.lower() == 'n':
                        program_state = self.interface.run_next_step()
                        break
                    else:
                        print("Invalid input.")
            
            clear_screen()
            if program_state: # Program finished
                reg = self.interface.get_reg_last_cycle()
                mem = self.interface.get_reg_last_cycle()
                self.print_table(reg, mem, pc, True)
                print("Program finished.")
            else:
                print("Error running program.")
        except ValueError as e:
            print(e)
            input("\nPress Enter to continue...")
        input("\nPress Enter to continue...")
        self.main_menu()

    # Read file content
    def input_file(self, file_path: str) -> str:
        try:
            with open(file_path, 'r') as file:
                content = file.read()
            return content
        except FileNotFoundError:
            return "File not found."
        except IOError:
            return "Error reading file."


    def uart_init(self) -> Uart:
        port = serial_com.get_serial_port()
        uart = Uart(port)
        return uart

    def Interface_init(self, uart: Uart) -> Interface:
        interface = Interface(uart)
        return interface

    def prepare_code(self, codes: str) -> list:
        byte_list = []
        for code in codes:
            hex_byte = code[2:].zfill(8)
            byte_list.extend([hex_byte[i:i+2] for i in range(0, len(hex_byte), 2)])
        #print(byte_list)
        return byte_list

    def print_table(self, register: list, memory: list, pc: int, by_cicle: bool):
        terminal_width = os.get_terminal_size().columns
        half_twidth = terminal_width // 2
        line_len = '-' * terminal_width

        mem_side = f"{'Memory':^{half_twidth}}"
        reg_side = f"{'Registers':^{half_twidth}}"

        print(f"{line_len}\n{reg_side}{'|':^1}{mem_side}\n{line_len}")

        reg_print = []
        mem_print = []

        i_reg = 0
        for reg in register:
            addr = '0x' + format(reg['addr'], '08x').upper()
            data = '0x' + format(reg['data'], '08x').upper()
            if by_cicle:
                reg_print.append(f"Cycle: {reg['cycle']} {Fore.GREEN}R{i_reg}{Style.RESET_ALL}: {addr} Data:{data}")
            else:
                reg_print.append(f" {Fore.GREEN} R{i_reg}{Style.RESET_ALL}: {addr} Data: {data}")
            i_reg += 1

        i_mem = 0
        for mem in memory:
            addr = '0x' + format(mem['addr'], '08x').upper()
            data = '0x' + format(mem['data'], '08x').upper()
            if by_cicle:
                mem_print.append(f"Cycle: {mem['cycle']} {Fore.BLUE}M{i_mem} {Style.RESET_ALL}: {addr} Data: {data}")
            else:
                mem_print.append(f"{Fore.BLUE}M{i_mem}{Style.RESET_ALL}: {addr} Data: {data}")
            i_mem += 1
        
        if len(reg_print) > len(mem_print):
            mem_print.append(' ' * half_twidth)

        elif len(mem_print) > len(reg_print):
            reg_print.append(' ' * half_twidth)
            
        for i in range(max(len(reg_print), len(mem_print))):
            if i < len(reg_print):
                reg = reg_print[i] + " " * (half_twidth - len(reg_print[i])-1)
            else:
                reg = " " * len(half_twidth - 1)

            if i < len(mem_print):
                mem = mem_print[i] + " " * (half_twidth - len(mem_print[i])-1)
            else:
                mem = " " * len(half_twidth - 1)
            print(reg + " " + "|" + " " + mem)

        pc = '0x' + format(pc, '032x').upper()
        print(f"{line_len}\n {Fore.RED}PC{Style.RESET_ALL}: {pc}\n{line_len}")

def clear_screen():
    if os.name == 'nt':  # Para Windows
        os.system('cls')
    else:  # Para Linux/macOS
        os.system('clear')
