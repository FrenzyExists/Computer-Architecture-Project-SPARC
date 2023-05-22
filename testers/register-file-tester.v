`timescale 1ns / 1ns

//Test for Register File 
module register_file_tester;

    //Inputs
    reg [31:0] PW;
    reg [4:0] RW, RA, RB, RD;
    reg LE, Clk;

    //Outputs
    wire [31:0] PA, PB, PD;

    //Instantiating RegisterFile module
    register_file regFile (PA, PB, PD, PW, RW, RA, RB, RD, LE, Clk);

    //Running clock
    initial begin
        
        RA = 5'b00000;
        RB = 5'b11111;
        RD = 5'b11110;
        PW = 32'b00000000000000000000000000010100; //20
        RW = 5'b00000; //0

        #1 //una unidad de tiempo para la estabilizacion de las señales

        repeat (32) begin //cada cuatro unidades de tiempo se debe incrementar por uno los valores de PW, RW, RA, RB y RD hasta que RA alcance el valor de 31.
        #4 Clk = ~Clk; //clock period
        RW = RW + 1;
        RA = RA + 1;
        RB = RB + 1;
        RD = RD + 1;
        PW = PW + 1;
        #4;
        end

    end

    initial begin   
        // Se inicializa el reloj en cero a tiempo cero y luego debe cambiar de estado cada dos unidades de tiempo de manera perpetua.
        Clk = 0;
        LE = 1;
        forever #2 Clk = ~Clk;

    end


    initial begin
        $display ("  PW         PA          PB         PD    ||||  RW    RA     RB   RD  LE Clk");
        $monitor("%h | %h | %h | %h |||| %b %b %b %b %b %b", PW, PA, PB, PD, RW, RA, RB, RD, LE, Clk);

    end

    initial 
        #200 $finish;

endmodule