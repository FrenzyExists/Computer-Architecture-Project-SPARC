
/***************************************************************
* Module: source_operand --> Source Operand2 Handler
****************************************************************
*
* Description:
* This module implements a source operand generator that selects and extends the appropriate operand based on the input opcode (IS) and immediate value (Imm). The module provides a 32-bit output (N) representing the selected and extended operand.
* 
* Inputs:
* - R [31:0]: 32-bit input register value
* - Imm [21:0]: 22-bit immediate value
* - IS [3:0]: 4-bit opcode representing the instruction type
* 
* Outputs:
* - N [31:0]: 32-bit output representing the selected and extended operand
* 
* Usage:
* 1. Instantiate the `source_operand` module in your design and provide the required inputs and outputs.
* 2. Connect the 32-bit input register value `R` to the desired source.
* 3. Assign the 22-bit immediate value `Imm` to the desired immediate value.
* 4. Set the 4-bit opcode `IS` to select the desired operation.
* 5. The output `N` will hold the selected and extended operand based on the opcode and immediate value.
* 
* Example:
* ```verilog
* module testbench;
*     reg [31:0] R;
*     reg [21:0] Imm;
*     reg [3:0] IS;
*     wire [31:0] N;
* 
*     source_operand source_operand_inst (
*         .R(R),
*         .Imm(Imm),
*         .IS(IS),
*         .N(N)
*     );
* 
*     initial begin
*         // Set input values
*         R = 32'hA5A5A5A5;
*         Imm = 22'h123456;
*         IS = 4'b0100; // Example opcode for sign extension operation
* 
*         // Wait some time for computation
*         #10;
* 
*         // Check output
*         $display("Result: %h", N);
*     end
* endmodule
* ```
***************************************************************/
module source_operand (
    input [31:0]       R,
    input [21:0]       Imm,
    input [3:0]        IS,
    output reg [31:0]  N
    );

    always @(*) begin
        case(IS)        
            4'b0000: N = {Imm, 10'b0}; // concatenate 10 0's to the right of Imm
            4'b0001: N = {Imm, 10'b0};
            4'b0010: N = {Imm, 10'b0};
            4'b0011: N = {Imm, 10'b0};
            4'b0100: begin
                if (Imm[21] == 1'b1) // if the sign bit is set
                    N = {10'b1111111111, Imm}; // sign extend with 1's
                else
                    N = {10'b0000000000, Imm}; // sign extend with 0's
            end
            4'b0101: begin
                if (Imm[21] == 1'b1) // if the sign bit is set
                    N = {10'b1111111111, Imm}; // sign extend with 1's
                else
                    N = {10'b0000000000, Imm}; // sign extend with 0's
            end
            4'b0110: begin
                if (Imm[21] == 1'b1) // if the sign bit is set
                    N = {10'b1111111111, Imm}; // sign extend with 1's
                else
                    N = {10'b0000000000, Imm}; // sign extend with 0's
            end
            4'b0111: begin
                if (Imm[21] == 1'b1) // if the sign bit is set
                    N = {10'b1111111111, Imm}; // sign extend with 1's
                else
                    N = {10'b0000000000, Imm}; // sign extend with 0's
            end
            4'b1000: N = R;
            4'b1001: begin
                if (Imm[21] == 1'b1) // if the sign bit is set
                    N = {22'b1111111111111111111111, Imm[12:0]}; // sign extend with 1's
                else
                    N = {22'b0000000000000000000000, Imm[12:0]}; // sign extend with 1's
            end
            4'b1010: N = {27'b0, R[4:0]};
            4'b1011: N = {27'b0, Imm[4:0]};
            4'b1100: N = R;        
            4'b1101: begin
                if (Imm[21] == 1'b1) // if the sign bit is set
                    N = {22'b1111111111111111111111, Imm[12:0]}; // sign extend with 1's
                else
                    N = {22'b0000000000000000000000, Imm[12:0]}; // sign extend with 1's
            end
            4'b1110: N = R;
            4'b1111: begin
                if (Imm[21] == 1'b1) // if the sign bit is set
                    N = {22'b1111111111111111111111, Imm[12:0]}; // sign extend with 1's
                else
                    N = {22'b0000000000000000000000, Imm[12:0]}; // sign extend with 1's
            end
        endcase
    end
endmodule
