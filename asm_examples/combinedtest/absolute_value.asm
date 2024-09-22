# Propósito:
# Determinar el valor absoluto de un número almacenado en `r1` y almacenarlo en `r2`.

# Resumen:
# - Compara si el número en `r1` es negativo.
# - Si es negativo, lo convierte en positivo usando **SUBU**.
# - Utiliza **SLTI** para la comparación y **BEQ** para saltos condicionales.

ADDI r1,r0,-8               # r1 = -8 (número a convertir)
SLTI r3,r1,0                # Si r1 < 0, r3 = 1
BEQ  r3,r0,positive         # Si r1 no es negativo, salta a "positive"
SUBU r1,r0,r1               # Si r1 es negativo, r1 = -r1
positive: ADDU r2,r1,r0     # r2 = |r1| (valor absoluto)
HALT                        # Termina la ejecución
