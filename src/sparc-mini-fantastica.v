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
            $display("\n\n\n\nLoading Instruction:\n-----------------------------------------------------\nAddress: %b | Instruction Memory: %b | time: %d\n", Address, DataOut, $time);
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
    reg S; // To trigger the CU or something idfk

    // Counters
    wire [31:0] PC;
    wire [31:0] nPC;
    wire [31:0] PC_ID;
    wire [31:0] PC_EX;
    wire [31:0] PC_MEM;

    // 
    wire [31:0] instruction_out;

    wire [3:0] ALU_OP;
    wire CC_Enable;
    wire [3:0] IS;

    wire [21:0] Imm22;
    wire [21:0] EX_Imm22;
    wire [29:0] I29_0;
    wire I29_branch_instr;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [3:0] cond;

    wire [18:0] ID_CU;
    wire [8:0] EX_CU;
    wire       MEM_CU;

    reg  [4:0] RD_ID = 5'b01011;
    wire [4:0] RD_EX;
    wire [4:0] RD_MEM;
    wire [4:0] RD_WB;

    wire [4:0] DataMemInstructions;
    wire [2:0] OutputHandlerInstructions;

    wire [31:0] OutputMUX;
    wire [31:0] WB_RD_out;

    wire WB_Register_File_Enable;

    // These are more for phase 4
    reg [1:0] PC_MUX = 2'b00;
    reg [31:0] TA;
    reg [31:0] ALU_OUT;

    PC_adder adder (
        .PC_in(PC),
        .PC_out(nPC)
    );

    PC_nPC_Register PC_reg (
        .clk        (clk),
        .clr        (clr),
        .LE         (LE),
        .nPC        (nPC),
        .ALU_OUT    (ALU_OUT),
        .TA         (TA),
        .mux_select (PC_MUX),
        .OUT        (PC)
    );


    rom_512x8 ram1 (
        instruction, // OUT
        PC[7:0]      // IN
    );

    // Precharging the Instruction Memory
    initial begin
        fi = $fopen("precharge/sparc-instructions-precharge.txt","r");
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
        #1 clr <= 1'b0;
        #1 clk <= ~clk; 

        // repeat(2) #2 clk = ~clk;
        // clr <= 1'b0;
       forever #2 clk = ~clk;
    end


    pipeline_IF_ID IF_ID (
        .PC                             (PC),
        .instruction                    (instruction),
        .reset                          (reset), 
        .LE                             (LE), 
        .clk                            (clk), 
        .clr                            (clr),

        .PC_ID_out                      (PC_ID),
        .I21_0                          (Imm22),
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

        .instr_signals(ID_CU)
    );

    pipeline_ID_EX ID_EX (
         .PC                            (PC_ID),
         .clk                           (clk),
         .clr                           (clr),
         .ID_control_unit_instr         (ID_CU[17:0]),
         .ID_RD_instr                   (RD_ID),
         .Imm22                         (Imm22),

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
        .MEM_RD_instr                   (RD_MEM)
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
        $dumpvars(0,phase3Tester);
        #52;
        $display("\n----------------------------------------------------------\nSimmulation Complete! Remember to dump this on GTK Wave and subscribe to PewDiePie...");
        $finish;
    end 
 
    always @(posedge clk, negedge clr) begin

        $display("\n---------------------------------------------- reset: %b | TIME: %d\n", reset, $time);
        $display(">>> IF Stage");
        $display("-------------------> Instruction that is Entering: %b | clk: %b | clr: %b | PC: %d | nPC: %d", instruction, clk, clr, PC, nPC);
        // $display(">>> Control Unit");
        // $display("-------------------> call: %b | jmpl: %b | load: %b | Register File Enable: %b | Data MEM SE: %b | Data MEM R/W: %b | Data MEM Enable: %b", ID_CU[0], ID_CU[1], ID_CU[2], ID_CU[3], ID_CU[4], ID_CU[5], ID_CU[6]);
        // $display("                     Data MEM Size: %b | Condition Code Enable: %b | I31: %b | I30: %b | I24: %b | I13: %b | Alu Opcode: %b | Branch Instruction: %b", ID_CU[8:7], ID_CU[9], ID_CU[10], ID_CU[11], ID_CU[12], ID_CU[13], ID_CU[17:14], ID_CU[18]);
        $display(">>> ID Stage");
        $display("-------------------> Instruction that is Decoded: %b | Imm22: %b | Rs1: %b | Rs2: %b | Rd: %b | RD: %b | PC: %d", instruction_out, Imm22, rs1, rs2, rd, RD_ID, PC_ID);
        $display("                     call: %b | jmpl: %b | load: %b | Register File Enable: %b | Data MEM SE: %b | Data MEM R/W: %b | Data MEM Enable: %b | branch cond instruction: %b", ID_CU[0], ID_CU[1], ID_CU[2], ID_CU[3], ID_CU[4], ID_CU[5], ID_CU[6], I29_branch_instr);
        $display("                     Data MEM Size: %b | Condition Code Enable: %b | I31: %b | I30: %b | I24: %b | I13: %b | Alu Opcode: %b | Branch Instruction: %b ", ID_CU[8:7], ID_CU[9], ID_CU[10], ID_CU[11], ID_CU[12], ID_CU[13], ID_CU[17:14], ID_CU[18]);        
        $display(">>> EX Stage");
        $display("-------------------> ALU Opcode: %b | Source Operand Handler Is: %b | Imm22: %b | Condition Code Enable: %b | RD: %b | PC: %d", ALU_OP, IS, EX_Imm22, CC_Enable, RD_EX, PC_EX);
        $display("                     call: %b | jmpl: %b | load: %b | Register File Enable: %b | Data MEM SE: %b | Data MEM R/W: %b | Data MEM Enable: %b", EX_CU[0], EX_CU[1], EX_CU[2], EX_CU[3], EX_CU[4], EX_CU[5], ID_CU[6]);
        $display("                     Data Mem Size: %b", EX_CU[8:7]);
        $display(">>> MEM Stage");
        $display("-------------------> Data MEM SE: %b | Data MEM R/W: %b | Data MEM Enable: %b | Data MEM Size: %b | jmpl: %b | call: %b | load: %b | register file enable: %b | RD: %b | PC: %d", DataMemInstructions[0], DataMemInstructions[1], DataMemInstructions[2], DataMemInstructions[4:3], OutputHandlerInstructions[0], OutputHandlerInstructions[1], OutputHandlerInstructions[2], MEM_CU, RD_MEM, PC_MEM);
        $display(">>> WB Stage");
        $display("-------------------> Data MEM Output: %b | Register File Enable: %b | RD: %b", WB_Register_File_Enable, WB_Register_File_Enable, RD_WB);
    end

    // initial begin
    //     $monitor("Instruction that is processed: %b || clk: %b | clr: %b | PC: %d | nPC: %d | call: %b | jmpl: %b | load: %b | Register File Enable: %b | Data MEM SE: %b | Data MEM R/W: %b | Data MEM Enable: %b \nTIME: %d | reset: %b\nI31: %b | I30: %b | I24: %b | I13: %b\n-----------------------------------------", instruction_out, clk, clr, PC, nPC, ID_CU[0], ID_CU[1], ID_CU[2], ID_CU[3], ID_CU[4], ID_CU[5], ID_CU[6], $time, reset, ID_CU[10], ID_CU[11], ID_CU[12], ID_CU[13]);
    // end
    // initial begin
    //     $monitor("IMM ID: %b | IMM EX: %b | clk: %b | clr: %b | PC: %d | instruction: %b ", Imm22, EX_Imm22, clk, clr, PC, instruction, $time);
    // end

    initial begin
        LE = 1'b1;
        reset = 1;
        #3;
        reset = 0;
    end

endmodule