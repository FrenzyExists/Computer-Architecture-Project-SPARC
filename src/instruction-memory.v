// Instruction memory - Victor Barriera
`timescale 1ns / 1ps

/**
 * ROM 512x8-bit module.
 *
 * This module implements a 512x8-bit ROM using Verilog. The ROM stores data in an
 * array of 512 8-bit locations, which can be accessed using an 8-bit address input.
 * The data output is a 32-bit value obtained by concatenating four adjacent 8-bit
 * values from the memory array.
 *
 * Inputs:
 *  - Address [7:0]: 8-bit input used to address a location in the memory array.
 *
 * Outputs:
 *  - DataOut [31:0]: 32-bit output obtained by concatenating four adjacent 8-bit
 *                    values from the memory array.
 *
 * Implementation details:
 *  - The module uses a memory array of 512 8-bit locations to store data.
 *  - The memory array is declared as a Verilog reg [7:0] type with a range of 0 to 511.
 *  - The DataOut output is computed using a concatenation of four adjacent 8-bit values
 *    from the memory array, starting at the address specified by the Address input.
 *  - The always@(Address) block is used to update the DataOut output whenever the
 *    Address input changes.
 */
module rom_512x8 (output reg [31:0] DataOut, input [7:0] Address);
    reg [7:0] Mem[0:511];       //512 8bit locations
    always@(Address)            //Loop when Address changes
        DataOut = {Mem[Address], Mem[Address+1], Mem[Address+2], Mem[Address+3]};
endmodule