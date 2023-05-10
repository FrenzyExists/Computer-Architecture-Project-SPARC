module control_unit_test();

    // Instantiate the control_unit module
    control_unit dut(
        .instr(instr),
        .clk(clk),
        .clr(clr),
        .instr_signals(instr_signals)
    );

    // Declare inputs
    reg [31:0] instr;
    reg clk;
    reg clr;

    // Declare outputs
    wire [18:0] instr_signals;

    // Clock generator
    always #5 clk = 1'b0;

    // Test case 1: Reset state
    initial begin
        $monitor("Test case 1: Reset state -> instr = %b clk = %b clr = %b instr_signals = %b", instr, clk, clr, instr_signals);
        
        // b10001010000000000010000000111000
        //b111000
        instr = 32'b10001011110000000010000000111000;
        #1;
        #10 clk = 1'b1;
        #1;
        #10 clk = 1'b0;
        #1;
        #10 clk = 1'b1;
        #1;
      
        #60 $finish;
    end
    
    // Test case 2: Sethi instruction
    // initial begin
        
    //     $monitor("Test case 2: Sethi instruction - instr_signals = %b", instr_signals);
    //     instr = 32'h10040000; // Sethi 1024, %g1
    //     clr = 1'b1;
    //     #1;
    //     #10 clr = 1'b0;
    //     #1;
    //     #10 $finish;
    // end

    // // Test case 3: Branch instruction
    // initial begin
    //     $monitor("Test case 3: Branch instruction - instr_signals = %b", instr_signals);
    //     instr = 32'h10800003; // bne 2 (pc + 8)
    //     clr = 1'b1;
    //     #10 clr = 1'b0;
    //     #10 $finish;
    // end

    // // Test case 4: Call instruction
    // initial begin
    //     $monitor("Test case 4: Call instruction - instr_signals = %b", instr_signals);
    //     instr = 32'h4000001c; // call foo
    //     clr = 1'b1;
    //     #10 clr = 1'b0;
    //     #10 $finish;
    // end

    // // Test case 5: Load instruction
    // initial begin
    //     $monitor("Test case 5: Load instruction - instr_signals = %b", instr_signals);
    //     instr = 32'h04811000; // ld [ %g1 + 0 ], %o0
    //     clr = 1'b1;
    //     #10 clr = 1'b0;
    //     #10 $finish;
    // end

    // // Test case 6: Store instruction
    // initial begin
    //     $monitor("Test case 6: Store instruction - instr_signals = %b", instr_signals);
    //     instr = 32'h00c11000; // st %g1, [ %o0 ]
    //     clr = 1'b1;
    //     #10 clr = 1'b0;
    //     // #10 $finish;
    // end

endmodule
