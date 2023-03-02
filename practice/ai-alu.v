module alu (
  input [7:0] a, b,
  input [2:0] op,
  output reg [7:0] out
);

always @(*) begin
  case (op)
    3'b000: out = a + b; // Add
    3'b001: out = a - b; // Subtract
    3'b010: out = a & b; // Bitwise AND
    3'b011: out = a | b; // Bitwise OR
    3'b100: out = a ^ b; // Bitwise XOR
    3'b101: out = a << 1; // Shift left
    3'b110: out = a >> 1; // Shift right
    default: out = 8'hZZ; // Unknown operation
  endcase
end

endmodule
