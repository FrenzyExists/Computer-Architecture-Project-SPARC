module not_gate_tb;

  // Inputs
  reg [3:0] in;

  // Outputs
  wire [3:0] out;

  // Instantiate the Unit Under Test (UUT)
  not_gate uut (
    .in(in), 
    .out(out)
  );

  initial begin
    // Initialize inputs
    

    // Wait 10 clock cycles before checking outputs
    #10;

    // Check outputs
    in = 4'b1010;
    #3 $monitor("In = %b  Output = %b", in, out);

    // End the simulation
    $finish;
  end

endmodule
