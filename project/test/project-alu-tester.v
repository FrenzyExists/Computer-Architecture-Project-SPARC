`timescale 1ns / 1ns

module mini_alu_tb;

  reg signed [31:0] a;
  reg signed [31:0] b;
  reg cin;
  reg [3:0] opcode;
  wire signed [31:0] y;
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
  #3 $display("Test 1: postive number and negative number");
    a = 32'b0000000000001100;
    b = -32'b0000000000110011;
    cin = 1'b0;
    opcode = 4'b0000;
    repeat (7) #10 opcode = opcode + 4'b0001;

    a = -32'b0000000000001100;
    b = -32'b0000000000110011;
    opcode = 4'b0000;

repeat (7) #10 opcode = opcode + 4'b0001;

    // if (y !== 32'h00000000 || flags !== 4'b1000) $error("Test failed for ADD operation with flags");
    end
    initial begin
    
    #4 $display("opcode |      A      |      B      |      Y      | flags");
    #5 $monitor("%b   | %d | %d | %d | %b", opcode, a, b, y, flags);
    end



endmodule
