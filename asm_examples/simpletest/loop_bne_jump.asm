ADDI r1,r0,7
ADDI r3,r0,3
SW r3,0(r0)    # Almacena el valor de r3 (3) en la dirección de memoria 0
LW r2,0(r0)
LOOP: ADDI r2,r2,1
BNE r1,r2,LOOP
ADDI r3,r0,0x0045
J END
ADDI r5,r0,10
END: ADDI r6,r0,3
NOP
HALT
