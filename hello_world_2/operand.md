I31 I30 I24 I13 N
0 0 0 0 Imm || 0b0000000000
0 0 0 1 Imm || 0b0000000000
0 0 1 0 Imm || 0b0000000000
0 0 1 1 Imm || 0b0000000000
0 1 0 0 Imm (sign extended)
0 1 0 1 Imm (sign extended)
0 1 1 0 Imm (sign extended)
0 1 1 1 Imm (sign extended)
1 0 0 0 R
1 0 0 1 Imm12-0 (sign extended)
1 0 1 0 0b0000...000 ||R4-0
1 0 1 1 0b0000...000 ||Imm4-0
1 1 0 0 R
1 1 0 1 Imm12-0 (sign extended)
1 1 1 0 R
1 1 1 1 Imm12-0 (sign extended)