module not_gate(input [3:0] in, output reg [3:0] out);

  always @* begin
    out = ~in;
  end

endmodule
