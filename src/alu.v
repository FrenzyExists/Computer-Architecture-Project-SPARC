module mini_alu (
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
    // carry = {1'b0,a} + {1'b0,b};    
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