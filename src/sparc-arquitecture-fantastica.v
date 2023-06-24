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
    reg [36:0] dataR; // for data register
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
    wire [31:0] TA;         // The Target Address
    wire [31:0] ID_Imm22Extended;
    wire [31:0] CallJmplAddress;
    wire [31:0] CallJmplAddressMultiplied;


    // Multiplexer outputs
    wire [1:0] forwardMX1;              // Multiplexer selection for Mux 1 of ID Stage
    wire [1:0] forwardMX2;              // Multiplexer selection for Mux 2 of ID Stage
    wire [1:0] forwardMX3;              // Multiplexer selection for Mux 3 of ID Stage

    wire [1:0] forwardOutputHandler;    // Selects an option from the MUX connected to the output handler
    wire [1:0] forwardPC;               // Selects an option from the MUX that inside a nPC/PC logic box
    
    wire forwardCU;
    // reg forwardCU;

    // Instruction Signals from the Control Unit
    wire [19:0] CU_SIG;     // Unslized Control Unit instructions between CU and CU_MUX
    wire [18:0] ID_CU;      // Unslized Control Unit instructions at the ID Stage
    wire [9:0]  EX_CU;      // Unslized Control Unit instructions at the EX Stage
    wire  MEM_CU;     // Unslized Control Unit instructions at the MEM Stage

    // Outputs of Components
    wire [31:0] ALU_OUT;        // ALU Output, used for the PC/nPC system
    wire [31:0] MEM_OUT;        // This is the output of a MUX located in MEM stage
    wire [31:0] WB_OUT;         // Writeback instruction. Goe to PW of the Register File and to the Muxes of ID Stage
    // reg [31:0] WB_OUT;
    wire [31:0] PC_MUX_OUT;     // Output between the PC and the PC_MUX

    // Controls when the flow will flow and when it should stop
    wire PC_LE;
    wire nPC_LE;
    wire IF_ID_Pipeline_LE;

    wire reset;    // controls PC, nPC and IF/ID pipeline register

    // reg cond_branch_OUT = 0; // Goes to nPC/PC handler, from condition handler
    wire cond_branch_OUT;
    wire [3:00] CC_COND;


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
    wire [31:0] MEM_ALU_OUT_Address;
    wire [31:0] DataMemory_OUT;
    wire [31:0] MEM_MX3;

    // ------------------- In WB Stage
    // --------------------------------------------------------------------------------------------
    wire WB_Register_File_Enable;
    wire [4:0] RD_WB;
    // reg WB_Register_File_Enable;
    // reg [4:0] RD_WB;



    reg [31:0] TempR5;


