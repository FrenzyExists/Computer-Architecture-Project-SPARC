module control_unit_mux(

    output reg [3:0] ID_ALU_OP_out, 

    output reg ID_jmpl_instr_out,              // 1
    output reg ID_call_instr_out,              // 2
    output reg ID_branch_instr_out,            // 3
    output reg ID_load_instr_out,              // 4
    output reg ID_register_file_Enable_out,    // 5

    output reg ID_data_mem_SE,                 // 6
    output reg ID_data_mem_RW,                 // 7
    output reg ID_data_mem_Enable,             // 8
    output reg [1:0] ID_data_mem_Size,         // 9,10

    output reg I31_out,                        // 11
    output reg I30_out,                        // 12
    output reg I24_out,                        // 13
    output reg I13_out,                        // 15

    output reg [3:0] ID_ALU_OP_instr,          // 15,16,17,18
    output reg CC_Enable,                      // 19

    input S,
    input [18:0] cu_in_mux
);

    always  @(S) begin
        if (S == 1'b0) begin
            ID_jmpl_instr_out           <= cu_in_mux[0];
            ID_call_instr_out           <= cu_in_mux[1];
            ID_branch_instr_out         <= cu_in_mux[2];
            ID_load_instr_out           <= cu_in_mux[3];
            ID_register_file_Enable_out <= cu_in_mux[4];
            ID_data_mem_SE              <= cu_in_mux[5]; 
            ID_data_mem_RW              <= cu_in_mux[6];
            ID_data_mem_Enable          <= cu_in_mux[7];
            ID_data_mem_Size            <= cu_in_mux[9:8];
            I31_out                     <= cu_in_mux[10];
            I30_out                     <= cu_in_mux[11];
            I24_out                     <= cu_in_mux[12];
            I13_out                     <= cu_in_mux[13];
            ID_ALU_OP_instr             <= cu_in_mux[17:14];
            CC_Enable                   <= cu_in_mux[18];
        end
        else begin
            ID_jmpl_instr_out           <= 1'b0;
            ID_call_instr_out           <= 1'b0;
            ID_branch_instr_out         <= 1'b0;
            ID_load_instr_out           <= 1'b0;
            ID_register_file_Enable_out <= 1'b0;
            ID_data_mem_SE              <= 1'b0;
            ID_data_mem_RW              <= 1'b0;
            ID_data_mem_Enable          <= 1'b0;
            ID_data_mem_Size            <= 1'b0;
            I31_out                     <= 1'b0;
            I30_out                     <= 1'b0;
            I24_out                     <= 1'b0;
            I13_out                     <= 1'b0;
            ID_ALU_OP_instr             <= 1'b0;
            CC_Enable                   <= 1'b0;
        end
    end
endmodule


module control_unit(
    input [31:0] instr,
    input clk, clr, // clock and clear
    output reg [18:0] instr_signals

);

reg ID_jmpl_instr;              // 1
reg ID_call_instr;              // 2
reg ID_branch_instr;            // 3
reg ID_load_instr;              // 4
reg ID_register_file_Enable;    // 5
reg ID_data_mem_SE;             // 6
reg ID_data_mem_RW;             // 7
reg ID_data_mem_Enable;         // 8
reg [1:0] ID_data_mem_Size;     // 9,10
reg I31;                        // 11
reg I30;                        // 12
reg I24;                        // 13
reg I13;                        // 14
reg [3:0] ID_ALU_OP_instr;      // 15,16,17,18
reg CC_Enable;                  // 19

reg [2:0] is_sethi;
reg [5:0] op3;

reg a;

 // the two most significant bits that specifies the instruction format
reg [1:0] instr_op;

always @(posedge clk) begin
    if (clr == 0 && clk == 1) begin
    if (instr == 32'b0) begin
        // $display("Instructions are NOP...");
        ID_jmpl_instr               = 1'b0;
        ID_call_instr               = 1'b0;
        ID_branch_instr             = 1'b0;
        ID_load_instr               = 1'b0;
        ID_register_file_Enable     = 1'b0;
        ID_data_mem_SE              = 1'b0;
        ID_data_mem_RW              = 1'b0;
        ID_data_mem_Enable          = 1'b0;
        ID_data_mem_Size            = 2'b0;
        ID_ALU_OP_instr             = 4'b0;
        CC_Enable                   = 1'b0;
    end else begin
        instr_op = instr[31:30];
        // $display("Getting the op instruction =  %b", instr_op);
        case (instr_op)
            2'b00: begin // SETHI or Branch Instructions
                ID_jmpl_instr               = 1'b0;
                ID_call_instr               = 1'b0;
                ID_load_instr               = 1'b0; 
                ID_register_file_Enable     = 1'b0;
                CC_Enable                   = 1'b0;

                // Ask the professor for these
                ID_data_mem_SE              = 1'b0;
                ID_data_mem_RW              = 1'b0;
                ID_data_mem_Enable          = 1'b0;
                ID_data_mem_Size            = 2'b0;

                is_sethi = instr[24:22];

                if (is_sethi == 3'b100) begin
                    // We specify the ALU to simply forward B.
                    // The source operand2 handler will deal with the
                    // Sethi instruction
                    ID_ALU_OP_instr         = 4'b1110;
                    ID_branch_instr         = 1'b0;
                end
                else if (is_sethi == 3'b010) begin // So this is actually a branch instruction
                    ID_branch_instr         <= 1'b1;
                end
            end
            2'b01: begin // Call Instruction
                
                ID_jmpl_instr               = 1'b0;
                ID_call_instr               = 1'b1;
                ID_branch_instr             = 1'b0;
                ID_load_instr               = 1'b0;
                ID_register_file_Enable     = 1'b1;

                // Ask professor about this
                ID_data_mem_SE              = 1'b0;
                ID_data_mem_RW              = 1'b0;
                ID_data_mem_Enable          = 1'b0;
                ID_data_mem_Size            = 2'b00;

                // Also ask prof bout the alu
                ID_ALU_OP_instr             = 4'b0000;
                CC_Enable                   = 1'b0;
            end

            2'b10, 2'b11: begin
                op3 = instr[24:19]; // the opcode instruction that tells what to do
                // $display("Getting the op3 code =  %b", op3);
                if (instr_op == 2'b11) begin
                    // $display("Instruction is a Load/Store Instruction");
                    // Load/Store Instruction
                    ID_jmpl_instr               = 1'b0;
                    ID_call_instr               = 1'b0;
                    ID_branch_instr             = 1'b0;
                    CC_Enable                   = 1'b0;
                    ID_ALU_OP_instr             = 4'b0000;
                    ID_register_file_Enable     = 1'b1;
                    ID_data_mem_Enable          = 1'b1;

                    case (op3)
                        6'b001001, 6'b001010, 6'b000000, 6'b000001, 6'b000010: 
                        begin
                            // Load Mode
                            // Load	sign byte | Load sign halfword | Load word | Load unsigned byte | Load unsigned halfword
                            // Turn on Load Instruction
                            // Enable Memory
                            // Trigger Memory to Read mode

                            ID_load_instr               = 1'b1;
                            ID_data_mem_RW              = 1'b0;
                            
                            if (op3 == 6'b001001) begin// Load signed byte
                                ID_data_mem_SE          = 1'b1;
                                ID_data_mem_Size        = 2'b00;
                            end else if (op3 == 6'b001010) begin // Load signed halfword
                                ID_data_mem_SE          = 1'b1;
                                ID_data_mem_Size        = 2'b01;       
                            end else if (op3 == 6'b000000) begin // Load word
                                ID_data_mem_SE          = 1'b0;
                                ID_data_mem_Size        = 2'b10;                            
                            end else if (op3 == 6'b000001) begin // Load unsigned byte
                                ID_data_mem_SE          = 1'b0;
                                ID_data_mem_Size        = 2'b00;
                            end else begin // 6'b000010 Load unsigned halfword
                                ID_data_mem_SE          = 1'b0;
                                ID_data_mem_Size        = 2'b01;
                            end
                        end
                        6'b000101, 6'b000110, 6'b000100:
                        begin
                            // Store Mode (mem is set to write mode)
                            ID_load_instr               = 1'b0;
                            ID_data_mem_RW              = 1'b1;

                            if (op3 == 6'b000101) begin // Store byte
                                // ID_data_mem_SE              <= 1'b0;
                                ID_data_mem_Size            = 2'b00;
                            end else if (op3 == 6'b000110) begin //  Store Halfword
                                // ID_data_mem_SE              <= 1'b0;
                                ID_data_mem_Size            = 2'b01;
                            end else  begin // 6'b000100 Store Word
                                // ID_data_mem_SE              <= 1'b0;
                                ID_data_mem_Size            = 2'b10;
                            end 
                        end
                    endcase
                end else if (instr_op == 2'b10) begin
                    // Read/Write/Trap/Save/Restore/Jmpl/Arithmetic
                    // Why the fuck Sparc had to squeeze so many possible instructions on this one block, like... bruh
                    ID_call_instr               = 1'b0;
                    ID_branch_instr             = 1'b0;
                    case (op3)
                    
                        // Jmpl
                        6'b111000: begin
                            // $display("Instruction is a jmpl instruction");    
                            ID_jmpl_instr               = 1'b1;
                            ID_load_instr               = 1'b0;
                            ID_data_mem_SE              = 1'b0;
                            ID_data_mem_RW              = 1'b0;
                            ID_register_file_Enable     = 1'b0;
                            ID_ALU_OP_instr             = 4'b0000;
                            ID_data_mem_Enable          = 1'b0;
                            ID_data_mem_Size            = 2'b00;    
                            CC_Enable                   = 1'b0;
                        end
                        // Save and Restore Instruction Format
                        6'b111100, 6'b111101: begin

                            ID_jmpl_instr               = 1'b0;
                            ID_load_instr               = 1'b0;
                            ID_register_file_Enable     = 1'b1;
                            ID_ALU_OP_instr             = 4'b0000;
                            CC_Enable                   = 1'b0;
                            ID_data_mem_SE              = 1'b0;

                            // a <= instr[13];
                            // if (a == 1'b1) ;// normal r2
                            // else if (a == 1'b0) ID_data_mem_SE <= 1'b1;// with sign extend

                            ID_data_mem_RW              = 1'b0;
                            ID_data_mem_Enable          = 1'b1;
                            ID_data_mem_Size            = 2'b10;                            
                           
                        end
                        // Arithmetic
                        default: begin
                            // For cases where the signal modifies condition codes
                            case (op3)
                                6'b000000: begin // add
                                    ID_ALU_OP_instr = 4'b0000;
                                    CC_Enable       = 1'b0;
                                end
                                6'b010000: begin // addcc
                                    ID_ALU_OP_instr = 4'b0000;
                                    CC_Enable       = 1'b1;
                                end
                                6'b001000: begin // addx
                                    ID_ALU_OP_instr = 4'b0001;
                                    CC_Enable       = 1'b0;
                                end
                                6'b011000: begin // addxcc
                                    ID_ALU_OP_instr = 4'b0001;
                                    CC_Enable       = 1'b1;
                                end
                                6'b000100: begin // sub
                                    ID_ALU_OP_instr = 4'b0010;
                                    CC_Enable       = 1'b0;
                                end
                                6'b010100: begin // subcc
                                    ID_ALU_OP_instr = 4'b0010;
                                    CC_Enable       = 1'b1;
                                end
                                6'b001100: begin // subx
                                    ID_ALU_OP_instr = 4'b0011;
                                    CC_Enable       = 1'b0;
                                end
                                6'b000001: begin // and
                                    ID_ALU_OP_instr = 4'b0100;
                                    CC_Enable       = 1'b0;
                                end
                                6'b010001: begin // andcc
                                    ID_ALU_OP_instr = 4'b0100;
                                    CC_Enable       = 1'b1;
                                end
                                6'b000101: begin // andn (and not)
                                    ID_ALU_OP_instr = 4'b1000;
                                    CC_Enable       = 1'b0;
                                end
                                6'b010101: begin // andncc
                                    ID_ALU_OP_instr = 4'b1000;
                                    CC_Enable       = 1'b1;
                                end
                                6'b000010: begin // or
                                    ID_ALU_OP_instr = 4'b0101;
                                    CC_Enable       = 1'b0;
                                end
                                6'b010010: begin // orcc
                                    ID_ALU_OP_instr = 4'b0101;
                                    CC_Enable       = 1'b1;
                                end
                                6'b000110: begin // orn (or not)
                                    ID_ALU_OP_instr = 4'b1001;
                                    CC_Enable       = 1'b0;
                                end
                                6'b010110: begin // orncc
                                    ID_ALU_OP_instr = 4'b1001;
                                    CC_Enable       = 1'b1;
                                end
                                6'b000011: begin // xor
                                    ID_ALU_OP_instr = 4'b0110;
                                    CC_Enable       = 1'b0;
                                end
                                6'b010011: begin // xorcc
                                    ID_ALU_OP_instr = 4'b0110;
                                    CC_Enable       = 1'b1;
                                end
                                6'b000111: begin // xorn (xnor)
                                    ID_ALU_OP_instr = 4'b0111;
                                    CC_Enable       = 1'b0;
                                end
                                6'b010111: begin // xorncc
                                    ID_ALU_OP_instr = 4'b0111;
                                    CC_Enable       = 1'b1;
                                end
                                6'b100101: begin // sll (shift left logical)
                                    ID_ALU_OP_instr = 4'b1010;
                                    CC_Enable       = 1'b0;
                                end
                                6'b100110: begin // srl shift right logical
                                    ID_ALU_OP_instr = 4'b1011;
                                    CC_Enable       = 1'b0;
                                end
                                6'b100111: begin // sra shift right arithmetic
                                    ID_ALU_OP_instr = 4'b1100;
                                    CC_Enable       = 1'b0;
                                end
                            endcase
                            // include the rest of the flags here
                            ID_jmpl_instr               = 1'b0;
                            ID_call_instr               = 1'b0;
                            ID_branch_instr             = 1'b0;
                            ID_load_instr               = 1'b0;
                            ID_register_file_Enable     = 1'b0;

                            ID_data_mem_SE              = 1'b0;
                            ID_data_mem_RW              = 1'b0;
                            ID_data_mem_Enable          = 1'b0;
                            ID_data_mem_Size            = 2'b0;
                        end
                    endcase
                end
            end
        endcase
    end

    I31 = instr[31];
    I30 = instr[30];
    I24 = instr[24];
    I13 = instr[13];

    // Output
    instr_signals[0]      = ID_jmpl_instr;
    instr_signals[1]      = ID_call_instr;
    instr_signals[2]      = ID_branch_instr;
    instr_signals[3]      = ID_load_instr;
    instr_signals[4]      = ID_register_file_Enable;

    instr_signals[5]      = ID_data_mem_SE;
    instr_signals[6]      = ID_data_mem_RW;
    instr_signals[7]      = ID_data_mem_Enable;
    instr_signals[9:8]    = ID_data_mem_Size;

    instr_signals[10]     = I31;
    instr_signals[11]     = I30;
    instr_signals[12]     = I24;
    instr_signals[13]     = I13;

    instr_signals[17:14]  = ID_ALU_OP_instr;
    instr_signals[18]     = CC_Enable;

end
end
endmodule

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

module pipeline_ID_EX (
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

module pipeline_EX_MEM (
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

    always@(posedge clk, negedge clr) begin
        if (clk  == 1 && clr == 0) begin
            if (reset) begin
                //reset
                Data_Mem_instructions_reg           = 4'b0;
                Output_Handler_instructions_reg     = 3'b0;
                MEM_control_unit_instr_reg          = 1'b0;
                MEM_RD_instr_reg                    = 5'b0;
                PC_MEM_out_reg                      = 32'b0;
            end else begin
                //update
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

module pipeline_MEM_WB (
    input wire reset, clk, clr,
    input wire [4:0]   MEM_RD_instr,
    input wire [31:0]  MUX_out,
    input wire         MEM_control_unit_instr,

    output wire [4:0]  WB_RD_instr,
    output wire [31:0] WB_RD_out,
    output wire        WB_Register_File_Enable 
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
                // Reset all your registers here
            end else begin
                // Update your registers here
            end
        end
    end

    // Assign your outputs here

endmodule


`timescale 1ns / 1ns
// Data memory pre-load - Victor Barriera

module rom_512x8 (output reg [31:0] DataOut, input [8:0] Address);
    reg [7:0] Mem[0:511];       //512 8bit locations

    always@(Address)            //Loop when Address changes
        DataOut <= {Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]};
endmodule



module control_unit_test;

    integer fi, fo, code, i; 
    reg [31:0] data;
    reg [8:0] Address, Addr; 
    wire [31:0] DataOut;

    // Declare inputs
    // reg [31:0] instr;
    reg clk;
    reg clr;


    // Declare outputs
    wire [18:0] instr_signals;

    // Define function to decode instructions
    function [31:0] decode_instr;
        input [31:0] instr;

        case (instr[31:24]) // example opcode extraction
            8'b11001010: decode_instr = "stb r5,[r1,1]";
            8'b00010010: decode_instr = "bne -2";
            8'b00001011: decode_instr = "sethi #3F0F06, r5";
            8'b01000000: decode_instr = "call +4";
            8'b10000001: decode_instr = "jmpl r0,r15, r0";
            8'b10001010: decode_instr = "add r0,r0,r5";
            8'b10000110: decode_instr = "subcc r3,1,r3";
            8'b11000100: decode_instr = "ldub [r0,r1],r2";
            8'b00000000: decode_instr = "nop";
            default: decode_instr = "Unknown";
        endcase
    endfunction

    // Instantiate the control_unit module
    control_unit dut(
        .instr(DataOut),
        .clk(clk),
        .clr(clr),
        .instr_signals(instr_signals)
    );

    // Insantiate Pipieline Registers
    pipeline_IF_ID if_id (
        .reset(clr),
        .LE(clk),
        .clk(clk),
        .clr(clr),
        .PC(PC),
        .instruction(instruction_reg),
        .PC_ID_out(PC_ID_out),
        .instruction_out(instruction_out)
    );

    pipeline_ID_EX id_ex (
    .clk(clk),
    .clr(clr),
    .instruction(instruction_out),
    .PC(PC_ID_out),
    // Add more inputs as needed
    .ALU_op(ALU_op_out),
    .operand_a(operand_a_out),
    .operand_b(operand_b_out)
    // Add more outputs as needed
    );

    pipeline_EX_MEM ex_mem (
        .clk(clk),
        .clr(clr),
        .ALU_result(ALU_result_out),
        .data_to_write(data_to_write_out),
        // Add more inputs as needed
        .ALU_result_MEM(ALU_result_MEM_out),
        .data_to_write_MEM(data_to_write_MEM_out)
        // Add more outputs as needed
    );

    pipeline_MEM_WB mem_wb (
        .clk(clk),
        .clr(clr),
        .data_read(data_read_out),
        .ALU_result(ALU_result_MEM_out),
        // Add more inputs as needed
        .data_to_write_WB(data_to_write_WB_out),
        .write_register(write_register_out)
        // Add more outputs as needed
    );


    rom_512x8 ram1 (
        DataOut,
        Address
    );

    initial begin
        fi = $fopen("sparc-instructions-precharge.txt","r");
        Addr = 9'b000000000;
        while (!$feof(fi)) begin
            code = $fscanf(fi, "%b", data);
            ram1.Mem[Addr] = data;
            Addr = Addr + 1;
        end
        $fclose(fi);
    end


    // Clock generator
    initial begin
        clr <= 1'b1;
        clk <= 1'b0;
        repeat(2) #2 clk = ~clk;
        clr <= 1'b0;
        repeat(64) begin
            #2 clk = ~clk;
        end
    end

    // Modified monitor statement
    initial begin
    $monitor("Address = %d, clk = %b, clr = %b, DataOut = %b, instr_signals = %b, instr_keyword = %s, time=%d, PC_IF_ID=%h, instruction_IF_ID=%h, PC_ID_EX=%h, instruction_ID_EX=%h, PC_EX_MEM=%h, instruction_EX_MEM=%h, PC_MEM_WB=%h, instruction_MEM_WB=%h", 
            Address, clk, clr, DataOut, instr_signals, decode_instr(DataOut), $time, PC_ID_out, instruction_out, PC_EX_out, instruction_EX_out, PC_MEM_out, instruction_MEM_out, PC_WB_out, instruction_WB_out);
    end        

    initial begin
        #100
        $finish;
    end 

    initial begin
        Address = 9'b000000000;
        repeat (15) begin
            #4; // 
            Address = Address + 4;
        end
        end
endmodule
