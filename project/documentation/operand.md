# Design of the Operand2 Handler


|I31 | I30 | I24  | I13 | N
-----|-----|------|-----|---
| 0 | 0 | 0 | 0 | Imm \|\| 0b0000000000
| 0 | 0 | 0 | 1 | Imm \|\| 0b0000000000
| 0 | 0 | 1 | 0 | Imm \|\| 0b0000000000
| 0 | 0 | 1 | 1 | Imm \|\| 0b0000000000
| 0 | 1 | 0 | 0 | Imm (sign extended)
| 0 | 1 | 0 | 1 | Imm (sign extended)
| 0 | 1 | 1 | 0 | Imm (sign extended)
| 0 | 1 | 1 | 1 | Imm (sign extended)
| 1 | 0 | 0 | 0 | R
| 1 | 0 | 0 | 1 | Imm12-0 (sign extended)
| 1 | 0 | 1 | 0 | 0b0000...000 ||R4-0
| 1 | 0 | 1 | 1 | 0b0000...000 ||Imm4-0
| 1 | 1 | 0 | 0 | R
| 1 | 1 | 0 | 1 | Imm12-0 (sign extended)
| 1 | 1 | 1 | 0 | R
| 1 | 1 | 1 | 1 | Imm12-0 (sign extended)


Yes, you will need to design a testbench to verify the functionality of your mini_alu and source_operand modules. In the testbench, you can generate input signals to the modules and compare the output signals with expected values.

Regarding the registers, you can either use the Verilog reg data type to declare variables in your testbench or design separate register modules if necessary. The registers can be used to hold the input values for your modules and to compare the output values with expected results.





En el diagrama de la página siguiente se muestra un diagrama de bloque y la tabla de la verdad del circuito que
se debe implementar. Este es un circuito combinacional (el efecto de las entradas se puede manifestar en las
salidas casi de manera instantánea). Según indica la tabla de la verdad, el “Handler” tiene como entradas un
número de 32 bits (R), un número de 22 bits (Imm) y cuatro bits (IS) que corresponden a bits de una
instrucción. El circuito tiene como salida un número N de 32 bits cuyo su valor depende de los inputs según
indica la tabla de la verdad. El símbolo || significa concatenación