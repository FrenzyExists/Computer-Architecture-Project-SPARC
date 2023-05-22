`timescale 1ns / 1ns
`include "src/control-unit.v"

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
        Addr = 8'b00000000;
        $display("Precharging Instruction Memory...\n---------------------------------------------\n");
        while (!$feof(fi)) begin
            if (Addr % 4 == 0 && !$feof(fi)) $display("\n\nLoading Next Instruction...\n-------------------------------------------------------------------------");
            code = $fscanf(fi, "%b", data);
            $display("---- %b ----\n", data);
            ram1.Mem[Addr] = data;
            Addr = Addr + 1;
        end
        $fclose(fi);
        Addr = 8'b00000000;
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
        #80
        $finish;
    end 

    initial begin
        Address = 8'b00000000;
        repeat (15) begin
            #6;
            Address = Address + 4;
        end
        end
endmodule