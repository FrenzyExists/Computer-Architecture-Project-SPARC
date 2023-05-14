

module PC_nPC_Register(
    input           clk,
    input           clr,
    input           reset,
    input           LE,
    input [31:0]    nPC,
    input [31:0]    ALU_OUT,
    input [31:0]    TA,
    input [1:0]     mux_select,
    output reg [31:0]   OUT
    );

    always @ (posedge clk, negedge clr) begin
        if (clr == 0 && clk == 1) begin
            if(reset) begin
                OUT <= 32'b0;
            end else if (LE) begin
                case (mux_select)
                    2'b00: OUT <= nPC;
                    2'b01:  OUT <= TA;
                    2'b10:  OUT <= ALU_OUT;
                    default: OUT <= OUT;
                endcase
            end
        end
    end 
endmodule


module PC_adder (
    input wire [31:0] PC_in,
    output reg [31:0] PC_out
    );
    always @(*) begin
        PC_out <= PC_in + 4;
    end

endmodule


module register (
    output reg [31:0] OUT, 
    input [31:0] IN, 
    input LE, clk, reset, clr
    );

    always @ (posedge clk, negedge clr) begin
        // $display("PC reset value: %b | clk = %b | time:%d", reset, clk, $time);
        if (clr == 0 && clk == 1) begin
            if(reset) begin
                OUT <= 32'b0;
            end else if (LE) begin
                OUT <= IN;
            end
        end
    end 
endmodule

module tester;
    wire [31:0] PC;
    wire [31:0] PC_4;
    wire [31:0] nPC;
    reg LE;
    reg clr;
    reg clk;
    reg reset;


    // These are more for phase 4
    reg [1:0] PC_MUX = 2'b00;
    reg [31:0] TA;
    reg [31:0] ALU_OUT;

    // Clock generator
    initial begin
        clr <= 1'b1;
        clk <= 1'b0;
        repeat(2) #2 clk = ~clk;
        clr <= 1'b0;
        repeat(12) begin
            #2 clk = ~clk;
        end
    end

    // register nPC_reg (
    //     .clk(clk),
    //     .clr(clr),
    //     .reset(reset),
    //     .LE(LE),
    //     .IN(PC_4),
    //     .OUT(nPC)
    // );


    PC_adder adder (
        .PC_in(PC),
        .PC_out(nPC)
    );


    // register PC_reg(
        // .clk    (clk),
        // .clr    (clr),
        // .reset  (reset),
        // .LE     (LE),
    //     .IN     (nPC),
    //     .OUT    (PC)
    // );

    PC_nPC_Register PC_reg(
        .clk        (clk),
        .clr        (clr),
        .reset      (reset),
        .LE         (LE),
        .nPC        (nPC),
        .ALU_OUT    (ALU_OUT),
        .TA         (TA),
        .mux_select (PC_MUX),
        .OUT        (PC)

    );




    initial begin
        #52;
        $finish;
    end 

    initial begin
        $monitor("PC: %d | nPC: %d | PC+4: %d", PC, nPC, PC_4);
    end

    initial begin
        LE = 1'b1;
        reset = 1;
        #8;
        reset = 0;
        #12;
    end
endmodule