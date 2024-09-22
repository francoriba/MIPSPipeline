ADDI r4,r0,12
ADDI r5,r0,12
BEQ r4,r5,function1
ADDI r4,r0,99
ADDI r5,r0,99
function1: ADDI r7,r0,87
J function2
ADDI r4,r0,99
ADDI r5,r0,99
function2: ADDI r4,r0,1
ADDI r5,r0,1
HALT