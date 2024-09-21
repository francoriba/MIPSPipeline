from cli import Cli
from ui import MIPS32UI
import tkinter as tk

def main():
    print("Choose the interface:")
    print("1. Command Line Interface (CLI)")
    print("2. Graphical User Interface (GUI)")
    
    choice = input("Enter your choice (1 or 2): ")
    
    if choice == "1":
        ui = Cli()
        ui.__init__()
    elif choice == "2":
        root = tk.Tk()
        app = MIPS32UI(root)
        root.mainloop()
    else:
        print("Invalid choice. Exiting.")

if __name__ == '__main__':
    main()