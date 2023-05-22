`timescale 1ns / 1ps
`include "src/reset-handler.v"

module reset_handler_test();

    reg system_reset;
    reg ID_branch_instr;
    reg a;
    wire reset_out;

    reset_handler reset_handler_inst(
        .system_reset(system_reset),
        .ID_branch_instr(ID_branch_instr),
        .a(a),
        .reset_out(reset_out)
    );

    initial begin

        $display ("Tesing Reset Handler...\n");
        $monitor("system_reset=%b, a=%b, ID_branch_instr=%b, reset_out=%b", system_reset, a, ID_branch_instr, reset_out);

        // Test case 1: System reset is triggered
        system_reset = 1'b1;
        ID_branch_instr = 1'b0;
        a = 1'b0;
        $display ("Test 1: System Reset is triggered but Branch Instruction is not...\n");
        #1;
        if (reset_out !== 1'b1) $error("Test case 1 failed");

        // Test case 2: System reset is not triggered due to ID_branch_instr = 1'b1 and a = 1'b0
        system_reset = 1'b0;
        ID_branch_instr = 1'b1;
        a = 1'b0;
        $display ("Test 2: System Reset isn't triggered, but Branch Instruction is...\n");
        #1;
        if (reset_out !== 1'b0) $error("Test case 2 failed");

        // Test case 3: System reset is triggered due to ID_branch_instr = 1'b1 and a = 1'b1
        system_reset = 1'b1;
        ID_branch_instr = 1'b1;
        a = 1'b1;
        $display ("System Reset is triggered as well as Branch Instruction...\n");
        #1;
        if (reset_out !== 1'b1) $error("Test case 3 failed");

        // Test case 4: System reset is not triggered due to ID_branch_instr = 0 and a = 1'b1
        system_reset = 1'b0;
        ID_branch_instr = 1'b0;
        a = 1'b1;
        $display ("System reset isn't triggered nor is Branch Instruction...\n");
        #1;
        if (reset_out !== 1'b0) $error("Test case 4 failed");

        // Test case 5: System reset is not triggered due to ID_branch_instr = 0 and a = 0
        system_reset = 1'b0;
        ID_branch_instr = 1'b0;
        a = 1'b0;
        $display ("System Reset isn't triggered nor is Branch Instruction and Condition is set to False...\n");
        #1;
        if (reset_out !== 1'b0) $error("Test case 5 failed");

    end

endmodule
