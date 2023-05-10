`timescale 1ns / 1ns
// Data memory pre-load - Victor Barriera

module ram_512x8_precharge;

    integer fi, fo, code, i, data; 

    wire [31:0] DataOut;
    reg Enable, ReadWrite, SignExtend;
    reg [8:0] Address;
    reg [31:0] DataIn;
    reg [1:0] Size;

    ram_512x8 ram1 (
        DataOut, 
        Enable, 
        ReadWrite, 
        SignExtend,
        Address, 
        DataIn,
        Size
    );

    initial begin
        fi = $fopen("precharge/sparc-instructions-precharge.txt","r");
        Address = 9'b000000000;
        while (!$feof(fi)) begin
            code = $fscanf(fi, "%b", data);
            ram1.Mem[Address] = data;
            Address = Address + 1;
            // #10 $display("Address = %d  code = %b, time=%d", Address, code, $time);
        end
        $fclose(fi);
    end

    initial begin
            $monitor("Address = %d  DataOut = %h, time=%d", Address, DataOut, $time);
    end

    initial begin
        #20
        $finish;
    end

    initial begin
        Enable = 1'b1; ReadWrite = 1'b0; Size = 2'b11; 
        Address = 9'b000000000;
        #1
        Address = Address + 4;
        #1
        Address = Address + 4;
        #1
        Address = Address + 4;
        #1
        $display("Read Mode");
        Enable = 1'b1; ReadWrite = 1'b0; Size = 2'b00; SignExtend = 1'b0;
        Address = 9'b000000000;
        #1
        Enable = 1'b1; ReadWrite = 1'b0; Size = 2'b01; SignExtend = 1'b0;
        Address = Address + 2;
        #1
        Enable = 1'b1; ReadWrite = 1'b0; Size = 2'b01; SignExtend = 1'b0;
        Address = Address + 2;
        #1
        Enable = 1'b1; ReadWrite = 1'b0; Size = 2'b00; SignExtend = 1'b1;
        Address = 9'b000000000;
        #1
        Enable = 1'b1; ReadWrite = 1'b0; Size = 2'b01; SignExtend = 1'b1;
        Address = Address + 2;
        #1
        Enable = 1'b1; ReadWrite = 1'b0; Size = 2'b01; SignExtend = 1'b1;
        Address = Address + 2;
        #1
        Enable = 1'b1; ReadWrite = 1'b1; Size = 2'b00; 
        Address = 9'b000000000;
        DataIn = 32'h000000a6; 
        #1
        Enable = 1'b1; ReadWrite = 1'b1; Size = 2'b01; 
        Address = Address + 2;
        DataIn = 32'h0000bbcc; 
        #1
        Enable = 1'b1; ReadWrite = 1'b1; Size = 2'b01; 
        Address = Address + 2;
        DataIn = 32'h00aab419; 
        #1
        Enable = 1'b1; ReadWrite = 1'b1; Size = 2'b10; 
        Address = Address + 4;
        DataIn = 32'haeeabba6; 
        #1
        Enable = 1'b1; ReadWrite = 1'b0; Size = 2'b11; 
        Address = 9'b000000000;
        #1
        Address = Address + 4;
        #1
        Address = Address + 4;
    end
endmodule