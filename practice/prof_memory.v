module ram128x32 (
    output reg [31:0] DataOut, 
    input Enable, ReadWrite, 
    input [6:0] Address, 
    input [31:0] DataIn
    );
    reg [31:0] Mem[0:127]; //128 localizaciones de 32 bits
    always @ (Enable, ReadWrite)
    if (Enable)
        if (ReadWrite) DataOut = Mem[Address];
        else Mem[Address] = DataIn;
endmodule