module Three_Port_Register_File (
    input  [4:0] RA,RB,RC,RW,  // Entradas del registro para seleccionar registros A, B, C y el registro de escritura
    input  [31:0] PW,          // Entrada de datos del registro de escritura
    output  [31:0] PA, PB, PC, // Salidas de los registros A, B y C
    input Clk, LE            // Entradas de reloj y carga del registro
);

wire [31:0] O;
wire [31:0] R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,R14,R15,R16,R17,R18,R19,R20,R21,R22,R23,R24,R25,R26,R27,R28,R29,R30,R31;

// Instanciación de los módulos

// Instanciación del decodificador binario para decodificar las entradas RA, RB, RC y activar la selección de registro correspondiente
Binary_Decoder BD (RW,LE,O);

// Instanciación del array de registros de 32 bits cada uno para almacenar los datos en el registro de escritura y en los registros A, B y C
Register Regs0 (PW,R0,O[0],Clk);
Register Regs1 (PW,R1,O[1],Clk);
Register Regs2 (PW,R2,O[2],Clk);
Register Regs3 (PW,R3,O[3],Clk);
Register Regs4 (PW,R4,O[4],Clk);
Register Regs5 (PW,R5,O[5],Clk);
Register Regs6 (PW,R6,O[6],Clk);
Register Regs7 (PW,R7,O[7],Clk);
Register Regs8 (PW,R8,O[8],Clk);
Register Regs9 (PW,R9,O[9],Clk);
Register Regs10 (PW,R10,O[10],Clk);
Register Regs11 (PW,R11,O[11],Clk);
Register Regs12 (PW,R12,O[12],Clk);
Register Regs13 (PW,R13,O[13],Clk);
Register Regs14 (PW,R14,O[14],Clk);
Register Regs15 (PW,R15,O[15],Clk);
Register Regs16 (PW,R16,O[16],Clk);
Register Regs17 (PW,R17,O[17],Clk);
Register Regs18 (PW,R18,O[18],Clk);
Register Regs19 (PW,R19,O[19],Clk);
Register Regs20 (PW,R20,O[20],Clk);
Register Regs21 (PW,R21,O[21],Clk);
Register Regs22 (PW,R22,O[22],Clk);
Register Regs23 (PW,R23,O[23],Clk);
Register Regs24 (PW,R24,O[24],Clk);
Register Regs25 (PW,R25,O[25],Clk);
Register Regs26 (PW,R26,O[26],Clk);
Register Regs27 (PW,R27,O[27],Clk);
Register Regs28 (PW,R28,O[28],Clk);
Register Regs29 (PW,R29,O[29],Clk);
Register Regs30 (PW,R30,O[30],Clk);
Register Regs31 (PW,R31,O[31],Clk);

// Instanciación de los multiplexores de 32x1 para seleccionar el valor almacenado en el registro correspondiente y enviarlo a las salidas de los registros A, B y C
Multiplexer_32x1 MuxA (RA,0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,R14,R15,R16,R17,R18,R19,R20,R21,R22,R23,R24,R25,R26,R27,R28,R29,R30,R31,PA);

Multiplexer_32x1 MuxB (RB,0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,R14,R15,R16,R17,R18,R19,R20,R21,R22,R23,R24,R25,R26,R27,R28,R29,R30,R31,PB);

  Multiplexer_32x1 MuxC (RC,0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,R14,R15,R16,R17,R18,R19,R20,R21,R22,R23,R24,R25,R26,R27,R28,R29,R30,R31,PC);

endmodule


