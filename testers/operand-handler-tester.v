`timescale 1ns / 1ns
`include "src/operand-handler.v"

module operand_tb;
    reg [31:0] R;
    reg [21:0] Imm;
    reg [3:0] IS;
    wire [31:0] N;

    source_operand uut (
        .R(R),
        .Imm(Imm),
        .IS(IS),
        .N(N)
    );

    initial begin
        R = 32'b11100000000000000000000000000011;
        Imm = 22'b1000110001000100010011;
        
        IS = 4'b0000;
        repeat (15) #20 IS = IS + 4'b0001;

        Imm = 22'b1000110000000100010011;
        #3 $display(" ");
        
        IS = 4'b1000;
        repeat (7) #20 IS = IS + 4'b0001;
    end

    initial begin
        $dumpfile("gtk-wave-testers/operand-handler.vcd"); // pass this to GTK Wave to visualize better wtf is going on
        $dumpvars(0, operand_tb);

        #3 $display("  IS |%17sR%16s|%10sImm%11s|%17sN%16s", "", "", "", "", "", "");
        #3 $display("-----|%s|%s|%s", "----------------------------------", "------------------------", "----------------------------------");
        #10 $monitor("%b | %b | %b | %b", IS, R, Imm, N);
    end
endmodule