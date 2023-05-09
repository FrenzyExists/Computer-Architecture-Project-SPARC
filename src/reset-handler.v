

module reset_handler(
    input system_reset,
    input ID_branch_instr,
    input a, // I29 instruction
    output reg reset_out // The thing that triggers reset
);

    always @(posedge system_reset, posedge ID_branch_instr) begin
        if (system_reset || (ID_branch_instr && a)) begin
            reset_out <= 1'b1;
        end else begin
            reset_out <= 1'b0;
        end
    end

endmodule