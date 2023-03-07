
module ram_512x8_tb;

  // Instantiate the module under test
  reg [7:0] DataIn;
  wire [7:0] DataOut;
  reg Enable, ReadWrite;
  reg [6:0] Address;
  
  ram_512x8 dut(
    .DataOut(DataOut),
    .Enable(Enable),
    .ReadWrite(ReadWrite),
    .Address(Address),
    .DataIn(DataIn)
  );

  // Drive the inputs and observe the outputs
  initial begin
    // Write data to memory location 0
    Enable = 1;
    ReadWrite = 0;
    Address = 0;
    DataIn = 8'hFF;
    #10;
    
    // Read data from memory location 0 and verify
    Enable = 1;
    ReadWrite = 1;
    Address = 0;
    #10;
    if (DataOut !== 8'hFF) $error("Test failed: incorrect data read from memory location 0");
    
    // Write data to memory location 100
    Enable = 1;
    ReadWrite = 0;
    Address = 100;
    DataIn = 8'hA5;
    #10;
    
    // Read data from memory location 100 and verify
    Enable = 1;
    ReadWrite = 1;
    Address = 100;
    #10;
    if (DataOut !== 8'hA5) $error("Test failed: incorrect data read from memory location 100");
    
    // Disable the RAM and attempt to read and write
    Enable = 0;
    ReadWrite = 1;
    Address = 0;
    #10;
    if (DataOut !== 8'h00) $error("Test failed: RAM should not respond when disabled");
    
    Enable = 0;
    ReadWrite = 0;
    Address = 0;
    DataIn = 8'hAA;
    #10;
    if (DataOut !== 8'h00) $error("Test failed: RAM should not respond when disabled");
    
    $display("Testbench completed successfully");
    $finish;
  end
  
endmodule