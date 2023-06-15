
/***************************************************************
* Module: reset_handler
***************************************************************
* Description:
*   The reset_handler module is responsible for generating a reset
*   signal based on the input conditions. It monitors the system
*   reset signal and an ID branch instruction signal along with
*   an additional input 'a'. When either the system reset is active
*   or the ID branch instruction is active along with input 'a',
*   it triggers the reset signal 'reset_out'.
* 
* Inputs:
*   - system_reset: System reset signal
*   - ID_branch_instr: ID branch instruction signal
*   - a: Additional input signal 'a'
* 
* Outputs:
*   - reset_out: Reset output signal
* 
***************************************************************/
module reset_handler (
    input system_reset,
    input ID_branch_instr,
    input a, // I29 instruction
    input condition_handler_instr,
    output reg reset_out // The thing that triggers reset
);
    always @* begin
        if (system_reset || (ID_branch_instr && a)) begin
            reset_out <= 1'b1;
        end else begin
            reset_out <= 1'b0;
        end
    end
endmodule