/**************************************************************
 * Module: psr_register
 **************************************************************
 * Description:
 *   The psr_register module represents a Processor Status Register
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
module psr_register (
    output reg [3:0] out,
    output reg carry,
    input wire [3:0] flags, 
    input wire enable, clk
);
always @ (posedge clk)
    if (enable) begin
        out <= flags;
        carry <= flags[1];
    end
endmodule