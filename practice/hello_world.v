// simple AND program

/*
Things in verilog work in modules.
Modules could be the analogous of functions
*/

module and_gate(input a, b, output c);
    assign c = a & b;
endmodule