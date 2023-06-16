# Makefile

COCOTB_LOG_LEVEL = WARNING
COCOTB_ANSI_OUTPUT = 1
COCOTB_RESOLVE_X = ZEROS

# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# use VHDL_SOURCES for VHDL files

VERILOG_SOURCES += /mnt/c/Users/frenz/Dev/Computer-Architecture-Project-SPARC/src/hazard-forwading-unit.v

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = hazard_forwarding_unit

# MODULE is the basename of the Python test file
MODULE = hazard_test

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
