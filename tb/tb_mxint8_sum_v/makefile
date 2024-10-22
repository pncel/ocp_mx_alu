# Variables
OUTPUT_VVP = simv
DESIGN_DIR = ../../src/v
TB_DIR = .
HIGH_TB_DIR = ..

# Files
DESIGN_FILES = $(DESIGN_DIR)/mxint8_sum.v
TB_FILES =  $(TB_DIR)/mx_int8_sum_mon.sv \
			$(TB_DIR)/mx_int8_sum_drv.sv \
			$(TB_DIR)/tb_mx_int8_sum.sv 
HIGH_TB_FILES = $(HIGH_TB_DIR)/transection.sv
all: compile simulation
# Compile target
compile:
	iverilog -g2012 -o $(OUTPUT_VVP) \
	    -I $(DESIGN_DIR) \
	    $(DESIGN_FILES) \
	    $(HIGH_TB_FILES) \
	    $(TB_FILES)

# Simulation target
simulation: 
	vvp -n $(OUTPUT_VVP) > test.log

wave: 
	gtkwave test.vcd

# Clean target
clean:
	rm -f *.log *.vcd $(OUTPUT_VVP)

