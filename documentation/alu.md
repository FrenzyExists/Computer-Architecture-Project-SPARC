# ALU

The ALU is a combinational circuit, meaning that the effect of the inputs is almost instantly reflected in the outputs. The ALU takes two inputs, A and B, and performs arithmetic and logical operations on them as per the table given in the following section. The result of the operation is output as "Out", and the condition flags Z, N, C, and V are generated as needed.

## Operation

The ALU performs the following arithmetic and logical operations on the two input operands A and B.

| OP  | Out | Flags |
| --- | --- | ----- |
| 0000| A+B | Z N C V|
| 0001| A+B+CIN | Z N C V|
| 0010| A-B | Z N C V|
| 0011| A-B-CIN | Z N C V|
| 0100| A and B | Z N |
| 0101| A or B | Z N |
| 0110| A xor B | Z N |
| 0111| A xnor B | Z N |
| 1000| A and (not B) | Z N |
| 1001| A or (not B) | Z N |
| 1010| shift left logical (A) B positions | none |
| 1011| shift right logical (A) B positions | none |
| 1100| shift right arithmetic (A) B positions | none |
| 1101| A | none |
| 1110| B | none |
| 1111| not B | none |

## Flags

The ALU generates four flag bits indicating certain conditions:

Z: Zero flag is set when the output of the ALU is zero.
N: Negative flag is set when the output of the ALU is negative.
C: Carry flag is set when the output of the ALU generates a carry out (for addition) or borrow out (for subtraction).
V: Overflow flag is set when the output of the ALU generates an overflow condition (for signed operations).

## Limitations

The ALU has the following limitations:

- It does not support floating-point operations.
- It does not have any memory or storage capabilities.
- It does not handle exceptions or interrupts.

