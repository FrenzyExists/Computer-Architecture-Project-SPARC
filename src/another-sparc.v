`timescale 1ns / 1ns

// Phase 4 of the project. Similar to phase 3, but here
// the architecture is fully implemented
`include "src/control-unit.v"
`include "src/alu.v"
`include "src/pipeline-registers.v"
`include "src/muxes.v"
`include "src/reset-handler.v"
`include "src/operand-handler.v"
`include "src/psr-register.v"
`include "src/condition-handler.v"
`include "src/instruction-memory.v"
`include "src/register-file.v"
`include "src/data-memory.v"
`include "src/npc-pc-handler.v"
`include "src/output-handler.v"
`include "src/hazard-forwading-unit.v" 

// This module is for testing, DO NOT synthetize
module sparcV8ArchitectureTester;

// -------------- R E G I S T E R S -------------------- //

    // Instruction Memory stuff
    integer fi, fo, code, i; 
    reg [7:0] data;
    reg [7:0] Addr; 
    wire [31:0] instruction;
    wire [31:0] instruction_out;

    // Clock and Clear
    reg clr;    // Clear, aka the General Reset
    reg clk;   

    // Counters
    wire [31:0] nPC;     // The Next Program Counter
    wire [31:0] nPC4;    // Next Program Counter (Modified)
    wire [31:0] PC;      // The actual Program Counter. This counter state is at the Fetch State
    wire [31:0] PC_ID;   // The Program Counter state at the Decode Stage
    wire [31:0] PC_EX;   // The Program Counter state at the Execute State
    wire [31:0] PC_MEM;  // The Program Counter state at the Memory State

    // Used to calculate the instruction that should be executed by modifying the Program Counter (PC)
    reg [31:0] TA;         // The Target Address

    // Multiplexer outputs
    // wire [1:0] forwardMX1;              // Multiplexer selection for Mux 1 of ID Stage
    // wire [1:0] forwardMX2;              // Multiplexer selection for Mux 2 of ID Stage
    // wire [1:0] forwardMX3;              // Multiplexer selection for Mux 3 of ID Stage

    reg [1:0] forwardMX1;              // Multiplexer selection for Mux 1 of ID Stage
    reg [1:0] forwardMX2;              // Multiplexer selection for Mux 2 of ID Stage
    reg [1:0] forwardMX3;              // Multiplexer selection for Mux 3 of ID Stage

    wire [1:0] forwardOutputHandler;    // Selects an option from the MUX connected to the output handler
    wire [1:0] forwardPC;               // Selects an option from the MUX that inside a nPC/PC logic box
    
    // wire forwardCU;
    reg forwardCU;

    // Instruction Signals from the Control Unit
    wire [18:0] CU_SIG;     // Unslized Control Unit instructions between CU and CU_MUX
    wire [17:0] ID_CU;      // Unslized Control Unit instructions at the ID Stage
    wire [8:0]  EX_CU;      // Unslized Control Unit instructions at the EX Stage
    wire        MEM_CU;     // Unslized Control Unit instructions at the MEM Stage

    // Outputs of Components
    wire [31:0] ALU_OUT;        // ALU Output, used for the PC/nPC system
    wire [31:0] MEM_OUT;        // This is the output of a MUX located in MEM stage
    //wire [31:0] WB_OUT;         // Writeback instruction. Goe to PW of the Register File and to the Muxes of ID Stage
    reg [31:0] WB_OUT;
    wire [31:0] PC_MUX_OUT;     // Output between the PC and the PC_MUX

    // Controls when the flow will flow and when it should stop
    // wire PC_LE;
    // wire nPC_LE;
    // wire IF_ID_Pipeline_LE;
    // wire WB_Register_File_Enable;

    reg PC_LE;
    reg nPC_LE;
    reg IF_ID_Pipeline_LE;
    reg reset;    

    reg cond_branch_OUT = 0; // Goes to nPC/PC handler, from condition handler

    // -------  Other Outputs -------- /

    // ------------------- In ID Stage
    // --------------------------------------------------------------------------------------------
    wire [3:0] cond;               // branch condition instruction
    wire [4:0] rs1;                // operand register 1
    wire [4:0] rs2;                // operand register 2
    wire [4:0] rd;                 // destiny register

    // Register File Output
    wire [31:0] pa;
    wire [31:0] pb;
    wire [31:0] pd;

    wire [21:0] ID_Imm22;          // Immediate 22-bit from Decode
    wire [29:0] I29_0;             // Remaining bits from the call instruction

    wire ID_branch_instr;

    // Multiplexer Output (ID)
    wire [31:0] ID_MX1;
    wire [31:0] ID_MX2;
    wire [31:0] ID_MX3;

    wire [4:0] RD_CALL_ID; // Destination Register (ID) filtered by a MUX :)

    // ------------------- In EX Stage
    // --------------------------------------------------------------------------------------------
    wire [3:0] ALU_OP; // ALU OPCODE Instructions
    wire [3:0] IS;      // Selects the operation the source2 operand handler would perform
    wire [21:0] EX_Imm22;          // Immediate 22-bit from Execute
    wire CC_Enable;     // Condition Code Enable

    // Multiplexer Output (EX)
    wire [31:0] EX_MX1;
    wire [31:0] EX_MX2;
    wire [31:0] EX_MX3;

    wire [31:0] N; // Source2 Operand Handler output
    wire [3:0] ALU_FLAGS;
    wire [3:0] PSR_OUT;

    wire [4:0] RD_EX; // Destination Register filtered by a MUX (EX)

    // ------------------- In MEM Stage
    // --------------------------------------------------------------------------------------------
    wire [4:0] RD_MEM; // Destination Register filtered by a MUX (MEM)
    wire [4:0] DataMemInstructions;         // This goes on the Data Memory
    wire [2:0] OutputHandlerInstructions;   // This goes on the output handler

    // ------------------- In WB Stage
    // --------------------------------------------------------------------------------------------
    // wire WB_Register_File_Enable;
    reg WB_Register_File_Enable;
    // wire [4:0] RD_WB;
    reg [4:0] RD_WB;


// -------------- M O D U L E  I N S T A N C I A T I O N -------------------- //

    // Adder, updates the PC
    PC_adder adder (
        .PC_in(nPC),
        .PC_out(nPC4) // nPC + 4
    );

    // nPC register
    nPC_Reg nPC_Reg ( 
        .Q      (nPC), // Out
        .LE     (nPC_LE), 
        .clk    (clk), 
        .clr    (clr),
        .D      (nPC4) // In
    );

    nPC_PC_Handler nPC_PC_Handler (
        .branch_out               (cond_branch_OUT),
        .ID_jmpl_instr            (ID_CU[1]),
        .ID_call_instr            (ID_CU[0]),
        .pc_handler_out_selector  (forwardPC)
    );

    // Multiplexer, filters which value to update the PC
    PC_MUX PC_MUX (
    .nPC        (nPC),
    .ALU_OUT    (ALU_OUT),
    .TA         (TA),
    .select     (forwardPC),
    .Q          (PC_MUX_OUT)
    );

    // PC register
    PC_Reg PC_Reg ( 
        .Q      (PC), // Out
        .LE     (PC_LE), 
        .clk    (clk), 
        .clr    (clr),
        .D      (PC_MUX_OUT)  // In
    );

    // Instruction Memory
    rom_512x8 ram1 (
        instruction, // OUT
        PC[7:0]      // IN
    );

    // Precharging the Instruction Memory
    initial begin
        fi = $fopen("precharge/sparc-instructions-3-precharge.txt","r");
        Addr = 8'b00000000;
        $display("Precharging Instruction Memory...\n---------------------------------------------\n");
        while (!$feof(fi)) begin
            if (Addr % 4 == 0 && !$feof(fi)) $display("\n\nLoading Next Instruction...\n-------------------------------------------------------------------------");
            code = $fscanf(fi, "%b", data);
            $display("---- %b ----\n", data);
            ram1.Mem[Addr] = data;
            Addr = Addr + 1;
        end
        $fclose(fi);
        Addr = 8'b00000000;
    end

    // Clock generator
    initial begin
        clr <= 1'b1;
        clk <= 1'b0;
        #2 clk <= ~clk;
        // #1 clk <= ~clk;
        // #1 clr <= 1'b0;
        #2 clk <= ~clk; 
       forever #2 clk = ~clk;
    end

    // -|-|-|-|-|-|-|-|----- I D  S T A G E -----|-|-|-|-|-|-|-|- //


    pipeline_IF_ID pipeline_IF_ID (
        .PC                             (PC),
        .instruction                    (instruction),
        .reset                          (reset), 
        .LE                             (IF_ID_Pipeline_LE), 
        .clk                            (clk), 
        .clr                            (clr),

        .PC_ID_out                      (PC_ID),
        .I21_0                          (ID_Imm22),
        .I29_0                          (I29_0),
        .I29_branch_instr               (I29_branch_instr),
        .I18_14                         (rs1),
        .I4_0                           (rs2),
        .I29_25                         (rd),
        .I28_25                         (cond),
        .instruction_out                (instruction_out) 
    );

    control_unit CU (
        .clk                            (clk),
        .clr                            (clr),
        .instr                          (instruction_out),
        .instr_signals                  (CU_SIG)
    );

    control_unit_mux CU_MUX (
        .ID_branch_instr_out            (ID_branch_instr),
        .CU_SIGNALS                      (ID_CU),

        .S                              (forwardCU),
        .cu_in_mux                      (CU_SIG)
    );  


    // Register File, saves operand and destiny registers
    register_file REG_FILE (
        .PA                             (pa),
        .PB                             (pb),
        .PD                             (pd),
        .PW                             (WB_OUT),
        .RW                             (RD_WB),
        .RA                             (rs1),
        .RB                             (rs2),
        .RD                             (rd),
        .LE                             (WB_Register_File_Enable),
        .clk                            (clk)
    );

    // Precharge Register File with some values to work with
    initial begin

    WB_Register_File_Enable = 1'b1;
    WB_OUT <= 32'b00000000000000000000000000000100; // 20
    RD_WB <= 5'b00000; // RW
    #4;
    WB_OUT <= 5'b01000;
    RD_WB <= 24;
    #4;
    WB_OUT <= 5'b00111;
    RD_WB <= 3;
    #4;
    WB_OUT <= 5'b00010;
    RD_WB <= 7;
    #4;
    WB_OUT <= 5'b11010;
    RD_WB <= 4;
    end



    mux_4x1 MX1 (
        .S                              (forwardMX1),
        .I0                             (pa),      // File Register value selected by rs1
        .I1                             (ALU_OUT), // EX_RD
        .I2                             (MEM_OUT), // MEM_RD
        .I3                             (WB_OUT),  // WB_RD 
        .Y                              (ID_MX1)   // MUX OUTPUT
    );

    mux_4x1 MX2 (
        .S                              (forwardMX2),
        .I0                             (pb),
        .I1                             (ALU_OUT),
        .I2                             (MEM_OUT),
        .I3                             (WB_OUT),
        .Y                              (ID_MX2)
    );

    mux_4x1 MX3 (
        .S                              (forwardMX3),
        .I0                             (pd),
        .I1                             (ALU_OUT),
        .I2                             (MEM_OUT),
        .I3                             (WB_OUT),
        .Y                              (ID_MX3)
    );

    mux_2x5 MUX_RD (
        .I0     (rd),
        .I1     (5'b00111),

        .S      (ID_CU[1]),
        .Y      (RD_CALL_ID)
    );

    // -|-|-|-|-|-|-|-|----- E X  S T A G E -----|-|-|-|-|-|-|-|- //

    pipeline_ID_EX ID_EX (
         .PC                            (PC_ID),
         .clk                           (clk),
         .clr                           (clr),
         .ID_control_unit_instr         (ID_CU),
         .ID_RD_instr                   (RD_CALL_ID),
         .Imm22                         (ID_Imm22),

        // OUTPUT
        .PC_EX                          (PC_EX),
        .EX_IS_instr                    (IS),
        .EX_ALU_OP_instr                (ALU_OP),
        .EX_RD_instr                    (RD_EX),
        .EX_CC_Enable_instr             (CC_Enable),
        .EX_control_unit_instr          (EX_CU),
        .EX_Imm22                       (EX_Imm22),

        .ID_MX1                         (ID_MX1),
        .ID_MX2                         (ID_MX2),
        .ID_MX3                         (ID_MX3),
        
        .EX_MX1                         (EX_MX1),
        .EX_MX2                         (EX_MX2),
        .EX_MX3                         (EX_MX3)
    );

   // 
    source_operand source_operand (
        .R                              (EX_MX2),
        .Imm                            (EX_Imm22),
        .IS                             (IS),
        .N                              (N)
    );

    alu ALU (
        .a                              (EX_MX1),
        .b                              (N),
        .cin                            (CIN),
        .opcode                         (ALU_OP),
        .y                              (ALU_OUT),
        .flags                          (ALU_FLAGS)
    );  

    psr_register PSR (
        .out                            (PSR_OUT),
        .carry                          (CIN),
        .flags                          (ALU_FLAGS),
        .enable                         (CC_Enable),
        .clk                            (clk)
    );

    // hazard_forwarding_unit hazard_forwarding_unit (
    //     .forwardMX1                     (forwardMX1),
    //     .forwardMX2                     (forwardMX2),
    //     .forwardMX3                     (forwardMX3),
        
    //     .nPC_LE                         (nPC_LE),
    //     .PC_LE                          (PC_LE),
    //     .IF_ID_LE                       (IF_ID_Pipeline_LE),
        
    //     .CU_S                           (forwardCU), 
        
    //     .EX_Register_File_Enable        (EX_CU[3]),
    //     .MEM_Register_File_Enable       (MEM_CU),
    //     .WB_Register_File_Enable        (WB_Register_File_Enable),
        
    //     .EX_RD                          (RD_EX),
    //     .MEM_RD                         (RD_MEM),
    //     .WB_RD                          (RD_WB),
        
    //     .ID_rs1                         (rs1),
    //     .ID_rs2                         (rs2),
    //     .ID_rd                          (rd)
    // );


    // -|-|-|-|-|-|-|-|----- M E M  S T A G E -----|-|-|-|-|-|-|-|- //

    pipeline_EX_MEM pipeline_EX_MEM (
        // INPUTS
        .clk                            (clk),
        .clr                            (clr),
        .EX_control_unit_instr          (EX_CU),
        .PC                             (PC_EX),
        .EX_RD_instr                    (RD_EX),

        // OUTPUTS
        .Data_Mem_instructions          (DataMemInstructions),
        .Output_Handler_instructions    (OutputHandlerInstructions),
        .MEM_control_unit_instr         (MEM_CU),
        .PC_MEM                         (PC_MEM),
        .MEM_RD_instr                   (RD_MEM)
    );

// -|-|-|-|-|-|-|-|----- W B  S T A G E -----|-|-|-|-|-|-|-|- //

    pipeline_MEM_WB pipeline_MEM_WB (
        // INPUT
        .clk                            (clk),
        .clr                            (clr),
        .MEM_RD_instr                   (RD_MEM),
        .MUX_out                        (PC_MEM), // (OutputMUX),
        .MEM_control_unit_instr         (MEM_CU)

        // OUTPUT 
        // .WB_RD_instr                    (RD_WB),
        // .WB_RD_out                      (WB_OUT),
        // .WB_Register_File_Enable        (WB_Register_File_Enable) 
    );



    // ------------------------- T E S T E R S --------------------------- //

    initial begin
        $dumpfile("gtk-wave-testers/sparcv8-architecture-Tester.vcd"); // pass this to GTK Wave to visualize better wtf is going on
        $dumpvars(0, sparcV8ArchitectureTester);
        #50;
        $display("\n----------------------------------------------------------\nSimmulation Complete! Remember to dump this on GTK Wave and subscribe to PewDiePie...");
        $finish;
    end 

    // initial  begin
    //     $monitor("\n\n\nTIME: %d | S: %b\n---------------------------------\
    //     \nPC: %d | nPC: %d\n--------------------------------------\
    //     \nInstruction at Decode Stage: %b | Signals at Decode Stage:\
    //     \n--------------------------------------------------\
    //     \nPC in ID stage: %d | jmpl: %b | call: %b | load: %b | Register File Enable: %b | Data MEM SE: %b | Data MEM R/W: %b | Data MEM Enable: %b\
    //     \nData MEM Size: %b | Condition Code Enable: %b | I31: %b | I30: %b | I24: %b | I13: %b | Alu Opcode: %b | Branch Instruction: %b\
    //     \n\Signals at Excecute Stage:\
    //     \n--------------------------------------------------\
    //     \nPC in EX Stage: %d | jmpl: %b | call: %b | load: %b | Register File Enable: %b | Data MEM SE: %b | Data MEM R/W: %b | Data MEM Enable: %b\
    //     \nData MEM Size: %b | Condition Code Enable: %b | I31: %b | I30: %b | I24: %b | I13: %b | Alu Opcode: %b\
    //     \n\Signals at Memory Stage:\
    //     \n--------------------------------------------------\
    //     \nPC in MEM Stage: %d | jmpl: %b | call: %b | load: %b | Register File Enable: %b | Data MEM SE: %b | Data MEM R/W: %b | Data MEM Enable: %b\
    //     \nData MEM Size: %b\
    //     \n\Signals at  Writeback Stage:\
    //     \n--------------------------------------------------\
    //     \nRegister File Enable: %b",
    //     $time, S,
        
    //     PC, nPC,

    //     instruction_out, 

    //     PC_ID, ID_CU[0], ID_CU[1], ID_CU[2], ID_CU[3], ID_CU[4], ID_CU[5], ID_CU[6],
    //     ID_CU[8:7], ID_CU[9], ID_CU[10], ID_CU[11], ID_CU[12], ID_CU[13], ID_CU[17:14], ID_branch_instr,
        
    //     PC_EX, EX_CU[0], EX_CU[1], EX_CU[2], EX_CU[3], EX_CU[4], EX_CU[5], EX_CU[6],
    //     EX_CU[8:7], CC_Enable, IS[0], IS[1], IS[2], IS[3], ALU_OP,

    //     PC_MEM, OutputHandlerInstructions[0], OutputHandlerInstructions[1], OutputHandlerInstructions[2], MEM_CU, DataMemInstructions[0], DataMemInstructions[1], DataMemInstructions[2], 
    //     DataMemInstructions[4:3],

    //     WB_Register_File_Enable
    //     );
    // end

    initial begin
        // WB_Register_File_Enable = 1'b1;
        // #10;
        // WB_Register_File_Enable = 1'b0;
    end

    initial begin
        clr = 1;
        #18
        clr=0;
        PC_LE   = 1'b1;
        nPC_LE  = 1'b1;
        IF_ID_Pipeline_LE   = 1'b1;
        forwardCU = 1'b0;

        forwardMX1 = 2'b00;
        forwardMX2 = 2'b00;
        forwardMX3 = 2'b00;

        reset = 1;
        #3;
        reset = 0;
        // #30;
        // clr = 1;
        // reset = 1;
    end


endmodule