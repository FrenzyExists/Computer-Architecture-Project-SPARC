`timescale 1ns / 1ns


module rom_512x8 (output reg [31:0] DataOut, input [7:0] Address);
    reg [7:0] Mem[0:511];       //512 8bit locations
    always@(Address)            //Loop when Address changes
        DataOut = {Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]};
endmodule


/**
 * PC_adder - A module for incrementing the program counter by 4
 *
 * The PC_adder module receives a 32-bit program counter value (PC_in) and
 * increments it by 4 to obtain the next program counter value (PC_out).
 *
 * Inputs:
 *  - PC_in: a 32-bit input wire representing the current program counter value
 *
 * Outputs:
 *  - PC_out: a 32-bit output register representing the next program counter value
 *
 * Usage example:
 *
 *  PC_adder pc_adder(
 *      .PC_in(PC),
 *      .PC_out(next_PC)
 *  );
 *
 */
module PC_adder (
    input wire [31:0] PC_in,
    output reg [31:0] PC_out
    );
    always @(*) begin
        PC_out = PC_in + 4;
    end
endmodule


/*
 * PC/nPC Register module
 *
 * The module represents a pair of registers, PC and nPC, that hold 32-bit values
 * for the current and next program counters, respectively. The module also includes
 * a multiplexer that selects between different input signals to update the PC register.
 * The selected signal is determined by the mux_select input, which is a 2-bit wide signal.
 *
 * Inputs:
 *   clk: Clock signal
 *   clr: Active low clear signal
 *   reset: Reset signal to initialize the register to zero
 *   LE: Load enable signal, determines when to update the PC register
 *   nPC: 32-bit input signal for the next program counter
 *   ALU_OUT: 32-bit input signal from the ALU
 *   TA: 32-bit input signal from the target address
 *   mux_select: 2-bit input signal to select between different input signals
 *
 * Outputs:
 *   OUT: 32-bit output signal that holds the value of the PC register after the update
 *
 * Example usage:
 *   PC_nPC_Register PC (
 *     .clk(clk),
 *     .clr(clr),
 *     .reset(reset),
 *     .LE(LE),
 *     .nPC(nPC),
 *     .ALU_OUT(ALU_OUT),
 *     .TA(TA),
 *     .mux_select(mux_select),
 *     .OUT(PC_out)
 *   );
 */
module PC_nPC_Register(
    input           clk,
    input           clr,
    input           reset,
    input           LE,
    input [31:0]    nPC,
    input [31:0]    ALU_OUT,
    input [31:0]    TA,
    input [1:0]     mux_select,
    output reg [31:0]   OUT
    );

    always @ (posedge clk, negedge clr) begin
        if (clr == 0 && clk == 1) begin
            if(reset) begin
                OUT <= 32'b0;
            end else if (LE) begin
                case (mux_select)
                    2'b00: OUT <= nPC;
                    2'b01:  OUT <= TA;
                    2'b10:  OUT <= ALU_OUT;
                    default: OUT <= OUT;
                endcase
            end
        end
    end 
endmodule


// MUX Module that was not the bane of my existance
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

/*
* Control Unit Module
*
* The registers in the module are as follows:
* 
*
* ID_jmpl_instr: a register that stores the value 1 if the instruction is a jmpl instruction, and 0 otherwise.
* ID_call_instr: a register that stores the value 1 if the instruction is a call instruction, and 0 otherwise.
* ID_branch_instr: a register that stores the value 1 if the instruction is a branch instruction, and 0 otherwise.
* ID_load_instr: a register that stores the value 1 if the instruction is a load instruction, and 0 otherwise.
* ID_register_file_Enable: a register that stores the value 1 if the register file should be enabled, and 0 otherwise.
* ID_data_mem_SE: a register that stores the value 1 if the data memory should be sign-extended, and 0 otherwise.
* ID_data_mem_RW: a register that stores the value 1 if the data memory should be read from, and 0 otherwise.
* ID_data_mem_Enable: a register that stores the value 1 if the data memory should be enabled, and 0 otherwise.
* ID_data_mem_Size: a register that stores the size of the data memory.
* I31: a register that stores the value of the 31st bit of the instruction.
* I30: a register that stores the value of the 30th bit of the instruction.
* I24: a register that stores the value of the 24th bit of the instruction.
* I13: a register that stores the value of the 13th bit of the instruction.
* ID_ALU_OP_instr: a register that stores the value of the ALU operation code in the instruction.
* CC_Enable: a register that stores the value 1 if the condition codes should be enabled, and 0 otherwise.
*/
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
                                ID_data_mem_RW              = 1'b1;
                                ID_data_mem_Enable          = 1'b1;
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
        instr_signals[2]      = ID_load_instr;
        instr_signals[3]      = ID_register_file_Enable;

        instr_signals[4]      = ID_data_mem_SE;
        instr_signals[5]      = ID_data_mem_RW;
        instr_signals[6]      = ID_data_mem_Enable;
        instr_signals[8:7]    = ID_data_mem_Size;

        instr_signals[9]      = CC_Enable;

        instr_signals[10]     = I31;
        instr_signals[11]     = I30;
        instr_signals[12]     = I24;
        instr_signals[13]     = I13;

        instr_signals[17:14]  = ID_ALU_OP_instr;
        instr_signals[18]     = ID_branch_instr;

       
        $display(">>> Control Unit Instruction Signals:\n------------------------------------------");
        $display("Instructions found on CU: %b\n------------------------------------------", instr);
        $display("jmpl: %d | call: %b | load: %b | regfile E: %b | branch: %b | CC_E: %b\n-------------------------", ID_jmpl_instr, ID_call_instr, ID_load_instr, ID_register_file_Enable, ID_branch_instr, CC_Enable);
        $display("Data Memory Instructions from Control Unit:");
        $display("SE: %b | R/W: %b | E: %b | Size: %b\n-------------------------", ID_data_mem_SE, ID_data_mem_RW, ID_data_mem_Enable, ID_data_mem_Size);
        $display("Operand2 Handler and ALU Instructions from Control Unit:");
        $display("I31: %b | I30: %b | I24: %b | I13: %b | ALU_OP: %b\n-------------------------\n\n", I31, I30, I24, I13, ID_ALU_OP_instr);

        end
    end
endmodule


// Pipeline module for IF/ID
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
    reg [8:0]  EX_control_unit_instr_reg;
    reg [5:0]  EX_RD_instr_reg;
    reg        EX_CC_Enable_instr_reg;

    always@(posedge clk, negedge clr) begin
        if (clk  == 1 && clr == 0) begin
            if (reset) begin
                PC_ID_out_reg               = 32'b0;
                EX_IS_instr_reg             = 4'b0;
                EX_ALU_OP_instr_reg         = 4'b0;
                EX_control_unit_instr_reg   = 8'b0;
                EX_RD_instr_reg             = 5'b0;
                EX_CC_Enable_instr_reg      = 1'b0;
            end else begin
                PC_ID_out_reg               = PC;
                EX_IS_instr_reg             = ID_control_unit_instr[13:10];
                EX_ALU_OP_instr_reg         = ID_control_unit_instr[17:14];
                EX_RD_instr_reg             = ID_RD_instr;
                EX_CC_Enable_instr_reg      = ID_control_unit_instr[9];
                
                EX_control_unit_instr_reg   = ID_control_unit_instr[8:0];
            end
        end

    $display(">>> ID/EX Output Signals:\n------------------------------------------");
    $display("PC: %d | EX_IS: %b | EX_ALU: %b | EX_RD: %b | EX_CC: %b", 
            PC_ID_out_reg, EX_IS_instr_reg, EX_ALU_OP_instr_reg, EX_RD_instr_reg, EX_CC_Enable_instr_reg);
    $display("Signals that are forwarded:\n---------------------\nID jmpl: %b | ID call: %b | ID load: %b | ID Reg Enable: %b | ID Mem SE: %b | ID MEM R/W: %b | ID MEM E: %b | ID MEM Size: %b\n\n",
        EX_control_unit_instr_reg[0], EX_control_unit_instr_reg[1], EX_control_unit_instr_reg[2], EX_control_unit_instr_reg[3], EX_control_unit_instr_reg[4], EX_control_unit_instr_reg[5],
        EX_control_unit_instr_reg[6], EX_control_unit_instr_reg[8:7]
    );
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

    reg [4:0]   Data_Mem_instructions_reg;
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
    $display("Signals that are forwarded to MEM:\n---------------------\nMEM jmpl: %b | MEM call: %b | MEM load: %b | MEM Reg Enable: %b | EX Mem SE: %b | EX MEM R/W: %b | EX MEM E: %b | EX MEM Size: %b\n\n",
        Output_Handler_instructions_reg[0], Output_Handler_instructions_reg[1], Output_Handler_instructions_reg[2], MEM_control_unit_instr_reg, 
        Data_Mem_instructions_reg[0], Data_Mem_instructions_reg[1], Data_Mem_instructions_reg[2], Data_Mem_instructions_reg[4:3]
    );
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


module phase3Tester;
    // Instruction Memory stuff
    integer fi, fo, code, i; 
    reg [32:0] data;
    reg [8:0] Addr; 
    wire [31:0] instruction;

    reg LE;
    reg clr;
    reg clk;
    reg reset;
    reg enable;
    reg S; // To trigger the CU or something idfk

    wire [31:0] PC;
    wire [31:0] nPC;
    wire [31:0] PC_ID;
    wire [31:0] PC_EX;
    wire [31:0] PC_MEM;
    wire [31:0] instruction_out;

    wire [3:0] ALU_OP;
    wire CC_Enable;
    wire [3:0] IS;

    wire [21:0] Imm22;
    wire [29:0] I29_0;
    wire I29_branch_instr;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [3:0] cond;

    wire [18:0] ID_CU;
    wire [8:0] EX_CU;
    wire       MEM_CU;

    reg  [4:0] RD_ID;
    wire [4:0] RD_EX;
    wire [4:0] RD_MEM;
    wire [4:0] RD_WB;

    wire [3:0] DataMemInstructions;
    wire [2:0] OutputHandlerInstructions;

    wire [31:0] OutputMUX;
    wire [31:0] WB_RD_out;

    wire WB_Register_File_Enable;

    // These are more for phase 4
    reg [1:0] PC_MUX = 2'b00;
    reg [31:0] TA;
    reg [31:0] ALU_OUT;


    // Clock generator
    initial begin
        clr <= 1'b1;
        clk <= 1'b0;
        repeat(2) #2 clk = ~clk;
        clr <= 1'b0;
       forever #2 clk = ~clk;
    end

    PC_adder adder (
        .PC_in(PC),
        .PC_out(nPC)
    );


    PC_nPC_Register PC_reg(
        .clk        (clk),
        .clr        (clr),
        .reset      (reset),
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


    initial begin
        fi = $fopen("../precharge/sparc-instructions-precharge.txt","r");
        Addr = 9'b000000000;
        while (!$feof(fi)) begin
            code = $fscanf(fi, "%b", data);
            // $display("---- %b ----\n", data);
            ram1.Mem[Addr] = data;
            Addr = Addr + 1;
        end
        $fclose(fi);
        Addr = 9'b000000000;
        
    end


    pipeline_IF_ID IF_ID(
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


    pipeline_ID_EX ID_EX(
         .PC                            (PC_ID),
         .clk                           (clk),
         .clr                           (clr),
         .ID_control_unit_instr         (ID_CU[17:0]),
         .ID_RD_instr                   (RD_EX),

        // OUTPUT
        .PC_EX_out                      (PC_EX),
        .EX_IS_instr                    (IS),
        .EX_ALU_OP_instr                (ALU_OP),
        .EX_RD_instr                    (RD_EX),
        .EX_CC_Enable_instr             (CC_Enable),
        .EX_control_unit_instr          (EX_CU)
    );


    pipeline_EX_MEM EX_MEM(
        .reset                          (reset),
        .clk                            (clk), 
        .clr                            (clr),
        .EX_control_unit_instr          (EX_CU),
        .PC                             (PC_EX),
        .EX_RD_instr                    (RD_EX),

        .Data_Mem_instructions          (DataMemInstructions),
        .Output_Handler_instructions    (OutputHandlerInstructions),
        .MEM_control_unit_instr         (MEM_CU),
        .PC_MEM_out                     (PC_MEM),
        .MEM_RD_instr                   (RD_MEM)
    );

    pipeline_MEM_WB MEM_WB(
        .reset                          (reset),
        .clk                            (clk),
        .clr                            (clr),
        .MEM_RD_instr                   (RD_MEM),
        .MUX_out                        (PC_MEM), // (OutputMUX),
        .MEM_control_unit_instr         (MEM_CU),
        .WB_RD_instr                    (RD_WB),
        .WB_RD_out                      (WB_RD_out),
        .WB_Register_File_Enable        (WB_Register_File_Enable) 
    );

    initial begin
        #52;
        $finish;
    end 
    reg [9:0] wow;
    initial begin
        // $monitor("\n\n TIME: %d | CLK: %b\nData Out (Memory): %b | PC: %d | nPC: %d | Reset: %b\n--->IF ID out: %b<---\n--------Control Unit Outputs Signals-------- \n\nID jmpl: %d | ID call: %b | ID load: %b | ID regfile E: %b | ID branch: %b | ID CC_E: %b ID_shift_imm: %b | ID_load_instr: %b | ID_RF_enable: %b | ID_Enable_instr: %b | ID_ReadWrite_instr: %b | ID_Size_instr: %b | bit_S: %b | ID_shiftType: %b | ALU_op: %b | ID_B_instr: %b | ID_BL_instr: %b \n\n-> Mux CU Output: %b \n---> Pipeline ID-EX Output: %b | B_instr: %b | BL_instr: %b \n-----> Pipeline EX-MEM Output: %b | B_instr: %b | BL_instr: %b \n--------> Pipeline MEM-WB Output: %b | B_instr: %b | BL_instr: %b", $time, clk, DataOut, Qs, reset, instruction_to_CU, cu_out[0], cu_out[1], cu_out[2], cu_out[3], cu_out[4], cu_out[6:5], cu_out[7], cu_out[9:8], cu_out[13:10], b_bl_signals[0], b_bl_signals[1], OutputHandlerInstructions[0], OutputHandlerInstructions[1], OutputHandlerInstructions[2], EX_signals_out, b_bl_signals[0], b_bl_signals[1], MEM_signals_out, b_bl_signals[0], b_bl_signals[1], WB_signals_out, b_bl_signals[0], b_bl_signals[1]);

        // $monitor("Monitoring PCs Clocks and Claks:\n------------------------------------------\ntime %d | LE: %b | reset: %b | PC: %d | nPC: %b | clk: %d clr: %d | Instructions: %b\n----> IF/ID \n\n", LE, reset, PC, $time, clk, clr, instruction);
        // $monitor("Baseline: \n---------------------\nenable: %b | reset: %b | PC: %d | nPC: %d | PC_ID: %d | PC_EX: %d | PC_MEM: %d | time %d | clk: %d clr: %d\n----- Instruction: %b ----- Addr: %d\n\n", enable, reset, PC, nPC, PC_ID, PC_EX, PC_MEM, $time, clk, clr, instruction_out, Address);
    end

    initial begin
        LE = 1'b1;
        reset = 1;
        #8;
        reset = 0;
        #12;
    end
endmodule