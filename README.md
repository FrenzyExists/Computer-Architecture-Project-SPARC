# SPARC V8 Based Hardware Design

## Overview

This project is a verilog hardware design of the SPARC V8 architecture. The design includes the implementation of four pipelines: IF/ID, ID/EX, EX/MEM, and MEM/WB.

The design was created as part of a college course in Computer Architecture (ICOM 4215) by a team of three students: Detective Pikachu, Ash Ketchum, and Misty Waterflower.

## Designers

The design was created as part of a college course in Computer Architecture taught by Dr. Nestor J. Rodriguez by a team of three students:

- Detective Pikachu (Angel L Garca)
- Dinkleberg (Victor Hernandez)
- The Rat Man (Victor Barriera)

## Motivation

The goal of this project is to design and implement a super simple hardware version of the SPARC V8 architecture. By working on this design, we hope to gain a better undesanding of how computers really work at a hardware level, improve our technical skills in hardware design and learn the Verilog hardware language.

## Challenges

## Running the Project

It is important to first download Icarus Verilog for windows machines to either get Git Bash or WSL in order to execute bash scripts.

After installing the necessary programs, clone this project and navigate to project/scripts and execute the build.sh script. This will build all the design components in a build folder located in the project folder. navigate to the build folder and in a terminal pointed at this directory type:

```
./<build-file>
```

This should execute the test file as well as the component that is being tested

## Design

The SPARC V8 verilog hardware design includes the following components:

- ALU
- Operand2 Handler
- Precharge System
- Instruction Fetch (IF) Unit
- Instruction Decode (ID) Unit
- Execution (EX) Unit
- Memory (MEM) Unit
- Write-Back (WB) Unit
- Register File
- PSR (Processor State Register)
- WIM (Window Invalid Mask)
- Data Memory


## Future Work

While this simple (yet challenging) design met our goals, there are several areas where we could improve and expand in the future. Here are some possible improvements:

1. **Floating Point Support**: Currently, our design does not include support for floating point operations. In the future, we could explore adding floating point units and instructions to our design to enable floating point calculations.

2. **Cache Hierarchy**: Our current design includes a single data memory unit. In a real-world implementation, however, there would typically be multiple levels of cache memory between the processor and main memory. In the future, we could explore adding a cache hierarchy to our design to improve performance.

3. **Instruction Set Extensions**: While we implemented the basic SPARC V8 instruction set, there are several instruction set extensions available that could improve performance or enable new functionality. In the future, we could explore adding these extensions to our design.
