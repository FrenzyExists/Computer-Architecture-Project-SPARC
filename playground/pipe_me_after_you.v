
// Pipeline module for IF/ID
module pipeline_IF_ID (
    input wire reset, LE, clk, clr,
    input wire [31:0] PC,
    input wire [31:0] instruction,


    output wire [31:0] PC_ID_out,        // PC
    output wire [21:0] I21_0,            // Imm22
    output wire [29:0] I29_0,            // Can't remember, don't ask
    output wire I29_branch_instr,        // For Branch, part of Phase 4
    output wire [4:0] I18_14,            // rs1
    output wire [4:0] I4_0,              // rs2
    output wire [4:0] I29_25,            // rd
    output wire [3:0] I28_25,            // cond, for Branch
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


module pipeline_ID_EX(
    input  wire reset, clk, clr,
    input  wire [17:0] ID_control_unit_instr,      // Control Unit Instructions
    input  wire [31:0] PC,
    input  wire [4:0]  ID_RD_instr,

    output wire [31:0] PC_EX_out,                  // PC
    output wire [3:0]  EX_IS_instr,                // The bits used by the operand handler            
    output wire [3:0]  EX_ALU_OP_instr,            // The opcode used by the ALU 
    output wire [4:0]  EX_RD_instr,                 // 
    output wire        EX_CC_Enable_instr,

    output wire [8:0]  EX_control_unit_instr      // The rest of the control unit instructions that don't need to be deconstructed
    );

    reg [31:0] PC_ID_out_reg;
    reg [3:0]  EX_IS_instr_reg;
    reg [3:0]  EX_ALU_OP_instr_reg;
    reg [8:0] EX_control_unit_instr_reg;
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
    end

    assign  PC_EX_out                   = PC_ID_out_reg;
    assign  EX_IS_instr                 = EX_IS_instr_reg;
    assign  EX_ALU_OP_instr             = EX_ALU_OP_instr_reg;
    assign  EX_control_unit_instr       = EX_control_unit_instr_reg;
    assign  EX_RD_instr                 = EX_RD_instr_reg;
    assign  EX_CC_Enable_instr          = EX_CC_Enable_instr_reg;
endmodule


module pipeline_EX_MEM(
    input wire reset,  clk, clr,
    input wire [8:0]   EX_control_unit_instr,
    input wire [31:0]  PC,
    input wire [4:0]   EX_RD_instr,
    
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
    end

    assign Data_Mem_instructions        = Data_Mem_instructions_reg;
    assign Output_Handler_instructions  = Output_Handler_instructions_reg;
    assign MEM_control_unit_instr       = MEM_control_unit_instr_reg;
    assign MEM_RD_instr                 = MEM_RD_instr_reg;
    assign PC_MEM_out                   = PC_MEM_out_reg;
endmodule


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
                WB_RD_instr_reg                 = WB_RD_instr
                WB_RD_out_reg                   = MUX_out;
                WB_Register_File_Enable_reg     = MEM_control_unit_instr
            end
        end
    end


    assign WB_RD_instr              = WB_RD_instr_reg;
    assign WB_RD_out                = WB_RD_out_reg;
    assign WB_Register_File_Enable  = WB_Register_File_Enable_reg;


endmodule