# Verilog source files and directories
SRC_DIR = verilog
TB_DIR = testbench
OBJ_DIR = obj_dir
DUMP_DIR = dump

# Top-level testbench module name and output binary
TOP_MODULE ?= tb_alu  # Specify a default; can be overridden on the command line
OUTPUT_BIN = V$(TOP_MODULE)

# Verilator flags
VERILATOR_FLAGS = --binary --trace -Wno-fatal --top-module $(TOP_MODULE)

# Source files (all Verilog files in the source directory)
VERILOG_SRC = $(TB_DIR)/$(TOP_MODULE).v $(SRC_DIR)/*.v $(SRC_DIR)/*.sv

# Verible linter
VERIBLE_BIN = ../../verible/binMacOs/verible-verilog-lint #TOmodify
VERIBLE_FLAGS = --rules_config ../../../flags.txt  #TOmodify

# Default target to build and simulate
all: $(OUTPUT_BIN) run

# Build the simulation binary using Verilator
$(OUTPUT_BIN): $(VERILOG_SRC)
	@mkdir -p $(OBJ_DIR) $(DUMP_DIR)
	verilator $(VERILATOR_FLAGS) -o $(OUTPUT_BIN) $(VERILOG_SRC)

# Run the simulation
run: $(OUTPUT_BIN)
	./$(OBJ_DIR)/$(OUTPUT_BIN)

# Lint
lint:
	$(VERIBLE_BIN) $(VERILOG_SRC) $(VERIBLE_FLAGS)

# Clean up generated files
clean:
	rm -rf $(OBJ_DIR) $(DUMP_DIR) *.log

.PHONY: all run clean
