# Computer Architecture Project

### Team members:
- Victor Barriera
- Angel L Garcia
- Victor Blue

These are the documents design notes and other miscelaneous related to the final (and only) project of the course of Computer Architecture (ICOM [])

## How to run this project

It is important to first download Icarus Verilog for windows machines to either get Git Bash or WSL in order to execute bash scripts.

After installing the necessary programs, clone this project and navigate to `project/scripts` and execute the `build.sh` script. This will build all the design components in a `build` folder located in the project folder. navigate to the build folder and in a terminal pointed at this directory type:

```bash
./<build-file>
```

This should execute the test file as well as the component that is being tested

## Documentation

The documentation of each component is located in `project/documentation`. You can also jump from here

- [ALU](./project/documentation/alu.md)
- [Operand Handler](./project/documentation/operand.md)
- [Instruction Memory](./project/documentation/instruction-memory.md)
- [Register File](./project/documentation/register.md)


## Verilog basics.

The following notes are not really from the project and were quick notes taken by the team members while learning verilog during Phase 1 of this project

### Things I have no idea what they are and should ask

- RTL register transfer language

Verilog is used in hardware design and synthesis. For those who don't know, verilog is a codified way to describe the behaviour of hardware. The way its compilled and written may remind you of C.


### Examples n stuff

The Flip-Flop: A lil latch thingy where for every positive edge of a clock, Q changes to become equal to D.

```verilog

always@(posedge clock)
    Q <= D;
```

Here, everything aside after the a noise at the posedge clock trigger becomes the output of the flip-flop


### Syntax n stuff

```verilog
always@()
```
- Triggers immediately the execution of whatever codeblock is bellow
- The `()` is the sensitivity list, when would you trigger the codeblock bellow.


You have different ways to do something in verilog. For example, you can write verilog in the form of combinatorial circuit logic.

If someone gave you something like:

```
if a == 1, then 
    foo = b xor c
else
    foo = b or c
end
```

This would be something you can do in a combinatorial circuit, where
-  `foo` is an *output*
- `a`, `b` and `c` are *inputs*
- You have a multiplexer to combine all three inputs, and `a` would act as some kind of *opcode*

In verilog it would be something like:

```verilog
always@(a or b or c)
    if (a) foo = b ^ c;
    else foo = b | c;
```

Here, the `if-else` statement is basically a multiplexer, the `xor` gate is `^` and the `or` gate is a `|`.

Verilog has other ways to achieve the same behaviour: `Continuous Assignment`

```verilog
assign foo = a ? b ^ c : b | c;
```
In this one-liner we're using ternary operators which is a short-hand way to write if-else statements, and we immediately assign the *output* `foo` whatever we get from doing the logic operation of `b ^ c` or `b | c`. Pretty neat.

The statement with continuous assignment is re-evaluated whenever anything on the right-hand side changes. We call that an *implicit trigger*.