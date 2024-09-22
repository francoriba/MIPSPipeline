import tkinter as tk
from tkinter import ttk, messagebox, filedialog
from mipsAssambler import mipsAssambler
from serial_com import Uart, get_serial_port
from interface import Interface, ExecMode

class MIPS32UI:
    def __init__(self, root):
        self.root = root
        self.root.title("MIPS32 Simulator")
        self.root.geometry("400x300")
        self.root.configure(bg="#f0f0f0")
        
        self.style = ttk.Style()
        self.style.theme_use("clam")
        self.style.configure("TButton", padding=10, relief="flat", background="#4CAF50", foreground="white")
        self.style.map("TButton", background=[("active", "#45a049")])
        
        self.uart = self.uart_init()
        self.interface = self.Interface_init(self.uart)
        self.create_widgets()
        self.table_window = None
        self.prev_registers = None
        self.prev_memory = None
        self.min_font_size = 10
        self.max_font_size = 20

    def create_widgets(self):
        main_frame = ttk.Frame(self.root, padding="20 20 20 20")
        main_frame.pack(fill=tk.BOTH, expand=True)

        self.title_label = ttk.Label(main_frame, text="MIPS32 Simulator", font=("Helvetica", 18, "bold"))
        self.title_label.pack(pady=(0, 20))

        button_frame = ttk.Frame(main_frame)
        button_frame.pack(fill=tk.BOTH, expand=True)

        self.compile_button = ttk.Button(button_frame, text="Compile and Load", command=self.compile_and_load)
        self.compile_button.pack(fill=tk.X, pady=5)

        self.run_button = ttk.Button(button_frame, text="Run Program", command=self.run_program)
        self.run_button.pack(fill=tk.X, pady=5)

        self.step_button = ttk.Button(button_frame, text="Step by Step Program", command=self.step_program)
        self.step_button.pack(fill=tk.X, pady=5)

        self.exit_button = ttk.Button(button_frame, text="Exit", command=self.root.quit)
        self.exit_button.pack(fill=tk.X, pady=5)

    def compile_and_load(self):
        input_file = filedialog.askopenfilename(title="Select Assembly File")
        if input_file:
            assembler = mipsAssambler()
            file_content = self.input_file(input_file)
            try:
                if assembler.validate_asm_syntax(file_content):
                    messagebox.showinfo("Info", "Syntax OK!")
                    assembler.assamble(file_content)
                    code = self.prepare_code(assembler.get_compiled_code())
                    self.interface.load_program(code)
                    messagebox.showinfo("Info", "Program loaded successfully.")
                else:
                    messagebox.showerror("Error", "Syntax validation failed.")
            except Exception as e:
                messagebox.showerror("Error", str(e))

    def run_program(self):
        self.interface.run_program(ExecMode.RUN)
        reg = self.interface.registers
        mem = self.interface.memory
        pc = self.interface.get_pc()
        self.print_table(reg, mem, pc, False)

    def step_program(self):
        try:
            if not hasattr(self, 'program_state'):
                self.program_state = self.interface.run_program(ExecMode.STEP)
                self.prev_registers = None
                self.prev_memory = None
            self.execute_next_step()
        except ValueError as e:
            messagebox.showerror("Error", str(e))

    def execute_next_step(self):
        if not self.program_state:
            reg = self.interface.get_reg_last_cycle()
            mem = self.interface.get_mem_last_cycle()
            pc = self.interface.get_pc()
            self.print_table(reg, mem, pc, True)
            self.program_state = self.interface.run_next_step()
        else:
            reg = self.interface.get_reg_last_cycle()
            mem = self.interface.get_mem_last_cycle()
            pc = self.interface.get_pc()
            self.print_table(reg, mem, pc, True)
            self.show_program_finished()

    def show_program_finished(self):
        if self.table_window:
            self.finish_label = ttk.Label(self.table_window, text="Program finished!", foreground="green", font=("Helvetica", 14, "bold"))
            self.finish_label.pack(pady=10)
            self.next_step_button.config(state=tk.DISABLED)
            self.restart_button = ttk.Button(self.table_window, text="Restart Step-by-Step", command=self.restart_step_program)
            self.restart_button.pack(pady=5)

    def restart_step_program(self):
        if hasattr(self, 'program_state'):
            del self.program_state
        self.prev_registers = None
        self.prev_memory = None
        if self.table_window:
            self.table_window.destroy()
            self.table_window = None
        self.step_program()

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
        port = get_serial_port()
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
        return byte_list

    def print_table(self, register: list, memory: list, pc: int, by_cycle: bool):
        if self.table_window is None or not self.table_window.winfo_exists():
            self.table_window = tk.Toplevel(self.root)
            self.table_window.title("Registers and Memory")
            self.table_window.geometry("800x600")
            self.table_window.configure(bg="#f0f0f0")

            main_frame = ttk.Frame(self.table_window, padding="20 20 20 20")
            main_frame.pack(fill=tk.BOTH, expand=True)

            self.reg_text = tk.Text(main_frame, height=20, width=50, font=("Courier", self.min_font_size))
            self.mem_text = tk.Text(main_frame, height=20, width=50, font=("Courier", self.min_font_size))

            self.reg_text.grid(row=0, column=0, sticky="nsew", padx=(0, 10))
            self.mem_text.grid(row=0, column=1, sticky="nsew", padx=(10, 0))

            main_frame.grid_columnconfigure(0, weight=1)
            main_frame.grid_columnconfigure(1, weight=1)
            main_frame.grid_rowconfigure(0, weight=1)

            self.pc_label = ttk.Label(main_frame, text=f"PC: 0x{pc:08X}", font=("Helvetica", 12))
            self.pc_label.grid(row=1, column=0, columnspan=2, pady=(10, 0))

            if by_cycle:
                self.next_step_button = ttk.Button(main_frame, text="Next Step", command=self.execute_next_step)
                self.next_step_button.grid(row=2, column=0, columnspan=2, pady=(10, 0))

            self.reg_text.tag_configure('red', foreground='red')
            self.mem_text.tag_configure('blue', foreground='blue')

            self.table_window.bind("<Configure>", self.adjust_font_size)
        else:
            self.reg_text.delete(1.0, tk.END)
            self.mem_text.delete(1.0, tk.END)
            self.pc_label.config(text=f"PC: 0x{pc:08X}")

        self.update_table_content(register, memory)

    def update_table_content(self, register, memory):
        self.reg_text.insert(tk.END, "Registers:\n", "bold")
        for reg in register:
            changed = self.value_changed(self.prev_registers, reg, 'addr')
            color = 'red' if changed else 'black'
            self.reg_text.insert(tk.END, f"Cycle: {reg['cycle']:02d} Addr: 0x{reg['addr']:02X} Data: 0x{reg['data']:08X}\n", color)

        self.mem_text.insert(tk.END, "Memory:\n", "bold")
        for mem in memory:
            changed = self.value_changed(self.prev_memory, mem, 'addr')
            color = 'blue' if changed else 'black'
            self.mem_text.insert(tk.END, f"Cycle: {mem['cycle']:02d} Addr: 0x{mem['addr']:08X} Data: 0x{mem['data']:08X}\n", color)

        self.prev_registers = register
        self.prev_memory = memory

    def adjust_font_size(self, event):
        if event.widget == self.table_window:
            width = event.width
            height = event.height

            # Calculate the ideal font size based on window dimensions
            ideal_font_size = min(width // 80, height // 40)
            
            # Clamp the font size between min and max values
            new_font_size = max(self.min_font_size, min(ideal_font_size, self.max_font_size))

            # Update font size for both text widgets
            current_font = self.reg_text.cget("font")
            new_font = (current_font[0], new_font_size)
            self.reg_text.configure(font=new_font)
            self.mem_text.configure(font=new_font)

            # Redraw the content with the new font size
            self.reg_text.delete(1.0, tk.END)
            self.mem_text.delete(1.0, tk.END)
            self.update_table_content(self.prev_registers, self.prev_memory)

    def value_changed(self, prev_list, current_item, key):
        if prev_list is None:
            return False
        for prev_item in prev_list:
            if prev_item[key] == current_item[key]:
                return prev_item['data'] != current_item['data']
        return True

def main():
    root = tk.Tk()
    app = MIPS32UI(root)
    root.mainloop()

if __name__ == "__main__":
    main()