

/*
 * Module: pipeline_IF_ID
 * 
 * Description:
 *   This module represents the pipeline stage between the Instruction Fetch (IF) and Instruction Decode (ID) stages.
 *   It is responsible for forwarding relevant signals from the IF stage to the ID stage.
 * 
 * Inputs:
 *   - reset: Asynchronous reset signal
 *   - LE: Little-endian signal
 *   - clk: Clock signal
 *   - clr: Clear signal
 *   - PC: Program Counter value
 *   - instruction: Instruction value
 * 
 * Outputs:
 *   - PC_ID_out: Program Counter output for the ID stage
 *   - I21_0: Imm22 value
 *   - I29_0: Value for an unspecified purpose
 *   - I29_branch_instr: Branch instruction value for Phase 4
 *   - I18_14: rs1 value
 *   - I4_0: rs2 value
 *   - I29_25: rd value
 *   - I28_25: cond value for Branch
 *   - instruction_out: Output instruction value
 * 
 * Registers:
 *   - PC_ID_out_reg: Register for storing the PC value for the ID stage
 *   - I21_0_reg: Register for storing the Imm22 value
 *   - I29_0_reg: Register for storing the value for an unspecified purpose
 *   - I29_branch_instr_reg: Register for storing the Branch instruction value for Phase 4
 *   - I18_14_reg: Register for storing the rs1 value
 *   - I4_0_reg: Register for storing the rs2 value
 *   - I29_25_reg: Register for storing the rd value
 *   - I28_25_reg: Register for storing the cond value for Branch
 *   - instruction_reg: Register for storing the instruction value
 * 
 * Operation:
 *   - On the positive edge of the clock and when the clear signal is low, the registers in
 *     the module are updated based on the inputs.
 *   - If the reset signal is high, the registers are reset to their default values.
 *   - The relevant signals are forwarded to the output ports.
 *   - The module also displays the output signals using $display.
 */
module pipeline_IF_ID (
    input wire         reset, LE, clk, clr,
    input wire [31:0]  PC,
    input wire [31:0]  instruction,

    output wire [31:0] PC_ID_out,        // PC
    output wire [21:0] I21_0,            // Imm22
    output wire [29:0] I29_0,            // Can't remember, don't ask
    output wire        I29_branch_instr, // For Branch, part of Phase 4
    output wire [4:0]  I18_14,            // rs1
    output wire [4:0]  I4_0,              // rs2
    output wire [4:0]  I29_25,            // rd
    output wire [3:0]  I28_25,            // cond, for Branch
    output wire [31:0] instruction_out   
    );

    reg [31:0] PC_ID_out_reg;
    reg [21:0] I21_0_reg;
    reg [29:0] I29_0_reg;
    reg I29_branch_instr_reg;
    reg [4:0] I18_14_reg;
    reg [4:0] I4_0_reg;
    reg [4:0] I29_25_reg;
    reg [3:0] I28_25_reg;
    reg [31:0] instruction_reg;
    
    always@(posedge clk, negedge clr) begin
        if (clk  == 1 && clr == 0) begin
            if (reset) begin
                PC_ID_out_reg            = 31'b0;
                I21_0_reg                = 21'b0;
                I29_0_reg                = 29'b0;
                I29_branch_instr_reg     = 32'b0;
                I18_14_reg               = 32'b0;
                I4_0_reg                 = 5'b0;
                I29_25_reg               = 5'b0;
                I28_25_reg               = 5'b0;
                instruction_reg          = 32'b0;
            end else begin
                PC_ID_out_reg            = PC;
                I21_0_reg                = instruction[21:0];
                I29_0_reg                = instruction[29:0];
                I29_branch_instr_reg     = instruction[29];
                I18_14_reg               = instruction[18:14];
                I4_0_reg                 = instruction[4:0];
                I29_25_reg               = instruction[29:25];
                I28_25_reg               = instruction[28:25]; 
                instruction_reg          = instruction;
            end
        end
    $display(">>> IF/ID Output Signals:\n------------------------------------------");
    $display("PC: %d | imm: %b | I29: %b | branch: %b | rs1: %b | rs2: %b | rd: %b | cond: %b | inst: %b\n\n", 
             PC_ID_out_reg, I21_0_reg, I29_0_reg, I29_branch_instr_reg, I18_14_reg, I4_0_reg, I29_25_reg, I28_25_reg, instruction_reg);
    end
    assign PC_ID_out         = PC_ID_out_reg;       
    assign I21_0             = I21_0_reg;   
    assign I29_0             = I29_0_reg;   
    assign I29_branch_instr  = I29_branch_instr_reg;           
    assign I18_14            = I18_14_reg;   
    assign I4_0              = I4_0_reg;
    assign I29_25            = I29_25_reg;   
    assign I28_25            = I28_25_reg;   
    assign instruction_out   = instruction_reg;     
