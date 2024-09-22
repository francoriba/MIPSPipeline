# Inicialización de valores
ADDI r1,r0,10   # r1 = 10
ADDI r2,r0,20   # r2 = 20

# Ejemplo de forwarding desde MEM
ADDU r3,r1,r2   # r3 = r1 + r2  -> resultado disponible en MEM
SUBU r4,r3,r1   # r4 = r3 - r1  -> r3 debe ser reenviado desde MEM

# Ejemplo de forwarding desde WB
ADDU r5,r4,r2   # r5 = r4 + r2  -> r4 debe ser reenviado desde WB
AND  r6,r5,r1   # r6 = r5 & r1

# Fin del programa
HALT