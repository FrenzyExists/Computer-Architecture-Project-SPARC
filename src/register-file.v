//Register File de 32 registros de 32 bits y 3 puertos de salida.

//Escrito por: Victor Hernandez (802-19-4188)
`include "src/decoders.v"
// `include "src/muxes.v"


module register_file (output [31:0] PA, PB, PD, input [31:0] PW,  input [4:0] RW, RA, RB, RD, input LE, clk);
    //Outputs: Puertos A, B y D
    //Inputs: Puerto de Entrada (PW), RW (Write Register) y LE (BinaryDecoder Selector y "load"), 
    //RA, RB y RD  (Selectors de multiplexers a la salida), y clk (Clock)

    //Wires
    wire [31:0] E;
    wire [31:0] Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15, 
    Q16, Q17, Q18, Q19, Q20, Q21, Q22, Q23, Q24, Q25, Q26, Q27, Q28, Q29, Q30, Q31;

    //Instanciando módulos:

    //Binary Decoder for RA,RB,RD
    binaryDecoder bdecoder (E, RW, LE);

    //Los multiplexers a continuacion cogen valor almacenado en el registro 
    //correspondiente y lo envian a las salidas de los registros:

    //Multiplexer for PA register
    mux_32bit mux_32x1A (PA, RA, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9,
                    Q10, Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18, Q19, Q20, Q21, Q22, 
                    Q23, Q24, Q25, Q26, Q27, Q28, Q29, Q30, Q31);
    //Multiplexer for PB register
    mux_32bit mux_32x1B (PB, RB, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9,
                    Q10, Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18, Q19, Q20, Q21, Q22, 
                    Q23, Q24, Q25, Q26, Q27, Q28, Q29, Q30, Q31);
    //Multiplexer for PD register
    mux_32bit mux_32x1D (PD, RD, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9,
                    Q10, Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18, Q19, Q20, Q21, Q22, 
                    Q23, Q24, Q25, Q26, Q27, Q28, Q29, Q30, Q31);                
   
    
    //Insanciando registros del 0 al 31
    register_32bit R0 (Q0, PW, clk, E[0]);
    register_32bit R1 (Q1, PW, clk, E[1]);
    register_32bit R2 (Q2, PW, clk, E[2]);
    register_32bit R3 (Q3, PW, clk, E[3]);
    register_32bit R4 (Q4, PW, clk, E[4]);
    register_32bit R5 (Q5, PW, clk, E[5]);
    register_32bit R6 (Q6, PW, clk, E[6]);
    register_32bit R7 (Q7, PW, clk, E[7]);
    register_32bit R8 (Q8, PW, clk, E[8]);
    register_32bit R9 (Q9, PW, clk, E[9]);
    register_32bit R10 (Q10, PW, clk, E[10]);
    register_32bit R11 (Q11, PW, clk, E[11]);
    register_32bit R12 (Q12, PW, clk, E[12]);
    register_32bit R13 (Q13, PW, clk, E[13]);
    register_32bit R14 (Q14, PW, clk, E[14]);
    register_32bit R15 (Q15, PW, clk, E[15]);
    register_32bit R16 (Q16, PW, clk, E[16]);
    register_32bit R17 (Q17, PW, clk, E[17]);
    register_32bit R18 (Q18, PW, clk, E[18]);
    register_32bit R19 (Q19, PW, clk, E[19]);
    register_32bit R20 (Q20, PW, clk, E[20]);
    register_32bit R21 (Q21, PW, clk, E[21]);
    register_32bit R22 (Q22, PW, clk, E[22]);
    register_32bit R23 (Q23, PW, clk, E[23]);
    register_32bit R24 (Q24, PW, clk, E[24]);
    register_32bit R25 (Q25, PW, clk, E[25]);
    register_32bit R26 (Q26, PW, clk, E[26]);
    register_32bit R27 (Q27, PW, clk, E[27]);
    register_32bit R28 (Q28, PW, clk, E[28]);
    register_32bit R29 (Q29, PW, clk, E[29]);
    register_32bit R30 (Q30, PW, clk, E[30]);
    register_32bit R31 (Q31, PW, clk, E[31]);

    // Uncomment for testing, else don't touch or it won't synthetize
    // always @(*) begin
    //     $display("LE: %b  | PA: %b", LE, PA);
    // end

endmodule

//-----------------Modules that will be instantiated in the file------------------------------//

//MULTIPLEXOR 32X1 - S and R0-R31 are 32bit inputs. Y is a 32bit output.
//A case for S is used to select one of the R0-R31 and assign the output to Y.
//We will be instantiating three of them due to it being a three port register file.

module mux_32bit (output reg [31:0] Y, input [4:0] S, 
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

    // For debugging only, remove before synthetizing
    always @(R5, R6, R16, R17, R18) begin
        $display("R5:  %d | R6:  %d\nR16: %d | R17: %d\nR18: %d\n----------------------------------", R5, R6, R16, R17, R18);
    end
endmodule

//REGISTER - The register takes care of charging the data in D to the Q output register.
//Ld signal will indicate the register that isn't 0 and make Q the output for the bits in the register.
//clk is the clock that syncs the register with the rest.

module register_32bit (output reg [31:0] Q, input [31:0] D, input clk, Ld);
    always @ (posedge clk)
        if(Ld) Q <= D;
endmodule

// Three Port Register File

// Reading:

// El contenido de un registro se coloca en un puerto de salida P cuando el número de registro se especifica 
// en su correspondiente entrada de selección de registro R. Esta acción se lleva a cabo tan pronto como el 
// número de registro se coloca en la entrada R correspondiente (es una acción asíncrona).

// Writing:

// Un número colocado en PW se escribirá en el registro especificado por la entrada RW, si y solo si, LE = 1 y 
// el borde ascendente del reloj toma ritmo (esta es una acción sincrónica).

// RA, RB, RC y RW son números de 5 bits PA, PB, PC y PW son números de 32 bits