

// Source Operand2 Handler
/*
TODO: Preguntar al profe que rayos se supone que 
haga este modulo que pidio

*/
module source_operand (
    input [31:0] R,
    input [21:0] Imm,
    input reg [3:0] Is,
    output [31:0] N
);

always @(*) begin
    case(Is)
        4'b000: N = Imm || 10'b0; // concatenate 10 0's to the right of Imm
        4'b001: N = Imm || 10'b0;
        4'b010: N = Imm || 10'b0;
        4'b011: N = Imm || 10'b0;
        4'b100: N = {{12{Imm[31]}}, Imm[31:0]}; // sign extend Imm to 32 bits

        4'b1000: N = R;

        4'b1100: N = {16'b0, R[4:0]}; // concatenate 16 0's to the left of R[4:0]

        4'b1110: N = {16'b0, Imm[4:0]}; // concatenate 16 0's to the left of Imm[4:0]

        // add these cases to match the behavior described in the table
        4'b1001: N = {20{Imm[31]} , Imm[11:0]}; // sign extend Imm12-0 to 32 bits
        4'b1010: N = {28'b0, R[4:0]}; // concatenate 28 0's to the left of R[4:0]
        4'b1011: N = {28'b0, Imm[4:0]}; // concatenate 28 0's to the left of Imm[4:0]
        4'b1101: N = {20{Imm[31]}, Imm[11:0]}; // sign extend Imm12-0 to 32 bits
        4'b1111: N = {20{Imm[31]}, Imm[11:0]}; // sign extend Imm12-0 to 32 bits
    endcase
end
endmodule
