ADDI r1,r0,5    # r1 = 5
SLL r2,r1,2     # r2 = r1 << 2 (r2 = 5 << 2 = 20)

ADDI r3,r0,-8   # r1 = -8
SRA r4,r3,1     # r2 = r1 >>> 1 (r2 = -8 >>> 1 = -4)

ADDI r5,r0,20 # r1 = 20
SRL r6,r5,2 # r2 = r1 >> 2 (r2 = 20 >> 2 = 5) 
HALT