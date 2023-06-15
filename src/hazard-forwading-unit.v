`timescale 1ns / 1ns

module hazard_forwarding_unit (
    output reg [1:0] forwardMX1,
    output reg [1:0] forwardMX2,
    output reg [1:0] forwardMX3,

    output reg nPC_LE,
    output reg PC_LE,
    output reg IF_ID_LE,

    output reg CU_S,

    input wire EX_Register_File_Enable,
    input wire MEM_Register_File_Enable,
    input wire WB_Register_File_Enable,

    input wire [4:0] EX_RD,
    input wire [4:0] MEM_RD,
    input wire [4:0] WB_RD,

    input wire [4:0] ID_rs1,
    input wire [4:0] ID_rs2,
    input wire [4:0] ID_rd,
    input wire EX_load_instr,
    input wire ID_store_instr
);

    always @* begin
 /**********************************************************************************DATA FORWARDING DETECTION & HANDLING***********************************************************************************/
        /*//FORWARDING PA (ID_mux1)\\*/
        if (EX_Register_File_Enable && (ID_rs1 == EX_RD))           // EX forwarding
            forwardMX1 <= 2'b01;   
        else if (MEM_Register_File_Enable && (ID_rs1 == MEM_RD))    // MEM forwarding
            forwardMX1 <= 2'b10; 
        else if (WB_Register_File_Enable && (ID_rs1 == WB_RD)) 
            forwardMX1 <= 2'b11; 
        else forwardMX1 <= 2'b00;                                   // Not forwarding (passing PA from the register file)

        /*//FORWARDING PB (ID_mux2)\\*/
        if (EX_Register_File_Enable && (ID_rs2 == EX_RD))           // EX forwarding
            forwardMX2 <= 2'b01; 
        else if (MEM_Register_File_Enable && (ID_rs2 == MEM_RD))    // MEM forwarding
            forwardMX2 <= 2'b10; 
        else if (WB_Register_File_Enable && (ID_rs2 == WB_RD))      // WB forwarding
            forwardMX2 <= 2'b11;                                    // Forwarding [HFU_WB_Rd] to ID
        else forwardMX2 <= 2'b00;                                   // Not forwarding (passing PB from the register file)

        /*//FORWARDING PC (ID_mux3)\\*/
        if (ID_store_instr) begin
            if (EX_Register_File_Enable && (ID_rd == EX_RD))        // EX forwarding
                forwardMX3 <= 2'b01; 
            else if (MEM_Register_File_Enable && (ID_rd == MEM_RD)) // MEM forwarding
                forwardMX3 <= 2'b10; 
            else if (WB_Register_File_Enable && (ID_rd == WB_RD))   // WB forwarding
                forwardMX3 <= 2'b11; 
            else forwardMX3 <= 2'b00;                               // Not forwarding (passing PB from the register file)
        end

        if (EX_load_instr && ((ID_rs1 == EX_RD) || (ID_rs2 == EX_RD) || (ID_rd == EX_RD) && ID_store_instr)) begin // Hazard asserted
            nPC_LE          <= 1'b0; // Disable Load Enable of the Next Program Counter (nPC)
            PC_LE           <= 1'b0; // Disable Load Enable of the Program Counter (PC)
            IF_ID_LE        <= 1'b0; // Disable IF/ID Pipeline Register from loading
            CU_S            <= 1'b1; // Forward Control Signals corresponding to a NOP instruction
        end else begin               // Hazard not asserted
            nPC_LE          <= 1'b1; // Program Counter is Load Enable
            PC_LE           <= 1'b1; // Next Program Counter is Load Enable
            IF_ID_LE        <= 1'b1; // IF/ID Pipeline Register is enabled
            CU_S            <= 1'b0; // Dont Forward Control Signals corresponding to a NOP instruction
        end
    end
endmodule
