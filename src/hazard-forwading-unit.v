

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
    input wire [4:0] ID_rd
    
    // output reg [1:0] HFU_Forw_PA, HFU_Forw_PB, HFU_Forw_PC,

    // output reg HFU_NOP, HFU_IFID_LE, HFU_LE_PC,
    // input [3:0] HFU_EX_Rd, HFU_MEM_Rd, HFU_WB_Rd, HFU_ID_Rn, HFU_ID_Rm, 
    // input HFU_EX_RF_enable, HFU_MEM_RF_enable, HFU_WB_RF_enable, HFU_EX_load_instr, HFU_ID_shift_imm
);

    always @ (*) begin
 /**********************************************************************************DATA FORWARDING DETECTION & HANDLING***********************************************************************************/
        /*//FORWARDING PA (ID_mux1)\\*/
        if (EX_Register_File_Enable && (ID_rs1 === EX_RD)) // EX forwarding
            forwardMX1 <= 2'b01;   // Forwarding [HFU_EX_Rd] to ID

        else if (MEM_Register_File_Enable && (ID_rs1 === MEM_RD)) //MEM forwarding
            forwardMX1 <= 2'b10; //Forwarding [HFU_MEM_Rd] to ID
    
        else if (WB_Register_File_Enable && (ID_rs1 === WB_RD)) 
            forwardMX1 <= 2'b11; //Forwarding [HFU_WB_Rd] to ID

        else forwardMX1 <= 2'b00; //Not forwarding (passing PA from the register file)

        /*//FORWARDING PB (ID_mux2)\\*/
        if (EX_Register_File_Enable && (ID_rs2 === EX_RD)) //EX forwarding
            forwardMX2 <= 2'b01; //Forwarding [HFU_EX_Rd] to ID

        else if (MEM_Register_File_Enable && (ID_rs2 === MEM_RD)) //MEM forwarding
            forwardMX2 <= 2'b10; //Forwarding [HFU_MEM_Rd] to ID

        else if (WB_Register_File_Enable && (ID_rs2 === WB_RD)) //WB forwarding
            forwardMX2 <= 2'b11; //Forwarding [HFU_WB_Rd] to ID

        else forwardMX2 <= 2'b00; //Not forwarding (passing PB from the register file)

        /*//FORWARDING PC (ID_mux3)\\*/
        if (EX_Register_File_Enable && (ID_rd === EX_RD)) //EX forwarding
            forwardMX3 <= 2'b01; //Forwarding [HFU_EX_Rd] to ID

        else if (MEM_Register_File_Enable && (ID_rd === MEM_RD)) //MEM forwarding
            forwardMX3 <= 2'b10; //Forwarding [HFU_MEM_Rd] to ID

        else if (WB_Register_File_Enable && (ID_rd === WB_RD)) //WB forwarding
            forwardMX3 <= 2'b11; //Forwarding [HFU_WB_Rd] to ID

        else forwardMX3 <= 2'b00; //Not forwarding (passing PB from the register file)

/**********************************************************************************LOAD HAZARD DETECTION & HANDLING**************************************************************************************/
        //Hazard asserted
        // if (HFU_EX_load_instr && ((ID_rs2 === HFU_EX_Rd) || ((ID_rs1 === HFU_EX_Rd) && !HFU_ID_shift_imm))) begin
        if ((ID_rs2 === ID_rd) || (ID_rs1 === ID_rd)) begin
            nPC_LE        <= 1'b0;
            PC_LE         <= 1'b0;
            IF_ID_LE      <= 1'b0;

            // HFU_NOP <= 1'b1; //Forward Control Signals corresponding to a NOP instruction
            // HFU_IFID_LE <= 1'b0; //Disable IF/ID Pipeline Register from loading
            // HFU_LE_PC <= 1'b0; //Disable Load Enable of the Program Counter (PC)
        end

        //Hazard not asserted
        else begin

            nPC_LE        <= 1'b0;
            PC_LE         <= 1'b0;
            IF_ID_LE      <= 1'b0;
            // HFU_NOP <= 1'b0;//Dont Forward Control Signals corresponding to a NOP instruction
            // HFU_IFID_LE <= 1'b1; // IF/ID Pipeline Register is enabled
            // HFU_LE_PC <= 1'b1; // Program Counter is Load Enable
        end
    end
endmodule