// -------------- M O D U L E  I N S T A N C I A T I O N -------------------- //

    // Adder, updates the PC
    PC_adder PC_adder (
        .PC_in(PC_MUX_OUT),
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
    rom_512x8 ROM (
        instruction, // OUT
        PC[7:0]      // IN
    );


    // Data Memory
    ram_512x8 RAM (
        .DataOut                        (DataMemory_OUT),
        .SignExtend                     (DataMemInstructions[0]),   
        .ReadWrite                      (DataMemInstructions[1]),      
        .Enable                         (DataMemInstructions[2]), 
        .Size                           (DataMemInstructions[4:3]),
        .Address                        (MEM_ALU_OUT_Address[7:0]),
        .DataIn                         (MEM_MX3)
    );


    // Precharging the Instruction Memory and Data Memory
    initial begin
        fi = $fopen("precharge/sparc-instructions-2-precharge.txt","r");
        Addr = 8'b00000000;
        // $display("Precharging Instruction Memory...\n---------------------------------------------\n");
        while (!$feof(fi)) begin
            // if (Addr % 4 == 0 && !$feof(fi)) $display("\n\nLoading Next Instruction...\n-------------------------------------------------------------------------");
            code = $fscanf(fi, "%b", data);
            // $display("---- %b ----     Address: %d\n", data, Addr);
            ROM.Mem[Addr] = data;
            RAM.Mem[Addr] = data;
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
        #1 clr <= 1'b0;
        #1 clk <= ~clk; 
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
        .I29_0                          (I29_0),   // Displacement, used on call instructions
        .I29_branch_instr               (I29_branch_instr), // also known as 'a'
        .I18_14                         (rs1),
        .I4_0                           (rs2),
        .I29_25                         (rd),
        .I28_25                         (cond),
        .instruction_out                (instruction_out) 
    );

    SignExtender SignExtender (
        .extended               (ID_Imm22Extended),
        .extend                 (ID_Imm22)
    );

    mux_2x1 TargetAddressMUX (
        .Y                      (CallJmplAddress), // Its either used by call instructions or jmpl instructions. I think branch instructions use this
        .S                      (ID_branch_instr),
        .I0                     ({2'b00, {I29_0}}),
        .I1                     (ID_Imm22Extended)
    );

    multiplierBy4 multiplierBy4 (
        .multipliedOut          (CallJmplAddressMultiplied),
        .in                     (CallJmplAddress)
    );

    adder32Bit adder32Bit (
        .out (TA),
        .a   (CallJmplAddressMultiplied),
        .b   (PC_ID)
    );

    // ID_jmpl_instr;              // 1
    // ID_call_instr;              // 2
    // ID_load_instr;              // 3
    // ID_store_instr;             // 4
    // ID_register_file_Enable;    // 5
    // ID_data_mem_SE;             // 6
    // ID_data_mem_RW;             // 7
    // ID_data_mem_Enable;         // 8
    // [1:0] ID_data_mem_Size;     // 9,10
    // CC_Enable;                  // 11
    // I31;                        // 12
    // I30;                        // 13
    // I24;                        // 14
    // I13;                        // 15
    // [3:0] ID_ALU_OP_instr;      // 16,17,18,19
    // ID_branch_instr;            // 20
    control_unit control_unit (
        .clk                            (clk),
        .clr                            (clr),
        .instr                          (instruction_out),
        .instr_signals                  (CU_SIG)
    );

    control_unit_mux control_unit_mux (
        .ID_branch_instr_out            (ID_branch_instr), // Branch Instruction (20), to reset and condition handler
        .CU_SIGNALS                      (ID_CU),

        .S                              (forwardCU),
        .cu_in_mux                      (CU_SIG)
    );  

    reset_handler reset_handler (
        .reset_out                  (reset),

        .system_reset               (clr),
        .ID_branch_instr            (ID_branch_instr),
        .condition_handler_instr    (cond_branch_OUT),
        .a                          (I29_branch_instr)
    );

    // Register File, saves operand and destiny registers
    register_file register_file (
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

    mux_4x1 MX1 (
        .S                              (forwardMX1),
        .I0                             (pa),               // File Register value selected by rs1
        .I1                             (ALU_OUT),          // EX_RD
        .I2                             (MEM_OUT),          // MEM_RD
        .I3                             (WB_OUT),           // WB_RD 
        .Y                              (ID_MX1)            // MUX OUTPUT
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

        .S      (ID_CU[1]),     // ID_CALL_INSTR
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
        .EX_CC_Enable_instr             (CC_Enable), // to psr and condition handlers
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

    mux_condtion mux_condtion (
        .S                              (CC_Enable), // It acts as a selector
        .I0                             (PSR_OUT),
        .I1                             (ALU_FLAGS),
        .Y                              (CC_COND)
    );

    condition_handler condition_handler (
        .flags                          (CC_COND),
        .cond                           (cond),
        .ID_branch_instr                (ID_branch_instr),
        .branch_out                     (cond_branch_OUT)
    );

    hazard_forwarding_unit hazard_forwarding_unit (
        .forwardMX1                     (forwardMX1),
        .forwardMX2                     (forwardMX2),
        .forwardMX3                     (forwardMX3),
        
        .nPC_LE                         (nPC_LE),
        .PC_LE                          (PC_LE),
        .IF_ID_LE                       (IF_ID_Pipeline_LE),
        
        .CU_S                           (forwardCU), 
        
        .EX_Register_File_Enable        (EX_CU[4]),
        .MEM_Register_File_Enable       (MEM_CU),
        .WB_Register_File_Enable        (WB_Register_File_Enable),
        
        .EX_RD                          (RD_EX),
        .MEM_RD                         (RD_MEM),
        .WB_RD                          (RD_WB),
        
        .ID_rs1                         (rs1),
        .ID_rs2                         (rs2),
        .ID_rd                          (rd),
        .EX_load_instr                  (EX_CU[2]), // the load instruction, check the EX pipeline and CU
        .ID_store_instr                 (ID_CU[3])
    );

    // -|-|-|-|-|-|-|-|----- M E M  S T A G E -----|-|-|-|-|-|-|-|- //

    pipeline_EX_MEM pipeline_EX_MEM (
        // INPUTS
        .clk                            (clk),
        .clr                            (clr),
        .EX_control_unit_instr          (EX_CU),
        .PC                             (PC_EX),
        .EX_RD_instr                    (RD_EX),
        .EX_ALU_OUT                     (ALU_OUT),
        .EX_MX3                         (EX_MX3),

        // OUTPUTS
        .Data_Mem_instructions          (DataMemInstructions),
        .Output_Handler_instructions    (OutputHandlerInstructions),
        .MEM_control_unit_instr         (MEM_CU),
        .PC_MEM                         (PC_MEM),
        .MEM_RD_instr                   (RD_MEM),
        .Store_instr                    (MEM_Store_instr),
        .MEM_ALU_OUT                    (MEM_ALU_OUT_Address),
        .MEM_MX3                        (MEM_MX3)
    );


    mux_4x1 OutputHandlerMUX (
        .S (forwardOutputHandler),
        .I0(PC_MEM),        // DataOut31:0  -> 00
        .I1(MEM_ALU_OUT_Address),   // ALU-OUT31:0  -> 01
        .I2(DataMemory_OUT),                // PC31:0       -> 10
        .I3(/**/),                  // X
        .Y (MEM_OUT)                // Goes to WB and back to the MUXes from ID stage
    );

    output_handler output_handler (
        .MEM_jmpl_instr                 (OutputHandlerInstructions[0]),
        .MEM_call_instr                 (OutputHandlerInstructions[1]),
        .MEM_load_instr                 (OutputHandlerInstructions[2]),
        .output_handler_out_selector    (forwardOutputHandler)
    );

// -|-|-|-|-|-|-|-|----- W B  S T A G E -----|-|-|-|-|-|-|-|- //

    pipeline_MEM_WB pipeline_MEM_WB (
        // INPUT
        .clk                            (clk),
        .clr                            (clr),
        .MEM_RD_instr                   (RD_MEM),
        .MUX_out                        (MEM_OUT), // (OutputMUX),
        .MEM_control_unit_instr         (MEM_CU),   // MEM Register File Enable

        // OUTPUT 
        .WB_RD_instr                    (RD_WB),
        .WB_RD_out                      (WB_OUT),
        .WB_Register_File_Enable        (WB_Register_File_Enable) 
    );

    // ------------------------- T E S T E R S --------------------------- //
    initial begin
        $dumpfile("gtk-wave-testers/sparc-v8-architecture.vcd"); // pass this to GTK Wave to visualize better wtf is going on
        $dumpvars(0, sparcV8ArchitectureTester);
        #100;
        $display("\n----------------------------------------------------------\nSimmulation Complete! Remember to dump this on GTK Wave and subscribe to PewDiePie...");
        $finish;
    end 

    initial begin
        $monitor("\n\n\nTIME: %d\n---------------------------------\
        \nPC: %d\n--------------------------------------\
        \nR5: %d | R6: %d\
        \nR16: %d | R17: %d\
        \nR18: %d\
        \n--------------------------------------------------",
        $time,
        PC,
        register_file.Q5, register_file.Q6, register_file.Q16, register_file.Q17, register_file.Q18);
    end

    initial begin
        #90;
        $display("---------->>>>>> LOC 59", RAM.Mem[59]);
    end
endmodule