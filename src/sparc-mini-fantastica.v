`timescale 1ns / 1ns

// Phase 3 Module. This phase is just setting up the basic
// Structure and whatnot. No need to explicitly compile
// the rest of the files
`include "src/npc-pc-handler.v"
`include "src/pipeline-registers.v"
`include "src/control-unit.v"

module rom_512x8 (output reg [31:0] DataOut, input [7:0] Address);
    reg [7:0] Mem[0:511];       //512 8bit locations
    always@(Address)            //Loop when Address changes
        begin 
            DataOut = {Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]};
            // $display("\n\n\n\nLoading Instruction:\n-----------------------------------------------------\nAddress: %b | Instruction Memory: %b | time: %d\n", Address, DataOut, $time);
        end
endmodule

module phase3Tester;

    // Instruction Memory stuff
    integer fi, fo, code, i; 
    reg [7:0] data;
    reg [7:0] Addr; 
    wire [31:0] instruction;

    // Clock and Clear
    reg clr;    // Clear, aka the General Reset
    reg clk;    

    // Controls when the flow will flow and when it should stop
    reg LE;
    reg reset;
    reg enable;

    // Counters
    wire [31:0] nPC;     // The Next Program Counter
    wire [31:0] PC;      // The actual Program Counter. This counter state is at the Fetch State
    wire [31:0] PC_ID;   // The Program Counter state at the Decode Stage
    wire [31:0] PC_EX;   // The Program Counter state at the Execute State
    wire [31:0] PC_MEM;  // The Program Counter state at the Memory State

    // 
    wire [31:0] instruction_out;

    wire [3:0] ALU_OP;
    wire CC_Enable;
    wire [3:0] IS;

    // Deconstructed Signals
    wire [21:0] ID_Imm22;          // Immediate 22-bit from Decode
    wire [21:0] EX_Imm22;          // Immediate 22-bit from Execute
    wire [29:0] I29_0;             // Remaining bits from the call instruction
    wire I29_branch_instr;         // Specifies if branch is true or false, also known as 'a'
    wire [4:0] rs1;                // operand register 1
    wire [4:0] rs2;                // operand register 2
    wire [4:0] rd;                 // destiny register
    wire [3:0] cond;               // branch condition instruction

    wire MEM_Store_instr;          // Store instruction from the CU at the MEM stage

    // Instruction Signals from the Control Unit
    wire [18:0] ID_CU;
    wire [9:0]  EX_CU;
    wire        MEM_CU;

    // A register where you store stuff, propagates the 
    // instruction across all pipelines
    reg  [4:0] RD_ID = 5'b01011;
    wire [4:0] RD_EX;
    wire [4:0] RD_MEM;
    wire [4:0] RD_WB;

    wire [4:0] DataMemInstructions;
    wire [2:0] OutputHandlerInstructions;

    wire [31:0] OutputMUX;
    wire [31:0] WB_RD_out;

    wire WB_Register_File_Enable;

    // Branch Instruction from CU
    wire ID_branch_instr;
    wire [19:0] CU_SIG; // Output instructions between CU and CU_MUX
    reg S; // The signal that controls the CU_MUX

    wire [31:0] nPC4;

    // Lil module that always adds 4 to the PC
    PC_adder adder (
        .PC_in(nPC),
        .PC_out(nPC4) // nPC + 4
    );

    nPC_Reg nPC_Reg ( 
        .Q      (nPC), // Out
        .LE     (LE), 
        .clk    (clk), 
        .clr    (clr),
        .D      (nPC4) // In
    );

    PC_Reg PC_Reg ( 
        .Q      (PC), // Out
        .LE     (LE), 
        .clk    (clk), 
        .clr    (clr),
        .D      (nPC)  // In
    );

    // Instruction Memory
    rom_512x8 ram1 (
        instruction, // OUT
        PC[7:0]      // IN
    );

    // Precharging the Instruction Memory
    initial begin
        fi = $fopen("precharge/sparc-instructions-precharge.txt","r");
        Addr = 8'b00000000;
        // $display("Precharging Instruction Memory...\n---------------------------------------------\n");
        while (!$feof(fi)) begin
            // if (Addr % 4 == 0 && !$feof(fi)) $display("\n\nLoading Next Instruction...\n-------------------------------------------------------------------------");
            code = $fscanf(fi, "%b", data);
            // $display("---- %b ----\n", data);
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
        #1 clr <= 1'b0;
        #1 clk <= ~clk; 
       forever #2 clk = ~clk;
    end
    
    // My existance is to stop things so I can then let then pass
    pipeline_IF_ID IF_ID (
        .PC                             (PC),
        .instruction                    (instruction),
        .reset                          (reset), 
        .LE                             (LE), 
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
        .clk(clk),
        .clr(clr),
        .instr(instruction_out),

        .instr_signals(CU_SIG)
    );

    control_unit_mux CU_MUX (
        .ID_branch_instr_out            (ID_branch_instr),
        .CU_SIGNALS                      (ID_CU),

        .S                              (S),
        .cu_in_mux                      (CU_SIG)
    );  

    pipeline_ID_EX ID_EX (
         .PC                            (PC_ID),
         .clk                           (clk),
         .clr                           (clr),
         .ID_control_unit_instr         (ID_CU),
         .ID_RD_instr                   (RD_ID),
         .Imm22                         (ID_Imm22),

        // OUTPUT
        .PC_EX                          (PC_EX),
        .EX_IS_instr                    (IS),
        .EX_ALU_OP_instr                (ALU_OP),
        .EX_RD_instr                    (RD_EX),
        .EX_CC_Enable_instr             (CC_Enable),
        .EX_control_unit_instr          (EX_CU),
        .EX_Imm22                       (EX_Imm22)            
    );


    pipeline_EX_MEM EX_MEM (
        .clk                            (clk),
        .clr                            (clr),
        .EX_control_unit_instr          (EX_CU),
        .PC                             (PC_EX),
        .EX_RD_instr                    (RD_EX),

        .Data_Mem_instructions          (DataMemInstructions),
        .Output_Handler_instructions    (OutputHandlerInstructions),
        .MEM_control_unit_instr         (MEM_CU),
        .PC_MEM                         (PC_MEM),
        .MEM_RD_instr                   (RD_MEM),
        .Store_instr                    (MEM_Store_instr)
    );


    pipeline_MEM_WB MEM_WB (
        .clk                            (clk),
        .clr                            (clr),
        .MEM_RD_instr                   (RD_MEM),
        .MUX_out                        (PC_MEM), // (OutputMUX),



        // INPUT 
        .MEM_control_unit_instr         (MEM_CU),
        .WB_RD_instr                    (RD_WB),
        .WB_RD_out                      (WB_RD_out),
        .WB_Register_File_Enable        (WB_Register_File_Enable)
    );


    initial begin
        $dumpfile("gtk-wave-testers/sparc-mini-fantastica.vcd"); // pass this to GTK Wave to visualize better wtf is going on
        $dumpvars(0, phase3Tester);
        #52;
        $display("\n----------------------------------------------------------\nSimmulation Complete! Remember to dump this on GTK Wave and subscribe to PewDiePie...");
        $finish;
    end 

    initial  begin
        $monitor("\n\n\nTIME: %d | S: %b\n---------------------------------\
        \nPC: %d | nPC: %d\n--------------------------------------\
        \nInstruction at Decode Stage: %b | Signals at Decode Stage:\
        \n--------------------------------------------------\
        \nPC in ID stage: %d | jmpl: %b | call: %b | load: %b | Register File Enable: %b | Data MEM SE: %b | Data MEM R/W: %b | Data MEM Enable: %b\
        \nData MEM Size: %b | Condition Code Enable: %b | I31: %b | I30: %b | I24: %b | I13: %b | Alu Opcode: %b | Branch Instruction: %b\
        \n\Signals at Excecute Stage:\
        \n--------------------------------------------------\
        \nPC in EX Stage: %d | jmpl: %b | call: %b | load: %b | Register File Enable: %b | Data MEM SE: %b | Data MEM R/W: %b | Data MEM Enable: %b\
        \nData MEM Size: %b | Condition Code Enable: %b | I31: %b | I30: %b | I24: %b | I13: %b | Alu Opcode: %b\
        \n\Signals at Memory Stage:\
        \n--------------------------------------------------\
        \nPC in MEM Stage: %d | jmpl: %b | call: %b | load: %b | Register File Enable: %b | Data MEM SE: %b | Data MEM R/W: %b | Data MEM Enable: %b\
        \nData MEM Size: %b\
        \n\Signals at  Writeback Stage:\
        \n--------------------------------------------------\
        \nRegister File Enable: %b",
        $time, S,
        
        PC, nPC,

        instruction_out, 

        PC_ID, ID_CU[0], ID_CU[1], ID_CU[2], ID_CU[3], ID_CU[4], ID_CU[5], ID_CU[6],
        ID_CU[8:7], ID_CU[9], ID_CU[10], ID_CU[11], ID_CU[12], ID_CU[13], ID_CU[17:14], ID_branch_instr,
        
        PC_EX, EX_CU[0], EX_CU[1], EX_CU[2], EX_CU[3], EX_CU[4], EX_CU[5], EX_CU[6],
        EX_CU[8:7], CC_Enable, IS[0], IS[1], IS[2], IS[3], ALU_OP,

        PC_MEM, OutputHandlerInstructions[0], OutputHandlerInstructions[1], OutputHandlerInstructions[2], MEM_CU, DataMemInstructions[0], DataMemInstructions[1], DataMemInstructions[2], 
        DataMemInstructions[4:3],

        WB_Register_File_Enable
        );
    end

    initial begin
        S = 1'b0;
        #40;
        S = 1'b1;
    end

    initial begin
        LE = 1'b1;
        reset = 1;
        #3;
        reset = 0;
        #30;
        clr = 1;
        reset = 1;
    end
endmodule