

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
    input [31:0] instr
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

        I31                         <= 1'b0;
        I30                         <= 1'b0;
        I24                         <= 1'b0;
        I13                         <= 1'b0;

        ID_ALU_OP_instr             <= 4'b0;
        CC_Enable                   <= 1'b0;
    end
    else begin
        instr_op = instr[31:30];

        case (instr_op)

            2'b00: // SETHI or Branch Instructions
            begin
                ID_jmpl_instr               <= 1'b0;
                ID_call_instr               <= 1'b0;
                ID_branch_instr             <= 1'b0;
                ID_load_instr               <= 1'b1;
                ID_register_file_Enable     <= 1'b1;

                // Ask the professor for these cuz me stoopid
                // ID_data_mem_SE              <= 1'b0;
                // ID_data_mem_RW              <= 1'b0;
                ID_data_mem_Enable          <= 1'b1;
                // ID_data_mem_Size            <= 2'b0;

                I31                         <= 1'b0;
                I30                         <= 1'b0;
                I24                         <= 1'b0;
                I13                         <= 1'b0;

                ID_ALU_OP_instr             <= 4'b0;
                CC_Enable                   <= 1'b0;

            end
            2'b01: // Call Instruction



            begin
            
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
                            ID_data_mem_Enable          <= 1'b1;

                           
                            
                        end

                        6'b000101 | 6'b000110 | 6'b000100 | 6'b000111:
                        begin

                        end
                    endcase
                end
                else begin
                    if (instr_op == 2'10) begin
                    // Read/Write/Trap/Save/Restore/Jmpl/Arithmetic
                    // Why the fuck Sparc had to squeeze so many possible instructions on this one block, like... bruh

                    end
                end


            end
        endcase
    end
end



endmodule