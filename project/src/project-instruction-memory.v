//instruction memory - Victor Barriera

module ram_512x8 (output reg [7:0] DataOut, input Enable, ReadWrite, input [6:0] Address, input [7:0] DataIn);

reg [7:0] Mem[0:511];       //512 8bit locations

always@(Enable, ReadWrite)
    if (Enable) 
        if(ReadWrite) DataOut = Mem[Address];
        else Mem[Address] = DataIn;

endmodule