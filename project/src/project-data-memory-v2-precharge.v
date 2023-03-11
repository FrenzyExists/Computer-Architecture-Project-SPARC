`timescale 1ns / 1ns
// Data memory pre-load - Victor Barriera

module ram_512x8_precharge;

    integer fi, fo, code, i; 

    reg Enable, ReadWrite; 
    reg [31:0] DataIn;
    reg [1:0] Size;
    reg [1:0] SignExtend;

    reg [32:0] data;
    reg [8:0] Address; 
    wire [31:0] DataOut;

    ram_512x8 ram1 (
        .Enable(Enable),
        .DataIn(DataIn),
        .ReadWrite(ReadWrite),
        .SignExtend(SignExtend),
        .Size(Size),

        .DataOut(DataOut),
        .Address(Address)
    );

    initial begin
        fi = $fopen("test-file.txt","r");
        Address = 9'b000000000;
        while (!$feof(fi)) begin
            code = $fscanf(fi, "%d", data);
            ram1.Mem[Address] = data;
            Address = Address + 1;
            // #10 $display("Address = %d  code = %b, time=%d", Address, code, $time);
        end
        $fclose(fi);
    end

    initial begin
        fo = $fopen("memcontent.txt", "w");

        Enable = 1'b0; ReadWrite = 1'b0;
        Address = 9'b000000000;

        repeat (12) begin 
            #5 Enable = 1'b1;
            #5 SignExtend = 1'b0;

            #5 Enable = 1'b0;
            #5 SignExtend = 1'b0;

            #5 Enable = 1'b1;
            #5 SignExtend = 1'b1;

            #5 Enable = 1'b0;
            #5 SignExtend = 1'b1;

            Address = Address + 1;
            $display("Address = %d  DataOut = %h, time=%d", Address, DataOut, $time);
            end
            $finish;
        end
        always @ (posedge Enable) #10
        begin
        $fdisplay(fo,"data en %d = %h %d",Address, DataOut, $time);
    end
endmodule