endmodule


/*
 * Module: pipeline_ID_EX
 * 
 * Description:
 *   This module represents the pipeline stage between the Instruction Decode (ID) and
 *   Execute (EX) stages. It is responsible for forwarding relevant signals from the ID
 *   stage to the EX stage.
 * 
 * Inputs:
 *   - reset: Asynchronous reset signal
 *   - clk: Clock signal
 *   - clr: Clear signal
 *   - ID_control_unit_instr: Control unit instructions from the ID stage
 *   - PC: Program Counter value
 *   - ID_RD_instr: RD instructions from the ID stage
 * 
 * Outputs:
 *   - PC_EX_out: Program Counter output for the EX stage
 *   - EX_IS_instr: Instruction bits used by the operand handler in the EX stage
 *   - EX_ALU_OP_instr: Opcode used by the ALU in the EX stage
 *   - EX_RD_instr: RD instructions for the EX stage
 *   - EX_CC_Enable_instr: Control signal for enabling condition code updates in the EX stage
 *   - EX_control_unit_instr: Remaining control unit instructions for the EX stage
 * 
 * Registers:
 *   - PC_ID_out_reg: Register for storing the PC value from the ID stage
 *   - EX_IS_instr_reg: Register for storing the instruction bits used by the operand handler
 *   - EX_ALU_OP_instr_reg: Register for storing the ALU opcode
 *   - EX_RD_instr_reg: Register for storing the RD instructions
 *   - EX_CC_Enable_instr_reg: Register for storing the control signal for enabling condition code updates
 *   - EX_control_unit_instr_reg: Register for storing the remaining control unit instructions
 * 
 * Operation:
 *   - On the positive edge of the clock and when the clear signal is low, the registers in
 *     the module are updated based on the inputs.
 *   - If the reset signal is high, the registers are reset to their default values.
 *   - The relevant signals are forwarded to the output ports.
 *   - The module also displays the output signals using $display.
 */
module pipeline_ID_EX(
    input  wire reset, clk, clr,
    input  wire [17:0] ID_control_unit_instr,      // Control Unit Instructions
    input  wire [31:0] PC,
    input  wire [4:0]  ID_RD_instr,

    input [21:0] IMM22,     // These will exist if op == 00 (SETHI in this case) 
    input [31:0] MX1,       // Source register output RS1, from the ID stage
    input [31:0] MX2,       // Source register output RS2, from the ID stage
    input [31:0] MX3,       // Destiny register output RD, from the ID stage

    output wire [31:0] PC_EX_out,                  // PC
    output wire [3:0]  EX_IS_instr,                // The bits used by the operand handler            
    output wire [3:0]  EX_ALU_OP_instr,            // The opcode used by the ALU 
    output wire [4:0]  EX_RD_instr,                 // 
    output wire        EX_CC_Enable_instr,

    output wire [8:0]  EX_control_unit_instr,      // The rest of the control unit instructions that don't need to be deconstructed

    output [21:0] EX_IM22,
    output [31:0] EX_MX1,
    output [31:0] EX_MX2,
    output [31:0] EX_MX3
    );

    reg [31:0] PC_ID_out_reg;
    reg [3:0]  EX_IS_instr_reg;
    reg [3:0]  EX_ALU_OP_instr_reg;
    reg [8:0]  EX_control_unit_instr_reg;
    reg [5:0]  EX_RD_instr_reg;
    reg        EX_CC_Enable_instr_reg;

    always@(posedge clk, negedge clr) begin
        if (clk  == 1 && clr == 0) begin
            if (reset) begin
                PC_ID_out_reg               = 32'b0;
                EX_IS_instr_reg             = 4'b0;
                EX_ALU_OP_instr_reg         = 4'b0;
                EX_control_unit_instr_reg   = 11'b0;
                EX_RD_instr_reg             = 5'b0;
                EX_CC_Enable_instr_reg      = 1'b0;
            end else begin
                PC_ID_out_reg               = PC;
                EX_IS_instr_reg             = ID_control_unit_instr[13:10];
                EX_ALU_OP_instr_reg         = ID_control_unit_instr[17:14];
                EX_RD_instr_reg             = EX_RD_instr;
                EX_CC_Enable_instr_reg      = ID_control_unit_instr[9];
                
                EX_control_unit_instr_reg   = ID_control_unit_instr[8:0];
            end
        end

    $display(">>> ID/EX Output Signals:\n------------------------------------------");
    $display("PC: %d | EX_IS: %b | EX_ALU: %b | EX_control: %b | EX_RD: %b | EX_CC: %b\n", 
            PC_ID_out_reg, EX_IS_instr_reg, EX_ALU_OP_instr_reg, EX_control_unit_instr_reg, EX_RD_instr_reg, EX_CC_Enable_instr_reg);
    end

    assign  PC_EX_out                   = PC_ID_out_reg;
    assign  EX_IS_instr                 = EX_IS_instr_reg;
    assign  EX_ALU_OP_instr             = EX_ALU_OP_instr_reg;
    assign  EX_control_unit_instr       = EX_control_unit_instr_reg;
    assign  EX_RD_instr                 = EX_RD_instr_reg;
    assign  EX_CC_Enable_instr          = EX_CC_Enable_instr_reg;
