ADDI r1,r0,10
ADDI r2,r0,25
ADDI r3,r0,30
ADDI r4,r0,40
ADDI r5,r0,50

# EX/MEM to EX Forwarding
ADDU r6,r1,r2      # r6 = 10 + 25 = 35
SUBU r7,r6,r3      # Forward r6 from EX/MEM, r7 = 35 - 30 = 5

# MEM/WB to EX Forwarding
ADDU r8,r4,r5      # r8 = 40 + 50 = 90
NOP                 # No operation, creates a cycle gap
ADDU r9,r8,r1      # Forward r8 from MEM/WB, r9 = 90 + 10 = 100

# EX/MEM to MEM Forwarding (for store instructions)
ADDU r10,r2,r3     # r10 = 25 + 30 = 55
SW r10,0(r1)       # Store r10 to memory address in r1, forward r10 from EX/MEM

# Multiple forwarding in a sequence
ADDU r11,r1,r2     # r11 = 10 + 25 = 35
ADDU r12,r11,r3    # Forward r11 from EX/MEM, r12 = 30 + 30 = 60
ADDU r13,r12,r4    # Forward r12 from EX/MEM, r13 = 60 + 40 = 100

# Forwarding with immediate values
ADDI r14,r1,5     # r14 = 10 + 5 = 15
ADDU r15,r14,r2    # Forward r14 from EX/MEM, r15 = 15 + 20 = 35

# Load-use hazard with forwarding
LW r16,0(r1)       # Load value from memory address in r1 to r16
ADDU r17,r16,r2    # Forward r16 from MEM/WB (after stall), r17 = mem[r1] + 25

# End of test program
HALT