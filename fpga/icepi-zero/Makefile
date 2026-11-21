ICEPI_DIR ?= $(PWD)/icepi-zero
LPF := $(ICEPI_DIR)/gateware/v1.3/icepi-zero-v1_3.lpf
SOURCES := main_icepi_zero.sv ../../src/tt_um_gianluca_rainis_ASILUC.v ../../src/calculation_ASILUC.v ../../src/phase_timer_ASILUC.v

.PHONY: all build debug clean

all: build

build:
	mkdir -p build
	yosys -p "read_verilog -sv $(SOURCES); synth_ecp5 -top main_icepi_zero -json build/asiluc.json"
	nextpnr-ecp5 --25k --package CABGA256 --lpf $(LPF) --json build/asiluc.json --textcfg build/asiluc.config
	ecppack --compress build/asiluc.config build/asiluc.bit

debug: build
	openFPGALoader -b icepi-zero build/asiluc.bit

clean:
	rm -rf build
