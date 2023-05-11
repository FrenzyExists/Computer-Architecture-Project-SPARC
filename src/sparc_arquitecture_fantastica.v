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


    initial begin
        reset<=1'b1;
        clk<=1'b0;
        repeat(2) #2 clk=~clk;
        reset<=1'b0;
        repeat(100)begin
            #2 clk=~clk;
        end
    end


    // Instruction Memory

    // Data Memory


    // Initialize Thing

    pipeline_IF_ID IF_ID(

    );
    // ID Stage

    reset_handler RESET_HAND(
        .system_reset(),
        .ID_branch_instr(),
        .a(),
        .reset_out()
    );

    SE_adder_mult YES(

    );

    control_unit CU(
        .instr(DataOut),
        .clk(clk),
        .clr(clr),
        .instr_signals(instr_signals)
    );

    control_unit_mux CMUX(
        .ID_jmpl_instr_out(),
        .ID_call_instr_out(),
        .ID_branch_instr_out(),
        .ID_load_instr_out(),
        .ID_register_file_Enable_out(),
        .ID_data_mem_SE(),
        .ID_data_mem_RW(),
        .ID_data_mem_Enable(),
        .ID_data_mem_Size(),
        .I31_ou(),
        .I30_ou(),
        .I24_ou(),
        .I13_ou(),
        .ID_ALU_OP_instr(),
        .CC_Enable(),

        .S(),
        .cu_in_mux()
    );

    register_file REG(
        .PA(), 
        .PB(), 
        .PD(), 
           
        .PW(),
        .RW(), 
        .RA(), 
        .RB(), 
        .RD(), 
        .LE(), 
        .Clk()
    );


    mux_4x1 MX1(
        .Y(),

        .S(),
        .I0(),
        .I1(),
        .I2(),
        .I3()
    );

    mux_4x1 MX2(
        .Y(),

        .S(),
        .I0(),
        .I1(),
        .I2(),
        .I3()
    );

    mux_4x1 MX3(
        .Y(),

        .S(),
        .I0(),
        .I1(),
        .I2(),
        .I3()
    );

    pipeline_ID_EX (
        .EX_MX1(), 
        .EX_MX2(), 
        .EX_MX3(), 
        .EX_IM22(),
        .EX_PC(),  
        .EX_RD(),  
        .EX_IS_instr(),
        .EX_ALU_OP_instr(),
        .EX_control_unit_instr(),


        .ID_IS_instr(),
        .ID_ALU_OP_instr(),
        .ID_control_unit_instr(),
        .clk(),
        .clr(),
        .reset(),
        .MX1(),
        .MX2(),
        .MX3(),
        .IMM22(),
        .RD()
    ); 

    // EX State

    alu ALU_BOI(
        .y(),
        .flags(),

        .a(),
        .b(),
        .cin(),
        .opcode(),
    );

    source_operand OPERAND (
        .N(),

        .R(),
        .Imm(),
        .IS()
    );

    condition_handler CONDITION_HAND(
        .branch_out(),
        
        .flags(),
        .cond(),
        .ID_branch_instr()
    );

    pipeline_EX_MEM EX_MEM(
        .I21_0(),
        .I29_0(),
        .nPC(),

        .PC(),
        .clr(),
        .clk(),
        .enable(),
        .reset(),
        .instr(),
    );

    // MEM State 

    output_handler OUTPUT_HAND(
    .output_handler_out_selector(),

    .MEM_jmpl_instr(),
    .MEM_call_instr(),
    .MEM_load_instr(),
    );

    pipeline_MEM_WB MEM_WB(
        .WB_RD(),
        .WB_register_file_enable(),
        .WB_OUT(),

        
    );

    // WB Stage




    initial begin
        $display(" PC   NPC   Mem Address  RS1  RS2  RD  OP  OP3   Data Out  SE  A B ALU TIME");
        $monitor();
    end


endmodule