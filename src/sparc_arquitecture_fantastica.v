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
 

module sparc_fantastica;
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

    // These are used to calculate the instruction that should be executed by
    // Modifying the Program Counter (PC)
    reg [31:0] TA;         // The Target Address
    wire [31:0] nPC;       // The Next Program Counter


    // Counters
    wire [31:0] PC;       // The actual Fucking Program Counter. This counter state is at the Fetch State
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

    // Instruction Signals from the Control Unit
    wire [17:0] ID_CU;
    wire [8:0]  EX_CU;
    wire        MEM_CU;

    // A register where you store stuff, propagates the 
    // instruction across all pipelines
    reg  [4:0] RD_ID = 5'b01011;
    wire [4:0] RD_EX;
    wire [4:0] RD_MEM;
    wire [4:0] RD_WB;

    // MEM pipeline output
    wire [4:0] DataMemInstructions;         // This goes on the Data Memory
    wire [2:0] OutputHandlerInstructions;   // This goes on the output handler


    // Branch Instruction from CU
    wire ID_branch_instr;
    wire [18:0] CU_SIG; // Output instructions between CU and CU_MUX
    reg S; // The signal that controls the CU_MUX

    // These Go on all muxes that are connected to the register file
    // And come from different sections of the pipeline system
    wire [31:0] ALU_OUT;   // This is also used for the PC/nPC system
    wire [31:0] MEM_OUT;   // This is the output of a MUX located in MEM stage
    // This wire goes straight to PW of the register FIle and to the muxes
    wire [31:0] WB_OUT;    // Comes from the WB stage 
    
    // This go connected to the output of the Data Memory
    wire [31:0] DataMemory_OUT; //  Goes to the MEM MUX
    wire [31:0] MEM_ALU_OUT_Address; // Address for the Data Memory in MEM stage. Also to the MEM MUX
    // This wire is basically what comes from PD back in ID Stage
    wire [31:0] MEM_Data_IN_PD; // this goes to the Data In of the Data Memory in MEM Stage. 

    // These Select which register value for the muxes to pick
    // and forward to the EX stage
    wire [1:0] forwardMX1;
    wire [1:0] forwardMX2;
    wire [1:0] forwardMX3;
    wire [1:0] forwardOutputHandler;   // Selects an option from the MUX connected to the output handler
    wire [1:0] forwardPC;  // Selects an option from the MUX that inside a nPC/PC logic box

    wire cond_branch_OUT; // Goes to nPC/PC handler, from condition handler

    // These go into the Output Handler from MEM stage
    wire [2:0] MEM_Output_Handler; // These are jmpl|call|load form MEM stage 
    // These go into the Data Memory, the thing that makes
    // MEM stage a MEM stage
    wire [4:0] MEM_Data_Memory; // These are SE|R/W|Enable|Size
    

    /////////////////////////////// No idea what to do with these
    wire [31:0] OutputMUX;
    wire [31:0] WB_RD_BACK;
    
    wire WB_Register_File_Enable;
    ///////////////////////////////

    // Register File Output
    wire [31:0] pa;
    wire [31:0] pb;
    wire [31:0] pd;


   wire [31:0] ID_MX1;
   wire [31:0] EX_MX1;
   wire [31:0] ID_MX2;
   wire [31:0] EX_MX2;
   wire [31:0] ID_MX3;
   wire [31:0] EX_MX3;


    npc_pc_handler pc_npc_H (
        .branch_out               (cond_branch_OUT),
        .ID_jmpl_instr            (ID_CU[1]),
        .ID_call_instr            (ID_CU[0]),
        .pc_handler_out_selector  (forwardPC)
    );

    // Lil module that always adds 4 to the PC
    PC_adder adder (
        .PC_in(PC),
        .PC_out(nPC)
    );

    // Initialize the nPC/PC Handler Logic Box
    PC_nPC_Register PC_reg (
        .clk        (clk),
        .clr        (clr),
        .LE         (LE),
        .nPC        (nPC),
        .ALU_OUT    (ALU_OUT),
        .TA         (TA),
        .mux_select (forwardPC),
        .OUT        (PC)
    );

    // Instruction Memory
    rom_512x8 rom (
        instruction, // OUT
        PC[7:0]      // IN
    );

    // Precharging Instruction Memory
    initial begin
        fi = $fopen("precharge/sparc-instructions-precharge.txt","r");
        Addr = 8'b00000000;
        $display("Precharging Instruction Memory...\n---------------------------------------------\n");
        while (!$feof(fi)) begin
            if (Addr % 4 == 0 && !$feof(fi)) $display("\nLoading Next Instruction...\n---------------------------------------------");
            code = $fscanf(fi, "%b", data);
            $display("---- %b ----\n", data);
            rom.Mem[Addr] = data;
            Addr = Addr + 1;
        end
        $fclose(fi);
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

    // Register File, saves operand and destiny registers
    register_file REG_FILE (
        .PA(pa),
        .PB(pb), 
        .PD(pd), 
        
        .PW(WB_OUT),
        .RW(RD_WB),
        .RA(rs1),
        .RB(rs2),
        .RD(rd),
        .LE(WB_Register_File_Enable),
        .clk(clk)
    );

    // MUXES and Friends
    mux_4x1 MX1(
        .S (forwardMX1),
        .I0(pa),
        .I1(WB_OUT),
        .I2(MEM_OUT),
        .I3(ALU_OUT),
        .Y (ID_MX1)
    );

    mux_4x1 MX2(
        .S (forwardMX2),
        .I0(pb),
        .I1(WB_OUT),
        .I2(MEM_OUT),
        .I3(ALU_OUT),
        .Y (ID_MX2)
    );

    mux_4x1 MX3(
        .S (forwardMX3),
        .I0(pd),
        .I1(WB_OUT),
        .I2(MEM_OUT),
        .I3(ALU_OUT),
        .Y (ID_MX3)
    );
    // END OF MUXES AND DEATH :3

    // I am Voldemort :)
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
        .MEM_RD_instr                   (RD_MEM)
    );

    // Data Memory
    ram_512x8 ram (
        .DataOut      (DataMemory_OUT),

        .SignExtend   (MEM_Output_Handler[0]),   
        .ReadWrite    (MEM_Output_Handler[1]),      
        .Enable       (MEM_Output_Handler[2]), 
        .Size         (MEM_Output_Handler[4:3]),
        .Address      (MEM_ALU_OUT_Address[7:0]),
        .DataIn       (MEM_Data_IN_PD)
    );

   // Precharging Data Memory
    initial begin
        fi = $fopen("precharge/sparc-instructions-2-precharge.txt","r");
        Addr = 8'b00000000;
        $display("Precharging Data Memory...\n---------------------------------------------\n");
        while (!$feof(fi)) begin
            if (Addr % 4 == 0 && !$feof(fi)) $display("\nPrecharging Next Instruction...\n---------------------------------------------");
            code = $fscanf(fi, "%b", data);
            $display("Address = %d  code = %b, time=%d", Addr, data, $time);
            ram.Mem[Addr] = data;
            Addr = Addr + 1;
        end
        $fclose(fi);
    end


    mux_4x1 MEM_MUX (
        .S (forwardOutputHandler),
        .I0(DataMemory_OUT),        // DataOut31:0
        .I1(MEM_ALU_OUT_Address),   // ALU-OUT31:0
        .I2(PC_MEM),                // PC31:0
        .I3(/**/),                  // X
        .Y (WB_RD_BACK)             // Goes to WB and back to the MUXes from ID stage
    );

    output_handler output_H (
        .MEM_jmpl_instr                 (MEM_Output_Handler[0]),
        .MEM_call_instr                 (MEM_Output_Handler[1]),
        .MEM_load_instr                 (MEM_Output_Handler[2]),
        .output_handler_out_selector    (forwardOutputHandler)
    );

    pipeline_MEM_WB MEM_WB (
        .clk                            (clk),
        .clr                            (clr),
        .MEM_RD_instr                   (RD_MEM),
        .MUX_out                        (PC_MEM), // (OutputMUX),

        // INPUT 
        .MEM_control_unit_instr         (MEM_CU),
        .WB_RD_instr                    (RD_WB),
        .WB_RD_out                      (WB_RD_BACK),
        .WB_Register_File_Enable        (WB_Register_File_Enable) 
    );

    hazard_forwarding_unit HAZARD (

    );


    initial begin
        $dumpfile("gtk-wave-testers/sparc-fantastica.vcd"); // pass this to GTK Wave to visualize better wtf is going on
        $dumpvars(0, sparc_fantastica);
        #62;
        $display("\n----------------------------------------------------------\nSimmulation Complete! Remember to dump this on GTK Wave and subscribe to PewDiePie...");
        $finish;
    end 

 
    always @(posedge clk, negedge clr) begin
        $display("TIME: %d", $time);
        $display(">>> IF Stage");
        $display("-------------------> Entering Instruction: %b | clk: %b | clr: %b | PC: %d | nPC: %d", instruction, clk, clr, PC, nPC);
        $display(">>> Control Unit");
        $display("-------------------> call: %b | jmpl: %b | load: %b | Register File Enable: %b | Data MEM SE: %b | Data MEM R/W: %b | Data MEM Enable: %b", CU_SIG[0], CU_SIG[1], CU_SIG[2], CU_SIG[3], CU_SIG[4], CU_SIG[5], CU_SIG[6]);
        $display("                     Data MEM Size: %b | Condition Code Enable: %b | I31: %b | I30: %b | I24: %b | I13: %b | Alu Opcode: %b | Branch Instruction: %b", CU_SIG[8:7], CU_SIG[9], CU_SIG[10], CU_SIG[11], CU_SIG[12], CU_SIG[13], CU_SIG[17:14], CU_SIG[18]);
        $display(">>> ID Stage");
        $display("-------------------> Current Instruction: %b | Imm22: %b | Rs1: %b | Rs2: %b | Rd: %b | branch cond instruction: %b | RD: %b | PC: %d", instruction_out, ID_Imm22, rs1, rs2, rd, I29_branch_instr, RD_ID, PC_ID);
        $display("                     call: %b | jmpl: %b | load: %b | Register File Enable: %b | Data MEM SE: %b | Data MEM R/W: %b | Data MEM Enable: %b", ID_CU[0], ID_CU[1], ID_CU[2], ID_CU[3], ID_CU[4], ID_CU[5], ID_CU[6]);
        $display("                     Data MEM Size: %b | Condition Code Enable: %b | I31: %b | I30: %b | I24: %b | I13: %b | Alu Opcode: %b | Branch Instruction: %b", ID_CU[8:7], ID_CU[9], ID_CU[10], ID_CU[11], ID_CU[12], ID_CU[13], ID_CU[17:14], ID_CU[18]);        
        
        $display(">>> EX Stage");
        $display("-------------------> ALU Opcode: %b | Source Operand Handler Is: %b | Imm22: %b | Condition Code Enable: %b | RD: %b | PC: %d", ALU_OP, IS, EX_Imm22, CC_Enable, RD_EX, PC_EX);
        $display("                     call: %b | jmpl: %b | load: %b | Register File Enable: %b | Data MEM SE: %b | Data MEM R/W: %b | Data MEM Enable: %b", EX_CU[0], EX_CU[1], EX_CU[2], EX_CU[3], EX_CU[4], EX_CU[5], ID_CU[6]);
        $display("                     Data Mem Size: %b", EX_CU[8:7]);
        $display(">>> MEM Stage");
        $display("-------------------> Data MEM SE: %b | Data MEM R/W: %b | Data MEM Enable: %b | Data MEM Size: %b | jmpl: %b | call: %b | load: %b | register file enable: %b | RD: %b | PC: %d", DataMemInstructions[0], DataMemInstructions[1], DataMemInstructions[2], DataMemInstructions[4:3], OutputHandlerInstructions[0], OutputHandlerInstructions[1], OutputHandlerInstructions[2], MEM_CU, RD_MEM, PC_MEM);
        $display(">>> WB Stage");
        $display("-------------------> Data MEM Output: %b | Register File Enable: %b | RD: %b", WB_Register_File_Enable, WB_Register_File_Enable, WB_RD_BACK);
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
    end
endmodule

