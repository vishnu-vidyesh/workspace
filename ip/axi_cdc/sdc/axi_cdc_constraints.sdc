# ==============================================================================
# AXI CDC Timing Constraints Template (SDC Format)
# ==============================================================================
# These constraints are CRITICAL for proper CDC operation
# Adjust clock periods and paths according to your actual design hierarchy
# ==============================================================================

# ==============================================================================
# Clock Definitions
# ==============================================================================
# Define your clocks here (adjust frequencies as needed)

# Master/Source clock domain (e.g., 200 MHz)
set SRC_CLK_PERIOD 5.0
create_clock -name master_clk -period $SRC_CLK_PERIOD [get_ports master_clk]

# Slave/Destination clock domain (e.g., 100 MHz)
set DST_CLK_PERIOD 10.0
create_clock -name slave_clk -period $DST_CLK_PERIOD [get_ports slave_clk]

# Define clocks as asynchronous to each other
set_clock_groups -asynchronous \
    -group [get_clocks master_clk] \
    -group [get_clocks slave_clk]

# ==============================================================================
# CDC FIFO Constraints - AW Channel (Write Address)
# ==============================================================================
# These paths cross from source to destination clock domain

# Gray write pointer: src -> dst
set_max_delay -datapath_only \
    -from [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_src/*i_cdc_fifo_gray_src_aw*/async_wptr_o*"}] \
    -to   [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_dst/*i_cdc_fifo_gray_dst_aw*/async_wptr_i*"}] \
    [expr $DST_CLK_PERIOD * 0.8]

# Gray read pointer: dst -> src
set_max_delay -datapath_only \
    -from [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_dst/*i_cdc_fifo_gray_dst_aw*/async_rptr_o*"}] \
    -to   [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_src/*i_cdc_fifo_gray_src_aw*/async_rptr_i*"}] \
    [expr $SRC_CLK_PERIOD * 0.8]

# Data path: src -> dst
set_max_delay -datapath_only \
    -from [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_src/*i_cdc_fifo_gray_src_aw*/async_data_o*"}] \
    -to   [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_dst/*i_cdc_fifo_gray_dst_aw*/async_data_i*"}] \
    [expr $DST_CLK_PERIOD * 0.8]

# ==============================================================================
# CDC FIFO Constraints - W Channel (Write Data)
# ==============================================================================

# Gray write pointer: src -> dst
set_max_delay -datapath_only \
    -from [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_src/*i_cdc_fifo_gray_src_w*/async_wptr_o*"}] \
    -to   [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_dst/*i_cdc_fifo_gray_dst_w*/async_wptr_i*"}] \
    [expr $DST_CLK_PERIOD * 0.8]

# Gray read pointer: dst -> src
set_max_delay -datapath_only \
    -from [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_dst/*i_cdc_fifo_gray_dst_w*/async_rptr_o*"}] \
    -to   [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_src/*i_cdc_fifo_gray_src_w*/async_rptr_i*"}] \
    [expr $SRC_CLK_PERIOD * 0.8]

# Data path: src -> dst
set_max_delay -datapath_only \
    -from [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_src/*i_cdc_fifo_gray_src_w*/async_data_o*"}] \
    -to   [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_dst/*i_cdc_fifo_gray_dst_w*/async_data_i*"}] \
    [expr $DST_CLK_PERIOD * 0.8]

# ==============================================================================
# CDC FIFO Constraints - B Channel (Write Response)
# ==============================================================================
# Note: B channel direction is dst -> src (response goes back)

# Gray write pointer: dst -> src
set_max_delay -datapath_only \
    -from [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_dst/*i_cdc_fifo_gray_src_b*/async_wptr_o*"}] \
    -to   [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_src/*i_cdc_fifo_gray_dst_b*/async_wptr_i*"}] \
    [expr $SRC_CLK_PERIOD * 0.8]

# Gray read pointer: src -> dst
set_max_delay -datapath_only \
    -from [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_src/*i_cdc_fifo_gray_dst_b*/async_rptr_o*"}] \
    -to   [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_dst/*i_cdc_fifo_gray_src_b*/async_rptr_i*"}] \
    [expr $DST_CLK_PERIOD * 0.8]

# Data path: dst -> src
set_max_delay -datapath_only \
    -from [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_dst/*i_cdc_fifo_gray_src_b*/async_data_o*"}] \
    -to   [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_src/*i_cdc_fifo_gray_dst_b*/async_data_i*"}] \
    [expr $SRC_CLK_PERIOD * 0.8]

