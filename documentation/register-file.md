# Register File

The `register_file` module represents a 32-bit register file with three output ports.

## Module Description

The module has the following inputs and outputs:

### Inputs:
- `PW` (32-bit): Input port for data to be written.
- `RW` (5-bit): Input port for selecting the register to be written.
- `RA`, `RB`, `RD` (5-bit): Input ports for selecting the registers for the output ports.
- `LE` (1-bit): BinaryDecoder selector and "load" control signal.
- `clk`: Clock input.

### Outputs:
- `PA`, `PB`, `PD` (32-bit): Output ports A, B, and D. The values on these ports represent the contents of the selected registers specified by the `RA`, `RB`, and `RD` inputs, respectively.
- `PA`, `PB`, `PD` (32-bit): Output ports A, B, and D.

## Submodules and Signals

The `register_file` module instantiates several submodules to implement its functionality. It also uses internal wire signals for data flow and control.


### Signals:

- `E` (32-bit): Wire signal for the output of the Binary Decoder module. This signal is used to select the target register for a write operation.
- `Q0` to `Q31` (32-bit): Wire signals for the outputs of the registers. These signals represent the contents of the individual registers.


### Submodules:
1. `binaryDecoder`: Binary Decoder module for decoding the `RW` and `LE` inputs. It generates the `E` signal, which is used for register selection.
2. `mux_32bit`: Multiplexer module for selecting the output of a specific register based on the `RA`, `RB`, or `RD` inputs. It routes the appropriate register output to the respective output ports.

The `register_file` module instantiates 32 `register_32bit` submodules, one for each register, with corresponding outputs `Q0` to `Q31`. The outputs of these registers are connected to the inputs of the `mux_32bit` submodules for selecting the appropriate output based on the `RA`, `RB`, or `RD` inputs.

## Operation

The `register_file` module operates as follows:

1. The `binaryDecoder` submodule decodes the `RW` and `LE` inputs and produces the `E` output.
2. The `mux_32bit` submodules select the output of the corresponding register based on the `RA`, `RB`, or `RD` inputs and provide the output to the respective output ports `PA`, `PB`, and `PD`.
3. The `register_32bit` submodules store and update the data in the registers based on the `PW` input, `clk` signal, and `E` values.

## Example

```verilog
register_file rf (
  .PA(PA),
  .PB(PB),
  .PD(PD),
  .PW(PW),
  .RW(RW),
  .RA(RA),
  .RB(RB),
  .RD(RD),
  .LE(LE),
  .clk(clk)
);
