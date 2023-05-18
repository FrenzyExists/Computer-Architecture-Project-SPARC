`timescale 1ns / 1ns

/*
Module Name: rom_512x8

Description:
This module represents a 512x8 bit ROM. It reads 32-bit data from the ROM based on the provided address.

Ports:
    - DataOut (output reg [31:0]): 32-bit output data from the ROM.
    - Address (input [7:0]): 8-bit input address to read data from the ROM.

Usage:
    1. Instantiate the module in your Verilog design.
    2. Provide the appropriate address value to read data from the ROM.
    3. The 32-bit output data will be available on the DataOut port.

Notes:
    - Modify the memory initialization code inside the "initial" block to set the desired values in the ROM.
    - Ensure that the Address input is within the valid range (0 to 511) to prevent out-of-bounds access.
*/
module rom_512x8 (output reg [31:0] DataOut, input [7:0] Address);
    reg [7:0] Mem[0:511];       //512 8bit locations
    always@(Address)            //Loop when Address changes
        begin 
            DataOut = {Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]};
            $display("\n\nLoading Instruction:\n----------------------------------\nAddress: %b | Instruction Memory: %b | time: %d\n", Address, DataOut, $time);
        end
endmodule



module binaryDecoder (output reg [31:0] E, input [4:0] C, input RF);
    always @ (*) begin
        if (RF == 1'b1) 
          begin
              case (C)
              5'b00000: E = 32'b00000000000000000000000000000001;
              5'b00001: E = 32'b00000000000000000000000000000010;
              5'b00010: E = 32'b00000000000000000000000000000100;
              5'b00011: E = 32'b00000000000000000000000000001000;
              5'b00100: E = 32'b00000000000000000000000000010000;
              5'b00101: E = 32'b00000000000000000000000000100000;
              5'b00110: E = 32'b00000000000000000000000001000000;
              5'b00111: E = 32'b00000000000000000000000010000000;
              5'b01000: E = 32'b00000000000000000000000100000000;
              5'b01001: E = 32'b00000000000000000000001000000000;
              5'b01010: E = 32'b00000000000000000000010000000000;
              5'b01011: E = 32'b00000000000000000000100000000000;
              5'b01100: E = 32'b00000000000000000001000000000000;
              5'b01101: E = 32'b00000000000000000010000000000000;
              5'b01110: E = 32'b00000000000000000100000000000000;
              5'b01111: E = 32'b00000000000000001000000000000000;
              5'b10000: E = 32'b00000000000000010000000000000000;
              5'b10001: E = 32'b00000000000000100000000000000000;
              5'b10010: E = 32'b00000000000001000000000000000000;
              5'b10011: E = 32'b00000000000010000000000000000000;
              5'b10100: E = 32'b00000000000100000000000000000000;
              5'b10101: E = 32'b00000000001000000000000000000000;
              5'b10110: E = 32'b00000000010000000000000000000000;
              5'b10111: E = 32'b00000000100000000000000000000000;
              5'b11000: E = 32'b00000001000000000000000000000000;
              5'b11001: E = 32'b00000010000000000000000000000000;
              5'b11010: E = 32'b00000100000000000000000000000000;
              5'b11011: E = 32'b00001000000000000000000000000000;
              5'b11100: E = 32'b00010000000000000000000000000000;
              5'b11101: E = 32'b00100000000000000000000000000000;
              5'b11110: E = 32'b01000000000000000000000000000000;
              5'b11111: E = 32'b10000000000000000000000000000000;
              endcase
          end
        else 
          E = 32'b00000000000000000000000000000000;
    end
endmodule



/**
 * PC_adder - A module for incrementing the program counter by 4
 *
 * The PC_adder module receives a 32-bit program counter value (PC_in) and
 * increments it by 4 to obtain the next program counter value (PC_out).
 *
 * Inputs:
 *  - PC_in: a 32-bit input wire representing the current program counter value
 *
 * Outputs:
 *  - PC_out: a 32-bit output register representing the next program counter value
 *
 * Usage example:
 *
 *  PC_adder pc_adder(
 *      .PC_in(PC),
 *      .PC_out(next_PC)
 *  );
 *
 */
module PC_adder (
    input wire [31:0] PC_in,
    output reg [31:0] PC_out
    );
    always @(*) begin
        PC_out = PC_in + 4;
    end
endmodule


/*
 * PC/nPC Register module
 *
 * The module represents a pair of registers, PC and nPC, that hold 32-bit values
 * for the current and next program counters, respectively. The module also includes
 * a multiplexer that selects between different input signals to update the PC register.
 * The selected signal is determined by the mux_select input, which is a 2-bit wide signal.
 *
 * Inputs:
 *   clk: Clock signal
 *   clr: Active low clear signal
 *   reset: Reset signal to initialize the register to zero
 *   LE: Load enable signal, determines when to update the PC register
 *   nPC: 32-bit input signal for the next program counter
 *   ALU_OUT: 32-bit input signal from the ALU
 *   TA: 32-bit input signal from the target address
 *   mux_select: 2-bit input signal to select between different input signals
 *
 * Outputs:
 *   OUT: 32-bit output signal that holds the value of the PC register after the update
 *
 * Example usage:
 *   PC_nPC_Register PC (
 *     .clk(clk),
 *     .clr(clr),
 *     .reset(reset),
 *     .LE(LE),
 *     .nPC(nPC),
 *     .ALU_OUT(ALU_OUT),
 *     .TA(TA),
 *     .mux_select(mux_select),
 *     .OUT(PC_out)
 *   );
 */
module PC_nPC_Register(
    input           clk,
    input           clr,
    input           reset,
    input           LE,
    input [31:0]    nPC,
    input [31:0]    ALU_OUT,
    input [31:0]    TA,
    input [1:0]     mux_select,
    output reg [31:0]   OUT
    );

    always @ (posedge clk, negedge clr) begin
        if (clr == 0 && clk == 1) begin
            if(reset) begin
                OUT <= 32'b0;
            end else if (LE) begin
                case (mux_select)
                    2'b00: OUT <= nPC;
                    2'b01:  OUT <= TA;
                    2'b10:  OUT <= ALU_OUT;
                    default: OUT <= OUT;
                endcase
            end
        end
    end 
endmodule


/**************************************************************
* Module Name: control_unit_mux
***************************************************************
* Description:
*     This module represents a control unit multiplexer. It selects and outputs control signals based on the input select signal (S) and the input data (cu_in_mux).
* 
* Ports:
*     - ID_ALU_OP_out (output reg [3:0]): 4-bit output for ALU operation.
*     - ID_jmpl_instr_out (output reg): Output for jump-link (jmpl) instruction.
*     - ID_call_instr_out (output reg): Output for call instruction.
*     - ID_branch_instr_out (output reg): Output for branch instruction.
*     - ID_load_instr_out (output reg): Output for load instruction.
*     - ID_register_file_Enable_out (output reg): Output for register file enable.
*     - ID_data_mem_SE (output reg): Output for data memory store-enable.
*     - ID_data_mem_RW (output reg): Output for data memory read-write.
*     - ID_data_mem_Enable (output reg): Output for data memory enable.
*     - ID_data_mem_Size (output reg [1:0]): 2-bit output for data memory size.
*     - I31_out (output reg): Output for I31 signal.
*     - I30_out (output reg): Output for I30 signal.
*     - I24_out (output reg): Output for I24 signal.
*     - I13_out (output reg): Output for I13 signal.
*     - ID_ALU_OP_instr (output reg [3:0]): 4-bit output for ALU operation instruction.
*     - CC_Enable (output reg): Output for condition code (CC) enable.
* 
*     - S (input): Select signal.
*     - cu_in_mux (input [18:0]): Input data for control unit multiplexer.
* 
* Usage:
*     1. Instantiate the module in your Verilog design.
*     2. Connect the select signal (S) and the input data (cu_in_mux) appropriately.
*     3. The control signals will be available on the corresponding output ports.
* 
* Notes:
*     - The control signals are selected based on the value of the select signal (S) and the input data (cu_in_mux).
*     - When S is high (1'b1), all output signals are set to 0.
*     - Ensure that the width of the input data (cu_in_mux) is compatible with the module's interface.
* 
*/
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


/**************************************************************
 * Module Name: control_unit
 **************************************************************
 * The control_unit module is responsible for generating control signals based on the input instruction.
 * It takes a 32-bit instruction as input and produces various control signals as outputs.
 * The module decodes the instruction opcode and opcode extension to determine the type of instruction
 * and sets the corresponding control signals accordingly.
 * The control signals include flags for different types of instructions such as jmpl, call, branch, load,
 * register file enable, memory operation type, memory size, ALU operation, condition code enable, and various
 * instruction-specific flags.
 * The control signals are used to control the operation of other modules in the processor pipeline.
 *
 * Inputs:
 * - instr: A 32-bit instruction to be decoded (input)
 * - clk: Clock signal (input)
 * - clr: Clear signal (input)
 *
 * Outputs:
 * - instr_signals: A 19-bit vector of control signals (output)
 *   - instr_signals[0]: ID_jmpl_instr - Signal indicating if the instruction is a jmpl instruction
 *   - instr_signals[1]: ID_call_instr - Signal indicating if the instruction is a call instruction
 *   - instr_signals[2]: ID_load_instr - Signal indicating if the instruction is a load instruction
 *   - instr_signals[3]: ID_register_file_Enable - Signal indicating if the register file should be enabled
 *   - instr_signals[4]: ID_data_mem_SE - Signal indicating if the memory operation is sign-extended
 *   - instr_signals[5]: ID_data_mem_RW - Signal indicating if the memory operation is a read or write
 *   - instr_signals[6]: ID_data_mem_Enable - Signal indicating if the memory should be enabled
 *   - instr_signals[8:7]: ID_data_mem_Size - Signal indicating the size of memory operation
 *   - instr_signals[9]: CC_Enable - Signal indicating if the condition codes should be enabled
 *   - instr_signals[10]: I31 - Bit 31 of the instruction
 *   - instr_signals[11]: I30 - Bit 30 of the instruction
 *   - instr_signals[12]: I24 - Bit 24 of the instruction
 *   - instr_signals[13]: I13 - Bit 13 of the instruction
 *   - instr_signals[17:14]: ID_ALU_OP_instr - Signal indicating the ALU operation for the instruction
 *   - instr_signals[18]: ID_branch_instr - Signal indicating if the instruction is a branch instruction
 *
 * Implementation:
 * - The module starts by checking if the clear signal is active and initializes all control signals to 0.
 * - Next, it checks the opcode of the instruction and determines the type of instruction based on the opcode.
 * - If the opcode is a branch instruction, the corresponding control signals are set.
 * - If the opcode is a load instruction, the corresponding control signals are set.
 * - If the opcode is a sethi instruction, the corresponding control signals are set.
 * - If the opcode is a format 2 instruction, the opcode extension is checked to determine the specific instruction type.
 * - For jmpl instructions, the control signals are set accordingly.
 * - For save and restore instructions, the control signals are set accordingly.
 * - For arithmetic instructions, the opcode extension is further checked to determine the ALU operation and condition code flags.
 * - Finally, the control signals are assigned to the output instr_signals.
 *
 * Note:
 * - This module assumes a specific instruction set architecture (SPARC) and may not be applicable to other architectures.
 * - The module implementation shown here is a simplified example
 *   and may need to be customized or extended to support additional instructions or architectures.
 * - The control signals generated by this module are used to control the operation of other modules in the processor pipeline,
 *   such as the register file, ALU, and memory units.
 * - The control signals determine the data paths and control flow within the processor based on the current instruction.
 * - The control signals are crucial for executing instructions correctly and efficiently, ensuring proper synchronization,
 *   and maintaining the pipeline stages.
 * - It is important to ensure that the control signals are generated accurately to match the behavior specified by the instruction set architecture.
 * - Changes or modifications to the instruction set architecture or the addition of new instructions may require updating
 *   the control unit module to handle the new instructions and generate the appropriate control signals.
 * - This control unit module is just one component of a complete processor design and should be integrated into a larger design
 *   that includes other modules such as instruction fetch, decode, execute, and memory units to create a functional processor.
 *
 * Usage:
 * - Instantiate the control_unit module in your processor design and connect the inputs and outputs as required.
 * - Connect the 'instr' input to the 32-bit instruction that needs to be decoded.
 * - Connect the 'clk' input to the clock signal of your design.
 * - Connect the 'clr' input to the clear signal of your design to initialize the control signals.
 * - Use the 'instr_signals' output to control the operation of other modules based on the decoded instruction.
 * - Ensure that the control signals are propagated correctly through the pipeline stages of your processor design.
 * - Verify the functionality and correctness of the control unit module using simulation and testing.
 * - Modify and customize the control unit module as needed to support the specific instruction set architecture and processor design requirements.
 *
 * Example:
 * // Instantiate the control_unit module
 * control_unit cu (
 *   .instr(instr),
 *   .clk(clk),
 *   .clr(clr),
 *   .instr_signals(instr_signals)
 * );
 *
 * // Connect the control signals to other modules in the processor design
 * module_name module_inst (
 *   .clk(clk),
 *   .instr_signals(instr_signals),
 *   // Other module inputs and outputs
 * );
 *
 * // Ensure correct propagation of control signals through the pipeline stages
 * // and synchronization with the clock signal in the processor design.
 *
 * // Simulate and test the control unit module functionality using testbenches and test cases.
 *
 * Design Considerations:
 * - The control_unit module assumes a single-cycle execution model, where each instruction is executed in a single clock cycle.
 *   If your processor design follows a different execution model, you may need to modify the control unit accordingly.
 * - This control unit module focuses on generating control signals for the execution of instructions and does not handle pipeline hazards,
 *   branch prediction, or other advanced techniques. Additional modules and logic may be required to handle such features.
 * - It is important to ensure that the control signals are synchronized with the clock signal to avoid timing issues and ensure proper operation.
 * - The control unit module relies on the instruction set architecture (ISA) specifications to determine the control signal assignments.
 *   Ensure that the ISA documentation is referenced correctly and that the control unit module accurately reflects the ISA requirements.
 * - Care should be taken to handle exceptional cases, such as unsupported instructions or illegal instruction combinations,
 *   to prevent unintended behavior and maintain the correctness and stability of the processor.
 * - Consider implementing error detection and correction mechanisms to handle faults and ensure reliable operation of the control unit.
 * - To support a wider range of instructions or a different instruction set architecture, the control unit module may need to be expanded
 *   with additional control signals and logic to accommodate the new instructions and their associated operations.
 * - It is recommended to thoroughly test the control unit module with various instruction sequences and corner cases to ensure its correctness,
 *   functionality, and compatibility with the processor design.
 * - Documentation and comments within the module should be kept up to date to provide clarity and aid in understanding and maintaining the code.
 * - Maintain good coding practices such as using meaningful signal and variable names, organizing the code in a modular and readable manner,
 *   and adhering to coding style guidelines to improve maintainability and readability of the control unit module.
 * - Collaborate and communicate with other members of the design team to ensure consistent understanding and implementation of the control signals
 *   throughout the processor design and to address any potential conflicts or issues that may arise during the integration process.
 *
 * Limitations:
 * - The control unit module provided here is a simplified implementation and may not cover all possible instructions or complex control scenarios.
 *   It serves as a starting point and should be customized and extended based on the specific requirements of the processor design.
 * - The control unit module assumes a specific instruction set architecture (ISA) and may not be compatible with other architectures without modifications.
 *   Ensure that the ISA specifications are carefully considered and accurately reflected in the control unit implementation.
 * - This control unit module does not include support for privileged instructions or operating system-specific functionality.
 *   If your processor design requires handling privileged instructions, additional logic and control signals may need to be added.
 * - It is important to consider the performance and efficiency of the control unit implementation, as it directly affects the overall processor performance.
 *   Complex control logic or excessive signal dependencies can introduce delays and reduce the maximum achievable clock frequency.
 *   Careful optimization and consideration of critical paths may be necessary to meet performance targets.
*/
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

    always @(posedge clk) begin
        if (clr == 0 && clk == 1) begin
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
                    $display("This is a call instruction");
                    ID_jmpl_instr                   <= 1'b0;
                    ID_call_instr                   <= 1'b1;
                    ID_branch_instr                 <= 1'b0;
                    ID_load_instr                   <= 1'b0;
                    ID_register_file_Enable         <= 1'b1;

                    // Ask professor about this
                    ID_data_mem_SE                  <= 1'b0;
                    ID_data_mem_RW                  <= 1'b0;
                    ID_data_mem_Enable              <= 1'b0;
                    ID_data_mem_Size                <= 2'b00;

                    // Also ask prof bout the alu
                    ID_ALU_OP_instr                 <= 4'b0000;
                    CC_Enable                       <= 1'b0;
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
                                    ID_data_mem_SE          <= 1'b1;
                                    ID_data_mem_Size        <= 2'b00;
                                end else if (op3 == 6'b001010) begin // Load signed halfword
                                    ID_data_mem_SE          <= 1'b1;
                                    ID_data_mem_Size        <= 2'b01;       
                                end else if (op3 == 6'b000000) begin // Load word
                                    ID_data_mem_SE          <= 1'b0;
                                    ID_data_mem_Size        <= 2'b10;                            
                                end else if (op3 == 6'b000001) begin // Load unsigned byte
                                    ID_data_mem_SE          <= 1'b0;
                                    ID_data_mem_Size        <= 2'b00;
                                end else begin // 6'b000010 Load unsigned halfword
                                    ID_data_mem_SE          <= 1'b0;
                                    ID_data_mem_Size        <= 2'b01;
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
                                $display("Instruction is a jmpl instruction");    
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

                                ID_data_mem_RW              <= 1'b0;
                                ID_data_mem_Enable          <= 1'b1;
                                ID_data_mem_Size            <= 2'b10;                            
                            
                            end
                            // Arithmetic
                            default: begin
                                // For cases where the signal modifies condition codes
                                $display("ALU MOMENT %b", op3);
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
                                        ID_ALU_OP_instr = 4'b0110;
                                        CC_Enable       = 1'b1;
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
                                ID_data_mem_RW              <= 1'b1;
                                ID_data_mem_Enable          <= 1'b1;
                                ID_data_mem_Size            <= 2'b0;
                            end
                        endcase
                    end
                end
            endcase
        end

        I31 = instr[31];
        I30 = instr[30];
        I24 = instr[24];
        I13 = instr[13];

        // Output
        instr_signals[0]      = ID_jmpl_instr;
        instr_signals[1]      = ID_call_instr;
        instr_signals[2]      = ID_load_instr;
        instr_signals[3]      = ID_register_file_Enable;

        instr_signals[4]      = ID_data_mem_SE;
        instr_signals[5]      = ID_data_mem_RW;
        instr_signals[6]      = ID_data_mem_Enable;
        instr_signals[8:7]    = ID_data_mem_Size;

        instr_signals[9]      = CC_Enable;

        instr_signals[10]     = I31;
        instr_signals[11]     = I30;
        instr_signals[12]     = I24;
        instr_signals[13]     = I13;

        instr_signals[17:14]  = ID_ALU_OP_instr;
        instr_signals[18]     = ID_branch_instr;
        // $display("THIS IS THE ALU INSTRUCTION BITCH %b", ID_ALU_OP_instr);
        // $display("AND FROM THE WIRE %b", instr_signals[17:14]);
       
         //$display(">>> Control Unit Instruction Signals:\n------------------------------------------");
         //$display("Instructions found on CU: %b\n------------------------------------------", instr);
         //$display("jmpl: %d | call: %b | load: %b | regfile E: %b | branch: %b | CC_E: %b\n-------------------------", ID_jmpl_instr, ID_call_instr, ID_load_instr, ID_register_file_Enable, ID_branch_instr, CC_Enable);
        // $display("Data Memory Instructions from Control Unit:");
        // $display("SE: %b | R/W: %b | E: %b | Size: %b\n-------------------------", ID_data_mem_SE, ID_data_mem_RW, ID_data_mem_Enable, ID_data_mem_Size);
        // $display("Operand2 Handler and ALU Instructions from Control Unit:");
        // $display("I31: %b | I30: %b | I24: %b | I13: %b | ALU_OP: %b\n-------------------------\n\n", I31, I30, I24, I13, ID_ALU_OP_instr);

        end
    end
endmodule


/**************************************************************
 * Module Name: mux_4x1
 **************************************************************
 *
 * Description:
 * This module implements a 4x1 multiplexer. It selects one of the four input signals I0, I1, I2, or I3 based on the select signals S[1:0]
 * and outputs the selected signal on the output port Y[31:0].
 *
 * Input Ports:
 * - S[1:0] (input [1:0]): Select signals used to choose the input signal to be routed to the output.
 * - I0, I1, I2, I3 (input [31:0]): Input signals to be selected by the multiplexer.
 *
 * Output Ports:
 * - Y[31:0] (output reg [31:0]): Output port that carries the selected input signal based on the select signals.
 *
 * Operation:
 * - The module uses a combinational always block that triggers on changes in the select signals S[1:0] or the input signals I0, I1, I2, I3.
 * - Based on the select signals S[1:0], the multiplexer selects the corresponding input signal I0, I1, I2, or I3 and assigns it to the output signal Y[31:0].
 * - The selected input signal is assigned to the output signal using non-blocking assignments ('<=').
 *
 * Limitations/Assumptions:
 * - This module assumes a 32-bit wide multiplexer, where the input signals I0, I1, I2, I3 and the output signal Y are all 32 bits wide.
 *   Modify the port and signal widths accordingly if using a different data width.
 * - The select signals S[1:0] are assumed to be 2 bits wide, allowing for up to four possible input signals.
 *   If the multiplexer needs to support a different number of input signals, modify the select signal width accordingly.
 * - This module does not handle any exceptions or error cases, such as invalid select signals or unsupported input signal combinations.
 *   Ensure that the select signals are valid and within the range of the available input signals to prevent undefined behavior.
 * - It is important to synchronize the select signals and the input signals with the clock signal to avoid timing issues and ensure proper operation.
 * - The module does not provide any built-in support for expanding the MUX to larger sizes or modifying the data widths.
 * - It is the designer's responsibility to properly size and connect the input and output ports to match the desired data widths and expand the MUX if needed.
 * - The module operates using combinational logic, and as such, it does not introduce any clock cycles or delays in the signal path.
 * - It is recommended to thoroughly test the module with different select signal values and input values to ensure its correctness and functionality.
 * - Care should be taken to avoid race conditions and glitches when using the module in designs with multiple combinational paths and changing inputs.
 *
 * Usage:
 *   - Connect the select signal (S) and input signals (I0, I1, I2, I3) to appropriate sources in your design.
 *   - The output signal (Y) will reflect the value of the selected input signal based on the select signal.
 *   - Ensure that the input and output signals are connected to appropriate data paths in your design.
 *   - The output signal will be updated whenever there is a change in the select signal or any of the input signals.
 *   - The module supports combinational behavior, and the output is updated immediately based on the input values.
 *   - The module assumes that only one select signal combination is active at a time (e.g., S = 2'b00, 2'b01, 2'b10, or 2'b11).
 *   - Any other value for the select signal (S) may lead to unintended behavior and should be avoided.
 *   - The module does not include any error detection or correction mechanisms. Ensure that the select signal is within the valid range.
 *   - The input and output widths are set to 32 bits, but they can be modified to support different data widths based on your requirements.
 *   - Properly size and connect the input and output ports of the module in your design to match the desired data widths.
 *   - The module uses combinational logic and does not introduce any additional clock cycles or delays in the signal path.
 *   - It is important to ensure proper synchronization and timing of the select signal and input signals to avoid glitches and timing issues.
 *   - Test the module with various select signal combinations and input values to verify its correctness and functionality in your design.
 *   - It is recommended to use meaningful signal names and adhere to coding style guidelines for better readability and maintainability of the code.
 *
 */
module mux_4x1  (
    output reg [31:0] Y,
    input [1:0] S, 
    input [31:0] I0, I1, I2, I3
);

always @ (S, I0, I1, I2, I3)
	case (S) 
		2'b00:  Y <= I0;
		2'b01:  Y <= I1;
		2'b10:  Y <= I2;
		2'b11:  Y <= I3;
	endcase
endmodule


/***************************************************************
 * Module: condition_handler
 * *************************************************************
 * 
 * Description:
 *   The condition_handler module handles branch conditions based on
 *   condition flags and a conditional opcode. It evaluates the branch
 *   condition and outputs a branch signal.
 * 
 * Inputs:
 *   - flags [3:0]: Condition flags (Z, N, C, V)
 *   - cond [3:0]: Conditional opcode
 *   - ID_branch_instr: Branch instruction enable signal
 * 
 * Outputs:
 *   - branch_out: Branch condition signal
 * 
 * Order of Condition flags:
 *   - Z: Zero
 *   - N: Negative
 *   - C: Carry
 *   - V: Overflow
 * 
 ***************************************************************/
module condition_handler (
    input [3:0] flags,
    input [3:0] cond,
    input ID_branch_instr,
    output reg branch_out
    );

    // Order of Condition flags
    // Z -> Zero
    // N -> Negative
    // C -> Carry
    // V -> Overflow

    reg Z, N, C, V;

    always @(flags) begin
        Z <= flags[0];
        N <= flags[1];
        C <= flags[2];
        V <= flags[3];
    end

    always @(flags, cond, ID_branch_instr) begin
        if (ID_branch_instr) begin
            case (cond)
                4'b0000: branch_out = ID_branch_instr; // Branch Never
                4'b0001: branch_out = Z; // Branch on Equals
                4'b0010: branch_out = Z | (N ^ V); // Branch on less or Equal
                4'b0011: branch_out = N ^ V; // Branch on Less - bl
                4'b0100: branch_out = C | Z; // Branch on Less or Equal Unsigned - bleu
                4'b0101: branch_out = C ; // Branch on Carry = 1 - bcs
                4'b0110: branch_out = N; // Branch on Negative - bneg
                4'b0111: branch_out = V; // Branch Overreflow = 1 - bvs
                4'b1000: branch_out = 1'b1; // Branch Always - ba
                4'b1001: branch_out = ~Z; // Branch on not Equals - bne
                4'b1010: branch_out = ~(Z | (N ^ V)); // Branch on Greater - bg
                4'b1011: branch_out = ~(N ^ V); // Branch on Greater or Equal - bge
                4'b1100: branch_out = ~(C | Z); // Branch on Greater Unsigned - bgu
                4'b1101: branch_out = ~C; // Branch on Carry = 0 - bcc
                4'b1110: branch_out = ~N; // Branch on Positive - bpos
                4'b1111: branch_out = ~V; // Branch overreflow = 0 - bvc
                default: branch_out = 1'b0; // Catch unexpected values of "cond"
            endcase
        end else branch_out <= 1'b0; // Output 0 when ID_branch_instr is 0
    end
endmodule


/*
* This module is responsible for selecting the output signal that will be used to update the Program Counter (PC)
* and the Next Program Counter (nPC) registers based on the execution of the previous instruction. 
*
* It takes three inputs: 'branch_out' which is high when the previous instruction was a branch 
* instruction, 'ID_jmpl_instr' which is high when the previous instruction was a Jmpl instruction, 
* and 'ID_call_instr' which is high when the previous instruction was a Call instruction. 
*
* It also has an output 'pc_handler_out_selector' which is a 2-bit signal that determines which of 
* the two input signals (TA or ALU_OUT) will be used to update the PC/nPC registers. 
*
* If 'ID_jmpl_instr' is high, then the ALU_OUT signal will be used to update the PC/nPC registers. 
*
* If 'ID_call_instr' or 'branch_out' is high, then the TA signal will be used to update the PC/nPC registers. 
* 
* If 'branch_out' is high and 'ID_call_instr' is low, then the Branch Taken (BT) signal will be 
* used to update the PC/nPC registers. 
*
* If none of these conditions are met, the normal execution will occur, and the nPC will be incremented 
* by 4 to point to the next instruction in memory.
*
* - 2'b00: Use the value of the ALU output as the next PC (for Jmpl instructions).
*
* - 2'b01: Use the value of TA (target address) as the next PC (for branch instructions
*          where the branch is taken).
*
* - 2'b10: Not used in this module.
*
* - 2'b11: Use the value of TA as the next PC (for Call instructions and branch instructions
*          where the branch is taken).
*
* The module has an always block that updates pc_handler_out_selector based on the values
* of the inputs. The priority of the cases in the always block is as follows: 
* 
* - Jmpl > Call/branch > branch taken > normal execution (nPC + 4).
*
* The module is intended to be used in a larger processor design, where it is responsible for
* generating the next PC value for the processor. 
*
*/
module npc_pc_handler (
    input branch_out,
    input ID_jmpl_instr,
    input ID_call_instr,
    output reg [1:0] pc_handler_out_selector
    );
    always @(branch_out, ID_jmpl_instr, ID_call_instr) begin
        if (ID_jmpl_instr)                   pc_handler_out_selector <= 2'b00; // Jmpl Instruction, use ALU out
        else if (ID_call_instr | branch_out) pc_handler_out_selector <= 2'b11; // call or branch, use TA
        else if (branch_out)                 pc_handler_out_selector <= 2'b01; // Branch Taken        
        else                                 pc_handler_out_selector <= 2'b00; // Normal Execution nPC+4
    end
endmodule



/***************************************************************
 * Module: PSR_register
 * 
 * Description:
 *   The PSR_register module represents a Processor Status Register
 *   register that holds condition flags and a carry flag. It provides
 *   an output for the condition flags and the carry flag based on
 *   the inputs.
 * 
 * Inputs:
 *   - flags [3:0]: Input condition flags
 *   - enable: Enable signal for updating the output
 *   - Clr: Clear signal for resetting the output
 *   - clk: Clock signal
 * 
 * Outputs:
 *   - out [3:0]: Output condition flags
 *   - carry: Output carry flag
 * 
 ***************************************************************/
module PSR_register (
    output reg [3:0] out,
    output reg carry,
    input wire [3:0] flags, 
    input wire enable, Clr, clk
);
always @ (posedge clk, posedge Clr)
	if (Clr) out <= 4'b000;
	else if (enable) begin
        out <= flags;
        carry <= flags[2];
    end
endmodule



/***************************************************************
 * Module: reset_handler
 * 
 * Description:
 *   The reset_handler module is responsible for generating a reset
 *   signal based on the input conditions. It monitors the system
 *   reset signal and an ID branch instruction signal along with
 *   an additional input 'a'. When either the system reset is active
 *   or the ID branch instruction is active along with input 'a',
 *   it triggers the reset signal 'reset_out'.
 * 
 * Inputs:
 *   - system_reset: System reset signal
 *   - ID_branch_instr: ID branch instruction signal
 *   - a: Additional input signal 'a'
 * 
 * Outputs:
 *   - reset_out: Reset output signal
 * 
 ***************************************************************/
 module reset_handler(
    input system_reset,
    input ID_branch_instr,
    input a, // I29 instruction
    output reg reset_out // The thing that triggers reset
);

    always @(posedge system_reset, posedge ID_branch_instr) begin
        if (system_reset || (ID_branch_instr && a)) begin
            reset_out <= 1'b1;
        end else begin
            reset_out <= 1'b0;
        end
    end

endmodule


//-----------------Modules that will be instantiated in the file------------------------------//

//MULTIPLEXOR 32X1 - S and R0-R31 are 32bit inputs. Y is a 32bit output.
//A case for S is used to select one of the R0-R31 and assign the output to Y.
//We will be instantiating three of them due to it being a three port register file.

module mux_32x1_32bit (output reg [31:0] Y, input [4:0] S, 
input [31:0] R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15,
R16, R17, R18, R19, R20, R21, R22, R23, R24, R25, R26, R27, R28, R29, R30, R31);
    
    always @ (*)
    begin
    case (S)
    5'b00000: Y = R0;
    5'b00001: Y = R1;
    5'b00010: Y = R2;
    5'b00011: Y = R3;
    5'b00100: Y = R4;
    5'b00101: Y = R5;
    5'b00110: Y = R6;
    5'b00111: Y = R7;
    5'b01000: Y = R8;
    5'b01001: Y = R9;
    5'b01010: Y = R10;
    5'b01011: Y = R11;
    5'b01100: Y = R12;
    5'b01101: Y = R13;
    5'b01110: Y = R14;
    5'b01111: Y = R15;
    5'b10000: Y = R16;
    5'b10001: Y = R17;
    5'b10010: Y = R18;
    5'b10011: Y = R19;
    5'b10100: Y = R20;
    5'b10101: Y = R21;
    5'b10110: Y = R22;
    5'b10111: Y = R23;
    5'b11000: Y = R24;
    5'b11001: Y = R25;
    5'b11010: Y = R26;
    5'b11011: Y = R27;
    5'b11100: Y = R28;
    5'b11101: Y = R29;
    5'b11110: Y = R30;
    5'b11111: Y = R31;
    endcase
    end
endmodule




//REGISTER - The register takes care of charging the data in D to the Q output register.
//Ld signal will indicate the register that isn't 0 and make Q the output for the bits in the register.
//Clk is the clock that syncs the register with the rest.

module register_32bit (output reg [31:0] Q, input [31:0] D, input Clk, Ld);
    always @ (posedge Clk)
        if(Ld) Q <= D;
endmodule



module register_file (output [31:0] PA, PB, PD, input [31:0] PW,  input [4:0] RW, RA, RB, RD, input LE, Clk);
    //Outputs: Puertos A, B y D
    //Inputs: Puerto de Entrada (PW), RW (Write Register) y LE (BinaryDecoder Selector y "load"), 
    //RA, RB y RD  (Selectors de multiplexers a la salida), y Clk (Clock)

    //Wires
    wire [31:0] E;
    wire [31:0] Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9, Q10, Q11, Q12, Q13, Q14, Q15, 
    Q16, Q17, Q18, Q19, Q20, Q21, Q22, Q23, Q24, Q25, Q26, Q27, Q28, Q29, Q30, Q31;

    //Instanciando módulos:

    //Binary Decoder for RA,RB,RD
    binaryDecoder bdecoder (E, RW, LE);

    //Los multiplexers a continuacion cogen valor almacenado en el registro 
    //correspondiente y lo envian a las salidas de los registros:

    //Multiplexer for PA register
    mux_32x1_32bit mux_32x1A (PA, RA, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9,
                    Q10, Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18, Q19, Q20, Q21, Q22, 
                    Q23, Q24, Q25, Q26, Q27, Q28, Q29, Q30, Q31);
    //Multiplexer for PB register
    mux_32x1_32bit mux_32x1B (PB, RB, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9,
                    Q10, Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18, Q19, Q20, Q21, Q22, 
                    Q23, Q24, Q25, Q26, Q27, Q28, Q29, Q30, Q31);
    //Multiplexer for PD register
    mux_32x1_32bit mux_32x1D (PD, RD, Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7, Q8, Q9,
                    Q10, Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18, Q19, Q20, Q21, Q22, 
                    Q23, Q24, Q25, Q26, Q27, Q28, Q29, Q30, Q31);                
   
    
    //Insanciando registros del 0 al 31
    register_32bit R0 (Q0, PW, Clk, E[0]);
    register_32bit R1 (Q1, PW, Clk, E[1]);
    register_32bit R2 (Q2, PW, Clk, E[2]);
    register_32bit R3 (Q3, PW, Clk, E[3]);
    register_32bit R4 (Q4, PW, Clk, E[4]);
    register_32bit R5 (Q5, PW, Clk, E[5]);
    register_32bit R6 (Q6, PW, Clk, E[6]);
    register_32bit R7 (Q7, PW, Clk, E[7]);
    register_32bit R8 (Q8, PW, Clk, E[8]);
    register_32bit R9 (Q9, PW, Clk, E[9]);
    register_32bit R10 (Q10, PW, Clk, E[10]);
    register_32bit R11 (Q11, PW, Clk, E[11]);
    register_32bit R12 (Q12, PW, Clk, E[12]);
    register_32bit R13 (Q13, PW, Clk, E[13]);
    register_32bit R14 (Q14, PW, Clk, E[14]);
    register_32bit R15 (Q15, PW, Clk, E[15]);
    register_32bit R16 (Q16, PW, Clk, E[16]);
    register_32bit R17 (Q17, PW, Clk, E[17]);
    register_32bit R18 (Q18, PW, Clk, E[18]);
    register_32bit R19 (Q19, PW, Clk, E[19]);
    register_32bit R20 (Q20, PW, Clk, E[20]);
    register_32bit R21 (Q21, PW, Clk, E[21]);
    register_32bit R22 (Q22, PW, Clk, E[22]);
    register_32bit R23 (Q23, PW, Clk, E[23]);
    register_32bit R24 (Q24, PW, Clk, E[24]);
    register_32bit R25 (Q25, PW, Clk, E[25]);
    register_32bit R26 (Q26, PW, Clk, E[26]);
    register_32bit R27 (Q27, PW, Clk, E[27]);
    register_32bit R28 (Q28, PW, Clk, E[28]);
    register_32bit R29 (Q29, PW, Clk, E[29]);
    register_32bit R30 (Q30, PW, Clk, E[30]);
    register_32bit R31 (Q31, PW, Clk, E[31]);

endmodule






// Pipeline module for IF/ID
module pipeline_IF_ID (
    input wire         reset, LE, clk, clr,
    input wire [31:0]  PC,
    input wire [31:0]  instruction,

    output wire [31:0] PC_ID_out,        // PC
    output wire [21:0] I21_0,            // Imm22
    output wire [29:0] I29_0,            // Can't remember, don't ask
    output wire        I29_branch_instr, // For Branch, part of Phase 4
    output wire [4:0]  I18_14,            // rs1
    output wire [4:0]  I4_0,              // rs2
    output wire [4:0]  I29_25,            // rd
    output wire [3:0]  I28_25,            // cond, for Branch
    output wire [31:0] instruction_out   
);

    reg [31:0] PC_ID_out_reg;
    reg [21:0] I21_0_reg;
    reg [29:0] I29_0_reg;
    reg I29_branch_instr_reg;
    reg [4:0] I18_14_reg;
    reg [4:0] I4_0_reg;
    reg [4:0] I29_25_reg;
    reg [3:0] I28_25_reg;
    reg [31:0] instruction_reg;
    
    always@(posedge clk, negedge clr) begin
        if (clk  == 1 && clr == 0) begin
            if (reset) begin
                PC_ID_out_reg            <= 31'b0;
                I21_0_reg                <= 21'b0;
                I29_0_reg                <= 29'b0;
                I29_branch_instr_reg     <= 32'b0;
                I18_14_reg               <= 32'b0;
                I4_0_reg                 <= 5'b0;
                I29_25_reg               <= 5'b0;
                I28_25_reg               <= 5'b0;
                instruction_reg          <= 32'b0;
            end else begin
                PC_ID_out_reg            <= PC;
                I21_0_reg                <= instruction[21:0];
                I29_0_reg                <= instruction[29:0];
                I29_branch_instr_reg     <= instruction[29];
                I18_14_reg               <= instruction[18:14];
                I4_0_reg                 <= instruction[4:0];
                I29_25_reg               <= instruction[29:25];
                I28_25_reg               <= instruction[28:25]; 
                instruction_reg          <= instruction;
                // #2; // Hello There I'm a bug anihilator :)
            end
        end

    // #2
    //$display(">>> IF/ID Output Signals:\n------------------------------------------");
    // $display(">>> ID Control Signals:\n------------------------------------------");
    // $display("PC: %d | imm: %b | I29: %b | branch: %b | rs1: %b | rs2: %b | rd: %b | cond: %b | inst: %b\n", 
    //          PC_ID_out_reg, I21_0_reg, I29_0_reg, I29_branch_instr_reg, I18_14_reg, I4_0_reg, I29_25_reg, I28_25_reg, instruction_reg);
    end
    assign PC_ID_out         = PC_ID_out_reg;       
    assign I21_0             = I21_0_reg;   
    assign I29_0             = I29_0_reg;   
    assign I29_branch_instr  = I29_branch_instr_reg;           
    assign I18_14            = I18_14_reg;   
    assign I4_0              = I4_0_reg;
    assign I29_25            = I29_25_reg;   
    assign I28_25            = I28_25_reg;   
    assign instruction_out   = instruction_reg;    
endmodule


/*
 * Module: pipeline_ID_EX
 * 
 * Description:
 *   This module represents the pipeline stage between the Instruction Decode (ID) and
 *   Execute (EX) stages. It is responsible for forwarding relevant signals from the ID
 *   stage to the EX stage.
 * 
 * Inputs:
 *   - reset: Asynchronous reset signal
 *   - clk: Clock signal
 *   - clr: Clear signal
 *   - ID_control_unit_instr: Control unit instructions from the ID stage
 *   - PC: Program Counter value
 *   - ID_RD_instr: RD instructions from the ID stage
 * 
 * Outputs:
 *   - PC_EX_out: Program Counter output for the EX stage
 *   - EX_IS_instr: Instruction bits used by the operand handler in the EX stage
 *   - EX_ALU_OP_instr: Opcode used by the ALU in the EX stage
 *   - EX_RD_instr: RD instructions for the EX stage
 *   - EX_CC_Enable_instr: Control signal for enabling condition code updates in the EX stage
 *   - EX_control_unit_instr: Remaining control unit instructions for the EX stage
 * 
 * Registers:
 *   - PC_ID_out_reg: Register for storing the PC value from the ID stage
 *   - EX_IS_instr_reg: Register for storing the instruction bits used by the operand handler
 *   - EX_ALU_OP_instr_reg: Register for storing the ALU opcode
 *   - EX_RD_instr_reg: Register for storing the RD instructions
 *   - EX_CC_Enable_instr_reg: Register for storing the control signal for enabling condition code updates
 *   - EX_control_unit_instr_reg: Register for storing the remaining control unit instructions
 * 
 * Operation:
 *   - On the positive edge of the clock and when the clear signal is low, the registers in
 *     the module are updated based on the inputs.
 *   - If the reset signal is high, the registers are reset to their default values.
 *   - The relevant signals are forwarded to the output ports.
 *   - The module also displays the output signals using $display.
 */
module pipeline_ID_EX(
    input  wire reset, clk, clr,
    input  wire [17:0] ID_control_unit_instr,      // Control Unit Instructions
    input  wire [31:0] PC,
    input  wire [4:0]  ID_RD_instr,
    input  wire [21:0] Imm22,

    output wire [31:0] PC_EX_out,                  // PC
    output wire [3:0]  EX_IS_instr,                // The bits used by the operand handler            
    output wire [3:0]  EX_ALU_OP_instr,            // The opcode used by the ALU 
    output wire [4:0]  EX_RD_instr,                 // 
    output wire        EX_CC_Enable_instr,
    output wire [21:0] EX_Imm22,

    output wire [8:0]  EX_control_unit_instr      // The rest of the control unit instructions that don't need to be deconstructed
    );

    reg [31:0] PC_ID_out_reg;
    reg [3:0]  EX_IS_instr_reg;
    reg [3:0]  EX_ALU_OP_instr_reg;
    reg [8:0]  EX_control_unit_instr_reg;
    reg [5:0]  EX_RD_instr_reg;
    reg        EX_CC_Enable_instr_reg;
    reg [21:0] EX_Imm22_reg = 22'b0;

    always@(posedge clk, negedge clr) begin
        if (clk  == 1 && clr == 0) begin
            if (reset) begin
                PC_ID_out_reg               <= 32'b0;
                EX_IS_instr_reg             <= 4'b0;
                EX_ALU_OP_instr_reg         <= 4'b0;
                EX_control_unit_instr_reg   <= 8'b0;
                EX_RD_instr_reg             <= 5'b0;
                EX_CC_Enable_instr_reg      <= 1'b0;
                EX_Imm22_reg                <= 22'b0;
            end else begin
                
            // #2;
            // $display("Immediate vals. IN %b and OUT %b", Imm22, EX_Imm22_reg);
                PC_ID_out_reg               <= PC;
                EX_IS_instr_reg             <= ID_control_unit_instr[13:10];
                EX_ALU_OP_instr_reg         <= ID_control_unit_instr[17:14];
                EX_RD_instr_reg             <= ID_RD_instr;
                EX_CC_Enable_instr_reg      <= ID_control_unit_instr[9];
                EX_control_unit_instr_reg   <= ID_control_unit_instr[8:0];
                EX_Imm22_reg                <= Imm22;
                // #2;
            end
        end
//     $display(">>> ID/EX Output Signals:\n------------------------------------------");
//     $display("PC: %d | EX_IS: %b | EX_ALU: %b | EX_RD: %b | EX_CC: %b", 
//             PC_ID_out_reg, EX_IS_instr_reg, EX_ALU_OP_instr_reg, EX_RD_instr_reg, EX_CC_Enable_instr_reg);
//     $display("Signals that are forwarded:\n---------------------\nID jmpl: %b | ID call: %b | ID load: %b | ID Reg Enable: %b | ID Mem SE: %b | ID MEM R/W: %b | ID MEM E: %b | ID MEM Size: %b\n\n",
//         EX_control_unit_instr_reg[0], EX_control_unit_instr_reg[1], EX_control_unit_instr_reg[2], EX_control_unit_instr_reg[3], EX_control_unit_instr_reg[4], EX_control_unit_instr_reg[5],
//         EX_control_unit_instr_reg[6], EX_control_unit_instr_reg[8:7]
//     );
    // $display("FROM THE EX: %b", EX_ALU_OP_instr_reg);
    end

    assign  PC_EX_out                   = PC_ID_out_reg;
    assign  EX_IS_instr                 = EX_IS_instr_reg;
    assign  EX_ALU_OP_instr             = EX_ALU_OP_instr_reg;
    assign  EX_control_unit_instr       = EX_control_unit_instr_reg;
    assign  EX_RD_instr                 = EX_RD_instr_reg;
    assign  EX_CC_Enable_instr          = EX_CC_Enable_instr_reg;
    assign  EX_Imm22                    = EX_Imm22_reg;
    // always@(*) begin
    //     $display("Immediate vals. IN %b and OUT %b", Imm22, EX_Imm22_reg);
    // end
endmodule


module pipeline_EX_MEM(
    input wire reset,  clk, clr,
    input wire [8:0]   EX_control_unit_instr,
    input wire [31:0]  PC,
    input wire [4:0]   EX_RD_instr,
    
    output wire [3:0]  Data_Mem_instructions,
    output wire [2:0]  Output_Handler_instructions,
    output wire        MEM_control_unit_instr,
    output wire [31:0] PC_MEM_out,
    output wire [4:0]  MEM_RD_instr
);

    reg [4:0]   Data_Mem_instructions_reg;
    reg [2:0]   Output_Handler_instructions_reg;
    reg         MEM_control_unit_instr_reg;
    reg [4:0]   MEM_RD_instr_reg;
    reg [31:0]  PC_MEM_out_reg;

    always@(posedge clk, negedge clr) begin
        if (clk  == 1 && clr == 0) begin
            if (reset) begin
                Data_Mem_instructions_reg           <= 4'b0;
                Output_Handler_instructions_reg     <= 3'b0;
                MEM_control_unit_instr_reg          <= 1'b0;
                MEM_RD_instr_reg                    <= 5'b0;
                PC_MEM_out_reg                      <= 32'b0;
            end else begin
                Data_Mem_instructions_reg           <= EX_control_unit_instr[8:4];
                Output_Handler_instructions_reg     <= EX_control_unit_instr[2:0];
                MEM_control_unit_instr_reg          <= EX_control_unit_instr[3];
                MEM_RD_instr_reg                    <= EX_RD_instr;
                PC_MEM_out_reg                      <= PC;
            end
        end
    

//     $display(">>> EX/MEM Output Signals:\n------------------------------------------");
//     $display("DataInst: %b | OutHandler: %b | MEM_control: %b | MEM_RD: %b | PC_MEM: %b\n", 
//              Data_Mem_instructions_reg, Output_Handler_instructions_reg, MEM_control_unit_instr_reg, MEM_RD_instr_reg, PC_MEM_out_reg);
//     $display("Signals that are forwarded to MEM:\n---------------------\nMEM jmpl: %b | MEM call: %b | MEM load: %b | MEM Reg Enable: %b | EX Mem SE: %b | EX MEM R/W: %b | EX MEM E: %b | EX MEM Size: %b\n\n",
//         Output_Handler_instructions_reg[0], Output_Handler_instructions_reg[1], Output_Handler_instructions_reg[2], MEM_control_unit_instr_reg, 
//         Data_Mem_instructions_reg[0], Data_Mem_instructions_reg[1], Data_Mem_instructions_reg[2], Data_Mem_instructions_reg[4:3]
//     );
    end
    assign Data_Mem_instructions        = Data_Mem_instructions_reg;
    assign Output_Handler_instructions  = Output_Handler_instructions_reg;
    assign MEM_control_unit_instr       = MEM_control_unit_instr_reg;
    assign MEM_RD_instr                 = MEM_RD_instr_reg;
    assign PC_MEM_out                   = PC_MEM_out_reg;    
endmodule


module pipeline_MEM_WB(
    input wire reset, clk, clr,
    input wire [4:0]   MEM_RD_instr,
    input wire [31:0]  MUX_out,
    input wire         MEM_control_unit_instr,

    output wire [4:0]  WB_RD_instr,
    output wire [31:0] WB_RD_out,
    output wire        WB_Register_File_Enable 
    );


    reg [4:0]  WB_RD_instr_reg;
    reg [31:0] WB_RD_out_reg;
    reg        WB_Register_File_Enable_reg;

    always@(posedge clk, negedge clr) begin
        if (clk  == 1 && clr == 0) begin
            if (reset) begin
                WB_RD_instr_reg                 <= 5'b0;
                WB_RD_out_reg                   <= 32'b0; 
                WB_Register_File_Enable_reg     <= 1'b0;
            end else begin 
                WB_RD_instr_reg                 <= WB_RD_instr;
                WB_RD_out_reg                   <= MUX_out;
                WB_Register_File_Enable_reg     <= MEM_control_unit_instr;
            end
        end
    // #8  
    //$display(">>> MEM/WB Output Signals:\n------------------------------------------");
    // $display(">>> WB Control Signals:\n------------------------------------------");
    // $display("WB_RD: %b | WB_out: %b | WB_reg_file: %b | MUX OUT: %b\n", 
    //          WB_RD_instr_reg, WB_RD_out_reg, WB_Register_File_Enable_reg, MUX_out);
    end
    assign WB_RD_instr              = WB_RD_instr_reg;
    assign WB_RD_out                = WB_RD_out_reg;
    assign WB_Register_File_Enable  = WB_Register_File_Enable_reg;
endmodule


module phase4Tester;

    // Instruction Memory stuff
    integer fi, fo, code, i; 
    reg [7:0] data;
    reg [7:0] Addr; 
    wire [31:0] instruction;

    // Clock and Clear
    reg clr;
    reg clk;

    // Controls when the flow will flow and when it should stop
    reg LE;
    reg reset;
    reg enable;
    reg S; // To trigger the CU or something idfk


    // Counters
    wire [31:0] PC;
    wire [31:0] nPC;
    wire [31:0] PC_ID;
    wire [31:0] PC_EX;
    wire [31:0] PC_MEM;

    // 
    wire [31:0] instruction_out;

    wire [3:0] ALU_OP;
    wire CC_Enable;
    wire [3:0] IS;

    wire [21:0] Imm22;
    wire [21:0] EX_Imm22;
    wire [29:0] I29_0;
    wire I29_branch_instr;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [3:0] cond;

    wire [18:0] ID_CU;
    wire [8:0] EX_CU;
    wire       MEM_CU;

    reg  [4:0] RD_ID = 5'b01011;
    wire [4:0] RD_EX;
    wire [4:0] RD_MEM;
    wire [4:0] RD_WB;


    wire [3:0] DataMemInstructions;
    wire [2:0] OutputHandlerInstructions;

    wire [31:0] OutputMUX;
    wire [31:0] WB_RD_out;

    wire WB_Register_File_Enable;


    // These are more for phase 4
    reg [1:0] PC_MUX = 2'b00;
    reg [31:0] TA;
    reg [31:0] ALU_OUT;


    PC_adder adder (
        .PC_in(PC),
        .PC_out(nPC)
    );


    PC_nPC_Register PC_reg (
        .clk        (clk),
        .clr        (clr),
        .reset      (reset),
        .LE         (LE),
        .nPC        (nPC),
        .ALU_OUT    (ALU_OUT),
        .TA         (TA),
        .mux_select (PC_MUX),
        .OUT        (PC)
    );


    rom_512x8 ram1 (
        instruction, // OUT
        PC[7:0]      // IN
    );


    initial begin
        fi = $fopen("../precharge/sparc-instructions-precharge.txt","r");
        Addr = 9'b000000000;
        $display("Precharging Instruction Memory...\n---------------------------------------------\n");
        while (!$feof(fi)) begin
            if (Addr % 4 == 0 && !$feof(fi)) $display("\nLoading Next Instruction...\n---------------------------------------------");
            code = $fscanf(fi, "%b", data);
            $display("---- %b ----\n", data);
            ram1.Mem[Addr] = data;
            Addr = Addr + 1;
        end
        $fclose(fi);
        Addr = 9'b000000000;
    end

    // Clock generator
    initial begin
        clr <= 1'b1;
        clk <= 1'b0;
        repeat(2) #2 clk = ~clk;
        clr <= 1'b0;
       forever #2 clk = ~clk;
    end


    pipeline_IF_ID IF_ID (
        .PC                             (PC),
        .instruction                    (instruction),
        .reset                          (reset), 
        .LE                             (LE), 
        .clk                            (clk), 
        .clr                            (clr),

        .PC_ID_out                      (PC_ID),
        .I21_0                          (Imm22),
        .I29_0                          (I29_0),
        .I29_branch_instr               (I29_branch_instr),
        .I18_14                         (rs1),
        .I4_0                           (rs2),
        .I29_25                         (rd),
        .I28_25                         (cond),
        .instruction_out                (instruction_out) 
    );


    control_unit CU (
        .clk(clk),
        .clr(clr),
        .instr(instruction_out),

        .instr_signals(ID_CU)
    );


    // control_unit_mux(
    //     // OUTPUTS
    // .ID_jmpl_instr_out
    // .ID_call_instr_out
    // .ID_branch_instr_out
    // .ID_load_instr_out
    // .ID_register_file_Enable_out  

    // // MORE OUTPUT
    // .ID_data_mem_SE         (),
    // .ID_data_mem_RW         (),
    // .ID_data_mem_Enable     (),

    // .I31_out                (),
    // .I30_out                (),
    // .I24_out                (),
    // .I13_out                (),
    // .ID_data_mem_Size       (),

    // .ID_ALU_OP_instr        (),
    // .CC_Enable              (),

    // // INPUT
    // .S                      (),
    // .cu_in_mux              ()
    // );

    pipeline_ID_EX ID_EX (
         .PC                            (PC_ID),
         .clk                           (clk),
         .clr                           (clr),
         .ID_control_unit_instr         (ID_CU[17:0]),
         .ID_RD_instr                   (RD_ID),
         .Imm22                         (Imm22),

        // OUTPUT
        .PC_EX_out                      (PC_EX),
        .EX_IS_instr                    (IS),
        .EX_ALU_OP_instr                (ALU_OP),
        .EX_RD_instr                    (RD_EX),
        .EX_CC_Enable_instr             (CC_Enable),
        .EX_control_unit_instr          (EX_CU),
        .EX_Imm22                       (EX_Imm22)            
    );

    pipeline_EX_MEM EX_MEM(
        .reset                          (reset),
        .clk                            (clk),
        .clr                            (clr),
        .EX_control_unit_instr          (EX_CU),
        .PC                             (PC_EX),
        .EX_RD_instr                    (RD_EX),

        .Data_Mem_instructions          (DataMemInstructions),
        .Output_Handler_instructions    (OutputHandlerInstructions),
        .MEM_control_unit_instr         (MEM_CU),
        .PC_MEM_out                     (PC_MEM),
        .MEM_RD_instr                   (RD_MEM)
    );


    pipeline_MEM_WB MEM_WB(
        .reset                          (reset),
        .clk                            (clk),
        .clr                            (clr),
        .MEM_RD_instr                   (RD_MEM),
        .MUX_out                        (PC_MEM), // (OutputMUX),

        // INPUT 
        .MEM_control_unit_instr         (MEM_CU),
        .WB_RD_instr                    (RD_WB),
        .WB_RD_out                      (WB_RD_out),
        .WB_Register_File_Enable        (WB_Register_File_Enable) 
    );


    initial begin
        #72;
        $display("\n----------------------------------------------------------\nSimmulation Complete! Remember to dump this on GTK Wave and subscribe to PewDiePie...");
        $finish;
    end 

 
    always @(posedge clk, negedge clr) begin
        $display("TIME: %d", $time);
        $display(">>> IF Stage");
        $display("-------------------> clk: %b | clr: %b | PC: %d | nPC: %d", clk, clr, PC, nPC);
        $display(">>> Control Unit");
        $display("-------------------> call: %b | jmpl: %b | load: %b | Register File Enable: %b | Data MEM SE: %b | Data MEM R/W: %b | Data MEM Enable: %b", ID_CU[0], ID_CU[1], ID_CU[2], ID_CU[3], ID_CU[4], ID_CU[5], ID_CU[6]);
        $display("                     Data MEM Size: %b | Condition Code Enable: %b | I31: %b | I30: %b | I24: %b | I13: %b | Alu Opcode: %b | Branch Instruction: %b", ID_CU[8:7], ID_CU[9], ID_CU[10], ID_CU[11], ID_CU[12], ID_CU[13], ID_CU[17:14], ID_CU[18]);
        $display(">>> ID Stage");
        $display("-------------------> Current Instruction: %b | Imm22: %b | Rs1: %b | Rs2: %b | Rd: %b | branch cond instruction: %b | RD: %b | PC: %d", instruction_out, Imm22, rs1, rs2, rd, I29_branch_instr, RD_ID, PC_ID);
        $display(">>> EX Stage");
        $display("-------------------> ALU Opcode: %b | Source Operand Handler Is: %b | Imm22: %b | Condition Code Enable: %b | RD: %b | PC: %d", ALU_OP, IS, EX_Imm22, CC_Enable, RD_EX, PC_EX);
        $display(">>> MEM Stage");
        $display("-------------------> DATA MEM ==> SE: %b | R/W: %b | Enable: %b | Size: %b || jmpl: %b | call: %b | load: %b | register file enable: %b | RD: %b | PC: %d", DataMemInstructions[0], DataMemInstructions[1], DataMemInstructions[2], DataMemInstructions[4:3], OutputHandlerInstructions[0], OutputHandlerInstructions[1], OutputHandlerInstructions[2], MEM_CU, RD_MEM, PC_MEM);
        $display(">>> WB Stage");
        $display("-------------------> Data MEM Output: %b | Register File Enable: %b | RD: %b", WB_Register_File_Enable, WB_Register_File_Enable, RD_WB);
    end

    // initial begin
    //     $monitor("TIME: %d | clk: %b | clr: %b | PC: %d | nPC: %d\
    //     \n>>> IF Stage\n\
    //     ------> Imm22: %b | Rs1: %b | Rs2: %b | Rd: %b\
    //     n\------> Imm22 after: %b\
    //     ", $time, clk, clr, PC, nPC, Imm22, rs1, rs2, rd, EX_Imm22);
    // end
    // initial begin
    //     $monitor("IMM ID: %b | IMM EX: %b | clk: %b | clr: %b | PC: %d | instruction: %b", Imm22, EX_Imm22, clk, clr, PC, instruction, $time);
    // end

    initial begin
        LE = 1'b1;
        reset = 1;
        #8;
        reset = 0;
        // #12;
    end

endmodule