# ==============================================================================
# CDC FIFO Constraints - AR Channel (Read Address)
# ==============================================================================

# Gray write pointer: src -> dst
set_max_delay -datapath_only \
    -from [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_src/*i_cdc_fifo_gray_src_ar*/async_wptr_o*"}] \
    -to   [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_dst/*i_cdc_fifo_gray_dst_ar*/async_wptr_i*"}] \
    [expr $DST_CLK_PERIOD * 0.8]

# Gray read pointer: dst -> src
set_max_delay -datapath_only \
    -from [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_dst/*i_cdc_fifo_gray_dst_ar*/async_rptr_o*"}] \
    -to   [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_src/*i_cdc_fifo_gray_src_ar*/async_rptr_i*"}] \
    [expr $SRC_CLK_PERIOD * 0.8]

# Data path: src -> dst
set_max_delay -datapath_only \
    -from [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_src/*i_cdc_fifo_gray_src_ar*/async_data_o*"}] \
    -to   [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_dst/*i_cdc_fifo_gray_dst_ar*/async_data_i*"}] \
    [expr $DST_CLK_PERIOD * 0.8]

# ==============================================================================
# CDC FIFO Constraints - R Channel (Read Data)
# ==============================================================================
# Note: R channel direction is dst -> src (data goes back)

# Gray write pointer: dst -> src
set_max_delay -datapath_only \
    -from [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_dst/*i_cdc_fifo_gray_src_r*/async_wptr_o*"}] \
    -to   [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_src/*i_cdc_fifo_gray_dst_r*/async_wptr_i*"}] \
    [expr $SRC_CLK_PERIOD * 0.8]

# Gray read pointer: src -> dst
set_max_delay -datapath_only \
    -from [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_src/*i_cdc_fifo_gray_dst_r*/async_rptr_o*"}] \
    -to   [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_dst/*i_cdc_fifo_gray_src_r*/async_rptr_i*"}] \
    [expr $DST_CLK_PERIOD * 0.8]

# Data path: dst -> src
set_max_delay -datapath_only \
    -from [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_dst/*i_cdc_fifo_gray_src_r*/async_data_o*"}] \
    -to   [get_pins -hier -filter {NAME =~ "*i_axi_cdc/*i_cdc_src/*i_cdc_fifo_gray_dst_r*/async_data_i*"}] \
    [expr $SRC_CLK_PERIOD * 0.8]

# ==============================================================================
# False Path Constraints
# ==============================================================================
# Mark reset paths as false paths if they are asynchronous
# (adjust based on your reset strategy)

set_false_path -from [get_ports master_reset]
set_false_path -from [get_ports slave_reset]

# ==============================================================================
# Additional Recommendations
# ==============================================================================

# 1. Set input/output delays appropriately for your interfaces
# set_input_delay -clock master_clk [expr $SRC_CLK_PERIOD * 0.2] [get_ports m_axi_*]
# set_output_delay -clock slave_clk [expr $DST_CLK_PERIOD * 0.2] [get_ports s_axi_*]

# 2. For more aggressive constraints, you can use the minimum of the two periods:
# set MIN_PERIOD [expr min($SRC_CLK_PERIOD, $DST_CLK_PERIOD)]
# Then use $MIN_PERIOD instead of the specific clock periods above

# 3. For very conservative constraints (recommended for first silicon):
# Use 0.5 * period instead of 0.8 * period

# 4. Verify all constraints are met with:
# report_timing -from [get_clocks master_clk] -to [get_clocks slave_clk]
# report_timing -from [get_clocks slave_clk] -to [get_clocks master_clk]

# ==============================================================================
# Vivado-specific Constraints (XDC)
# ==============================================================================
# If using Vivado, you may also need to add:
# set_property ASYNC_REG TRUE [get_cells -hier -filter {NAME =~ "*i_axi_cdc/*sync_*"}]

# ==============================================================================
# Notes:
# ==============================================================================
# 1. Adjust the hierarchical paths (*i_axi_cdc/*) based on your actual 
#    module instantiation hierarchy
# 2. The 0.8 multiplier allows some timing margin; adjust based on your 
#    technology and requirements
# 3. Always verify constraints with static timing analysis
# 4. Consider using set_property ASYNC_REG for synchronizer chains
# 5. These constraints assume standard Gray FIFO implementation from 
#    PULP Platform's common_cells
# ==============================================================================
