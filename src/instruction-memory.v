// Instruction memory - Victor Barriera
`timescale 1ns / 1ps


module rom_512x8 (output reg [31:0] DataOut, input [8:0] Address);
    reg [7:0] Mem[0:511];       //512 8bit locations

    always@(Address)            //Loop when Address changes
        DataOut <= {Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]};
endmodule

module rom_precharge;

    integer fi, fo, code, i; 
    reg [32:0] data;
    reg [8:0] Address, Addr; 
    wire [31:0] DataOut;


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

    initial begin
            $monitor("Address = %d  DataOut = %b, time=%d", Address, DataOut, $time);
    end

    initial begin
        #20
        $finish;
    end 

    initial begin
        Address = 9'b000000000;
        repeat (3) begin 
            #1
            Address = Address + 4;
            end
        end
endmodule
