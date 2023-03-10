// Instruction memory - Victor Barriera

module rom_512x8 (output reg [7:0] DataOut, input [8:0] Address);
    reg [7:0] Mem[0:511];       //512 8bit locations

    always@(Address)            //Loop when Address changes
        DataOut <= {Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]};
endmodule

module rom_precharge;

    integer fi, fo, code, i; 
    reg [32:0] data;
    reg [8:0] Address; 
    wire [7:0] DataOut;

    rom_512x8 ram1 (
        .DataOut(DataOut),
        .Address(Address)
    );

    initial begin
        fi = $fopen("test-file.txt","r");
        Address = 7'b0000000;
        while (!$feof(fi)) begin
            code = $fscanf(fi, "%d", data);
            ram1.Mem[Address] = data;
            Address = Address + 1;
        end
        $fclose(fi);
    end

    initial begin
        fo = $fopen("memcontent.txt", "w");
        Address = 7'b0000000;
        repeat (12) begin #100
            Address = Address + 1;
            $display("Address = %d  DataOut = %h, time=%d", Address, DataOut, $time);
            end
            $finish;
        end
        always @ (Address) #10
        begin
        $fdisplay(fo,"data en %d = %h %d",Address, DataOut, $time);
    end
endmodule