endmodule


/*
 * Module: pipeline_EX_MEM
 * 
 * Description:
 *   This module represents the pipeline stage between the Execute (EX) and Memory (MEM) stages.
 *   It is responsible for forwarding relevant signals from the EX stage to the MEM stage.
 * 
 * Inputs:
 *   - reset: Asynchronous reset signal
 *   - clk: Clock signal
 *   - clr: Clear signal
 *   - EX_control_unit_instr: Control unit instructions from the EX stage
 *   - PC: Program Counter value
 *   - EX_RD_instr: RD instructions from the EX stage
 * 
 * Outputs:
 *   - Data_Mem_instructions: Instructions for the Data Memory stage
 *   - Output_Handler_instructions: Instructions for the Output Handler stage
 *   - MEM_control_unit_instr: Control unit instruction for the MEM stage
 *   - PC_MEM_out: Program Counter output for the MEM stage
 *   - MEM_RD_instr: RD instructions for the MEM stage
 * 
 * Registers:
 *   - Data_Mem_instructions_reg: Register for storing the Data Memory instructions
 *   - Output_Handler_instructions_reg: Register for storing the Output Handler instructions
 *   - MEM_control_unit_instr_reg: Register for storing the MEM control unit instruction
 *   - MEM_RD_instr_reg: Register for storing the MEM RD instructions
 *   - PC_MEM_out_reg: Register for storing the PC value for the MEM stage
 * 
 * Operation:
 *   - On the positive edge of the clock and when the clear signal is low, the registers in
 *     the module are updated based on the inputs.
 *   - If the reset signal is high, the registers are reset to their default values.
 *   - The relevant signals are forwarded to the output ports.
 *   - The module also displays the output signals using $display.
 */
