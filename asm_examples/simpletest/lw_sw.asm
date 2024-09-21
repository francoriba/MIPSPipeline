ADDI r1,r0,0      # r1 = 0 (base address)
ADDI r2,r0,1234   # r2 = 1234 (valor a almacenar en memoria)
SW r2,4(r1)        # Almacenar el valor 1234 en la dirección 4
LW r3,4(r1)        # Cargar la palabra desde la dirección 4 en r3 (r3 = 1234)
HALT
