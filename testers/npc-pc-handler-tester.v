`include "src/npc-pc-handler.v"

module npc_pc_handler_tester;
    wire [31:0] PC;
    wire [31:0] PC_4;
    wire [31:0] nPC;
    reg LE;
    reg clr;
    reg clk;

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

    PC_adder adder (
        .PC_in(PC),
        .PC_out(nPC)
    );

    PC_nPC_Register PC_reg(
        .clk        (clk),
        .clr        (clr),
        .LE         (LE),
        .nPC        (nPC),
        .ALU_OUT    (ALU_OUT),
        .TA         (TA),
        .mux_select (PC_MUX),
        .OUT        (PC)
    );

    initial begin
        $dumpfile("gtk-wave-testers/npc-pc-handler.vcd"); // pass this to GTK Wave to visualize better wtf is going on
        $dumpvars(0, npc_pc_handler_tester);
        #52;
        $finish;
    end 

    initial begin
        $monitor("PC: %d | nPC: %d | PC+4: %d", PC, nPC, PC_4);
    end

    initial begin
        LE = 1'b1;
        #8;
        LE = 1'b0;
        #12;
    end
endmodule