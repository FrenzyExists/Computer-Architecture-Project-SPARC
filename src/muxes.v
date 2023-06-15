module mux_4x1  (
    output reg [31:0] Y,
    input [1:0] S, 
    input [31:0] I0, I1, I2, I3
);

always @ (S, I0, I1, I2, I3)
	case (S) 
		2'b00:  Y <= I0;
		2'b01:  Y <= I1;
		2'b10:  Y <= I2;
		2'b11:  Y <= I3;
	endcase
endmodule

module mux_2x1 (
    output reg [31: 0]Y, 
    input S, 
    input[31: 0] I0, I1
);
    always @ (S, I0, I1) begin 
    if (S) Y = I1; 
    else Y = I0; 
    end
endmodule

module mux_2x5 (
    input [4:0] I0,
    input [4:0] I1,
    input S,
    output reg [4:0] Y
);
always @ (S, I0, I1) 
    if (S) Y = I1; 
    else Y = I0; 
endmodule

module mux_condtion (
    output reg [3:0] Y,
    input [3:0] I0, 
    input [3:0] I1,
    input        S
);
always @ (S, I0, I1) 
    if (S) Y = I1; 
    else Y = I0; 
endmodule

module adder32Bit (
    output reg [31:0] out,
    input [31:0] a,
    input [31:0] b
);
    always @* begin
        out <= a + b;
    end
endmodule

module SignExtender( 
    output reg [31:0] extended,
    input wire [21:0] extend
    );

    always @* begin
        extended[31:0] <= { {10{extend[21]}}, extend[21:0] };
    end
endmodule

module multiplierBy4 (
    output reg [31:0] multipliedOut,
    input  [31:0]     in
);
    always @* begin
        multipliedOut <= in << 2'b10;
    end
endmodule