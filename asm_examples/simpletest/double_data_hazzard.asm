# Inicialización de valores
ADDI r1,r0,5     # r1 = 5
ADDI r2,r0,10    # r2 = 10
ADDI r3,r0,15    # r3 = 15
ADDI r4,r0,20    # r4 = 20
ADDI r5,r0,25    # r5 = 25
ADDI r7,r0,1    # r5 = 25

# Ejemplo de doble data hazard, debemos usar el valor mas reciente de r6
ADDU r6,r1,r2    # r6 = r1 + r2  (primer resultado producido)
SUBU r6,r3,r4    # r6 = r3 - r4  (segundo resultado producido)
AND  r8,r6,r7    # r8 = r6 & r7  (r6 y r7 son usados aquí)

# Fin del programa
HALT
