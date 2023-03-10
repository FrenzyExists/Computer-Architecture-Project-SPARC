module register_file_3_port (
  input [4:0] RA, RB, RD, // register inputs for reading
  input [4:0] RW, // register inputs for writing
  input [31:0] PW, // data input for writing
  input LE, // latch enable input for writing
  input clk, // clock input
  output wire [31:0] PA, PB, PD // output ports
);

//eliminar array e instanciar mejor el modulo
//crear modulo para cada uno de los componentes
//modulo de registro, binary dec, multiplexor
//instanciar todos los componentes en el modulo de prueba
 
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
  // initialize 
  RA = 0;
  RB = 31;
  RD = 30;
  RW = 0;
  PW = 20;
  LE = 1;
  clk = 0;
  
  #10; // delay de 10
  
  // read register 0 (output should be 0)
  RA = 0;
  #2;
  $monitor("%d %d %d %d %d %d %d %d", RW, RA, RB, RD, PW, PA, PB, PD);
  
  // read registers 0, 30, and 31
  RA = 0;
  RB = 31;
  RD = 30;
  #2;
  //cambiar a delay de 4 y añadir repeat
  //la primera suma se le pone un delay de 4 ay a las otras no
  $monitor("%d %d %d %d %d %d %d %d", RW, RA, RB, RD, PW, PA, PB, PD);
  
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
  $monitor("%d %d %d %d %d %d %d %d", RW, RA, RB, RD, PW, PA, PB, PD);
  
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
  $monitor("%d %d %d %d %d %d %d %d", RW, RA, RB, RD, PW, PA, PB, PD);
  
  // keep incrementing inputs until RA reaches 31
  repeat (27) begin
    PW = PW + 1;
    RW = RW + 1;
    RA = RA + 1;
    RB = RB + 1;
    RD = RD + 1;
    #4;
    $monitor("%d %d %d %d %d %d %d %d", RW, RA, RB, RD, PW, PA, PB, PD);
  end
end

always #1 clk = ~clk; // toggle clock every 1 time unit

endmodule

// A simple register file with three read ports and one write port. 
// The module has five input ports and three output ports.

// The input ports are:

// RA: a 5-bit input that specifies which register to read from for port A.
// RB: a 5-bit input that specifies which register to read from for port B.
// RD: a 5-bit input that specifies which register to read from for port D.
// RW: a 5-bit input that specifies which register to write to.
// PW: a 32-bit input that contains the data to be written to the register specified by RW.
// LE: a 1-bit input that is used as a latch enable signal for writing data.
// The output ports are:

// PA: a 32-bit output that contains the data read from the register specified by RA.
// PB: a 32-bit output that contains the data read from the register specified by RB.
// PD: a 32-bit output that contains the data read from the register specified by RD.
// The register file is implemented as an array of 32 32-bit registers called "registers". 
// The output ports PA, PB, and PD are assigned to the value of the corresponding register specified 
// by RA, RB, and RD, respectively. If the register address is 0, the output value is always 0.

// The data input PW is written to the register specified by RW on the positive edge of the clock 
// if the latch enable signal LE is high. The value of PW is stored in the array element corresponding 
// to the register address RW.
