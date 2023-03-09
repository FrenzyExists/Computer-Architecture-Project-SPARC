module RAM (
    input [8:0] Address,
    input clock,
    input R_W,
    input [1:0] Size,
    input SignExtend,
    input [31:0] DataIn,
    output reg [31:0] DataOut
);

reg [7:0] Mem [0:511]; // 512 locations of 8bits

always @(posedge clock) begin
    if (R_W) begin
        case ({Size, SignExtend})
            // Size = 00, SE = 0
            2'b0010: Mem[Address] <= DataIn[7:0];

            // Size = 00, SE = 1
            2'b0011: Mem[Address] <= {{24{DataIn[7]}}, DataIn[7:0]};

            // Size = 01, SE = 0
            2'b1000: begin
                Mem[Address] <= DataIn[15:8];
                Mem[Address+1] <= DataIn[7:0];
            end

            // Size = 01, SE = 1
            2'b1100: begin
                Mem[Address] <= {{8{DataIn[15]}}, DataIn[15:8]};
                Mem[Address+1] <= DataIn[7:0];
            end

            // Size = 10
            2'b0100: begin
                Mem[Address] <= DataIn[31:24];
                Mem[Address+1] <= DataIn[23:16];
                Mem[Address+2] <= DataIn[15:8];
                Mem[Address+3] <= DataIn[7:0];
            end

            default: begin end
        endcase
    end
    else begin
        case ({Size, SignExtend})
            // Size = 00, SE = 0
            2'b0010: DataOut <= {24'h000000, Mem[Address]};

            // Size = 00, SE = 1
            2'b0011: DataOut <= {{8{Mem[Address][7]}}, Mem[Address]};

            // Size = 01, SE = 0
            2'b1000: DataOut <= {16'h0000, Mem[Address], Mem[Address+1]};

            // Size = 01, SE = 1
            2'b1100: DataOut <= {{16{Mem[Address][7]}}, Mem[Address], Mem[Address+1]};

            // Size = 10
            2'b0100: DataOut <= {Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]};

            // Size = 11
            default: begin end
        endcase
    end
end

endmodule
