//instruction memory - Victor Barriera

module ram_512x8 (output reg [31:0] DataOut, input [8:0] Address);

reg [7:0] Mem[0:511];       //512 8bit locations

initial begin               //Read file
    $readmemb("test-file.txt", Mem);
    $display("Pre-charge Complete!");
end

always@(Address)            //Loop when Address changes
    DataOut <= {Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]};
    $display("Address = %b  DataOut = %h", Address, DataOut);

endmodule