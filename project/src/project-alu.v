
module mini_alu (
    input [31:0] a,
    input [31:0] b, 
    input cin, 
    input [3:0] opcode, 
    output reg [31:0] y,
    output reg [3:0] flags
    );
    always @(*) begin
        case (opcode)
            4'b0000: begin
                y = a + b; // Add => A + B
                flags = {y[31], y == 0, y < a, y < b, $signed(y) < 0};
            end
            4'b0001: begin
                y = a + b + cin; // Add with carry => A + B + cin
                flags = {y[31], y == 0, y < a, y < b, $signed(y) < 0};
            end
            4'b0010: begin
                y = a - b;
                flags = {y[31], y == 0, y < a, y < b, $signed(y) < 0};
            end
            4'b0011: begin 
                y = a - b - cin;
                flags = {y[31], y == 0, y < a, y < b, $signed(y) < 0};
            end
            4'b0100: begin
                y = a && b;
                flags = {y[31], y == 0};
            end
            4'b0101: begin
                y = a | b;
                flags = {y[31], y == 0};
            end
            4'b0110: begin
                y = a xor b;
                flags = {y[31], y == 0};
            end
            4'b0111: begin
                y = a xnor b;
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
            4'b1010: y = a << b;
            4'b1011: y = a >> b;
            4'b1100: y = a >>> b;
            4'b1101: y = a;
            4'b1110: y = b;
            4'b1111: y = ~b;
        endcase
    end
endmodule



module register_4bit (
    output reg [3:0] Q,
    input [3:0] D,
    input LE, Clr, Clk
    );
    always @ (posedge Clk)
    if (Clr) Q <= 4’b0000 ;
    else if (LE) Q <= D;
endmodule