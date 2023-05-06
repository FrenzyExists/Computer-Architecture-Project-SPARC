

// Needs some serious work

// Pipeline module for IF/ID
module pipeline_IF_ID (
    input [31:0] PC, 
    input  reset, Clk, enable,
    input [31:0] instr, // From the Instruction Memory
    
    output [21:0] I21_0,
    output [29:0] I29_0,
    output

    output [31:0]  nPC,
);
    reg [31:0] instr_out;
    always@(posedge Clk) begin // Dance Dance Dance Make the Motherfucker Burn!
        if (reset) begin // reset is 0
            instr <= 32'b0;
            nPC <= 32'b0;
        end
        else begin
            if (enable) begin // enable is 1 and reset is 0

                instr_out <= instr;
                // find a way to tell a module to increase the counter for the npc
            end
        end

    end

endmodule


// Pipeline module for ID/EX
module pipeline_ID_EX (
    input clk, reset 
    input [31:0] MX1,           // Source register output RS1, from the ID stage
    input [31:0] MX2,           // Source register output RS2, from the ID stage
    input [31:0] MX3,           // Destiny register output RD, from the ID stage (not to be confused with the other RD)
    input [21:0] IMM22,         // These will exist if op == 00 (SETHI in this case) 
    input [31:0] reset_vector,  // Reset vector address
    input [4:0] RD,             // PC moment of an instruction before the call
    
    // These are all comming from the Control Unit, I chopped like this
    // To make it easier to tell which is which. I could put it in a 
    // big signal, but I genuenly value the little sanity i have left
    input [3:0] ID_IS_instr,
    input [3:0] ID_ALU_OP_instr,
    input [9:0] ID_control_unit_instr,

    output [31:0] EX_MX1,
    output [31:0] EX_MX2,
    output [31:0] EX_MX3,
    output [21:0] EX_IM22,
    output [31:0] EX_PC,
    output [4:0] EX_RD,

    output [3:0] EX_IS_instr,
    output [3:0] EX_ALU_OP_instr,
    output [9:0] EX_control_unit_instr

);  

always @(posedge clk) begin
    if (reset) begin
        // Stuff happens
        EX_MX1                      <= 32'b0;
        EX_MX2                      <= 32'b0;
        EX_MX3                      <= 32'b0;

        EX_RD                       <= 5'b0;
        EX_IMM22                    <= 22'b0;
        EX_IS_instr                 <= 4'b0;
        EX_ALU_OP_instr             <= 4'b0;
        EX_control_unit_instr       <= 10'b0;
        
        // Do I really need to reset the PC here too?

        else begin

            // More stuff happens
            EX_MX1                      <= MX1;
            EX_MX2                      <= MX2;
            EX_MX3                      <= MX3;

            EX_RD                       <= RD;
            EX_IMM22                    <= IMM22;
            EX_IS_instr                 <= ID_IS_instr;
            EX_ALU_OP_instr             <= ID_ALU_OP_instr;
            EX_control_unit_instr       <= ID_control_unit_instr;
        

        end
    end
end

endmodule

// Pipeline module for EX/MEM
module pipeline_EX_MEM (
    // input [31:0] PC, nPC,
    // input  Clr, Clk
    input [31:0] PC,
    input clk, reset,
    input [32:0] ALU_OUT,
    input [32:0] EX_MX3,
    input [31:0] PC,
    input [4:0] EX_RD_in,

    input [3:0] EX_IS_instr_in,
    input [3:0] EX_ALU_OP_instr_in,
    input [9:0] EX_control_unit_instr_in

    output [32:0] MEM_ALU_OUT,
    output [32:0] MEM_MX3,
    output [4:0] MEM_RD,

    output [3:0] MEM_IS_instr,
    output [3:0] MEM_ALU_OP_instr,
    output [9:0] MEM_control_unit_instr


);

always @(posedge clk) begin
    if (reset) begin
        MEM_ALU_OUT                 <= 32'b0;
        MEM_MX3                     <= 32'b0;
        MEM_RD                      <= 5'b0;

        MEM_IS_instr                <= 22'b0;
        MEM_ALU_OP_instr            <= 4'b0;
        MEM_control_unit_instr      <= 10'b0;


    end
    else begin
        MEM_ALU_OUT                 <= ALU_OUT;
        MEM_MX3                     <= EX_MX3;
        MEM_RD                      <= EX_RD_in;

        MEM_IS_instr                <= EX_IS_instr_in;
        MEM_ALU_OP_instr            <= EX_ALU_OP_instr_in;
        MEM_control_unit_instr      <= EX_control_unit_instr_in;
    end
end

endmodule

// Pipeline module for MEM/WB
module pipeline_MEM_WB (
    // input [31:0] PC, nPC, 
    // input  Clr, Clk
    input clk, reset, MEM_register_file_enable
    input [31:0] MEM_OUT,
    input [4:0] MEM_RD_in,

    output [4:0] WB_RD,
    output WB_register_file_enable,
    output [31:0] WB_OUT
);

always @(posedge clk) begin
    if (reset) begin
        WB_RD                    <= 5'b0;
        WB_register_file_enable  <= 1'b0
        WB_OUT                   <= 32'b0
    end
    else begin
        WB_RD                    <= MEM_RD_in;
        WB_register_file_enable  <= MEM_register_file_enable;
        WB_OUT                   <= MEM_OUT;
    end
end

endmodule

