module npc_pc_handler(
    input branch_out,
    input ID_jmpl_instr,
    input ID_call_instr,
    output reg [1:0] pc_handler_out_selector
);

    always @(branch_out, ID_jmpl_instr, ID_call_instr) begin
        if (ID_jmpl_instr)                   pc_handler_out_selector <= 2'b00; // Jmpl Instruction, use ALU out
        else if (ID_call_instr | branch_out) pc_handler_out_selector <= 2'b11; // call or branch, use TA
        else if (branch_out)                 pc_handler_out_selector <= 2'b01; // Branch Taken        
        else                                 pc_handler_out_selector <= 2'b00; // Normal Execution nPC+4
    end
    
endmodule
