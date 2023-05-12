module A(
  input wire clk,
  input wire reset,
  input wire enable,
  input wire [31:0] PC_in,
  output wire [31:0] PC_out
);

  reg [31:0] PC_reg;

  always @(posedge clk) begin
    if (reset) begin
      PC_reg = 0;
    end else if (enable) begin
      PC_reg = PC_in;
    end
  end

  assign PC_out = PC_reg;

endmodule

module B(
  input wire clk,
  input wire reset,
  input wire [31:0] PC_in,
  output wire [31:0] PC_out
);

  reg [31:0] PC_reg;

  always @(posedge clk) begin
    if (reset) begin
      PC_reg = 0;
    end else begin
      PC_reg = PC_in;
    end
  end

  assign PC_out = PC_reg;

endmodule

module top;

    reg clk;
    reg reset;
    reg enable;
    reg [31:0] PC_in;
    wire [31:0] PC_out;

    wire [31:0] A_PC_out;


    // Clock generator
    initial begin
        clk <= 1'b0;
        repeat(2) #2 clk = ~clk;
        repeat(12) begin
            #2 clk = ~clk;
        end
    end


  A A_inst(
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .PC_in(PC_in),
    .PC_out(A_PC_out)
  );

    B B_inst(
    .clk(clk),
    .reset(reset),
    .PC_in(A_PC_out),
    .PC_out(PC_out)
  );

    initial begin
        #13
        $finish;
    end 

    initial begin
        $monitor("Testing a pipeline baseline of sorts: enable: %b | PC_in: %d | PC_out: %d | PC out of B: %d | reset: %b | time %d | clk: %d", enable, PC_in, A_PC_out, PC_out, reset, $time, clk);
    end

    initial begin 
        PC_in = 32'd21;
        reset = 1'b0;
        enable = 1'b0;
        #4;
        PC_in = 32'd21;
        reset = 1'b0;
        enable = 1'b1;
        #4;
        PC_in = 32'd21;
        reset = 1'b1;
        enable = 1'b1;
        #4;

    end


endmodule
