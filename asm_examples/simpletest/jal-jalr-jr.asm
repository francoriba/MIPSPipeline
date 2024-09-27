ADDI r13,r13,0x20
LUI r11,10
JAL 5  # salta a la dirección de 5 y guarda la dir de retorno ( PC + 1) en r31
ADDI r7,r7,7 
5: ADDI r9,r9,9
ADDI r2,r2,2 
JALR r31,r13 # salta a la dirección en r13 y guarda la dir de retorno ( PC + 1) en r31 (en realidad ignora siempre usa r31)
ADDI r4,r4,4 
ADDI r6,r6,0x2c
JR r6
ADDI r7,r6,7
HALT