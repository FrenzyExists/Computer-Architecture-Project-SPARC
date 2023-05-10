`timescale 1ns / 1ps

module condition_handler_tb;

reg [3:0] flags;
reg [3:0] cond;
reg ID_branch_instr;
wire branch_out;

condition_handler dut (
  .flags(flags),
  .cond(cond),
  .ID_branch_instr(ID_branch_instr),
  .branch_out(branch_out)
);

initial begin
    $display ("Tesing Condition Handler...\n");
    $monitor("flags=%b, cond=%b, ID_branch_instr=%b, branch_out=%b", flags, cond, ID_branch_instr, branch_out);

    // Test case 1: Branch Never (0000)
    flags = 4'b1010;
    cond = 4'b0000;
    ID_branch_instr = 1'b1;
    #1;
    if (branch_out !== 1'b1) $display("Test case 1 failed");

    // Test case 2: Branch on Equals (0001)
    flags = 4'b0001;
    cond = 4'b0001;
    ID_branch_instr = 1'b1;
    #1;
    if (branch_out !== 1'b0) $display("Test case 2 failed");

    // Test case 3: Branch on Less or Equal (0010)
    flags = 4'b0010;
    cond = 4'b0010;
    ID_branch_instr = 1'b1;
    #1;

    // Test case 4: Branch on Less (0011)
    flags = 4'b0011;
    cond = 4'b0011;
    ID_branch_instr = 1'b1;
    #1;

    // Test case 5: Branch on Less or Equal Unsigned (0100)
    flags = 4'b0100;
    cond = 4'b0100;
    ID_branch_instr = 1'b1;
    #1;

    // Test case 6: Branch on Carry = 1 (0101)
    flags = 4'b0101;
    cond = 4'b0101;
    ID_branch_instr = 1'b1;
    #1;

    // Test case 7: Branch on Negative (0110)
    flags = 4'b0110;
    cond = 4'b0110;
    ID_branch_instr = 1'b1;
    #1;

    // Test case 8: Branch Overreflow = 1 (0111)
    flags = 4'b0111;
    cond = 4'b0111;
    ID_branch_instr = 1'b1;
    #1;
    if (branch_out !== 1'b0) $error("Test case 8 failed");

    // Test case 9: Branch Always (1000)
    flags = 4'b1000;
    cond = 4'b1000;
    ID_branch_instr = 1'b1;
    #1;

    // Test case 10: Branch on not Equals (1001)
    flags = 4'b1001;
    cond = 4'b1001;
    ID_branch_instr = 1'b1;
    #1;
    if (branch_out !== 1'b1) $error("Test case 10 failed");


    // Test case 11: Branch on Greater (1010)
    flags = 4'b1010;
    cond = 4'b1010;
    ID_branch_instr = 1'b1;
    #1;

    // Test case 12: Branch on Greater or Equal (1011)
    flags = 4'b1011;
    cond = 4'b1011;
    ID_branch_instr = 1'b1;
    #1;

    // Test case 13: Branch on Greater Unsigned (1100)
    flags = 4'b1100;
    cond = 4'b1100;
    ID_branch_instr = 1'b1;
    #1;

    // Test case 14: Branch on Positive (b1110)
    flags = 4'b1100;
    cond = 4'b1110;
    ID_branch_instr = 1'b1;
    #1;


    // Test case 15: Branch overreflow = 0 (b 1111)
    flags = 4'b1110;
    cond = 4'b1111;
    ID_branch_instr = 1'b1;
    #1;

    // Test case 16: Branch overreflow = 0 (b 1111) Branch is off
    flags = 4'b1110;
    cond = 4'b1111;
    ID_branch_instr = 1'b0;
    #1;

    #10 $display("Testbench finished!");
    $finish;

end
endmodule