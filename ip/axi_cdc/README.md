# AXI Clock Domain Crossing (CDC) Module

This module provides a wrapper around the PULP Platform's AXI CDC implementation for crossing AXI signals between two independent clock domains.

## Overview

The `axi_cdc` module converts AXI4 signals from one clock domain (master_clk) to another clock domain (slave_clk) using Gray-coded FIFO implementations for safe asynchronous clock domain crossing.

## Features

- ✅ Full AXI4 protocol support including ATOPs (Atomic Operations)
- ✅ Independent clock domains with separate resets
- ✅ Gray-coded FIFO-based CDC for all 5 AXI channels (AW, W, B, AR, R)
- ✅ Configurable FIFO depth and synchronization stages
- ✅ Standard AXI4 interface with individual signal ports
- ✅ Synthesizable implementation

## Dependencies

This module requires the following repositories from PULP Platform:

1. **pulp-platform/axi** - Main AXI library
   ```bash
   git clone https://github.com/pulp-platform/axi.git
   ```

2. **pulp-platform/common_cells** - Common hardware primitives (required by axi)
   ```bash
   git clone https://github.com/pulp-platform/common_cells.git
   ```

## Module Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `AXI_ADDR_WIDTH` | int | 32 | Width of AXI address bus |
| `AXI_DATA_WIDTH` | int | 64 | Width of AXI data bus |
| `AXI_ID_WIDTH` | int | 4 | Width of AXI ID signals |
| `AXI_USER_WIDTH` | int | 1 | Width of AXI USER signals |
| `LOG_DEPTH` | int | 2 | FIFO depth = 2^LOG_DEPTH (depth = 4 by default) |
| `SYNC_STAGES` | int | 2 | Number of synchronizer stages for metastability protection |

## Port Description

### Clock and Reset
- `master_clk` - Clock for the master (source) side
- `master_reset` - Active-high reset for master side
- `slave_clk` - Clock for the slave (destination) side
- `slave_reset` - Active-high reset for slave side

### Master Interface (in master_clk domain)
Standard AXI4 master interface with separate signals for:
- Write Address Channel (m_axi_aw*)
- Write Data Channel (m_axi_w*)
- Write Response Channel (m_axi_b*)
- Read Address Channel (m_axi_ar*)
- Read Data Channel (m_axi_r*)

### Slave Interface (in slave_clk domain)
Standard AXI4 slave interface with separate signals for:
- Write Address Channel (s_axi_aw*)
- Write Data Channel (s_axi_w*)
- Write Response Channel (s_axi_b*)
- Read Address Channel (s_axi_ar*)
- Read Data Channel (s_axi_r*)

## Usage Example

```systemverilog
axi_cdc #(
    .AXI_ADDR_WIDTH ( 32 ),
    .AXI_DATA_WIDTH ( 64 ),
    .AXI_ID_WIDTH   ( 4  ),
    .AXI_USER_WIDTH ( 1  ),
    .LOG_DEPTH      ( 3  ),  // FIFO depth = 8
    .SYNC_STAGES    ( 2  )
) i_axi_cdc (
    // Master clock domain
    .master_clk     ( clk_a      ),
    .master_reset   ( rst_a      ),
    
    // Master AXI interface
    .m_axi_awid     ( master_awid    ),
    .m_axi_awaddr   ( master_awaddr  ),
    // ... (all other master signals)
    
    // Slave clock domain
    .slave_clk      ( clk_b      ),
    .slave_reset    ( rst_b      ),
    
    // Slave AXI interface
    .s_axi_awid     ( slave_awid    ),
    .s_axi_awaddr   ( slave_awaddr  ),
    // ... (all other slave signals)
);
```

## File Structure for Integration

Your project should have the following structure:

```
your_project/
├── rtl/
│   └── axi_cdc.sv              # This wrapper module
├── deps/
│   ├── axi/                     # PULP Platform AXI repository
│   │   ├── src/
│   │   │   ├── axi_pkg.sv
│   │   │   ├── axi_intf.sv
│   │   │   ├── axi_cdc_src.sv
│   │   │   ├── axi_cdc_dst.sv
│   │   │   └── axi_cdc.sv      # PULP's actual CDC implementation
│   │   └── include/
│   │       └── axi/
│   │           ├── assign.svh
│   │           └── typedef.svh
│   └── common_cells/            # PULP Platform common cells
│       ├── src/
│       │   ├── cf_math_pkg.sv
│       │   ├── cdc_fifo_gray.sv
│       │   ├── gray_to_binary.sv
│       │   ├── binary_to_gray.sv
│       │   ├── spill_register.sv
│       │   └── ...
│       └── include/
│           └── common_cells/
│               └── registers.svh
```

## Compilation Order

When compiling this design, use the following order:

1. **Common Cells Package and Dependencies:**
   ```
   common_cells/src/cf_math_pkg.sv
   common_cells/src/gray_to_binary.sv
   common_cells/src/binary_to_gray.sv
   common_cells/src/spill_register.sv
   common_cells/src/cdc_fifo_gray.sv
   ```

2. **AXI Package and Includes:**
   ```
   +incdir+axi/include
   +incdir+common_cells/include
   axi/src/axi_pkg.sv
   axi/src/axi_intf.sv
   ```

3. **AXI CDC Modules:**
   ```
   axi/src/axi_cdc_src.sv
   axi/src/axi_cdc_dst.sv
   axi/src/axi_cdc.sv
   ```

