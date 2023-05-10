module mux_4x1  (
    output reg [31:0] Y,
    input [1:0] S, 
    input [31:0] I0, I1, I2, I3
);

always @ (S, I0, I1, I2, I3)
	case (S) 
		2'b00:  Y <= I0;
		2'b01:  Y <= I1;
		2'b10:  Y <= I2;
		2'b11:  Y <= I3;
	endcase
endmodule

module mux_2x1 (
    output reg [31: 0]Y, 
    input S, 
    input[31: 0] I0, I1
);

always @ (S, I0, I1) 
if (S) Y = I1; 
else Y = I0; 
endmodule


//-----------------Modules that will be instantiated in the file------------------------------//

//MULTIPLEXOR 32X1 - S and R0-R31 are 32bit inputs. Y is a 32bit output.
//A case for S is used to select one of the R0-R31 and assign the output to Y.
//We will be instantiating three of them due to it being a three port register file.

module mux_32x1_32bit (output reg [31:0] Y, input [4:0] S, 
input [31:0] R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15,
R16, R17, R18, R19, R20, R21, R22, R23, R24, R25, R26, R27, R28, R29, R30, R31);
    
    always @ (*)
    begin
    case (S)
    5'b00000: Y = R0;
    5'b00001: Y = R1;
    5'b00010: Y = R2;
    5'b00011: Y = R3;
    5'b00100: Y = R4;
    5'b00101: Y = R5;
    5'b00110: Y = R6;
    5'b00111: Y = R7;
    5'b01000: Y = R8;
    5'b01001: Y = R9;
    5'b01010: Y = R10;
    5'b01011: Y = R11;
    5'b01100: Y = R12;
    5'b01101: Y = R13;
    5'b01110: Y = R14;
    5'b01111: Y = R15;
    5'b10000: Y = R16;
    5'b10001: Y = R17;
    5'b10010: Y = R18;
    5'b10011: Y = R19;
    5'b10100: Y = R20;
    5'b10101: Y = R21;
    5'b10110: Y = R22;
    5'b10111: Y = R23;
    5'b11000: Y = R24;
    5'b11001: Y = R25;
    5'b11010: Y = R26;
    5'b11011: Y = R27;
    5'b11100: Y = R28;
    5'b11101: Y = R29;
    5'b11110: Y = R30;
    5'b11111: Y = R31;
    endcase
    end
endmodule