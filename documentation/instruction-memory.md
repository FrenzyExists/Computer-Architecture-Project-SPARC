# Instruction Memory

The instruction memory is fundamentally a ROM, so it will be in perpetual read mode. Is a vital component of a computer system that stores instructions that the processor fetches and executes. This document explains the functionality of an instruction memory for SPARC.

## Memory Capacity:
The memory capacity of an instruction memory for SPARC is 512 bytes. This size is sufficient to store a limited number of instructions.

## Loading Instructions:
The instruction memory must be pre-loaded with a text file. This file contains the bytes of the instructions, separated by spaces or returns. The instructions are stored in groups of four bytes, where the first byte read is the most significant byte of the instruction, and the fourth byte read is the least significant byte (Big Endian).

## Memory Organization:
The instruction memory is organized into 32-bit words, and instructions are stored in consecutive 32-bit words. Each instruction word contains one instruction, and the maximum number of instructions that can be stored in the memory is equal to the memory size in bytes divided by four.