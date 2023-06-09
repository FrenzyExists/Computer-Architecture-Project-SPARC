/*
* This module is responsible for selecting the output signal that will be used to update the Program Counter (PC)
* and the Next Program Counter (nPC) registers based on the execution of the previous instruction. 
*
* It takes three inputs: 'branch_out' which is high when the previous instruction was a branch 
* instruction, 'ID_jmpl_instr' which is high when the previous instruction was a Jmpl instruction, 
* and 'ID_call_instr' which is high when the previous instruction was a Call instruction. 
*
* It also has an output 'pc_handler_out_selector' which is a 2-bit signal that determines which of 
* the two input signals (TA or ALU_OUT) will be used to update the PC/nPC registers. 
*
* If 'ID_jmpl_instr' is high, then the ALU_OUT signal will be used to update the PC/nPC registers. 
*
* If 'ID_call_instr' or 'branch_out' is high, then the TA signal will be used to update the PC/nPC registers. 
* 
* If 'branch_out' is high and 'ID_call_instr' is low, then the Branch Taken (BT) signal will be 
* used to update the PC/nPC registers. 
*
* If none of these conditions are met, the normal execution will occur, and the nPC will be incremented 
* by 4 to point to the next instruction in memory.
*
* - 2'b00: Use the value of the ALU output as the next PC (for Jmpl instructions).
*
* - 2'b01: Use the value of TA (target address) as the next PC (for branch instructions
*          where the branch is taken).
*
* - 2'b10: Not used in this module.
*
* - 2'b11: Use the value of TA as the next PC (for Call instructions and branch instructions
*          where the branch is taken).
*
* The module has an always block that updates pc_handler_out_selector based on the values
* of the inputs. The priority of the cases in the always block is as follows: 
* 
* - Jmpl > Call/branch > branch taken > normal execution (nPC + 4).
*
* The module is intended to be used in a larger processor design, where it is responsible for
* generating the next PC value for the processor. 
*
*/
module nPC_PC_Handler (
    input branch_out,
    input ID_jmpl_instr,
    input ID_call_instr,
    output reg [1:0] pc_handler_out_selector
    );
    always @(branch_out, ID_jmpl_instr, ID_call_instr) begin
        if (ID_jmpl_instr)                   pc_handler_out_selector <= 2'b00; // Jmpl Instruction, use ALU out
        else if (ID_call_instr | branch_out) pc_handler_out_selector <= 2'b11; // call or branch, use TA
        else if (branch_out)                 pc_handler_out_selector <= 2'b01; // Branch Taken        
        else                                 pc_handler_out_selector <= 2'b00; // Normal Execution nPC+4
    end
endmodule


/*
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

 // ===============================
module PC_Reg(
    output reg [31:0] Q,
    input LE, clk, clr,
    input [31:0] D
);
    always @ (posedge clk) 
        if (clr) Q <= 32'b0;
        else if (LE) Q <= D;
endmodule

module nPC_Reg(
    output reg [31:0] Q,
    input LE, clk, clr,
    input [31:0] D
);
    always @ (posedge clk) 
        if (clr) Q <= 32'd4;
        else if (LE) Q <= D;
endmodule

module PC_MUX(
    input [31:0] ALU_OUT,
    input [31:0] TA,
    input [31:0] nPC,
    input [1:0] select,
    output reg [31:0] Q
);

    always @(*) begin
        case (select)
            2'b00: Q <= nPC;
            2'b01: Q <= TA;
            2'b10: Q <= ALU_OUT;
            default: Q <= Q;
        endcase
    end
endmodule
// =============================


// Old
module PC_nPC_Register(
    input                clk,
    input                clr,
    input                LE,
    input      [31:0]    nPC,
    input      [31:0]    ALU_OUT,
    input      [31:0]    TA,
    input      [1:0]     mux_select,
    output reg [31:0]    OUT
    );

    always @ (posedge clk) begin
        if(clr) begin
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
endmodule