module pipeline_EX_MEM(
    input wire reset,  clk, clr,
    input wire [8:0]   EX_control_unit_instr,
    input wire [31:0]  PC,
    input wire [4:0]   EX_RD_instr,

    input [32:0] EX_ALU_OUT,
    input [32:0] EX_MX3,

    output wire [3:0]  Data_Mem_instructions,
    output wire [2:0]  Output_Handler_instructions,
    output wire        MEM_control_unit_instr,
    output wire [31:0] PC_MEM_out,
    output wire [4:0]  MEM_RD_instr
);

    reg [3:0]   Data_Mem_instructions_reg;
    reg [2:0]   Output_Handler_instructions_reg;
    reg         MEM_control_unit_instr_reg;
    reg [4:0]   MEM_RD_instr_reg;
    reg [31:0]  PC_MEM_out_reg;


    // About EX_control_unit_instr
    // from 3:0 its the jumpl, call, 

    always@(posedge clk, negedge clr) begin
        if (clk  == 1 && clr == 0) begin
            if (reset) begin
                Data_Mem_instructions_reg           = 4'b0;
                Output_Handler_instructions_reg     = 3'b0;
                MEM_control_unit_instr_reg          = 1'b0;
                MEM_RD_instr_reg                    = 5'b0;
                PC_MEM_out_reg                      = 32'b0;
            end else begin
                Data_Mem_instructions_reg           = EX_control_unit_instr[8:4];
                Output_Handler_instructions_reg     = EX_control_unit_instr[2:0];
                MEM_control_unit_instr_reg          = EX_control_unit_instr[3];
                MEM_RD_instr_reg                    = EX_RD_instr;
                PC_MEM_out_reg                      = PC;
            end
        end
    
    $display(">>> EX/MEM Output Signals:\n------------------------------------------");
    $display("DataInst: %b | OutHandler: %b | MEM_control: %b | MEM_RD: %b | PC_MEM: %b\n", 
             Data_Mem_instructions_reg, Output_Handler_instructions_reg, MEM_control_unit_instr_reg, MEM_RD_instr_reg, PC_MEM_out_reg);
    
    end
    assign Data_Mem_instructions        = Data_Mem_instructions_reg;
    assign Output_Handler_instructions  = Output_Handler_instructions_reg;
    assign MEM_control_unit_instr       = MEM_control_unit_instr_reg;
    assign MEM_RD_instr                 = MEM_RD_instr_reg;
    assign PC_MEM_out                   = PC_MEM_out_reg;    
endmodule


/*
 * Module: pipeline_MEM_WB
 * 
 * Description:
 *   This module represents the pipeline stage between the Memory Access (MEM) and Write Back (WB) stages.
 *   It is responsible for forwarding relevant signals from the MEM stage to the WB stage.
 * 
 * Inputs:
 *   - reset: Asynchronous reset signal
 *   - clk: Clock signal
 *   - clr: Clear signal
 *   - MEM_RD_instr: Instruction from the MEM stage
 *   - MUX_out: Output from the MUX
 *   - MEM_control_unit_instr: Control unit instruction from the MEM stage
 * 
 * Outputs:
 *   - WB_RD_instr: Instruction forwarded to the WB stage
 *   - WB_RD_out: Output forwarded to the WB stage
 *   - WB_Register_File_Enable: Register file enable signal forwarded to the WB stage
 * 
 * Registers:
 *   - WB_RD_instr_reg: Register for storing the WB_RD_instr value
 *   - WB_RD_out_reg: Register for storing the WB_RD_out value
 *   - WB_Register_File_Enable_reg: Register for storing the WB_Register_File_Enable value
 * 
 * Operation:
 *   - On the positive edge of the clock and when the clear signal is low, the registers in
 *     the module are updated based on the inputs.
 *   - If the reset signal is high, the registers are reset to their default values.
 *   - The relevant signals are forwarded to the output ports.
 *   - The module also displays the output signals using $display.
 */
module pipeline_MEM_WB(
    input wire reset, clk, clr,
    input wire [4:0]   MEM_RD_instr,
    input wire [31:0]  MUX_out,
    input wire         MEM_control_unit_instr,

    output wire [4:0]  WB_RD_instr,
    output wire [31:0] WB_RD_out,
    output wire        WB_Register_File_Enable 
    );


    reg [4:0]  WB_RD_instr_reg;
    reg [31:0] WB_RD_out_reg;
    reg        WB_Register_File_Enable_reg;

    always@(posedge clk, negedge clr) begin
        if (clk  == 1 && clr == 0) begin
            if (reset) begin
                WB_RD_instr_reg                 = 5'b0;
                WB_RD_out_reg                   = 32'b0; 
                WB_Register_File_Enable_reg     = 1'b0;
            end else begin 
                WB_RD_instr_reg                 = WB_RD_instr;
                WB_RD_out_reg                   = MUX_out;
                WB_Register_File_Enable_reg     = MEM_control_unit_instr;
            end
        end
    $display(">>> MEM/WB Output Signals:\n------------------------------------------");
    $display("WB_RD: %b | WB_out: %b | WB_reg_file: %b | MUX OUT: %b\n", 
             WB_RD_instr_reg, WB_RD_out_reg, WB_Register_File_Enable_reg, MUX_out);
    end
    assign WB_RD_instr              = WB_RD_instr_reg;
    assign WB_RD_out                = WB_RD_out_reg;
    assign WB_Register_File_Enable  = WB_Register_File_Enable_reg;
endmodule
