

`timescale 1ns / 1ps

// module control_unit_test;

//   reg [31:0] instr;
//   reg clk;
//   reg clr;
//   wire [18:0] instr_signals;
//   wire [63:0] TIME;

//   control_unit dut (
//     .instr(instr),
//     .clk(clk),
//     .clr(clr),
//     .instr_signals(instr_signals)
//   );

//   initial begin
//     // Reset
//     clr = 1;
//     clk = 0;
//     instr = 0;
//     #10;
    
//     // Test 1
//     clr = 0;
//     instr = 32'h00000000;
//     #10;
//     $display("Test case 1: instr = %b clk = %b clr = %b instr_signals = %b TIME = %b", instr, clk, clr, instr_signals, TIME);
    
//     // Test 2
//     clk = 1;
//     #10;
//     $display("Test case 1: instr = %b clk = %b clr = %b instr_signals = %b TIME = %b", instr, clk, clr, instr_signals, TIME);
    
//     // Test 3
//     clk = 0;
//     instr = 32'h8A000000;
//     #10;
//     $display("Test case 2: instr = %b clk = %b clr = %b instr_signals = %b TIME = %b", instr, clk, clr, instr_signals, TIME);

//     // Test 4
//     clk = 1;
//     #10;
//     $display("Test case 2: instr = %b clk = %b clr = %b instr_signals = %b TIME = %b", instr, clk, clr, instr_signals, TIME);
    
//     // Test 5
//     clk = 0;
//     #10;
//     $display("Test case 3: instr = %b clk = %b clr = %b instr_signals = %b TIME = %b", instr, clk, clr, instr_signals, TIME);

//     // Test 6
//     instr = 32'h8B1C0001;
//     clk = 1;
//     #10;
//     $display("Test case 3: instr = %b clk = %b clr = %b instr_signals = %b TIME = %b", instr, clk, clr, instr_signals, TIME);

//     // Test 7
//     clk = 0;
//     #10;
//     $display("Test case 4: instr = %b clk = %b clr = %b instr_signals = %b TIME = %b", instr, clk, clr, instr_signals, TIME);

//     // Test 8
//     clk = 1;
//     #10;
//     $display("Test case 4: instr = %b clk = %b clr = %b instr_signals = %b TIME = %b", instr, clk, clr, instr_signals, TIME);
    
//     // Test 9
//     clk = 0;
//     #10;
//     $display("Test case : instr = %b clk = %b clr = %b instr_signals = %b TIME = %b", instr, clk, clr, instr_signals, TIME);

//     // Test 10
//     instr = 32'hE8100001;
//     clk = 1;
//     #10;
//     $display("Test case : instr = %b clk = %b clr = %b instr_signals = %b TIME = %b", instr, clk, clr, instr_signals, TIME);


//     end
// endmodule

module control_unit_test();

    // Declare inputs
    reg [31:0] instr;
    reg clk;
    reg clr;

    // Declare outputs
    wire [18:0] instr_signals;

    // Instantiate the control_unit module
    control_unit dut(
        .instr(instr),
        .clk(clk),
        .clr(clr),
        .instr_signals(instr_signals)
    );

    // Clock generator
    initial begin
        clr <= 1'b1;
        clk <= 1'b0;
        repeat(2) #2 clk = ~clk;
        clr <= 1'b0;
        repeat(36) begin
            #2 clk = ~clk;
        end
    end


    // Test case 1: Reset state
    initial begin
        $monitor("Test case : instr = %b clk = %b clr = %b instr_signals = %b TIME = %b", instr, clk, clr, instr_signals, $time);
        
        // Load the instructions
        instr = 32'b0;
        #4
        instr = 32'b10001010000000000000000000000000;
        #6;
        instr = 32'b10000110101000001110000000000001;
        #6;
        instr = 32'b11000100000010000000000000000001;
        #6;
        instr = 32'b11001010001010000110000000000001;
        #6;
        instr = 32'b00010010101111111111111111111110;
        #6;
        instr = 32'b00001011000011110000111100000110;
        #6;
        instr = 32'b01000000000000000000000000000100;



        // $finish; // End the simulation
    end
endmodule