`timescale 1ns / 1ns
`include "project/src/project-operand.v"

module operand_tb;

    reg [31:0] R;
    reg [21:0] Imm;
    reg [31:0] IS;
    wire [31:0] N;

    source_operand uut (
        .R(R),
        .Imm(Imm),
        .IS(IS),
        .N(N)
    );

    initial begin

    // Test Main, taken from the example the professor gave us
    // TODO: Ask the professor for possible test case examples to include in this project
    R = 32'b11100000000000000000000000000011;
    Imm = 21'b100110001000100010011;
f
    #5 $display("Main Test for Operand. R=%b and Imm=%b. All following test will be outputting N for every change in IS", R, Imm);
    IS = 32'b0011111111111011111111110111111;


    end

    initial begin
        #15 $monitor("%d | %d | %d | %d", IS, R, Imm, N);
    end
endmodule