module and_gate_tb;

reg a;
reg b;
wire c;

and_gate uut (
  .a(a),
  .b(b),
  .c(c)
);

initial begin
  a = 1'b0;
  b = 1'b0;
  #5 $display("a=%b, b=%b, c=%b", a, b, c);

  a = 1'b0;
  b = 1'b1;
  #5 $display("a=%b, b=%b, c=%b", a, b, c);

  a = 1'b1;
  b = 1'b0;
  #5 $display("a=%b, b=%b, c=%b", a, b, c);

  a = 1'b1;
  b = 1'b1;
  #5 $display("a=%b, b=%b, c=%b", a, b, c);

  #5 $finish;
end

endmodule