`timescale 1ns / 1ns

module Three_Port_Register_File_tb;

reg clk, LE;
reg [4:0] RA, RB, RC, RW;
reg [31:0] PW;
wire [31:0] PA, PB, PC;

integer i;

Three_Port_Register_File dut (
RA,RB,RC,RW,
PW,
PA, PB, PC,
clk, LE
);

initial begin

PW = 32'b00000000000000000000000000010100;
RW = 5'b00000;
RA = 5'b00000;
RB = 5'b11111;
RC = 5'b11110;

#1; // Espera 1 unidades de tiempo para que las señales iniciales se estabilicen
// Lee y escribe valores en el archivo de registro
  repeat(32) begin
    #4; //periodo del reloj
    RW = RW + 1;
    RA = RA + 1;
    RB = RB + 1;
    RC = RC + 1;
    PW = PW + 1;
    #4;
end

end

initial begin   
    clk = 0;
    LE = 1;
    forever #2 clk = ~clk;
end

initial begin   
  $monitor("RW=%d, RA=%d, RB=%d, RC=%d, PW=%d, PA=%d, PB=%d, PD=%d", RW, RA, RB, RC, PW, PA, PB, PC);
end

initial 
    #200 $finish;

endmodule
/****************************************************************************************/
//Binary Decoder:
// Descripcion:El módulo Binary_Decoder toma una entrada de 5 bits llamada D y una entrada de 1 bit llamada E, y produce una salida de 32 bits llamada O. 
// La salida O es una función de D y E. Si E es 1, la salida O es igual a ~D (complemento a uno de D). Si E es 0, la salida O es 0.


module Binary_Decoder ( //El módulo tiene tres puertos: D, E y O. D es una entrada de 5 bits, E es una entrada de 1 bit y O es una salida de 32 bits.
    input [4:0] D,
    input E,
    output reg [31:0] O
);

always @(*) begin
    if (E == 1'b1) begin
        case (D)
            5'b00000: O = 32'b00000000000000000000000000000001;
            5'b00001: O = 32'b00000000000000000000000000000010;
            5'b00010: O = 32'b00000000000000000000000000000100;
            5'b00011: O = 32'b00000000000000000000000000001000;
            5'b00100: O = 32'b00000000000000000000000000010000;
            5'b00101: O = 32'b00000000000000000000000000100000;
            5'b00110: O = 32'b00000000000000000000000001000000;
            5'b00111: O = 32'b00000000000000000000000010000000;
            5'b01000: O = 32'b00000000000000000000000100000000;
            5'b01001: O = 32'b00000000000000000000001000000000;
            5'b01010: O = 32'b00000000000000000000010000000000;
            5'b01011: O = 32'b00000000000000000000100000000000;
            5'b01100: O = 32'b00000000000000000001000000000000;
            5'b01101: O = 32'b00000000000000000010000000000000;
            5'b01110: O = 32'b00000000000000000100000000000000;
            5'b01111: O = 32'b00000000000000001000000000000000;
            5'b10000: O = 32'b00000000000000010000000000000000;
            5'b10001: O = 32'b00000000000000100000000000000000;
            5'b10010: O = 32'b00000000000001000000000000000000;
            5'b10011: O = 32'b00000000000010000000000000000000;
            5'b10100: O = 32'b00000000000100000000000000000000;
            5'b10101: O = 32'b00000000001000000000000000000000;
            5'b10110: O = 32'b00000000010000000000000000000000;
            5'b10111: O = 32'b00000000100000000000000000000000;
            5'b11000: O = 32'b00000001000000000000000000000000;
            5'b11001: O = 32'b00000010000000000000000000000000;
            5'b11010: O = 32'b00000100000000000000000000000000;
            5'b11011: O = 32'b00001000000000000000000000000000;
            5'b11100: O = 32'b00010000000000000000000000000000;
            5'b11101: O = 32'b00100000000000000000000000000000;
            5'b11110: O = 32'b01000000000000000000000000000000;
            5'b11111: O = 32'b10000000000000000000000000000000;
    endcase
    end
    else 
        O = 32'b00000000000000000000000000000000;
end
endmodule

/****************************************************************************************/

//Registers:
// Descripcion:el módulo Register se encarga de cargar los datos de entrada Ds en el registro Q en la posición indicada 
// por la señal Ld cuando ésta es diferente de 0, y de proporcionar como salida Qs los bits [31:1] del registro Q. 
// La señal Clk es la señal de reloj que se utiliza para sincronizar el registro.

module Register (
    input [31:0] Ds, // Entrada de datos que se cargarán en el registro.
    output reg [31:0] Qs, // Salida del registro.
    input Ld, // Señal que indica cuándo cargar los datos en el registro. //LE en el documento
    input Clk // Señal de reloj.
);

always@(posedge Clk) begin
    if(Ld) Qs <=Ds;
end

endmodule

/****************************************************************************************/

//Multiplexors:
// Descripcion: El módulo Multiplexer_32x1 toma dos entradas de 32 bits llamadas S y D, y produce una salida de 32 bits llamada Y.
// La entrada S especifica qué uno de los 32 bits en D se debe seleccionar y enviar a la salida Y.

module Multiplexer_32x1 (
input [4:0] S, // Entrada selectora de 5 bits
  input [31:0] D0, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15, D16, D17, D18, D19, D20, D21, D22, D23, D24, D25, D26, D27, D28, D29, D30, D31, // Entrada de datos de 32 bits
output reg [31:0] Y // Salida de datos de 32 bits
);

always @ (*)
begin
case(S)
5'b00000: Y = D0;
5'b00001: Y = D1;
5'b00010: Y = D2;
5'b00011: Y = D3;
5'b00100: Y = D4;
5'b00101: Y = D5;
5'b00110: Y = D6;
5'b00111: Y = D7;
5'b01000: Y = D8;
5'b01001: Y = D9;
5'b01010: Y = D10;
5'b01011: Y = D11;
5'b01100: Y = D12;
5'b01101: Y = D13;
5'b01110: Y = D14;
5'b01111: Y = D15;
5'b10000: Y = D16;
5'b10001: Y = D17;
5'b10010: Y = D18;
5'b10011: Y = D19;
5'b10100: Y = D20;
5'b10101: Y = D21;
5'b10110: Y = D22;
5'b10111: Y = D23;
5'b11000: Y = D24;
5'b11001: Y = D25;
5'b11010: Y = D26;
5'b11011: Y = D27;
5'b11100: Y = D28;
5'b11101: Y = D29;
5'b11110: Y = D30;
5'b11111: Y = D31;
endcase
end
endmodule