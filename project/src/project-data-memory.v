
module ram_512x8 (
    output reg [31:0] DataOut, 
    input Enable, ReadWrite, 
    input [8:0] Address, 
    input [31:0] DataIn,
    input [1:0] Size,
    input [1:0] SignExtend
    );

    function [31:0] changeEndian;   //transform data from the memory to big-endian form
        input [31:0] value;
        changeEndian = {value[7:0], value[15:8], value[23:16], value[31:24]};
    endfunction

    reg [7:0] Mem[0:511];

    // Fuck it solution
    reg [0:31] fuck_it;
    
    // wire [7:0] C; // Little endian [7] [6] [5] [4] [3] [2] [1] [0]
    // wire [0:7] D; // Big endian    [0] [1] [2] [3] [4] [5] [6] [7]


    always @ (posedge Enable, ReadWrite)
    if (Enable)
        if (ReadWrite) begin
            // Writing Operation
            case (Size)
                3'b00:  begin
                    fuck_it <= changeEndian(DataIn);
                    Mem[Address] <= fuck_it[0:7];
                end
                3'b01: begin
                    fuck_it <= changeEndian(DataIn);
                    Mem[Address] <= {{8{DataIn[15]}}, DataIn[15:8]};
                    Mem[Address+1] <= fuck_it[0:7];
                end
                3'b10: begin
                    fuck_it <= changeEndian(DataIn);
                    Mem[Address] <= DataIn[31:24];
                    Mem[Address + 1] <= DataIn[23:16];
                    Mem[Address + 2] <= DataIn[15:8];
                    Mem[Address + 3] <= fuck_it[0:7];
                 end
                 default: DataOut = 0; // No action
            endcase
        end
        else begin
            // Reading Operation
            case ({Size, SignExtend})
                3'b000: DataOut <= {24'b000000000000000000000000, Mem[Address]};
                3'b001: DataOut <= {{8{Mem[Address][7]}}, Mem[Address]};
                3'b010: DataOut <= {16'b0000000000000000, Mem[Address], Mem[Address+1]};
                3'b011: DataOut <= {{16{Mem[Address][7]}}, Mem[Address], Mem[Address+1]};
                default:DataOut <= {Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]};
            endcase
        end
endmodule