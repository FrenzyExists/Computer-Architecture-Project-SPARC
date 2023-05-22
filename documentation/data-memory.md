# Data Memory

The data memory is fundamentally a RAM with a capacity of 512 bytes, which can handle three different data sizes: byte, halfword, and word. The bytes that make up the halfwords and words are managed using the Big Endian scheme.


## Preloading

The memory should be preloaded with the same text file that is provided for the instruction memory.

## Reading Operation

- R/W = 0, E = 1
    - Size = 00, SE = 0: DO <= 0b000000000000000000000000 || Mem[A]

    - Size = 00, SE = 1: DO <= sign_extension24 || Mem[A]

    - Size = 01, SE = 0: DO <= 0b0000000000000000 || Mem[A] || Mem[A+1]

    - Size = 01, SE = 1: DO <= sign_extension16 || Mem[A] || Mem[A+1]

    - Size = 10/11: DO <= Mem[A] || Mem[A+1] ||Mem[A+2] || Mem[A+3]

## Writing Operation

- R/W = 1, E = 1, SE = X
    - Size = 00: Mem[A] <= DI0-7

    - Size = 01: Mem[A] <= DI15-8, Mem[A+1] <= DI0-7,

    - Size = 10: Mem[A] <= DI31-24, Mem[A+1] <= DI23-16, Mem[A+2] <= DI15-8, Mem[A+3] <= DI0-7,

    - Size = 11: No action

## NO Operation

- R/W = X, E = 0, SE = X


## Demonstration

For demonstration purposes, a text file with 16 bytes is provided for preloading the memory. Using the external buses and signals of the RAM, the following operations must be carried out:

Read a word from locations 0, 4, 8, and 12.
Read an unsigned byte from location 0, a halfword from location 2, and a halfword from location 4.
Read a signed byte from location 0, a halfword from location 2, and a halfword from location 4.
Write a byte to location 0, a halfword to location 2, a halfword to location 4, and a word to location 8.
Read a word from locations 0, 4, and 8.
For the reading cases, the A signal (in decimal), the DO signal (in hexadecimal), and the Size, R/W, E, and SE signals (in binary) must be printed on a single line.




