
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
    input wire reset, LE, clk, clr,
    input wire [18:0] ID_control_unit_instr,     // Control Unit Instructions
    input wire [31:0] PC,
    

    output wire [31:0] PC_EX_out,                 // PC
    output wire [3:0] EX_IS_instr,                // The bits used by the operand handler            
    output wire [3:0] EX_ALU_OP_instr,            // The opcode used by the ALU 
    output wire [9:0] EX_control_unit_instr,      // The rest of the control unit instructions that don't need to be deconstructed
    output wire [31:0] instruction_out
    );

    reg [31:0] instruction_reg;
    reg [31:0] PC_ID_out_reg;


    always@(posedge clk, negedge clr) begin
        if (clk  == 1 && clr == 0) begin

        end
    end
endmodule