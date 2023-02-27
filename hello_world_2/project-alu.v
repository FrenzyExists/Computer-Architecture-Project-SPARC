
module mini_alu (
    input [31:0] a,
    input [31:0] b, 
    input c1, 
    
    input [3:0] opcode, 
    output reg [31:0] y
    );
    always @(*) begin
        case (opcode)
            4'b0000: y = a + b; // Add
            4'b0001: y = a + b + c1; // Add with carry 
            4'b0010: y = a - b;
            4'b0011: y = a - b - c1;
            4'b0100: y = a && b;
            4'b0101: y = a ^ b;
            4'b0110: y = a xor b;
            4'b0111: y = a xnor b;
            4'b1000: y = a && ~b;
            4'b1001: y = a ^ ~b;
            4'b1010: y = a << b;
            4'b1011: y = a >> b;
            4'b1100: y = a >>> b; 
            4'b1101: y = a;
            4'b1110: y = b;
            4'b1111: y = ~b;
        endcase
    end
endmodule


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
        4'b000: N = Imm || 0b0000000000;
        4'b001: N = Imm || 0b0000000000;
        4'b010: N = Imm || 0b0000000000;
        4'b011: N = Imm || 0b0000000000;
        4'b100: N = Imm[21:0] <= { {8{Is[7]}}, Is[7:0] }; // No tengo idea de lo que hago :v

        4'b1000: N = R;

        4'b1100: N = R;

        4'b1110: N = R;

    endcase
end

endmodule


module register_4bit (
    output reg [3:0] Q,
    input [3:0] D,
    input LE, Clr, Clk
    );
    always @ (posedge Clk)
    if (Clr) Q <= 4’b0000 ;
    else if (LE) Q <= D;
endmodule