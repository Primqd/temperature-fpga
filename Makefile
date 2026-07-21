# Build a Nandland Go Board image inside the bASICs VM.
# Examples: make                 # blink.bin
#           make TOP=counter     # counter.bin
# TOP ?= blink
PCF := go_board.pcf

# modified makefile for multifile projects (input.vc)
SOURCES := $(shell cat input.vc)
TOP ?= top # specify top module explciti

.PHONY: all clean

all: $(TOP).bin

$(TOP).json: $(SOURCES)
	yosys -p 'read_verilog -sv $(SOURCES); synth_ice40 -top $(TOP) -json $@'

$(TOP).asc: $(TOP).json $(PCF)
	nextpnr-ice40 --hx1k --package vq100 --freq 25 --pcf $(PCF) --json $< --asc $@

$(TOP).bin: $(TOP).asc
	icepack $< $@

.INTERMEDIATE: $(TOP).json $(TOP).asc

clean:
	rm -f *.json *.asc *.bin
