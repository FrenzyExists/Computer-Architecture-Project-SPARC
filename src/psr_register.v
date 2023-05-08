module PSR_register (
    output reg [3:0] out,
    output reg carry,
    input wire [3:0] flags, 
    input wire enable, Clr, clk
);
always @ (posedge clk, posedge Clr)
	if (Clr) out <= 4'b000;
	else if (enable) begin
        out <= flags;
        carry <= flags[2];
    end
endmodule