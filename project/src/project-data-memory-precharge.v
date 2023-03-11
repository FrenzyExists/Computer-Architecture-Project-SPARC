module RAM_Access;
    integer fi, fo, code, i; 
    reg [31:0] data;
    reg Enable, ReadWrite; 
    reg [31:0] DataIn;
    reg [8:0] Address;
    reg [1:0] sign_extend;
    wire [31:0] DataOut;
    

    ram_512x8 dut(
        .DataOut(DataOut),
        .clock(Enable),
        .R_W(ReadWrite),
        .Address(Address),
        .DataIn(DataIn),
        .SignExtend(sign_extend)
    );

    initial begin
        fi = $fopen("test-file.txt","r");
        Address = 9'b0000000;
        while (!$feof(fi)) begin
            code = $fscanf(fi, "%d", data);
            ram_512x8.Mem[Address] = data;
            Address = Address + 1;
        end
        
    $fclose(fi);
    end

    initial begin
        fo = $fopen("memcontent.txt", "w");
        Enable = 1'b0; ReadWrite = 1'b1;
        Address = #1 9'b0000000;
        repeat (10) begin
            #5 Enable = 1'b1;
            #5 sign_extend = 1'b0;

            #5 Enable = 1'b0;
            #5 sign_extend = 1'b0;

            #5 Enable = 1'b1;
            #5 sign_extend = 1'b1;

            #5 Enable = 1'b0;
            #5 sign_extend = 1'b1;

            Address = Address + 1;
        end
        $finish;
    end
        always @ (posedge Enable)
        begin
        #1;
        $fdisplay(fo,"data en %d = %b %d", Address, DataOut, $time);
    end

endmodule