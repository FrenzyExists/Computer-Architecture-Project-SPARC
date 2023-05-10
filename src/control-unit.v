module control_unit_mux(

    output reg [3:0] ID_ALU_OP_out, 

    output reg ID_jmpl_instr_out,              // 1
    output reg ID_call_instr_out,              // 2
    output reg ID_branch_instr_out,            // 3
    output reg ID_load_instr_out,              // 4
    output reg ID_register_file_Enable_out,    // 5

    output reg ID_data_mem_SE,                 // 6
    output reg ID_data_mem_RW,                 // 7
    output reg ID_data_mem_Enable,             // 8
    output reg [1:0] ID_data_mem_Size,         // 9,10

    output reg I31_out,                        // 11
    output reg I30_out,                        // 12
    output reg I24_out,                        // 13
    output reg I13_out,                        // 15

    output reg [3:0] ID_ALU_OP_instr,          // 15,16,17,18
    output reg CC_Enable,                      // 19

    input S,
    input [18:0] cu_in_mux
);

    always  @(S) begin
        if (S == 1'b0) begin
            ID_jmpl_instr_out           <= cu_in_mux[0];
            ID_call_instr_out           <= cu_in_mux[1];
            ID_branch_instr_out         <= cu_in_mux[2];
            ID_load_instr_out           <= cu_in_mux[3];
            ID_register_file_Enable_out <= cu_in_mux[4];
            ID_data_mem_SE              <= cu_in_mux[5]; 
            ID_data_mem_RW              <= cu_in_mux[6];
            ID_data_mem_Enable          <= cu_in_mux[7];
            ID_data_mem_Size            <= cu_in_mux[9:8];
            I31_out                     <= cu_in_mux[10];
            I30_out                     <= cu_in_mux[11];
            I24_out                     <= cu_in_mux[12];
            I13_out                     <= cu_in_mux[13];
            ID_ALU_OP_instr             <= cu_in_mux[17:14];
            CC_Enable                   <= cu_in_mux[18];
        end
        else begin
            ID_jmpl_instr_out           <= 1'b0;
            ID_call_instr_out           <= 1'b0;
            ID_branch_instr_out         <= 1'b0;
            ID_load_instr_out           <= 1'b0;
            ID_register_file_Enable_out <= 1'b0;
            ID_data_mem_SE              <= 1'b0;
            ID_data_mem_RW              <= 1'b0;
            ID_data_mem_Enable          <= 1'b0;
            ID_data_mem_Size            <= 1'b0;
            I31_out                     <= 1'b0;
            I30_out                     <= 1'b0;
            I24_out                     <= 1'b0;
            I13_out                     <= 1'b0;
            ID_ALU_OP_instr             <= 1'b0;
            CC_Enable                   <= 1'b0;
        end
    end
endmodule


module control_unit(
    input [31:0] instr,
    input clk, clr, // clock and clear
    output reg [18:0] instr_signals

);

reg ID_jmpl_instr;              // 1
reg ID_call_instr;              // 2
reg ID_branch_instr;            // 3
reg ID_load_instr;              // 4
reg ID_register_file_Enable;    // 5
reg ID_data_mem_SE;             // 6
reg ID_data_mem_RW;             // 7
reg ID_data_mem_Enable;         // 8
reg [1:0] ID_data_mem_Size;     // 9,10
reg I31;                        // 11
reg I30;                        // 12
reg I24;                        // 13
reg I13;                        // 14
reg [3:0] ID_ALU_OP_instr;      // 15,16,17,18
reg CC_Enable;                  // 19

reg [2:0] is_sethi;
reg [5:0] op3;

reg a;

 // the two most significant bits that specifies the instruction format
reg [1:0] instr_op;

always @(posedge clk or negedge clr) begin
    if (instr == 32'b0) begin
        // $display("Instructions are NOP...");
        ID_jmpl_instr               <= 1'b0;
        ID_call_instr               <= 1'b0;
        ID_branch_instr             <= 1'b0;
        ID_load_instr               <= 1'b0;
        ID_register_file_Enable     <= 1'b0;
        ID_data_mem_SE              <= 1'b0;
        ID_data_mem_RW              <= 1'b0;
        ID_data_mem_Enable          <= 1'b0;
        ID_data_mem_Size            <= 2'b0;
        ID_ALU_OP_instr             <= 4'b0;
        CC_Enable                   <= 1'b0;
    end else begin
        instr_op = instr[31:30];
        // $display("Getting the op instruction =  %b", instr_op);
        case (instr_op)
            2'b00: begin // SETHI or Branch Instructions
                ID_jmpl_instr               <= 1'b0;
                ID_call_instr               <= 1'b0;
                ID_load_instr               <= 1'b0; 
                ID_register_file_Enable     <= 1'b0;
                CC_Enable                   <= 1'b0;

                // Ask the professor for these
                ID_data_mem_SE              <= 1'b0;
                ID_data_mem_RW              <= 1'b0;
                ID_data_mem_Enable          <= 1'b0;
                ID_data_mem_Size            <= 2'b0;

                is_sethi = instr[24:22];

                if (is_sethi == 3'b100) begin
                    // We specify the ALU to simply forward B.
                    // The source operand2 handler will deal with the
                    // Sethi instruction
                    ID_ALU_OP_instr         <= 4'b1110;
                    ID_branch_instr         <= 1'b0;
                end
                else if (is_sethi == 3'b010) begin // So this is actually a branch instruction
                    ID_branch_instr         <= 1'b1;
                end
            end
            2'b01: begin // Call Instruction
                
                ID_jmpl_instr               <= 1'b0;
                ID_call_instr               <= 1'b1;
                ID_branch_instr             <= 1'b0;
                ID_load_instr               <= 1'b0;
                ID_register_file_Enable     <= 1'b1;

                // Ask professor about this
                ID_data_mem_SE              <= 1'b0;
                ID_data_mem_RW              <= 1'b0;
                ID_data_mem_Enable          <= 1'b0;
                ID_data_mem_Size            <= 2'b00;

                // Also ask prof bout the alu
                ID_ALU_OP_instr             <= 4'b0000;
                CC_Enable                   <= 1'b0;
            end

            2'b10, 2'b11: begin
                op3 = instr[24:19]; // the opcode instruction that tells what to do
                // $display("Getting the op3 code =  %b", op3);
                if (instr_op == 2'b11) begin
                    // $display("Instruction is a Load/Store Instruction");
                    // Load/Store Instruction
                    ID_jmpl_instr               <= 1'b0;
                    ID_call_instr               <= 1'b0;
                    ID_branch_instr             <= 1'b0;
                    CC_Enable                   <= 1'b0;
                    ID_ALU_OP_instr             <= 4'b0000;
                    ID_register_file_Enable     <= 1'b1;
                    ID_data_mem_Enable          <= 1'b1;

                    case (op3)
                        6'b001001, 6'b001010, 6'b000000, 6'b000001, 6'b000010: 
                        begin
                            // Load Mode
                            // Load	sign byte | Load sign halfword | Load word | Load unsigned byte | Load unsigned halfword
                            // Turn on Load Instruction
                            // Enable Memory
                            // Trigger Memory to Read mode

                            ID_load_instr               <= 1'b1;
                            ID_data_mem_RW              <= 1'b0;
                            
                            if (op3 == 6'b001001) begin// Load signed byte
                                ID_data_mem_SE              <= 1'b1;
                                ID_data_mem_Size            <= 2'b00;
                            end else if (op3 == 6'b001010) begin // Load signed halfword
                                ID_data_mem_SE              <= 1'b1;
                                ID_data_mem_Size            <= 2'b01;       
                            end else if (op3 == 6'b000000) begin // Load word
                                ID_data_mem_SE              <= 1'b0;
                                ID_data_mem_Size            <= 2'b10;                            
                            end else if (op3 == 6'b000001) begin // Load unsigned byte
                                ID_data_mem_SE              <= 1'b0;
                                ID_data_mem_Size            <= 2'b00;
                            end else begin // 6'b000010 Load unsigned halfword
                                ID_data_mem_SE              <= 1'b0;
                                ID_data_mem_Size            <= 2'b01;
                            end
                        end
                        6'b000101, 6'b000110, 6'b000100:
                        begin
                            // Store Mode (mem is set to write mode)
                            ID_load_instr               <= 1'b0;
                            ID_data_mem_RW              <= 1'b1;

                            if (op3 == 6'b000101) begin // Store byte
                                // ID_data_mem_SE              <= 1'b0;
                                ID_data_mem_Size            <= 2'b00;
                            end else if (op3 == 6'b000110) begin //  Store Halfword
                                // ID_data_mem_SE              <= 1'b0;
                                ID_data_mem_Size            <= 2'b01;
                            end else  begin // 6'b000100 Store Word
                                // ID_data_mem_SE              <= 1'b0;
                                ID_data_mem_Size            <= 2'b10;
                            end 
                        end
                    endcase
                end else if (instr_op == 2'b10) begin
                    // Read/Write/Trap/Save/Restore/Jmpl/Arithmetic
                    // Why the fuck Sparc had to squeeze so many possible instructions on this one block, like... bruh
                    ID_call_instr               <= 1'b0;
                    ID_branch_instr             <= 1'b0;
                    case (op3)
                    
                        // Jmpl
                        6'b111000: begin
                            // $display("Instruction is a jmpl instruction");    
                            ID_jmpl_instr               <= 1'b1;
                            ID_load_instr               <= 1'b0;
                            ID_data_mem_SE              <= 1'b0;
                            ID_data_mem_RW              <= 1'b0;
                            ID_register_file_Enable     <= 1'b0;
                            ID_ALU_OP_instr             <= 4'b0000;
                            ID_data_mem_Enable          <= 1'b0;
                            ID_data_mem_Size            <= 2'b00;    
                            CC_Enable                   <= 1'b0;
                        end
                        // Save and Restore Instruction Format
                        6'b111100, 6'b111101: begin

                            ID_jmpl_instr               <= 1'b0;
                            ID_load_instr               <= 1'b0;
                            ID_register_file_Enable     <= 1'b1;
                            ID_ALU_OP_instr             <= 4'b0000;
                            CC_Enable                   <= 1'b0;
                            ID_data_mem_SE              <= 1'b0;

                            // a <= instr[13];
                            // if (a == 1'b1) ;// normal r2
                            // else if (a == 1'b0) ID_data_mem_SE <= 1'b1;// with sign extend

                            ID_data_mem_RW              <= 1'b0;
                            ID_data_mem_Enable          <= 1'b1;
                            ID_data_mem_Size            <= 2'b10;                            
                           
                        end
                        // Arithmetic
                        default: begin
                            // For cases where the signal modifies condition codes
                            case (op3)
                                6'b000000: begin // add
                                    ID_ALU_OP_instr <= 4'b0000;
                                    CC_Enable       <= 1'b0;
                                end
                                6'b010000: begin // addcc
                                    ID_ALU_OP_instr <= 4'b0000;
                                    CC_Enable       <= 1'b1;
                                end
                                6'b001000: begin // addx
                                    ID_ALU_OP_instr <= 4'b0001;
                                    CC_Enable       <= 1'b0;
                                end
                                6'b011000: begin // addxcc
                                    ID_ALU_OP_instr <= 4'b0001;
                                    CC_Enable       <= 1'b1;
                                end
                                6'b000100: begin // sub
                                    ID_ALU_OP_instr <= 4'b0010;
                                    CC_Enable       <= 1'b0;
                                end
                                6'b010100: begin // subcc
                                    ID_ALU_OP_instr <= 4'b0010;
                                    CC_Enable       <= 1'b1;
                                end
                                6'b001100: begin // subx
                                    ID_ALU_OP_instr <= 4'b0011;
                                    CC_Enable       <= 1'b0;
                                end
                                6'b000001: begin // and
                                    ID_ALU_OP_instr <= 4'b0100;
                                    CC_Enable       <= 1'b0;
                                end
                                6'b010001: begin // andcc
                                    ID_ALU_OP_instr <= 4'b0100;
                                    CC_Enable       <= 1'b1;
                                end
                                6'b000101: begin // andn (and not)
                                    ID_ALU_OP_instr <= 4'b1000;
                                    CC_Enable       <= 1'b0;
                                end
                                6'b010101: begin // andncc
                                    ID_ALU_OP_instr <= 4'b1000;
                                    CC_Enable       <= 1'b1;
                                end
                                6'b000010: begin // or
                                    ID_ALU_OP_instr <= 4'b0101;
                                    CC_Enable       <= 1'b0;
                                end
                                6'b010010: begin // orcc
                                    ID_ALU_OP_instr <= 4'b0101;
                                    CC_Enable       <= 1'b1;
                                end
                                6'b000110: begin // orn (or not)
                                    ID_ALU_OP_instr <= 4'b1001;
                                    CC_Enable       <= 1'b0;
                                end
                                6'b010110: begin // orncc
                                    ID_ALU_OP_instr <= 4'b1001;
                                    CC_Enable       <= 1'b1;
                                end
                                6'b000011: begin // xor
                                    ID_ALU_OP_instr <= 4'b0110;
                                    CC_Enable       <= 1'b0;
                                end
                                6'b010011: begin // xorcc
                                    ID_ALU_OP_instr <= 4'b0110;
                                    CC_Enable       <= 1'b1;
                                end
                                6'b000111: begin // xorn (xnor)
                                    ID_ALU_OP_instr <= 4'b0111;
                                    CC_Enable       <= 1'b0;
                                end
                                6'b010111: begin // xorncc
                                    ID_ALU_OP_instr <= 4'b0111;
                                    CC_Enable       <= 1'b1;
                                end
                                6'b100101: begin // sll (shift left logical)
                                    ID_ALU_OP_instr <= 4'b1010;
                                    CC_Enable       <= 1'b0;
                                end
                                6'b100110: begin // srl shift right logical
                                    ID_ALU_OP_instr <= 4'b1011;
                                    CC_Enable       <= 1'b0;
                                end
                                6'b100111: begin // sra shift right arithmetic
                                    ID_ALU_OP_instr <= 4'b1100;
                                    CC_Enable       <= 1'b0;
                                end
                            endcase
                            // include the rest of the flags here
                            ID_jmpl_instr               <= 1'b0;
                            ID_call_instr               <= 1'b0;
                            ID_branch_instr             <= 1'b0;
                            ID_load_instr               <= 1'b0;
                            ID_register_file_Enable     <= 1'b0;

                            ID_data_mem_SE              <= 1'b0;
                            ID_data_mem_RW              <= 1'b0;
                            ID_data_mem_Enable          <= 1'b0;
                            ID_data_mem_Size            <= 2'b0;
                        end
                    endcase
                end
            end
        endcase
    end

    I31 <= instr[31];
    I30 <= instr[30];
    I24 <= instr[24];
    I13 <= instr[13];

    // Output
    instr_signals[0]      <= ID_jmpl_instr;
    instr_signals[1]      <= ID_call_instr;
    instr_signals[2]      <= ID_branch_instr;
    instr_signals[3]      <= ID_load_instr;
    instr_signals[4]      <= ID_register_file_Enable;

    instr_signals[5]      <= ID_data_mem_SE;
    instr_signals[6]      <= ID_data_mem_RW;
    instr_signals[7]      <= ID_data_mem_Enable;
    instr_signals[9:8]    <= ID_data_mem_Size;

    instr_signals[10]     <= I31;
    instr_signals[11]     <= I30;
    instr_signals[12]     <= I24;
    instr_signals[13]     <= I13;

    instr_signals[17:14]  <= ID_ALU_OP_instr;
    instr_signals[18]     <= CC_Enable;

end

endmodule