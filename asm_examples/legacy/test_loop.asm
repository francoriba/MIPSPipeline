ADDI r1,r0,10
ADDI r2,r0,3
LOOP: ADDI r2,r2,1
BNE r1,r2,LOOP
ADDI r3,r0,0x0045
NOP
NOP
HALT