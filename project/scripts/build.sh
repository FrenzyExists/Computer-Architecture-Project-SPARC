#!/bin/bash

current_dir="$(pwd)"
red="\033[0;31m"
yellow="\033[0;33m"
green="\033[0;32m"
blue="\033[0;34m"
magenta="\033[0;35m"
cyan="\033[0;36m"
black="\033[0;30m"
black_2="\033[0;90m"
reset="\033[0m"
white="\033[0;97m"



# Compile all verilog files

iverilog -o  tb_module1.vvp ../modules/module1.v module1_tb.v
iverilog -o tb_module2.vvp ../modules/module2.v module2_tb.v
