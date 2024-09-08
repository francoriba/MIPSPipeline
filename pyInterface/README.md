# pyASM


## Requisitos

- [x] Reconocer instrucciones del set
- [x] Reconocer labels y asignarles una dirección
- [x] Reconocer Comentarios
- [-] Reconocer formato hexadecimal y binario (Chequear todas)
- [x] definir y reconocer variables

## Notas
El registro que corresponde a guardar las direcciones de retorno (En le teórico llamado $ra) en nuestro caso es el registro $r31

# Funcionamiento

1. `validate_asm_code(file)` Hace un reconocimiento del código para detectar: 
    + Comentarios y saltos de linea (Se ignoran).
    + Comprobación de sintaxis de instrucciones y argumentos (Esta última en fomrato mas general).
    + Detección de etiquetas y asignación de dirección a correspondiente. Se lanza una excepcion si alguna etiqueta está vacía.
    + Detección de varaibles. Tipos aceptados: `int` y `uint` de 8, 16 y 32 bits.
 
2. `assamble()` Compilación:
    + Solo se avanza si la etapa anterior devuelve `True`.
    + Se traduce línea por linea de intrucción y se realizan los reemplazos pertinentes (Nombres de variables y etiquetas).
    + Cada línea se traduce según el tipo de intrucción al que pertenecen.
    + El código compilado en código máquina se almacena en `instructions_machine_code`
