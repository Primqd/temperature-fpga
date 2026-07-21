# Temperature FPGA
Temperature-sensing setup driven by the  **Nandland Go Board**. Makefile is based on the **bASICs VM** toolkit at https://basics.alpacawebservices.com/.

Week 2 BWSI Basics of ASICs capstone project.

## What it does

Measures the charge and discharge timing of an RC circuit connected to the board, then displays the resulting temperature on the two seven-segment displays. The design also uses the onboard LEDs to show a rough temperature band.
Subject to change.

## Setup
Note the `lut_ones` and `lut_tens` are derived off my own thermistor values.
To change them, you can input your own values in `thermistor.py` and regenerate them.

### Breadboard setup

Connect VCC pin to the thermistor, the thermistor to a capacitor, then the capacitor to GND. Connect the PMOD1 port after the thermistor and before the capacitor.

### Building project

The project is built with the standard iCE40 toolchain:

```sh
make TOP=top
```

Run `iceprog top.bin` to put it on the FPGA.

## Credit
[Ananya Bontha](https://devpost.com/bonthaananya) and [Mihir Kotamraju](https://www.linkedin.com/in/mihir-kotamraju-684200262/) for code contributions and the idea.

[Basics of ASICs](https://bwsi.mit.edu/bwsi-programs-2/basics-of-asics/) program.
