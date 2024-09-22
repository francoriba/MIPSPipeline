# Propósito: Comparar dos números y ejecutar diferentes instrucciones dependiendo de si son iguales o no.
# Resumen:
# - Compara los registros r1 y r2.
# - Si son iguales, realiza una operación de AND en r3 y r4.
# - Si no son iguales, realiza una operación de OR en r3 y r4.
# - Utiliza BEQ y BNE para saltos condicionales.
# Instrucciones usadas: ADDI, BEQ, BNE, AND, OR, J, HALT.

ADDI r1,r0,5            # r1 = 5
ADDI r2,r0,10           # r2 = 10
ADDI r3,r0,7            # r3 = 7
ADDI r4,r0,12           # r4 = 12
BEQ r1,r2,equal         # Si r1 == r2, salta a "equal"
OR r5,r3,r4             # Si no son iguales, r5 = r3 | r4
J end                   # Salta al final 
equal: AND r5,r3,r4     # Si son iguales, r5 = r3 & r4
end: NOP                # No Operation
HALT                    # Termina la ejecución
