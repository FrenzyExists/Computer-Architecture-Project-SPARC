//Register File de 32 registros de 32 bits y 3 puertos de salida.

//Escrito por: Victor Hernandez (802-19-4188)

module register_file (output [31:0] PA, PB, PD, input [31:0] PW,  input [4:0] RW, RA, RB, RD, input LE, Clk);
    //Outputs: Puertos A, B y D
    //Inputs: Puerto de Entrada (PW), RW (Write Register) y LE (BinaryDecoder Selector y "load"), 
    //RA, RB y RD  (Selectors de multiplexers a la salida), y Clk (Clock)

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
    mux_32x1_32bit mux_32x1A (PA, RA, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9,
                    Q10, Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18, Q19, Q20, Q21, Q22, 
                    Q23, Q24, Q25, Q26, Q27, Q28, Q29, Q30, Q31);
    //Multiplexer for PB register
    mux_32x1_32bit mux_32x1B (PB, RB, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9,
                    Q10, Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18, Q19, Q20, Q21, Q22, 
                    Q23, Q24, Q25, Q26, Q27, Q28, Q29, Q30, Q31);
    //Multiplexer for PD register
    mux_32x1_32bit mux_32x1D (PD, RD, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9,
                    Q10, Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18, Q19, Q20, Q21, Q22, 
                    Q23, Q24, Q25, Q26, Q27, Q28, Q29, Q30, Q31);                
   
    
    //Insanciando registros del 0 al 31
    register_32bit R0 (Q0, PW, Clk, E[0]);
    register_32bit R1 (Q1, PW, Clk, E[1]);
    register_32bit R2 (Q2, PW, Clk, E[2]);
    register_32bit R3 (Q3, PW, Clk, E[3]);
    register_32bit R4 (Q4, PW, Clk, E[4]);
    register_32bit R5 (Q5, PW, Clk, E[5]);
    register_32bit R6 (Q6, PW, Clk, E[6]);
    register_32bit R7 (Q7, PW, Clk, E[7]);
    register_32bit R8 (Q8, PW, Clk, E[8]);
    register_32bit R9 (Q9, PW, Clk, E[9]);
    register_32bit R10 (Q10, PW, Clk, E[10]);
    register_32bit R11 (Q11, PW, Clk, E[11]);
    register_32bit R12 (Q12, PW, Clk, E[12]);
    register_32bit R13 (Q13, PW, Clk, E[13]);
    register_32bit R14 (Q14, PW, Clk, E[14]);
    register_32bit R15 (Q15, PW, Clk, E[15]);
    register_32bit R16 (Q16, PW, Clk, E[16]);
    register_32bit R17 (Q17, PW, Clk, E[17]);
    register_32bit R18 (Q18, PW, Clk, E[18]);
    register_32bit R19 (Q19, PW, Clk, E[19]);
    register_32bit R20 (Q20, PW, Clk, E[20]);
    register_32bit R21 (Q21, PW, Clk, E[21]);
    register_32bit R22 (Q22, PW, Clk, E[22]);
    register_32bit R23 (Q23, PW, Clk, E[23]);
    register_32bit R24 (Q24, PW, Clk, E[24]);
    register_32bit R25 (Q25, PW, Clk, E[25]);
    register_32bit R26 (Q26, PW, Clk, E[26]);
    register_32bit R27 (Q27, PW, Clk, E[27]);
    register_32bit R28 (Q28, PW, Clk, E[28]);
    register_32bit R29 (Q29, PW, Clk, E[29]);
    register_32bit R30 (Q30, PW, Clk, E[30]);
    register_32bit R31 (Q31, PW, Clk, E[31]);

endmodule



//REGISTER - The register takes care of charging the data in D to the Q output register.
//Ld signal will indicate the register that isn't 0 and make Q the output for the bits in the register.
//Clk is the clock that syncs the register with the rest.

module register_32bit (output reg [31:0] Q, input [31:0] D, input Clk, Ld);
    always @ (posedge Clk)
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