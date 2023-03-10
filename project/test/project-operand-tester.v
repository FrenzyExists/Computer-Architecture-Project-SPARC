`timescale 1ns / 1ns

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
    Imm = 21'b1000110001000100010011;

    #5 $display("Main Test for Operand. R=%b and Imm=%b. All following test will be outputting N for every change in IS", R, Imm);
    IS = 32'b0011111111111011111111110111111;

    #5 $display("Test 1: IS=%b, N=%b", IS, N);

    end
endmodule