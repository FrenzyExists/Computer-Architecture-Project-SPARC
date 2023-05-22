
module rom_precharge;
    integer fi, fo, code, i; 
    reg [32:0] data;
    reg [7:0] Address, Addr; 
    wire [31:0] DataOut;

    rom_512x8 ram1 (
        DataOut,
        Address
    );

    initial begin
        fi = $fopen("precharge/instruction-precharge.txt","r");
        Addr = 7'b0;
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
        Address = 7'b0;
        repeat (3) begin 
            #1
            Address = Address + 4;
            end
        end
endmodule
