

module condition_handler (
input [3:0] flags,
input [3:0] cond,
input ID_branch_instr,
output reg branch_out
);

// Order of Condition flags
// Z -> Zero
// N -> Negative
// C -> Carry
// V -> Overflow

reg Z, N, C, V;

always @(flags) begin
    Z <= flags[0];
    N <= flags[1];
    C <= flags[2];
    V <= flags[3];
end

always @(flags, cond, ID_branch_instr) begin
    if (ID_branch_instr) begin
        case (cond)
            4'b0000: branch_out = ID_branch_instr; // Branch Never
            4'b0001: branch_out = Z; // Branch on Equals
            4'b0010: branch_out = Z | (N ^ V); // Branch on less or Equal
            4'b0011: branch_out = N ^ V; // Branch on Less - bl
            4'b0100: branch_out = C | Z; // Branch on Less or Equal Unsigned - bleu
            4'b0101: branch_out = C ; // Branch on Carry = 1 - bcs
            4'b0110: branch_out = N; // Branch on Negative - bneg
            4'b0111: branch_out = V; // Branch Overreflow = 1 - bvs
            4'b1000: branch_out = 1'b1; // Branch Always - ba
            4'b1001: branch_out = ~Z; // Branch on not Equals - bne
            4'b1010: branch_out = ~(Z | (N ^ V)); // Branch on Greater - bg
            4'b1011: branch_out = ~(N ^ V); // Branch on Greater or Equal - bge
            4'b1100: branch_out = ~(C | Z); // Branch on Greater Unsigned - bgu
            4'b1101: branch_out = ~C; // Branch on Carry = 0 - bcc
            4'b1110: branch_out = ~N; // Branch on Positive - bpos
            4'b1111: branch_out = ~V; // Branch overreflow = 0 - bvc
            default: branch_out = 1'b0; // Catch unexpected values of "cond"
        endcase
    end else branch_out <= 1'b0; // Output 0 when ID_branch_instr is 0
end
endmodule
