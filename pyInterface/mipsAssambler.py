import mips_isa as iset
import re

class mipsAssambler():
    labels_address_table = {} # {label: address}
    instruction_set = {} # Set of instructions
    instructions_asm = [] # Instructions in assembly
    instructions_machine_code = [] # Instructions in machine code
    current_address = 0
    register_table = {} # {register: address}
    current_line = None
    variables_table = {} # {variable: (type, value)}

    def __init__(self):
        self.labels_address_table = {}
        self.instruction_set = iset.instructionTable
        self.register_table = iset.registerTable
        self.instructions_asm = []
        self.instructions_machine_code = []
        self.variables_table = {}
        self.current_address = 0
        self.current_line = 1

    # Validate the syntax of the assembly code
    def validate_asm_syntax(self, input: str) -> bool:
        lines = input.split('\n')
        lines = [line.strip() for line in lines if line != '']
        #print(lines)
        # Split input string into lines
        for line in lines:
            #self.current_line += 1
            if line.startswith("DEFINE"):
                self.get_variables(line)
            if not line.startswith("#") and not line.startswith("DEFINE"): # Check if line is a comment
                self.instructions_asm.append(line)
        if self.validate_operation():
            print("OPCODES and LABELS Syntax OK!")
            #print(self.labels_address_table)
            if self.validate_arguments():
                self.current_line = 1 # Reset line counter
                print("ARGUMENTS Syntax OK!")
                return True
            else:
                return False
        else :
            return False
        
    # Assemble the code
    def assamble(self, input: str) -> str:
        self.current_address = 0
        self.current_line = 1
        for line in self.instructions_asm:
            inst = line.split(' ')
            inst = [item.strip() for item in inst if item != '']
            #print(self.labels_address_table)
            machine_code = self.resolve_instruction(inst)
            #print(machine_code)
            self.instructions_machine_code.append(machine_code)
            #print(str(hex(self.current_address*4)) + ": " + self.bin_to_hex(machine_code) + "  " + str(inst))
            #print(self.bin_to_hex(machine_code))
            self.current_address += 1
            self.current_line += 1
        self.print_out()
        
    # Validate the operation of the instructions
    def validate_operation(self) -> bool:
        for inst in self.instructions_asm:
            inst_parts = inst.split(' ')
            # Remove empty strings from list
            inst_parts = [item.strip() for item in inst_parts if item != '']
            if inst_parts[0] in self.instruction_set:
                self.current_line += 1
            else: # if is not an instruction, check if it is a label
                if ':' in inst_parts[0]:
                    inst_parts[0] = inst_parts[0].replace(':', '')
                    self.labels_address_table[inst_parts[0]] = self.current_address
                    self.current_line += 1
                else:
                    raise Invalid_instruction_exception("Invalid instruction on line " + str(self.current_line) + ": " + inst_parts[0])
            self.current_address += 1 # Increment address 
        return True
    
    # Validate the arguments of the instructions
    def validate_arguments(self) -> bool:
        for inst in self.instructions_asm:
            inst = inst.split(' ')
            inst = [item.strip() for item in inst if item != '']
            if len(inst) == 3: # Label: OP arg1,arg2,arg3
                op = inst[1]
                args = inst[2].split(',')
                if op not in self.instruction_set:
                    raise Invalid_instruction_exception("Invalid instruction on line " + str(self.current_line) + ": " + op)
                
            elif len(inst) == 2: # Op arg1,arg2,arg3 o Op Label
                args = inst[1].split(',')
                if len(args) == 1:
                    if args[0] not in self.labels_address_table and args[0] not in self.variables_table and args[0] not in self.register_table:
                        raise Label_not_found_exception("Label not found on line " + str(self.current_line) + ": " + args[0])
            self.current_line += 1
        return True
                
    # Resolve the instruction to machine code
    def resolve_instruction(self, inst: str) -> str:
        if inst[0] in self.instruction_set:
            if self.instruction_set[inst[0]][0] == str(iset.OP_CODE_R): # R type instruction
                #print("R type instruction: " + str(inst))
                mach_code_r_type = self.resolve_R_type(inst)
                return mach_code_r_type
            elif (self.instruction_set[inst[0]][0] == str(iset.OP_CODE_J) or self.instruction_set[inst[0]][0] == str(iset.OP_CODE_JAL)): # J type instruction
                mach_code_j_type = self.resolve_J_type(inst)
                return mach_code_j_type
            elif inst[0] == 'NOP' or inst[0] == 'HALT':
                return self.translate_to_bin(self.instruction_set[inst[0]][0], 32)
            else: # I type instruction
                mach_code_i_type = self.resolve_I_type(inst)
                return mach_code_i_type
        else:
            label = inst[0].replace(':', '')
            if label in self.labels_address_table:
                inst_label = [inst[1], inst[2]]
                label_mach_code = self.resolve_instruction(inst_label)
                return label_mach_code
                
    # Resolve the R type instructions
    def resolve_R_type(self, inst: str) -> str:
        args = inst[1].split(',')
        if len(args) == 3:
            if (inst[0] == 'SLL' or inst[0] == 'SRL' or inst[0] == 'SRA'):
                # XXXX $rd, $rt, shamt
                rs = self.dec_to_bin(0, 5)
                rt = self.to_register(args[1])
                rd = self.to_register(args[0])
                shamt = self.dec_to_bin(int(args[2]), 5)
                func = self.instruction_set[inst[0]][1]
                machine_code = self.instruction_set[inst[0]][0] + rs + rt + rd + shamt + func
                return machine_code
            
            elif (inst[0] == 'SLLV' or inst[0] == 'SRLV' or inst[0] == 'SRAV'):
                # XXXX $rd, $rt, $rs
                rd = self.to_register(args[0])
                rs = self.to_register(args[1])
                rt = self.to_register(args[2])
                shamt = self.dec_to_bin(0, 5)
                func = self.instruction_set[inst[0]][1]
                machine_code = self.instruction_set[inst[0]][0] + rs + rt + rd + shamt + func
                return machine_code
        
            else: #From ADDU to SLT
                # XXXX $rd, $rs, $rt
                rd = self.to_register(args[0])
                rs = self.to_register(args[1])
                rt = self.to_register(args[2])
                shamt = self.dec_to_bin(0, 5)
                func = self.instruction_set[inst[0]][1]
                machine_code = self.instruction_set[inst[0]][0] + rs + rt + rd + shamt + func
                return machine_code
        else:
            if inst[0] == 'JALR': #rd = R31 = PC + 4; rs = PC 
                # JARL $rd, $rs
                rd = self.to_register(args[0])
                rs = self.to_register(args[1])
                rt = self.dec_to_bin(0, 5)
                shamt = self.dec_to_bin(0, 5)
                func = self.instruction_set[inst[0]][1]
                machine_code = self.instruction_set[inst[0]][0] + rs + rt + rd + shamt + func
                return machine_code
            
            elif inst[0] == 'JR': #PC = Rs
                # JR $rs
                rs = self.to_register(args[0])
                rt = self.dec_to_bin(0, 5)
                rd = self.dec_to_bin(0, 5)
                shamt = self.dec_to_bin(0, 5)
                func = self.instruction_set[inst[0]][1]
                machine_code = self.instruction_set[inst[0]][0] + rs + rt + rd + shamt + func
                return machine_code

    # Resolve the J type instructions        
    def resolve_J_type(self, inst: str) -> str:
        if inst[0] == 'J':
            # J DIR
            if inst[1] in self.labels_address_table:
                dir = self.translate_to_bin(str(self.labels_address_table[inst[1]]), 26)
            else:
                dir = self.translate_to_bin(inst[1], 26)
            machine_code = self.instruction_set[inst[0]][0] + dir
            return machine_code
        if inst[0] == 'JAL':
            # JAL DIR
            if inst[1] in self.labels_address_table:
                dir = self.translate_to_bin(str(self.labels_address_table[inst[1]]), 26)
            else:
                dir = self.translate_to_bin(inst[1], 26)
            machine_code = self.instruction_set[inst[0]][0] + dir
            return machine_code

    # Resolve the I type instructions            
    def resolve_I_type(self, inst: str) -> str:
        args = inst[1].split(',')
        #print("I-type: " + str(args))
        if inst[0] == 'BNE' or inst[0] == 'BEQ':
            # BXX $rs, $rt, INM
            rs = self.to_register(args[0])
            rt = self.to_register(args[1])
            dir_src = self.bin_rezise(str(self.current_address), 16)
            if args[2] in self.labels_address_table:
                dir_dest = self.bin_rezise(str(self.labels_address_table[args[2]]), 16)
            else:
                dir_dest = self.translate_to_bin(args[2], 16)
            inm = self.calculate_offset(dir_dest, dir_src)
            return self.instruction_set[inst[0]][0] + rs + rt + inm
        
        if inst[0] in iset.load_and_store_inst: # XXXX $rt, INM($rs)
            opcode = self.instruction_set[inst[0]][0]
            rt = self.to_register(args[0])
            inm, rs = self.get_reg_and_offset(args[1])
            return opcode + rs + rt + inm
        
        if inst[0] == 'LUI': # LUI $rt, INM
            opcode = self.instruction_set[inst[0]][0]
            rt = self.to_register(args[0])
            inm = self.translate_to_bin(args[1], 16)
            return opcode + self.dec_to_bin(0, 5) + rt + inm
        else:# XXXX $rt, $rs, INM
            opcode = self.instruction_set[inst[0]][0]
            rt = self.to_register(args[0])
            rs = self.to_register(args[1])
            inm = self.translate_to_bin(args[2], 16)
            return opcode + rs + rt + inm

    # Calculate the offset of the branch instructions        
    def calculate_offset(self, dest: str, src: str) -> str:
        offset = int(dest, 16) - (int(src, 16) + 1) # + 1 porque se calcula el offset con respecto a la siguiente instrucción
        if offset < -32768 or offset > 32767:
            raise ValueError("Offset out of range")
        return self.dec_to_bin(offset, 16)


    # Hexadecimal to binary
    def hex_to_bin(self, hexnum: str, size: int) -> str:
        intnum = int(hexnum, 16)
        binnum = bin(intnum)[2:]
        binnum_filled = binnum.zfill(size)
        return binnum_filled

    # Binary to hexadecimal
    def bin_to_hex(self, binum: str) -> str:
        intnum = int(binum, 2)
        hexnum = hex(intnum)[2:]
        hexnum_32 = hexnum.zfill(8)
        return '0x' + hexnum_32
        
    # Decimal to binary
    def dec_to_bin(self, num: str, size: int) -> int:
        num = int(num)
        if num < 0:
            bin = format((1 << size) + num, '0{}b'.format(size))
        else:
            bin = format(num, '0{}b'.format(size))
        return bin
    
    # 0b0 bin format to binary
    def Ob_to_bin(self, num: str, size: int) -> str:
        num_int = int(num, 2)
        bin_str = format(num_int, '0{}b'.format(size))
        return bin_str

    # Get register to binary address
    def to_register(self, reg: str) -> str:
        if reg in self.register_table:
            return self.dec_to_bin(self.register_table[reg], 5)
        else:
            raise Invalid_reg_exception("Invalid register on line " + str(self.current_line) + ": " + reg)
    
    # Resize binary number
    def bin_rezise(self, binum: str, size: int) -> str:
        if len(binum) < size:
            binum_filled = binum.zfill(size)
            return binum_filled
        elif len(binum) > size:
            binum_resized = binum[-size:]
            return binum_resized

    # Extraer el registro y el offset de una cadena de texto. Formato: offset(registro)
    def get_reg_and_offset(self, reg: str) -> (str, str):
        match = re.match(r'([0-9]+|0x[0-9a-fA-F]+|0b[01]+|\w+)\((\w+)\)', reg)
        if match:
            inm = match.group(1)
            rx = match.group(2)
            if inm in self.variables_table:
                inm = self.translate_to_bin(str(self.variables_table[inm][1]), 16)
            else:
                inm = self.translate_to_bin(inm, 16)
            rx = self.to_register(rx)
            return inm, rx
        else:
            raise ValueError("El formato de entrada no es válido")

    # Extraer las variables de una línea de texto
    def get_variables(self, line: str) -> str:
        parts = line.split('=')
        if len(parts) != 2:
            raise ValueError("Wrong format. Use: DEFINE [INT__] [NAME] = value")
        # Obtener la parte antes del '=' y dividirla por espacios
        left_part = parts[0].strip().split(' ')
        
        if len(left_part) != 3 or left_part[0] != "DEFINE":
            raise ValueError("Wrong format. Use: DEFINE [INT__] [NAME] = value")
        
        int_type = left_part[1]
        name = left_part[2]
        value_str = parts[1].strip()
        
        # Validar tipo de entero
        valid_types = ["INT8", "INT16", "INT32", "UINT8", "UINT16", "UINT32"]
        if int_type not in valid_types:
            raise ValueError("Invalid input, data types supported: " + ", ".join(valid_types))
        
        if value_str.startswith("0x"): # Hexadecimal
            try:
                value = int(value_str, 16)
            except ValueError:
                raise ValueError("Invalid hexadecimal value")
        elif value_str.startswith("0b"):# Binario
            try:
                value = int(value_str, 2)
            except ValueError:
                raise ValueError("Invalid binary value")
        else: # Decimal
            try:
                value = int(value_str)
            except ValueError:
                raise ValueError("Invalid decimal value")
        
        # Verificar que el valor no exceda el tamaño de la variable
        if int_type == "INT8" and not (-128 <= value <= 127):
            raise ValueError("Value exceeds INT8 size")
        elif int_type == "UINT8" and not (0 <= value <= 255):
            raise ValueError("Value exceeds UINT8 size")
        elif int_type == "INT16" and not (-32768 <= value <= 32767):
            raise ValueError("Value exceeds INT16 size")
        elif int_type == "UINT16" and not (0 <= value <= 65535):
            raise ValueError("Value exceeds UINT16 size")
        elif int_type == "INT32" and not (-2147483648 <= value <= 2147483647):
            raise ValueError("Value exceeds INT32 size")
        elif int_type == "UINT32" and not (0 <= value <= 4294967295):
            raise ValueError("Value exceeds UINT32 size")
        
        # Imprimir o almacenar las variables extraídas
        self.variables_table[name] = (int_type, value)
    
    # Translate any number to binary
    def translate_to_bin(self, value: str, size: int) -> str:
        if value.startswith("0x"):
            return self.hex_to_bin(value, size)
        elif value.startswith("0b"):
            return self.Ob_to_bin(value, size)
        else:
            return self.dec_to_bin(value, size)

    def print_out(self):
        print(f"{'Address':<8} {'Machine Code':<15} {'Instruction':<20}")
        print("-" * 43)
        for i in range(len(self.instructions_machine_code)):
            address = f"{hex(i*4)}:"
            hex_code = self.bin_to_hex(self.instructions_machine_code[i])
            instruction = self.instructions_asm[i]
            print(f"{address:<8} {hex_code:<15} {instruction:<20}")

    def get_compiled_code(self):
        code = []
        for line in self.instructions_machine_code:
            code.append(self.bin_to_hex(line))
        return code

class Invalid_instruction_exception(Exception):
    def __init__(self, msj):
        super().__init__(msj)

class Invalid_reg_exception(Exception):
    def __init__(self, msj):
        super().__init__(msj)
        
class Label_not_found_exception(Exception):
    def __init__(self, msj):
        super().__init__(msj)

if __name__ == '__main__':
    print("mipsAssambler")
