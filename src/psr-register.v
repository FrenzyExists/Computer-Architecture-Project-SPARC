/**************************************************************
 * Module: PSR_register
 **************************************************************
 * Description:
 *   The PSR_register module represents a Processor Status Register
 *   register that holds condition flags and a carry flag. It provides
 *   an output for the condition flags and the carry flag based on
 *   the inputs.
 * 
 * Inputs:
 *   - flags [3:0]: Input condition flags
 *   - enable: Enable signal for updating the output
 *   - Clr: Clear signal for resetting the output
 *   - clk: Clock signal
 * 
 * Outputs:
 *   - out [3:0]: Output condition flags
 *   - carry: Output carry flag
 * 
 ***************************************************************/
module PSR_register (
    output reg [3:0] out,
    output reg carry,
    input wire [3:0] flags, 
    input wire enable, clr, clk
);
always @ (posedge clk, negedge clr)
	if (clr) out <= 4'b000;
	else if (enable) begin
        out <= flags;
        carry <= flags[2];
    end
endmodule