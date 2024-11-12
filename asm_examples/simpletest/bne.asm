# Inicialización de registros
ADDI r1,r0,5          # r1=5
ADDI r2,r0,5          # r2=5
ADDI r3,r0,8          # r3=8
ADDI r4,r0,10         # r4=10
ADDI r5,r0,0          # r5=0 (inicializado para almacenar el resultado)
# Prueba de BNE
BNE r3,r4,not_equal   # Si r3!=r4, salta a "not_equal"
OR r5,r4,r4           # Si son iguales (no debería ejecutar este código)
not_equal: AND r5,r5,r3          # Si r3!=r4, r5=r5&r3
end: NOP                   # No Operation
HALT                  # Termina la ejecución
