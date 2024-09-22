ADDI r1,r0,5            # r1 = 5
ADDI r2,r0,5            # r2 = 5
BEQ  r1,r2,EQUAL        # Si r1 == r2, salta a la etiqueta EQUAL
ADDI r3,r0,0            # Si r1 != r2, r3 = 0 (no se ejecuta porque r1 == r2)
J END                   # Salta al final del programa
EQUAL: ADDI r3,r0,1     # Si r1 == r2, r3 = 1
END: NOP                # No Operation
NOP                     # No Operation
HALT                    # Detiene la ejecución
