module register_file_3_port (
  input [4:0] RA, RB, RD, // register select inputs for reading
  input [4:0] RW, // register select input for writing
  input [31:0] PW, // data input for writing
  input LE, // latch enable input for writing
  input clk, // clock input
  output wire [31:0] PA, PB, PD // output ports
);

reg [31:0] registers [0:31]; // array of 32 registers
assign PA = (RA == 0) ? 0 : registers[RA]; // output for register RA
assign PB = (RB == 0) ? 0 : registers[RB]; // output for register RB
assign PD = (RD == 0) ? 0 : registers[RD]; // output for register RC

always @(posedge clk) begin
  if (LE) begin
    registers[RW] <= PW; // write to register RW
  end
end

endmodule

module register_file_3_port_test;

reg [4:0] RA, RB, RD, RW; // register select inputs for reading and writing
reg [31:0] PW; // data input for writing
reg LE, clk; // latch enable input and clock input
wire [31:0] PA, PB, PD; // output ports

register_file_3_port dut (
  .RA(RA),
  .RB(RB),
  .RD(RD),
  .RW(RW),
  .PW(PW),
  .LE(LE),
  .clk(clk),
  .PA(PA),
  .PB(PB),
  .PD(PD)
);

initial begin
  // initialize inputs
  RA = 0;
  RB = 31;
  RD = 30;
  RW = 0;
  PW = 20;
  LE = 1;
  clk = 0;
  
  #10; // wait for some time
  
  // read register 0 (output should be 0)
  RA = 0;
  #2;
  $display("%d %d %d %d %d %d %d %d", RW, RA, RB, RD, PW, PA, PB, PD);
  
  // read registers 0, 30, and 31
  RA = 0;
  RB = 31;
  RD = 30;
  #2;
  $display("%d %d %d %d %d %d %d %d", RW, RA, RB, RD, PW, PA, PB, PD);
  
  // increment inputs
  PW = PW + 1;
  RW = RW + 1;
  RA = RA + 1;
  RB = RB + 1;
  RD = RD + 1;
  
  // read registers again (output should be updated)
  RA = 0;
  RB = 31;
  RD = 30;
  #2;
  $display("%d %d %d %d %d %d %d %d", RW, RA, RB, RD, PW, PA, PB, PD);
  
  // increment inputs again
  PW = PW + 1;
  RW = RW + 1;
  RA = RA + 1;
  RB = RB + 1;
  RD = RD + 1;
  
  // read registers again (output should be updated)
  RA = 0;
  RB = 31;
  RD = 30;
  #2;
  $display("%d %d %d %d %d %d %d %d", RW, RA, RB, RD, PW, PA, PB, PD);
  
  // keep incrementing inputs until RA reaches 31
  repeat (27) begin
    PW = PW + 1;
    RW = RW + 1;
    RA = RA + 1;
    RB = RB + 1;
    RD = RD + 1;
    #4;
    $display("%d %d %d %d %d %d %d %d", RW, RA, RB, RD, PW, PA, PB, PD);
  end
end

always #1 clk = ~clk; // toggle clock every 1 time unit

endmodule
