# Inicialización de registros
ADDI r1,r0,5          # r1=5
ADDI r2,r0,5          # r2=5
ADDI r3,r0,8          # r3=8
ADDI r4,r0,10         # r4=10
ADDI r5,r0,0          # r5=0 (inicializado para almacenar el resultado)

# Prueba de BEQ
BEQ r1,r2,equal       # Si r1==r2, salta a "equal"
OR r5,r3,r4           # Si no son iguales, r5=r3|r4
J end                 # Salta al final

equal: AND r5,r3,r4          # Si r1==r2, r5=r3&r4

end: NOP                   # No Operation
HALT                  # Termina la ejecución
