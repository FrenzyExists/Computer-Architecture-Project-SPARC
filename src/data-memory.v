
module ram_512x8 (
    output reg [31:0] DataOut, 
    input Enable, ReadWrite, SignExtend,
    input [7:0] Address, 
    input [31:0] DataIn,
    input [1:0] Size
    );

    reg [7:0] Mem[0:511];
    
    always @ (*)
    if (Enable)
        if (ReadWrite) begin
            // Writing Operation
            case (Size)
                3'b00:  begin
                    Mem[Address] <= DataIn[7:0];
                    $display("%d    %h", Address, DataIn);
                end
                3'b01: begin
                    Mem[Address] <= DataIn[15:8];
                    Mem[Address+1] <= DataIn[7:0];
                end
                3'b10: begin
                    Mem[Address] <= DataIn[31:24];
                    Mem[Address + 1] <= DataIn[23:16];
                    Mem[Address + 2] <= DataIn[15:8];
                    Mem[Address + 3] <= DataIn[7:0];
                 end
            endcase
        end
        else begin
            // Reading Operation
            case ({Size, SignExtend})
                3'b000: DataOut <= {24'b000000000000000000000000, Mem[Address]};
                3'b001: DataOut <= {{24{Mem[Address][7]}}, Mem[Address]};
                3'b010: DataOut <= {16'b0000000000000000, Mem[Address], Mem[Address+1]};
                3'b011: DataOut <= {{16{Mem[Address][7]}}, Mem[Address], Mem[Address+1]};
                default:DataOut <= {Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]};
            endcase
        end
endmodule