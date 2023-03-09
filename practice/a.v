        // 4'b1100: N = {16'b0, R[4:0]}; // concatenate 16 0's to the left of R[4:0]
        // 4'b1110: N = {16'b0, Imm[4:0]}; // concatenate 16 0's to the left of Imm[4:0]
        // // add these cases to match the behavior described in the table
        // 4'b1001: N = {20{Imm[31]} , Imm[11:0]}; // sign extend Imm12-0 to 32 bits
        // 4'b1010: N = {28'b0, R[4:0]}; // concatenate 28 0's to the left of R[4:0]
        // 4'b1011: N = {28'b0, Imm[4:0]}; // concatenate 28 0's to the left of Imm[4:0]
        