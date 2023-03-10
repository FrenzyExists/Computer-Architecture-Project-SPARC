// Source Operand2 Handler

module source_operand (
    input [31:0] R,
    input [21:0] Imm,
    input [31:0] IS,
    output reg [31:0] N
);

always @(*) begin
    case({IS[31], IS[30], IS[24], IS[13]})
        
        4'b0000: N = {Imm, 10'b0}; // concatenate 10 0's to the right of Imm
        4'b0001: N = {Imm, 10'b0};
        4'b0010: N = {Imm, 10'b0};
        4'b0011: N = {Imm, 10'b0};
        4'b0100: begin
            if (Imm[21] == 1'b1) // if the sign bit is set
                N = {10'b1111111111, Imm}; // sign extend with 1's
            else
                N = {10'b0000000000, Imm}; // sign extend with 0's
        end

        4'b0101: begin
            if (Imm[21] == 1'b1) // if the sign bit is set
                N = {10'b1111111111, Imm}; // sign extend with 1's
            else
                N = {10'b0000000000, Imm}; // sign extend with 0's
        end
        4'b0110: begin
            if (Imm[21] == 1'b1) // if the sign bit is set
                N = {10'b1111111111, Imm}; // sign extend with 1's
            else
                N = {10'b0000000000, Imm}; // sign extend with 0's
        end
        4'b0111: begin
            if (Imm[21] == 1'b1) // if the sign bit is set
                N = {10'b1111111111, Imm}; // sign extend with 1's
            else
                N = {10'b0000000000, Imm}; // sign extend with 0's
        end
        4'b1000: N = R;
        4'b1001: begin
            if (Imm[21] == 1'b1) // if the sign bit is set
                N = {22'b1111111111111111111111, Imm[12:0]}; // sign extend with 1's
            else
                N = {22'b0000000000000000000000, Imm[12:0]}; // sign extend with 1's
        end
        4'b1010: N = {27'b0, R[4:0]};
        4'b1011: N = {27'b0, Imm[4:0]};
        4'b1100: N = R;        
        4'b1101: begin
            if (Imm[21] == 1'b1) // if the sign bit is set
                N = {22'b1111111111111111111111, Imm[12:0]}; // sign extend with 1's
            else
                N = {22'b0000000000000000000000, Imm[12:0]}; // sign extend with 1's
        end
        4'b1110: N = R;
        4'b1111: begin
            if (Imm[21] == 1'b1) // if the sign bit is set
                N = {22'b1111111111111111111111, Imm[12:0]}; // sign extend with 1's
            else
                N = {22'b0000000000000000000000, Imm[12:0]}; // sign extend with 1's
        end

        // 4'b1101: N = {Imm[:], Imm[11:0]}; // sign extend Imm12-0 to 32 bits
        // 4'b1111: N = {20 {Imm[31]}, Imm[11:0]}; // sign extend Imm12-0 to 32 bits        
        // 4'b1001: begin
        // // check the Imm 13 bits (bit 21) if its 0 fill 0s else fill
        // N = {Imm[12:0], }
    endcase
end
endmodule
