`timescale 1ns / 1ns

module mini_alu_tb;

  reg [31:0] a;
  reg [31:0] b;
  reg cin;
  reg [3:0] opcode;
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
    // Test ADD operation with flags (without flags)
    a = 32'h00000001;
    b = 32'hFFFFFFFF;
    cin = 1'b0;
    opcode = 4'b0000;
    #5 $display("Test case 1: Add a positive number with a positive number: %h + %h = %h, flags=%b", a, b, y, flags);
    // #5;
    // if (y !== 32'h00000000 || flags !== 4'b1000) $error("Test failed for ADD operation with flags");


    // Test case 2: Add a negative number with a positive number without carry
    a = 32'h8000000C;
    b = 32'h0000000D;
    cin = 1'b1;
    opcode = 4'b0001;
    #5 $display("Test case 2: Add a negative number with a positive number: %h + %h = %h, flags=%b", a, b, y, flags);


    // Test case 3: Subtract a positive number with another positive number without carry
    a = 32'h80000000;
    b = 32'h7FFFFFFF;
    cin = 1'b0;
    opcode = 4'b0010;
    #5 $display("Test case 3: Subtract a positive number with a positive number: %h - %h = %h, flags=%b", a, b, y, flags);


    // Test case 4: Subtract a postive number with a positive number with carry
    a = 32'h80000000;
    b = 32'h7FFFFFFF;
    cin = 1'b1;
    opcode = 4'b0011;
    #5 $display("Test case 4: Subtract a positive number with a positive number with carry: %h - %h - %h = %h, flags=%b", a, b, cin, y, flags);
    // #5;
    // if (y !== 32'h00000000 || flags !== 4'b0100) $error("Test failed for SUBC operation with flags");

    
    // Test case 5: Perform AND operation with two positive numbers
    a = 32'hFFFFFFFF;
    b = 32'h0000FFFF;
    cin = 1'b0;
    opcode = 4'b0100;
    #5 $display("Test case 5: Do an AND operation with two numbers: %h AND %h = %h, flags=%b", a, b, y, flags);
    // #5;
    // if (y !== 32'h0000FFFF || flags !== 4'b0000) $error("Test failed for AND operation with flags");


    // Test case 6: Perform OR operation with two positive numbers
    a = 32'hFFFFFFFF;
    b = 32'h0000FFFF;
    opcode = 4'b0101;
    #5 $display("Test case 6: OR operation with positive numbers: %h OR %h = %h, flags=%b", a, b, y, flags);

    
    // Test case 7: Perform XOR operation with two positive numbers
    a = 32'hFFFFFFFF;
    b = 32'h0000FFFF;
    opcode = 4'b0110;
    #5 $display("Test case 7: XOR operation with positive numbers: %h XOR %h = %h, flags=%b", a, b, y, flags);


    // Test case 8: Perform XNOR operation with two positive numbers
    a = 32'hFFFFFFFF;
    b = 32'h0000FFFF;
    opcode = 4'b0111;
    #5 $display("Test case 8: XNOR operation with positive numbers: %h XNOR %h = %h, flags=%b", a, b, y, flags);


    // Test case 9: Perform AND operation with a positive number and a negated number
    a = 32'hFFFFFFFF;
    b = 32'h0000FFFF;
    opcode = 4'b1000;
    #5 $display("Test case 9: AND operation with a positive number and a negated number: %h AND (NOT %h) = %h, flags=%b", a, b, y, flags);


    // Test case 10: Perform XOR operation with a positive number and a negated number
    a = 32'hFFFFFFFF;
    b = 32'h0000FFFF;
    opcode = 4'b1001;
    #5 $display("Test case 10: XOR operation with a positive number and a negated number: %h XOR (NOT %h) = %h, flags=%b", a, b, y, flags);
    

    // Test case 11: Perform Left Shift with two positive numbers
    a = 32'h00000001;
    b = 32'h0000001F;
    opcode = 4'b1010;
    #5 $display("Test case 11: Left Shift between two positive numbers: %h << %h = %h", a, b, y);


    // Test case 12: Perform Right Shift with two positive numbers
    a = 32'hFFFFFFFF;
    b = 32'h0000FFFF;
    opcode = 4'b1011;
    #5 $display("Test case 12: Right Shift between two positive numbers: %h >> %h = %h", a, b, y);
    


    // Test case 13: Perform Arithmetic Right Shift with two positive numbers, no flags required
    a = 32'hFFFFFFFF;
    b = 32'h0000FFFF;
    opcode = 4'b1100;
    #5 $display("Test case 13: Arithmetic Right Shift between two positive numbers: %h >>> %h = %h", a, b, y);

    
    // Test case 14: Output set to A. Flags not required
    a = 32'hFFFFFFFF;
    b = 32'h0000FFFF;
    opcode = 4'b1101;
    #5 $display("Test case 14: Set output to A: a=%h, b=%h, output=%h", a, b, y);


    // Test case 15: Output set to B
    a = 32'hFFFFFFFF;
    b = 32'h0000FFFF;
    opcode = 4'b1110;
    #5 $display("Test case 15: Set output to B: a=%h, b=%h, output=%h", a, b, y);


    // Test case 16: Output set to negated B
    a = 32'hFFFFFFFF;
    b = 32'h0000FFFF;
    opcode = 4'b1111;
    #5 $display("Test case 16: Set output to negated B: a=%h, b=%h, output=%h", a, b, y);
    
    end

endmodule
