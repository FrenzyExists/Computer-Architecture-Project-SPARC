

// Pipeline module for IF/ID
module pipeline_IF_ID (
    input [31:0] PC, 
    input  reset, Clk,
    input [31:0] instr,
    output R24_R21,
    output R16_R23,
    output R8_R15,

    output nPC,
    
);

    always@(posedge Clk) begin // Dance Dance Dance Make the Motherfucker Burn!
        if ()

    end

endmodule


// Pipeline module for ID/EX
module pipeline_ID_EX (
    input [31:0] PC, nPC, 
    input  Clr, Clk
);

endmodule

// Pipeline module for EX/MEM
module pipeline_EX_MEM (
    input [31:0] PC, nPC, 
    input  Clr, Clk
);

endmodule

// Pipeline module for MEM/WB
module pipeline_MEM_WB (
    input [31:0] PC, nPC, 
    input  Clr, Clk
);

endmodule