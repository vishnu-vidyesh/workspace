# AXI CDC Compilation Filelist
# Include directories
+incdir+deps/axi/include
+incdir+deps/common_cells/include

# Common cells
deps/common_cells/src/cf_math_pkg.sv
deps/common_cells/src/gray_to_binary.sv
deps/common_cells/src/binary_to_gray.sv
deps/common_cells/src/spill_register_flushable.sv
deps/common_cells/src/spill_register.sv
deps/common_cells/src/stream_delay.sv
deps/common_cells/src/cdc_fifo_gray.sv

# AXI package and interface
deps/axi/src/axi_pkg.sv
deps/axi/src/axi_intf.sv

# AXI CDC modules
deps/axi/src/axi_cdc_src.sv
deps/axi/src/axi_cdc_dst.sv
deps/axi/src/axi_cdc.sv

# Wrapper module
rtl/axi_cdc.sv
