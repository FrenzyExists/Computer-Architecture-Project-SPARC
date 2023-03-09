
module mini_alu (
    input  [31:0] a,
    input [31:0] b, 
    input cin, 
    input [3:0] opcode, 
    output reg  [31:0] y,
    output reg [3:0] flags
    );

    reg [32:0] carry;
    reg  overflow;
    always @(opcode, a, b, cin) begin
        case (opcode)
            4'b0000: begin
                {carry, y} = a + b; // Add => A + B
                // y = a + b; // Add => A + B
                // Flag order: Z N C V
                /* Explanation:
                 * Z -> If Outout was 0 or not
                 * N -> 
                 * C -> 
                 * V ->
                */
                overflow = ({carry,y[31]} == 2'b01);
                flags = {y == 0, y[31], carry, overflow};
                
            end
            4'b0001: begin
                {carry, y} = a + b + cin; // Add with carry => A + B + cin

                overflow = ({carry,y[31]} == 2'b01);
                flags = {y == 0, y[31], carry, overflow};
            end
            4'b0010: begin
                {carry, y} = a - b;
                overflow = ({carry,y[31]} == 2'b01);
                flags = {y == 0, y[31], carry, overflow};
                // flags = {y[31], y == 0, y < a, y < b, $signed(y) < 0};
            end
            4'b0011: begin 
                {carry, y} = a - b - cin;
                flags = {y[31], y == 0, y < a, y < b, $signed(y) < 0};
            end
            4'b0100: begin
                {carry, y} = a && b;
                flags = {y[31], y == 0};
            end
            4'b0101: begin
                {carry, y} = a | b;
                flags = {y[31], y == 0};
            end
            4'b0110: begin
                y = a ^ b;
                flags = {y[31], y == 0};
            end
            4'b0111: begin
                y = ~(a ^ b);
                flags = {y[31], y == 0};
            end
            4'b1000: begin
                y = a && ~b;
                flags = {y[31], y == 0};
            end
            4'b1001: begin
                y = a ^ ~b;
                flags = {y[31], y == 0};
            end
            4'b1010: {carry, y} = a << b;
            4'b1011: {carry, y} = a >> b;
            4'b1100: {carry, y} = a >>> b;
            4'b1101: {carry, y} = a;
            4'b1110: {carry, y} = b;
            4'b1111: {carry, y} = ~b;
        endcase
    end
endmodule



module register_4bit (
    output reg [3:0] Q,
    input [3:0] D,
    input LE, Clr, Clk
    );
    always @ (posedge Clk)
    if (Clr) Q <= 4'b000;
    else if (LE) Q <= D;
endmodule