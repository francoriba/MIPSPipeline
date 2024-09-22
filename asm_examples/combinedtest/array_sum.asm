# Propósito: Sumar los elementos de un arreglo de 5 números y guardar el resultado en r3.
# Resumen:
# - Carga los elementos del arreglo desde memoria.
# - Suma los valores usando la instrucción ADDU.
# - Utiliza LW para cargar desde memoria y SW para almacenar resultados.
# Instrucciones usadas: ADDI, ADDU, LW, SW, BNE, HALT.

ADDI r1,r0,0         # r1 = 0 (índice del arreglo)
ADDI r2,r0,0         # r2 = 0 (acumulador)
ADDI r4,r0,20        # r4 = tamaño del arreglo (5 elementos * 4 bytes)
loop: LW r5,0(r1)    # Carga el valor en la dirección de r1 (elemento del arreglo)
ADDU r2,r2,r5        # Suma r2 (acumulador) + r5 (valor del elemento)
ADDI r1,r1,4        # Incrementa el índice del arreglo (4 bytes por palabra)
BNE r1,r4,loop      # Repite hasta que r1 == tamaño del arreglo
SW r2,0(r6)          # Guarda el resultado de la suma en memoria en r6
HALT                 # Termina la ejecución
