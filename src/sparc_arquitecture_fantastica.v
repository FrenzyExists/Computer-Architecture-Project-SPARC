`timescale 1ns / 1ns


module sparc_fantastica;

    // Control Unit inputs & outputs
    wire [13:0] cu_out;
    reg [31:0] instruction;

    // Mux Control Unit inputs & outputs
    reg S;


    // Data Memory inputs & outputs
    wire [31:0] DataOut;
    reg ReadWrite, Enable;
    reg [31:0] Address;
    reg [31:0] DataIn;
    reg [1:0] Size;
    reg[7:0] dataDM; 
    integer fi,fo,code,i;
    reg [31:0] DataDump;


    // Hazard/forwarding unit
    wire [1:0] HFU_Forw_PA, HFU_Forw_PB, HFU_Forw_PC;
    wire HFU_NOP, HFU_IFID_LE, HFU_LE_PC;

    // Mux outputs
    wire [31:0] mux1, mux2, mux3;


    // Instruction Memory

    // Data Memory


    // Initialize Thing

    pipeline_IF_ID IF_ID();
    // ID Stage

    reset_handler RESET();

    SE_adder_mult YES();

    control_unit CU();
    control_unit_mux CMUX();

    register_file REG();


    mux_4x1 MX1();
    mux_4x1 MX2();
    mux_4x1 MX3();

    // EX State

    alu ALU_BOI();

    operand_handler OPERAND();

    condition_handler CONDITION();

    pipeline_EX_MEM EX_MEM();

    // MEM State 

    
    
    output_handler OUTPUT();

    pipeline_MEM_WB MEM_WB();

    // WB Stage




    initial begin
        $display(" PC   NPC   Mem Address  RS1  RS2  RD  OP  OP3   Data Out  SE  A B ALU TIME");
        $monitor();
    end


endmodule