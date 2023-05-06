`timescale 1ns / 1ns


// Generated with AI, modify based on need (and add more test idk)

module pipeline_ID_EX_tb;

    // Inputs
    reg clk;
    reg reset;
    reg [31:0] MX1;
    reg [31:0] MX2;
    reg [31:0] MX3;
    reg [21:0] IMM22;
    reg [4:0] RD;
    reg [3:0] ID_IS_instr;
    reg [3:0] ID_ALU_OP_instr;
    reg [9:0] ID_control_unit_instr;

    // Outputs
    wire [31:0] EX_MX1;
    wire [31:0] EX_MX2;
    wire [31:0] EX_MX3;
    wire [21:0] EX_IMM22;
    wire [4:0] EX_RD;
    wire [3:0] EX_IS_instr;
    wire [3:0] EX_ALU_OP_instr;
    wire [9:0] EX_control_unit_instr;

    // Instantiate the module to be tested
    pipeline_ID_EX dut (
        .clk(clk),
        .reset(reset),
        .MX1(MX1),
        .MX2(MX2),
        .MX3(MX3),
        .IMM22(IMM22),
        .RD(RD),
        .ID_IS_instr(ID_IS_instr),
        .ID_ALU_OP_instr(ID_ALU_OP_instr),
        .ID_control_unit_instr(ID_control_unit_instr),
        .EX_MX1(EX_MX1),
        .EX_MX2(EX_MX2),
        .EX_MX3(EX_MX3),
        .EX_IMM22(EX_IMM22),
        .EX_RD(EX_RD),
        .EX_IS_instr(EX_IS_instr),
        .EX_ALU_OP_instr(EX_ALU_OP_instr),
        .EX_control_unit_instr(EX_control_unit_instr)
    );

    // Initialize inputs
    initial begin
        clk = 0;
        reset = 1;
        MX1 = 32'h00000001;
        MX2 = 32'h00000002;
        MX3 = 32'h00000003;
        IMM22 = 22'h1234;
        PC = 32'h80000000;
        RD = 5'b00000;
        ID_IS_instr = 4'b0000;
        ID_ALU_OP_instr = 4'b0000;
        ID_control_unit_instr = 10'b0000000000;
        #10 reset = 0; // release reset after 10 time units
    end

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Stimulus
    always begin
        #20 MX1 = 32'h01010101;
        #20 MX2 = 32'h02020202;
        #20 MX3 = 32'h03030303;
        #20 IMM22 = 22'h5678;
        #20 PC = 32'h90000000;
        #20 RD = 5'b00100;
        #20 ID_IS_instr = 4'b0011;
        #20 ID_ALU_OP_instr = 4'b0100;
        #20 ID_control_unit_instr = 10'b1111111111;
        #200 $finish; // End the simulation after 200 time units
    end

endmodule
