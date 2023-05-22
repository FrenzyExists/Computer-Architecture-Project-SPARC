
/***************************************************************
* Module: alu
***************************************************************
* Description:
* This module implements an Arithmetic Logic Unit (ALU) that performs various arithmetic and logic operations on two 32-bit inputs (a and b) based on a 4-bit opcode. The ALU computes the result (y) and sets the flags (Z, N, C, V) based on the operation performed.
* 
* Inputs:
* - a [31:0]: 32-bit input A
* - b [31:0]: 32-bit input B
* - cin: Carry-in input
* - opcode [3:0]: 4-bit operation code
* 
* Outputs:
* - y [31:0]: 32-bit output result
* - flags [3:0]: Flags indicating the result status (Z, N, C, V)
* 
* Limitations:
* - The ALU module only supports 32-bit inputs and outputs. Other bit widths are not supported.
* 
* Usage:
* 1. Instantiate the `alu` module in your design and provide the required inputs and outputs.
* 2. Connect the 32-bit inputs `a` and `b` to the desired sources.
* 3. Set the `cin` input to the carry-in value if required.
* 4. Assign the desired operation code to the `opcode` input to select the desired operation.
* 5. The output `y` will hold the result of the operation, and `flags` will indicate the status flags (Z, N, C, V) based on the operation performed.
* 
* Example:
* ```verilog
* module testbench;
*     reg [31:0] a, b;
*     reg cin;
*     reg [3:0] opcode;
*     wire [31:0] y;
*     wire [3:0] flags;
* 
*     alu alu_inst (
*         .a(a),
*         .b(b),
*         .cin(cin),
*         .opcode(opcode),
*         .y(y),
*         .flags(flags)
*     );
* 
*     initial begin
*         // Set input values
*         a = 32'hA5A5A5A5;
*         b = 32'hB5B5B5B5;
*         cin = 1'b1;
*         opcode = 4'b0000; // Addition operation
* 
*         // Wait some time for computation
*         #10;
* 
*         // Check outputs
*         $display("Result: %h", y);
*         $display("Flags: %b", flags);
*     end
* endmodule
* ```
***************************************************************/
module alu (
    input [31:0] a,
    input [31:0] b, 
    input cin, 
    input [3:0] opcode, 
    output reg  [31:0] y,
    output reg [3:0] flags
    );
    
    reg [32:0] carry;

    reg Z;
    reg N;
    reg C;
    reg V;
    
    /* Explanation:
    * Z -> If Outout was 0 or not
    * N -> Negative
    * C -> Carry
    * V -> Overflow
    */
    always @(opcode, a, b, cin) begin
        case (opcode)
            4'b0000: begin
                {carry, y} = a + b; // Add => A + B
                // y = carry;
                // y = a + b; // Add => A + B
                // Flag order: Z N C V
                
                Z = (y == 32'b0) ? 1:0;
                N = (y[31] == 1'b1) ? 1:0;
                C = carry[0];
                V = (~a[31] && ~b[31] && y[31]) | (a[31] && b[31] && ~y[31]);
                flags = {Z, N, C, V};          
            end
            4'b0001: begin
        
                {carry, y} = a + b + cin; // Add with carry => A + B + cin

                Z = (y == 32'b0) ? 1:0;
                N = (y[31] == 1'b1) ? 1:0;
                C = carry[32];
                V = (~a[31] && ~b[31] && y[31]) | (a[31] && b[31] && ~y[31]);
                flags = {Z, N, C, V};

                // overflow = ({carry,y[31]} == 2'b01);
                // flags = {y == 0, y[31], carry, overflow};
            end
            4'b0010: begin
                {carry, y} = a - b;

                Z = (y == 32'b0) ? 1:0;
                N = (y[31] == 1'b1) ? 1:0;
                C = carry[32];
                V = ({carry, y[31]} == 2'b01);
                flags = {Z, N, C, V};  
            end
            4'b0011: begin 
                {carry, y} = a - b - cin;

                Z = (y == 32'b0) ? 1:0;
                N = (y[31] == 1'b1) ? 1:0;
                C = carry[32];
                V = ({carry, y[31]} == 2'b01);
                flags = {Z, N, C, V};
            end
            4'b0100: begin
                {carry, y} = a && b;

                Z = (y == 32'b0) ? 1:0;
                N = (y[31] == 1'b1) ? 1:0;
                C = 1'b0;
                V = 1'b0;
                flags = {Z, N, C, V};
            end
            4'b0101: begin
                {carry, y} = a | b;

                Z = (y == 32'b0) ? 1:0;
                N = (y[31] == 1'b1) ? 1:0;
                C = 1'b0;
                V = 1'b0;
                flags = {Z, N, C, V};
            end
            4'b0110: begin
                y = a ^ b;

                Z = (y == 32'b0) ? 1:0;
                N = (y[31] == 1'b1) ? 1:0;
                C = 1'b0;
                V = 1'b0;
                flags = {Z, N, C, V};
            end
            4'b0111: begin
                y = ~(a ^ b);

                Z = (y == 32'b0) ? 1:0;
                N = (y[31] == 1'b1) ? 1:0;
                C = 1'b0;
                V = 1'b0;
                flags = {Z, N, C, V};
            end
            4'b1000: begin
                y = a && ~b;

                Z = (y == 32'b0) ? 1:0;
                N = (y[31] == 1'b1) ? 1:0;
                C = 1'b0;
                V = 1'b0;
                flags = {Z, N, C, V};
            end
            4'b1001: begin
                y = a ^ ~b;
                
                Z = (y == 32'b0) ? 1:0;
                N = (y[31] == 1'b1) ? 1:0;
                C = 1'b0;
                V = 1'b0;
                flags = {Z, N, C, V};
            end
            4'b1010: y = a << b;
            4'b1011: y = a >> b;
            4'b1100: y = $signed(a) >>> b[4:0];
            4'b1101: y = a;
            4'b1110: y = b;
            4'b1111: y = ~b;
        endcase
    end
endmodule