# Makefile for AXI Bus CDC Wrapper Generation and Build
# =======================================================
# This Makefile automates the entire process:
# 1. Builds the 'gen_amba_axi' C program.
# 2. Creates the necessary output directories.
# 3. Runs 'gen_amba_axi' to generate the interconnect Verilog.
# 4. Runs the Python script to generate the top-level CDC wrapper and headers.
# 5. Provides targets for simulation and cleaning.

# --- Configuration ---
CONFIG_FILE = switch_config.json
OUTPUT_DIR  = generated
RTL_DIR     = $(OUTPUT_DIR)/rtl
INCLUDE_DIR = $(OUTPUT_DIR)/include
GEN_AMBA_DIR = gen_amba_2021/gen_amba_axi

# --- Dynamic Configuration from JSON ---
# This robustly determines master/slave counts directly from the config file.
# Note on AXI Interconnect terminology:
#   - External Slaves (CPU, DMA) connect to the Interconnect's MASTER ports.
#   - External Masters (RAM, PERIPHERAL) connect to the Interconnect's SLAVE ports.
NUM_MASTERS := $(shell grep -c '"Port Type": "slave"' $(CONFIG_FILE))
NUM_SLAVES  := $(shell grep -c '"Port Type": "master"' $(CONFIG_FILE))
INTERCONNECT_RTL = $(RTL_DIR)/amba_axi_m$(NUM_MASTERS)s$(NUM_SLAVES).v

# --- Main Targets ---
.PHONY: all clean generate wrapper interconnect compile

# Default target: generate all RTL files.
all: generate

# 1. Main generation target that orchestrates the two primary steps.
generate: interconnect wrapper
	@echo "======================================================================"
	@echo "AXI Generation Complete!"
	@echo "Wrapper:      $(RTL_DIR)/axi_bus_cdc_top.sv"
	@echo "Interconnect: $(INTERCONNECT_RTL)"
	@echo "Address Map:  $(INCLUDE_DIR)/axi_addr_map.svh"
	@echo "======================================================================"

# 2. Generate the AXI Interconnect RTL.
#    - FIX: Creates the output directory before running the tool to prevent 'file open error'.
#    - Builds the C program and then executes it.
interconnect:
	@echo "--- 1. Generating AXI Interconnect RTL (using gen_amba_axi) ---"
	@mkdir -p $(RTL_DIR)
	@echo "Building gen_amba_axi tool..."
	@$(MAKE) -s -C $(GEN_AMBA_DIR)
	@echo "Running gen_amba_axi..."
	@$(GEN_AMBA_DIR)/gen_amba_axi --master=$(NUM_MASTERS) --slave=$(NUM_SLAVES) --output=$(INTERCONNECT_RTL)

# 3. Generate the top-level wrapper and address header using the Python script.
wrapper:
	@echo "--- 2. Generating AXI CDC Wrapper and Header (using python) ---"
	@python3 generate_axi_cdc.py --config $(CONFIG_FILE) --output $(OUTPUT_DIR)

# --- Utility Targets ---

# Example target to compile the generated design for simulation.
compile: generate rtl.f
	@echo "--- Compiling RTL for Simulation (VCS Example) ---"
	@echo "NOTE: This is an example. Update rtl.f with paths to your simulation models."
	# vcs -sverilog \
	# 	+incdir+$(INCLUDE_DIR) \
	# 	-f rtl.f \
	# 	-debug_all

# Generates a file list for the simulator.
# You will need to add the paths to your async_fifo and other common modules here.
rtl.f:
	@echo "# RTL File List for Simulation" > rtl.f
	@echo "$(RTL_DIR)/axi_bus_cdc_top.sv" >> rtl.f
	@echo "$(INTERCONNECT_RTL)" >> rtl.f
	@echo "" >> rtl.f
	@echo "// --- Add paths to simulation models below ---" >> rtl.f
	@echo "// e.g., /path/to/your/libs/async_fifo.sv" >> rtl.f

# Cleans up all generated files and build objects.
clean:
	@echo "--- Cleaning generated files and build objects ---"
	@rm -rf $(OUTPUT_DIR) rtl.f
	@$(MAKE) -s -C $(GEN_AMBA_DIR) clean

