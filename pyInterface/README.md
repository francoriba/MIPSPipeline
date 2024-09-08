# pyInterface

## Requirements

- [x] Recognize instructions from the set
- [x] Recognize labels and assign them an address
- [x] Recognize comments
- [x] Recognize hexadecimal and binary format
- [x] Define and recognize variables

> **_NOTE:_** Register used to store return addresses (theoretically called `$ra`) in our case is register `$r31`.

# Functionality

1. `validate_asm_syntax` Recognizes the code to detect:
    + Comments and line breaks (Ignored).
    + Syntax check for instructions and arguments (The latter in a more general format).
    + Detects labels and assigns the corresponding address. Throws an exception if any label is empty.
    + Detects variables. Accepted types: `int` and `uint` of 8, 16, and 32 bits.
 
2. `assemble()` Compilation:
    + Proceeds only if the previous stage returns `True`.
    + Translates each instruction line by line and makes the necessary replacements (variable names and labels).
    + Each line is translated according to the type of instruction it belongs to.
    + The compiled machine code is stored in `instructions_machine_code`.