4. **Your Wrapper:**
   ```
   rtl/axi_cdc.sv
   ```

## Example Filelist

Here's a complete filelist for simulation/synthesis:

```tcl
# Include directories
+incdir+deps/axi/include
+incdir+deps/common_cells/include

# Common cells
deps/common_cells/src/cf_math_pkg.sv
deps/common_cells/src/gray_to_binary.sv
deps/common_cells/src/binary_to_gray.sv
deps/common_cells/src/spill_register.sv
deps/common_cells/src/cdc_fifo_gray.sv

# AXI package and interface
deps/axi/src/axi_pkg.sv
deps/axi/src/axi_intf.sv

# AXI CDC modules
deps/axi/src/axi_cdc_src.sv
deps/axi/src/axi_cdc_dst.sv
deps/axi/src/axi_cdc.sv

# Your wrapper
rtl/axi_cdc.sv
```

## Important Timing Constraints

⚠️ **CRITICAL**: You must properly constrain the asynchronous paths through the CDC FIFOs!

For each of the 5 AXI channels, you need to constrain 3 paths:
1. Gray write pointer crossing from source to destination domain
2. Gray read pointer crossing from destination to source domain  
3. Data path (from source to destination domain)

### Example SDC Constraints:

```tcl
# For each channel (AW, W, B, AR, R), add constraints like:

# Example for AW channel:
set_max_delay -datapath_only \
    -from [get_pins i_axi_cdc/i_axi_cdc_src/i_cdc_fifo_gray_src_aw/async_wptr_o] \
    -to   [get_pins i_axi_cdc/i_axi_cdc_dst/i_cdc_fifo_gray_dst_aw/async_wptr_i] \
    [expr $DEST_CLK_PERIOD * 0.8]

set_max_delay -datapath_only \
    -from [get_pins i_axi_cdc/i_axi_cdc_dst/i_cdc_fifo_gray_dst_aw/async_rptr_o] \
    -to   [get_pins i_axi_cdc/i_axi_cdc_src/i_cdc_fifo_gray_src_aw/async_rptr_i] \
    [expr $SRC_CLK_PERIOD * 0.8]

set_max_delay -datapath_only \
    -from [get_pins i_axi_cdc/i_axi_cdc_src/i_cdc_fifo_gray_src_aw/async_data_o] \
    -to   [get_pins i_axi_cdc/i_axi_cdc_dst/i_cdc_fifo_gray_dst_aw/async_data_i] \
    [expr $DEST_CLK_PERIOD * 0.8]

# Repeat similar constraints for W, B, AR, and R channels
```

Refer to the `cdc_fifo_gray` module header in the PULP repository for detailed constraint instructions.

## Design Notes

### Reset Polarity
- **Input**: Active-high reset (`master_reset`, `slave_reset`)
- **Internal**: Active-low reset (converted automatically in the wrapper)
- The PULP modules use active-low reset (`_ni` suffix means "negative/inverted")

### Atomic Operations (ATOPs)
The module supports AXI5 Atomic Operations through the `awatop` field. Ensure your system properly handles ATOPs or filters them if not supported downstream.

### FIFO Depth Selection
- Choose `LOG_DEPTH` based on your maximum burst length and system latency
- Recommended minimum: `LOG_DEPTH = 2` (depth = 4)
- For high-throughput systems: `LOG_DEPTH = 3 or 4` (depth = 8 or 16)

### Synchronization Stages
- `SYNC_STAGES = 2` is recommended for most applications (MTBF considerations)
- Increase to 3 for very high frequency ratios or stringent MTBF requirements
- Never use less than 2 stages

## Verification

The PULP Platform provides testbenches for the CDC module. You can find them in:
- `axi/test/tb_axi_cdc.sv` - Main CDC testbench
- `axi/test/tb_axi_cdc_util.sv` - Utility functions for CDC testing

## Known Issues and Limitations

1. **Questa Simulator Workaround**: The PULP code includes conditional compilation for Questa due to a tool-specific bug with parameterized types.

2. **Back-to-back Transactions**: The CDC introduces latency due to FIFO stages. Design your system accordingly.

3. **Out-of-Order Support**: The module preserves transaction ordering per ID, but different IDs can be reordered.

## References

- [PULP Platform AXI Repository](https://github.com/pulp-platform/axi)
- [PULP Platform Common Cells](https://github.com/pulp-platform/common_cells)
- [AXI CDC Documentation](https://pulp-platform.github.io/axi/master/module.axi_cdc.html)
- [Original Paper on PULP AXI Architecture](https://ieeexplore.ieee.org/document/9238297)

## License

This wrapper follows the same licensing as the PULP Platform repositories:
- Solderpad Hardware License, Version 0.51

The original PULP Platform modules are:
- Copyright (c) 2019-2020 ETH Zurich, University of Bologna

## Support

For issues related to:
- **This wrapper**: Check the wrapper code and signal mappings
- **PULP AXI modules**: Visit https://github.com/pulp-platform/axi/issues
- **General AXI CDC questions**: Refer to the PULP documentation

## Version History

- **v1.0** (2025-10-22): Initial wrapper creation
  - Full AXI4 + ATOPs support
  - Standard signal interface
  - Compatible with PULP Platform axi v0.39.x

---

**Note**: Always ensure you're using compatible versions of the `axi` and `common_cells` repositories. Refer to the `Bender.yml` or dependency files in the axi repository for version compatibility.
