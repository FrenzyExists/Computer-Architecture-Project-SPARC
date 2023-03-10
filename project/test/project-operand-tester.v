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

    integer i;

    initial begin

        R = 32'b11100000000000000000000000000011;
        Imm = 21'b100110001000100010011;

        IS = 32'b00000000000000000000000000000000;
        
        #3 $display("               IS                |                 R                |              Imm                |               N");
        for (i = 0 ; i < 16 ; i = i+1) #1 begin;
            #15 $monitor("%b | %b | %b | %b", IS, R, Imm, N);
            IS[31] = i[3]; 
            IS[31] = i[2]; 
            IS[24] = i[1];
            IS[13] = i[0];
        end

    end

endmodule