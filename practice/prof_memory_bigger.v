module ram128x32 (
    output reg [31:0] DataOut, 
    input Enable, ReadWrite, 
    input [8:0] Address, 
    input [31:0] DataIn,
    input [1:0] Size,
    input [1:0] SignExtend
    );
    reg [0:7] Mem[0:511];
    
    // wire [7:0] C; // Little endian [7] [6] [5] [4] [3] [2] [1] [0]
    // wire [0:7] D; // Big endian    [0] [1] [2] [3] [4] [5] [6] [7]


    always @ (posedge Enable, ReadWrite)
    if (Enable)
        if (ReadWrite) begin

            case ({Size, SignExtend})
                3'b000: Mem[Address] = DataIn[0:7];

            endcase

            DataOut = Mem[Address];

        end
        else begin
            Mem[Address] = DataIn;
        end
endmodule