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
| 1 | 0 | 1 | 0 | 0b0000...000 \|\| R4-0
| 1 | 0 | 1 | 1 | 0b0000...000 \|\| Imm4-0
| 1 | 1 | 0 | 0 | R
| 1 | 1 | 0 | 1 | Imm12-0 (sign extended)
| 1 | 1 | 1 | 0 | R
| 1 | 1 | 1 | 1 | Imm12-0 (sign extended)


<!-- Yes, you will need to design a testbench to verify the functionality of your mini_alu and source_operand modules. In the testbench, you can generate input signals to the modules and compare the output signals with expected values.

Regarding the registers, you can either use the Verilog reg data type to declare variables in your testbench or design separate register modules if necessary. The registers can be used to hold the input values for your modules and to compare the output values with expected results. -->


A Operand Handler is a combinatorial circuit, which means that it will use case statements and will not really depend of a clock to trigger. This handler is a fairly simple one, bellow is listed the inputs and outputs:

- `R` (*input*) **32bit** number
- `Imm` (*input*) **22bit** number
- `IS` (*input*) **4bit** number
- `N` (*output*) **32bit** number

`R` is a register number you input and `Imm` is uhh, no idea :)

(ask professor what exactly is the purpose of this component)
(also ask the professor what Imm suppose to be)

The output `N` depends of the truth table from the inputs `R` and `Imm`

The **4bit** output `IS` corresponds to an instruction bit, similar to the opcode in the ALU.

We also learned that `||` in this context means concatenation. Neat!