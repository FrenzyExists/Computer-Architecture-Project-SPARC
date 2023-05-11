`timescale 1ns / 1ns
// Data memory pre-load - Victor Barriera

module rom_512x8 (output reg [31:0] DataOut, input [8:0] Address);
    reg [7:0] Mem[0:511];       //512 8bit locations

    always@(Address)            //Loop when Address changes
        DataOut <= {Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]};
endmodule

module control_unit_test;

    integer fi, fo, code, i; 
    reg [32:0] data;
    reg [8:0] Address, Addr; 
    wire [31:0] DataOut;

    // Declare inputs
    // reg [31:0] instr;
    reg clk;
    reg clr;


    // Declare outputs
    wire [18:0] instr_signals;



    // Instantiate the control_unit module
    control_unit dut(
        .instr(DataOut),
        .clk(clk),
        .clr(clr),
        .instr_signals(instr_signals)
    );


    rom_512x8 ram1 (
        DataOut,
        Address
    );

    initial begin
        fi = $fopen("precharge/sparc-instructions-precharge.txt","r");
        Addr = 9'b000000000;
        while (!$feof(fi)) begin
            code = $fscanf(fi, "%b", data);
            ram1.Mem[Addr] = data;
            Addr = Addr + 1;
        end
        $fclose(fi);
    end


    // Clock generator
    initial begin
        clr <= 1'b1;
        clk <= 1'b0;
        repeat(2) #2 clk = ~clk;
        clr <= 1'b0;
        repeat(64) begin
            #2 clk = ~clk;
        end
    end

    initial begin
            $monitor("Address = %d, clk = %b, clr = %b  DataOut = %b, instr_signals = %b, time=%d", Address, clk, clr, DataOut, instr_signals, $time);
    end

    initial begin
        #100
        $finish;
    end 

    initial begin
        Address = 9'b000000000;
        repeat (15) begin
            #6;
            Address = Address + 4;
        end
        // #4
        // Address = Address + 4;
        // #8
        // Address = Address + 4;
        // #12
        // Address = Address + 4;
        // #16;
        // Address = Address + 4;
        // #20;
        // Address = Address + 4;
        // #24;
        // Address = Address + 4;
        // #28;
        // Address = Address + 4;
        // #32;
        // Address = Address + 4;
        // #36;

        end
endmodule


// module control_unit_test;

//     // Declare inputs
//     reg [31:0] instr;
//     reg clk;
//     reg clr;

//     // Declare outputs
//     wire [18:0] instr_signals;


//     integer fi, fo, code, i; 
//     reg [32:0] data;
//     reg [8:0] Address, Addr; 
//     wire [31:0] DataOut;


//     rom_512x8 ram1 (
//         DataOut,
//         Address
//     );

//     initial begin
//         fi = $fopen("precharge/sparc-instructions-precharge.txt","r");
//         Addr = 9'b000000000;
//         while (!$feof(fi)) begin
//             code = $fscanf(fi, "%b", data);
//             ram1.Mem[Addr] = data;
//             Addr = Addr + 1;
//         end
//         $fclose(fi);
//     end





//     // Instantiate the control_unit module
//     control_unit dut(
//         .instr(instr),
//         .clk(clk),
//         .clr(clr),
//         .instr_signals(instr_signals)
//     );

    // // Clock generator
    // initial begin
    //     clr <= 1'b1;
    //     clk <= 1'b0;
    //     repeat(2) #2 clk = ~clk;
    //     clr <= 1'b0;
    //     repeat(64) begin
    //         #2 clk = ~clk;
    //     end
    // end


//     // Test case 1: Reset state
//     initial begin
//         $monitor("Test case : instr = %b clk = %b clr = %b instr_signals = %b TIME = %d", instr, clk, clr, instr_signals, $time);
        
//         // Don't touch, if it ain't broke, don't fix it :)
//         instr = 32'b0;
//         #4;
//         instr = 32'b0;
//         Address = 9'b000000000;
//         #8;
//         // Address = Address + 4;
//         instr = DataOut;
//         #12;
//         instr = 32'b10000110101000001110000000000001;
//         #16;
//         instr = 32'b11000100000010000000000000000001;
//         #20;
//         instr = 32'b11001010001010000110000000000001;
//         #24;
//         instr = 32'b00010010101111111111111111111110;
//         #28;
//         instr = 32'b00001011000011110000111100000110;
//         #32;
//         instr = 32'b01000000000000000000000000000100;
//         // #36;


//         // $finish; // End the simulation
//     end
// endmodule