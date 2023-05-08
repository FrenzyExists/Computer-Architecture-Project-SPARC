module output_handler(
  input MEM_jmpl_instr,
  input MEM_call_instr,
  input MEM_load_instr,
  output reg [1:0] output_handler_out_selector
);

  always @(*) begin
    if (MEM_jmpl_instr)         output_handler_out_selector <= 2'b10; // Jmpl instruction, use ALU out
    else if (MEM_call_instr)    output_handler_out_selector <= 2'b01; // Call instruction, use PC
    else if (MEM_load_instr)    output_handler_out_selector <= 2'b11; // Load instruction, use data memory output
    else                        output_handler_out_selector <= 2'b00; // Default to PC
  end

endmodule