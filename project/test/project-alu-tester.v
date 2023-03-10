`timescale 1ns / 1ns
`include "project/src/project-alu.v"

module mini_alu_tb;

  reg  [31:0] a;
  reg  [31:0] b;
  reg  cin;
  reg  [3:0] opcode;
  wire [31:0] y;
  wire [3:0] flags;

  mini_alu uut (
    .a(a),
    .b(b),
    .cin(cin),
    .opcode(opcode),
    .y(y),
    .flags(flags)
  );

  initial begin
  
  $display("Test 1\n");
  #10
    
    a = 32'b00000000000000000000000000000001;
    b = 32'b10111111111111111111111111111111;
    cin = 1'b0;
    opcode = 4'b0000;
    repeat (15) #20 opcode = opcode + 4'b0001;

    #100
    #3 $display("\nTest 2\n");
    a = 32'b00000000000000000000000000000000;
    b = 32'b00000000000000000000000000000001;
    cin = 1'b0;
    opcode = 4'b0000;
    repeat (15) #20 opcode = opcode + 4'b0001;

    #100
    
    #3 $display("\nTest 3\n");
    a = 32'b01000000000000000000000000000000;
    b = 32'b01000000000000000000000000000000;
    cin = 1'b0;
    opcode = 4'b0000;
    repeat (15) #20 opcode = opcode + 4'b0001;
    
    #100

    #3 $display("\nTest 4\n");
    a = 32'b10000000000000000000000000001000;
    b = 32'b10000000000000000000000001000000;
    cin = 1'b0;
    opcode = 4'b0000;
    repeat (15) #20 opcode = opcode + 4'b0001;


    // if (y !== 32'h00000000 || flags !== 4'b1000) $error("Test failed for ADD operation with flags");
    end
    initial begin
    
    #10 $display("| opcode |      A     |      B     |      Y     | flag |");
    #15 $monitor("| %b   | %d | %d | %d | %b |", opcode, a, b, y, flags);
    end
endmodule
