# Variables
OUTPUT_VVP = simv
DESIGN_DIR = ../../src/v
TB_DIR = .
HIGH_TB_DIR = ..

# Files
DESIGN_FILES = $(DESIGN_DIR)/mxint8_dot_product.v
TB_FILES =  $(TB_DIR)/mxint8_dot_product_mon.sv \
			$(TB_DIR)/mxint8_dot_product_drv.sv \
			$(TB_DIR)/tb_mxint8_dot_product.sv \
			# $(TB_DIR)/mx_int8_dot_product_ref.sv
HIGH_TB_FILES = $(HIGH_TB_DIR)/transaction.sv
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

