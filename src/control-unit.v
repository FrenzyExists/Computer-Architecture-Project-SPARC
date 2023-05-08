
module control_unit_mux(
    output reg [18:0] mux_out,
    input [18:0] cu_in_mux,
    input S
);

    always  @(S, cu_in_mux) begin
        if (S) begin
            mux_out <= 19'b0; // Output mux_selector when S is true
        end
        else begin
            mux_out <= cu_in_mux; // Output 0 when S is false
        end
    end
endmodule


module control_unit(
    input [31:0] instr,
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

 // the two most significant bits that specifies the instruction format
reg [1:0] instr_op;

always @(instr) begin

    if (instr == 32'b0) begin
        ID_jmpl_instr               <= 1'b0;
        ID_call_instr               <= 1'b0;
        ID_branch_instr             <= 1'b0;
        ID_load_instr               <= 1'b0;
        ID_register_file_Enable     <= 1'b0;

        ID_data_mem_SE              <= 1'b0;
        ID_data_mem_RW              <= 1'b0;
        ID_data_mem_Enable          <= 1'b0;
        ID_data_mem_Size            <= 2'b0;

        CC_Enable                   <= 1'b0;
    end
    else begin
        instr_op = instr[31:30];

        case (instr_op)

            2'b00: // SETHI or Branch Instructions
            begin
                ID_jmpl_instr               <= 1'b0;
                ID_call_instr               <= 1'b0;
                ID_load_instr               <= 1'b0; 

                ID_register_file_Enable     <= 1'b1;
                CC_Enable                   <= 1'b0;

                // Ask the professor for these
                // ID_data_mem_SE              <= 1'b0;
                // ID_data_mem_RW              <= 1'b0;
                // ID_data_mem_Enable          <= 1'b1;
                // ID_data_mem_Size            <= 2'b0;

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
            2'b01: // Call Instruction
            begin
                
                ID_jmpl_instr               <= 1'b0;
                ID_call_instr               <= 1'b1;
                ID_branch_instr             <= 1'b0;
                ID_load_instr               <= 1'b0;
                ID_register_file_Enable     <= 1'b1;

                // Ask professor about this
                // ID_data_mem_SE              <= 1'b0;
                // ID_data_mem_RW              <= 1'b0;
                // ID_data_mem_Enable          <= 1'b0;
                // ID_data_mem_Size            <= 2'b00;

                // Also ask prof bout the alu
                ID_ALU_OP_instr             <= 4'b0000;
                CC_Enable                   <= 1'b0;
            
            end
            2'b10|2'b11: // Remmaining Instructions
            begin
                op3 = instr[24:19]; // the opcode instruction that tells what to do

                if (instr_op == 2'b11) begin
                    // Load/Store Instruction
                    ID_jmpl_instr               <= 1'b0;
                    ID_call_instr               <= 1'b0;
                    ID_branch_instr             <= 1'b0;
                    CC_Enable                   <= 1'b0;
                    ID_ALU_OP_instr             <= 4'b0000;

                    case (op3)
                        6'b001001 | 6'b001010 | 6'b000000 | 6'b000001 | 6'b000010: 
                        begin
                            // Load	sign byte | Load sign halfword | Load word | Load unsigned byte | Load unsigned halfword
                            // Turn on Load Instruction
                            // Enable Memory
                            // Trigger Memory to Read mode

                            ID_load_instr               <= 1'b1;
                            ID_register_file_Enable     <= 1'b1;

                            ID_data_mem_SE              <= 1'b0;
                            ID_data_mem_RW              <= 1'b0;
                            ID_data_mem_Enable          <= 1'b1;
                            ID_data_mem_Size            <= 2'b00;

                        end
                        6'b000101 | 6'b000110 | 6'b000100 | 6'b000111:
                        begin
                            // Memory is se to Write mode
                            ID_load_instr               <= 1'b0;
                            ID_register_file_Enable     <= 1'b1;

                            ID_data_mem_SE              <= 1'b0;
                            ID_data_mem_RW              <= 1'b0;
                            ID_data_mem_Enable          <= 1'b1;
                            ID_data_mem_Size            <= 2'b00;
                        end
                    endcase
                end
                else if (instr_op == 2'b10) begin
                    // Read/Write/Trap/Save/Restore/Jmpl/Arithmetic
                    // Why the fuck Sparc had to squeeze so many possible instructions on this one block, like... bruh

                    case (op3)
                        // Jmpl
                        6'b111000:
                        begin
                            ID_jmpl_instr               <= 1'b1;
                            ID_call_instr               <= 1'b0;
                            ID_branch_instr             <= 1'b0;
                            ID_load_instr               <= 1'b0;
                            ID_ALU_OP_instr             <= 4'b0000;
                        end
                        // Read State Register
                        6'b101001 | 6'b101010 | 6'b101011:
                        begin
                            ID_jmpl_instr               <= 1'b0;
                            ID_call_instr               <= 1'b0;
                            ID_branch_instr             <= 1'b0;
                            ID_load_instr               <= 1'b0;
                            ID_register_file_Enable     <= 1'b1;

                            ID_data_mem_SE              <= 1'b0;
                            ID_data_mem_RW              <= 1'b0;
                            ID_data_mem_Enable          <= 1'b1;
                            ID_data_mem_Size            <= 2'b00;

                            ID_ALU_OP_instr             <= 4'b0000;
                            CC_Enable                   <= 1'b0;
                        end
                        // Write State Register
                        6'b110001 | 6'b110010 | 6'b110011:
                        begin
                            ID_call_instr               <= 1'b0;
                            ID_branch_instr             <= 1'b0;
                            ID_load_instr               <= 1'b0;
                            ID_register_file_Enable     <= 1'b1;

                            ID_data_mem_SE              <= 1'b0;
                            ID_data_mem_RW              <= 1'b0;
                            ID_data_mem_Enable          <= 1'b1;
                            ID_data_mem_Size            <= 2'b00;

                            ID_ALU_OP_instr             <= 4'b0000;
                            CC_Enable                   <= 1'b0;
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
        I31 <= instr[31];
        I30 <= instr[30];
        I24 <= instr[24];
        I13 <= instr[13];
    end

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