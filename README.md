# Computer Architecture Project thing


Verilog basics.

These are notes from a YT video btw

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