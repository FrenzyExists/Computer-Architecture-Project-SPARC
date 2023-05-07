

module control_unit_mux(
    output mux_out,
    input mux_selector,
    input S
);

always @(S, mux_selector) begin
    if (S) begin
        // mux_selector <= some number set in 0 or something idk
    end
    else begin
        // mux_out <= mux_selector
    end
end

endmodule


module control_unit(
    input [31:0] instr,
    output [18:0] instr_signals

);

reg ID_jmpl_instr;
reg ID_call_instr;
reg ID_branch_instr;
reg ID_load_instr;
reg ID_register_file_Enable;

reg ID_data_mem_SE;
reg ID_data_mem_RW;
reg ID_data_mem_Enable;
reg ID_data_mem_Size;

reg I31;
reg I30;
reg I24;
reg I13;

reg [3:0] ID_ALU_OP_instr;

reg CC_Enable;


 // the two most significant bits that specifies the instruction format
 // To explain this mess in a better way:
// if op == 00 =>
// if op == 11 | 10 =>

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
                    ID_ALU_OP_instr           <= 4'1110;
                    ID_branch_instr           <= 1'b0;
                end
                else if (is_sethi == 3'b010) begin // So this is actually a branch instruction
                    ID_branch_instr           <= 1'b1;
                end

            end
            2'b01: // Call Instruction
            begin
                
                ID_jmpl_instr               <= 1'b0;
                ID_call_instr               <= 1'b1;
                ID_branch_instr             <= 1'b0;
                ID_load_instr               <= 1'b0;
                ID_register_file_Enable     <= 1'b1;

                ID_data_mem_SE              <= 1'b0;
                ID_data_mem_RW              <= 1'b0;
                ID_data_mem_Enable          <= 1'b0;
                ID_data_mem_Size            <= 2'b00;

                ID_ALU_OP_instr             <= 4'b0000;
                CC_Enable                   <= 1'b0;
            
            end
            2'b10|2'b11: // Remmaining Instructions
            begin
                op3 = instr[24:19]; // the opcode instruction that tells what to do

                if (instr_op == 2'b11) begin
                    // Load/Store Instruction
                    case (op3)
                        6'b001001 | 6'b001010 | 6'b000000 | 6'b000001 | 6'b000010: 
                        begin
                            // Load	sign byte | Load sign halfword | Load word | Load unsigned byte | Load unsigned halfword
                            // Turn on Load Instruction
                            // Enable Memory
                            // Trigger Memory to Read mode

                            ID_jmpl_instr               <= 1'b0;
                            ID_call_instr               <= 1'b0;
                            ID_branch_instr             <= 1'b0;
                            ID_load_instr               <= 1'b1;
                            ID_register_file_Enable     <= 1'b1;

                            ID_data_mem_SE              <= 1'b0;
                            ID_data_mem_RW              <= 1'b0;
                            ID_data_mem_Enable          <= 1'b1;
                            ID_data_mem_Size            <= 2'b00;

                            CC_Enable                   <= 1'b0;
                        end
                        6'b000101 | 6'b000110 | 6'b000100 | 6'b000111:
                        begin

                        end
                    endcase
                end
                else if (instr_op == 2'10) begin
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

                            CC_Enable                   <= 1'b0;
                        end
                        // Arithmetic
                        default:
                            // For cases where the signal modifies condition codes
                            case (op3)
                                6'b000000: // add
                                    ID_ALU_OP_instr <= 4'b0000;
                                    CC_Enable <= 1'b0;
                                6'b010000: // addcc
                                    ID_ALU_OP_instr <= 4'b0000;
                                    CC_Enable <= 1'b1;
                                6'b001000: // addx
                                    ID_ALU_OP_instr <= 4'b0001;
                                    CC_Enable <= 1'b0;
                                6'b011000: // addxcc
                                    ID_ALU_OP_instr <= 4'b0001;
                                    CC_Enable <= 1'b1;
                                6'b000100: // sub
                                    ID_ALU_OP_instr <= 4'b0010;
                                    CC_Enable <= 1'b0;
                                6'b010100: // subcc
                                    ID_ALU_OP_instr <= 4'b0010;
                                    CC_Enable <= 1'b1;
                                6'b001100: // subx
                                    ID_ALU_OP_instr <= 4'b0011;
                                    CC_Enable <= 1'b0;
                                6'b000001: // and
                                    ID_ALU_OP_instr <= 4'0100;
                                    CC_Enable <= 1'b0;
                                6'b010001: // andcc
                                    ID_ALU_OP_instr <= 4'0100;
                                    CC_Enable <= 1'b1;
                                6'b000101: // andn (and not)
                                    ID_ALU_OP_instr <= 4'1000;
                                    CC_Enable <= 1'b0;
                                6'b010101: // andncc
                                    ID_ALU_OP_instr <= 4'1000;
                                    CC_Enable <= 1'b1;
                                6'b000010: // or
                                    ID_ALU_OP_instr <= 4'0101;
                                    CC_Enable <= 1'b0;
                                6'b010010: // orcc
                                    ID_ALU_OP_instr <= 4'0101;
                                    CC_Enable <= 1'b1;
                                6'b000110: // orn (or not)
                                    ID_ALU_OP_instr <= 4'1001;
                                    CC_Enable <= 1'b0;
                                6'b010110: // orncc
                                    ID_ALU_OP_instr <= 4'1001;
                                    CC_Enable <= 1'b1;
                                6'b000011: // xor
                                    ID_ALU_OP_instr <= 4'0110;
                                    CC_Enable <= 1'b0;
                                6'b010011: // xorcc
                                    ID_ALU_OP_instr <= 4'0110;
                                    CC_Enable <= 1'b1;
                                6'b000111: // xorn (xnor)
                                    ID_ALU_OP_instr <= 4'0111;
                                    CC_Enable <= 1'b0;
                                6'b010111: // xorncc
                                    ID_ALU_OP_instr <= 4'0111;
                                    CC_Enable <= 1'b1;
                                6'b100101: // sll (shift left logical)
                                    ID_ALU_OP_instr <= 4'1010;
                                    CC_Enable <= 1'b0;
                                6'b100110: // srl shift right logical
                                    ID_ALU_OP_instr <= 4'1011;
                                    CC_Enable <= 1'b0;
                                6'b100111: // sra shift right arithmetic
                                    ID_ALU_OP_instr <= 4'1100;
                                    CC_Enable <= 1'b0;
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

end



endmodule