#!/usr/bin/env python3
"""
AXI Bus CDC Generator - Production Ready Script
================================================
Generates a synthesizable, industry-standard AXI CDC wrapper with
full 5-channel asynchronous FIFO logic for robust clock domain crossing.
This script is intended to be driven by a Makefile.
"""

import json
import os
import sys
from datetime import datetime
from typing import Dict, List, Tuple

class AXIBusCDCGenerator:
    """
    Generates the content for the AXI bus CDC wrapper and address map header.
    """
    # Define AXI channel signals and their widths for robust generation
    AXI_SIGNALS = {
        'aw': {'id': 'AXI_ID_WIDTH', 'addr': 'AXI_ADDR_WIDTH', 'len': '8', 'size': '3', 'burst': '2', 'lock': '1', 'cache': '4', 'prot': '3'},
        'w':  {'data': 'AXI_DATA_WIDTH', 'strb': 'AXI_STRB_WIDTH', 'last': '1'},
        'b':  {'id': 'AXI_ID_WIDTH', 'resp': '2'},
        'ar': {'id': 'AXI_ID_WIDTH', 'addr': 'AXI_ADDR_WIDTH', 'len': '8', 'size': '3', 'burst': '2', 'lock': '1', 'cache': '4', 'prot': '3'},
        'r':  {'id': 'AXI_ID_WIDTH', 'data': 'AXI_DATA_WIDTH', 'resp': '2', 'last': '1'}
    }
    # Signals that are inputs to a slave interface (and outputs from a master)
    AXI_SLAVE_INPUTS = ['awvalid', 'awid', 'awaddr', 'awlen', 'awsize', 'awburst', 'awlock', 'awcache', 'awprot',
                        'wvalid', 'wdata', 'wstrb', 'wlast',
                        'bready',
                        'arvalid', 'arid', 'araddr', 'arlen', 'arsize', 'arburst', 'arlock', 'arcache', 'arprot',
                        'rready']


    def __init__(self, config_file: str, output_dir: str = "./generated"):
        """Initialize the generator with configuration and output directory."""
        self.config = self._load_config(config_file)
        self.output_dir = output_dir
        self._ensure_output_dir()

        self.addr_width = self.config.get('Address Width', 32)
        self.data_width = self.config.get('Data Width', 32)
        self.id_width = self.config.get('ID Width', 4)
        self.user_width = self.config.get('User Width', 1)

        self.ports = self.config['Ports']
        self.masters = []
        self.slaves = []
        self.clock_groups = set(['inter_bus_clk'])
        self._process_ports()

    def _load_config(self, config_file: str) -> Dict:
        """Load and validate the JSON configuration file."""
        with open(config_file, 'r') as f:
            config = json.load(f)
        required = ['Address Width', 'Data Width', 'Ports']
        for field in required:
            if field not in config:
                raise ValueError(f"Missing required config field: {field}")
        return config

    def _ensure_output_dir(self):
        """Create the necessary output directory structure."""
        os.makedirs(f"{self.output_dir}/rtl", exist_ok=True)
        os.makedirs(f"{self.output_dir}/include", exist_ok=True)

    def _process_ports(self):
        """Categorize ports into masters/slaves and identify clock domains."""
        master_idx, slave_idx = 0, 0
        for port in self.ports:
            port_info = {
                'name': port['Port Name'],
                'type': port['Port Type'],
                'clock': port.get('Clock Group', 'inter_bus_clk')
            }
            if 'Address Map' in port:
                port_info['addr_base'], port_info['addr_size'] = self._parse_address_map(port['Address Map'])

            if port['Port Type'] == 'master':
                port_info['idx'] = slave_idx
                self.slaves.append(port_info)
                slave_idx += 1
            else: # port type is 'slave'
                port_info['idx'] = master_idx
                self.masters.append(port_info)
                master_idx += 1
            
            self.clock_groups.add(port_info['clock'])

    def _parse_address_map(self, addr_map_str: str) -> Tuple[int, int]:
        """Parse 'BASE to END' address string into base and address bits."""
        parts = addr_map_str.split(' to ')
        base_addr = int(parts[0], 16)
        end_addr = int(parts[1], 16)
        size = end_addr - base_addr + 1
        addr_bits = (size - 1).bit_length()
        return base_addr, addr_bits

    def _format_signal(self, direction, width, name):
        """Helper to format a SystemVerilog port declaration."""
        return f"{direction:<6} wire {width:<23} {name}"

    def _get_port_declarations(self) -> str:
        """Generates the SystemVerilog port declarations for the top module."""
        wrapper = ""
        clocks = sorted(list(self.clock_groups))
        for clk in clocks:
            wrapper += f"    input wire {clk},\n"
            wrapper += f"    input wire {clk}_resetn,\n"
        
        # External Masters (connecting to our slave ports)
        for i, master in enumerate(self.slaves):
            prefix = f"s_axi_m{i}_{master['name'].lower()}"
            wrapper += f"\n    // -- AXI Slave Port {i} ({master['name']}) --\n"
            for ch, sigs in self.AXI_SIGNALS.items():
                for sig, width in sigs.items():
                    is_input = f"{ch}{sig}" in self.AXI_SLAVE_INPUTS
                    wrapper += f"    {self._format_signal('input' if is_input else 'output', f'[{width}-1:0]', f'{prefix}_{ch}{sig}')},\n"
                wrapper += f"    {self._format_signal('input' if f'{ch}valid' in self.AXI_SLAVE_INPUTS else 'output', '', f'{prefix}_{ch}valid')},\n"
                wrapper += f"    {self._format_signal('output' if f'{ch}valid' in self.AXI_SLAVE_INPUTS else 'input', '', f'{prefix}_{ch}ready')},\n"

        # External Slaves (connecting to our master ports)
        for i, slave in enumerate(self.masters):
            is_last_port = (i == len(self.masters) - 1)
            prefix = f"m_axi_s{i}_{slave['name'].lower()}"
            wrapper += f"\n    // -- AXI Master Port {i} ({slave['name']}) --\n"
            ch_count = 0
            for ch, sigs in self.AXI_SIGNALS.items():
                sig_count = 0
                for sig, width in sigs.items():
                    is_output = f"{ch}{sig}" in self.AXI_SLAVE_INPUTS
                    id_width = "AXI_SID_WIDTH" if sig == 'id' else width
                    is_last_sig_in_ch = (sig_count == len(sigs)-1)
                    is_last_ch = (ch_count == len(self.AXI_SIGNALS)-1)
                    is_last_sig_of_all = is_last_sig_in_ch and is_last_ch and is_last_port

                    wrapper += f"    {self._format_signal('output' if is_output else 'input', f'[{id_width}-1:0]', f'{prefix}_{ch}{sig}')}{'' if is_last_sig_of_all else ','}\n"
                    sig_count += 1

                is_last_ch = (ch_count == len(self.AXI_SIGNALS)-1)
                is_last_sig_of_all = is_last_ch and is_last_port
                is_output = f"{ch}valid" in self.AXI_SLAVE_INPUTS
                wrapper += f"    {self._format_signal('output' if is_output else 'input', '', f'{prefix}_{ch}valid')},\n"
                wrapper += f"    {self._format_signal('input' if is_output else 'output', '', f'{prefix}_{ch}ready')}{'' if is_last_sig_of_all else ','}\n"
                ch_count += 1
        return wrapper.strip().rstrip(',')

    def _get_full_cdc_module(self, port_type: str, port_info: Dict) -> str:
        """Generates the complete 5-channel CDC logic for a single port."""
        idx = port_info['idx']
        is_master_port = (port_type == 'master') # Master port on our wrapper (connects to external slave)
        src_clk, dst_clk = ('inter_bus_clk', port_info['clock']) if is_master_port else (port_info['clock'], 'inter_bus_clk')
        
        ext = f"m_axi_s{idx}_{port_info['name'].lower()}" if is_master_port else f"s_axi_m{idx}_{port_info['name'].lower()}"
        int_ = f"int_s{idx}" if is_master_port else f"int_m{idx}"
        
        code = ""
        for ch, sigs in self.AXI_SIGNALS.items():
            id_w = "AXI_SID_WIDTH" if is_master_port and 'id' in sigs else "AXI_ID_WIDTH"
            payload_width = " + ".join([id_w if s=='id' else w for s,w in sigs.items()])
            
            # Determine data flow direction for the FIFO
            is_downstream_flow = (port_type == 'slave' and ch in ['aw', 'w', 'ar']) or \
                               (port_type == 'master' and ch in ['b', 'r'])
            
            s_clk, d_clk = (src_clk, dst_clk) if is_downstream_flow else (dst_clk, src_clk)

            # Data source and destination for the FIFO
            wr_data_bus = int_ if (port_type == 'master' and is_downstream_flow) or (port_type == 'slave' and not is_downstream_flow) else ext_
            rd_data_bus = ext_ if (port_type == 'master' and is_downstream_flow) or (port_type == 'slave' and not is_downstream_flow) else int_
            
            wr_data_payload = f"{{ {', '.join([f'{wr_data_bus}_{ch}{s}' for s in sigs])} }}"
            rd_data_payload = f"{{ {', '.join([f'{rd_data_bus}_{ch}{s}' for s in sigs])} }}"

            wr_en_bus = ext_ if is_downstream_flow else int_
            rd_en_bus = int_ if is_downstream_flow else ext_

            wr_en = f"{wr_en_bus}_{ch}valid && !{ch}_full"
            rd_en = f"{rd_en_bus}_{ch}ready && !{ch}_empty"

            code += f"""
        // {ch.upper()} Channel CDC
        wire {ch}_full, {ch}_empty;
        async_fifo #( .WIDTH({payload_width}), .DEPTH(1 << CDC_LOG_DEPTH) )
        u_{ch}_cdc_{port_info['name'].lower()} (
            .wr_clk({s_clk}), .wr_rst_n({s_clk}_resetn), .wr_en({wr_en}), .wr_data({wr_data_payload}), .full({ch}_full),
            .rd_clk({d_clk}), .rd_rst_n({d_clk}_resetn), .rd_en({rd_en}), .rd_data({rd_data_payload}), .empty({ch}_empty)
        );
        assign {wr_en_bus}_{ch}ready = !{ch}_full;
        assign {rd_en_bus}_{ch}valid = !{ch}_empty;"""
        return code

    def _get_direct_connection_logic(self, port_type: str, port_info: Dict) -> str:
        """Generates assign statements for same-clock-domain connections."""
        idx = port_info['idx']
        is_master_port = (port_type == 'master')
        ext = f"m_axi_s{idx}_{port_info['name'].lower()}" if is_master_port else f"s_axi_m{idx}_{port_info['name'].lower()}"
        int_ = f"int_s{idx}" if is_master_port else f"int_m{idx}"
        
        code = f"\n                // Direct connection for port {idx} ({port_info['name']})\n"
        for ch, sigs in self.AXI_SIGNALS.items():
            for sig in list(sigs.keys()) + ['valid', 'ready']:
                ext_sig, int_sig = f"{ext}_{ch}{sig}", f"{int_}_{ch}{sig}"
                is_slave_input = f"{ch}{sig}" in self.AXI_SLAVE_INPUTS
                
                # Determine signal flow direction relative to the wrapper
                src, dst = (ext_sig, int_sig) if is_slave_input else (int_sig, ext_sig)
                if port_type == 'master': # Master port on wrapper (outputs to slave)
                    src, dst = (int_sig, ext_sig) if is_slave_input else (ext_sig, int_sig)
                    
                code += f"                assign {dst} = {src};\n"
        return code

    def generate_top_wrapper(self) -> str:
        """
        Generates the complete SystemVerilog top wrapper file content.
        This version contains the corrected logic for the interconnect instantiation.
        """
        num_masters, num_slaves = len(self.masters), len(self.slaves)
        
        wrapper = f"""
// -- AXI Bus CDC Top Wrapper - Synthesizable RTL --
// Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
// Masters (to Interconnect): {num_masters}, Slaves (from Interconnect): {num_slaves}

module axi_bus_cdc_top #(
    parameter int AXI_ADDR_WIDTH  = {self.addr_width},
    parameter int AXI_DATA_WIDTH  = {self.data_width},
    parameter int AXI_ID_WIDTH    = {self.id_width},
    parameter int AXI_USER_WIDTH  = {self.user_width},
    parameter int CDC_LOG_DEPTH   = 2
)({self._get_port_declarations()});
    localparam int AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;
    localparam int AXI_SID_WIDTH  = AXI_ID_WIDTH + $clog2({max(1, num_masters)}); // Use max(1,...) to avoid $clog2(0)
"""
        # Internal Signals
        wrapper += "\n    // -- Internal Signals (inter_bus_clk domain) --\n"
        for s in self.slaves:
            wrapper += f'    // Internal wires for Interconnect Slave Port {s["idx"]} ({s["name"]})\n'
            for ch, sigs in self.AXI_SIGNALS.items():
                for sig, width in sigs.items():
                    wrapper += f'    wire [{width}-1:0] int_m{s["idx"]}_{ch}{sig};\n'
                wrapper += f'    wire int_m{s["idx"]}_{ch}valid, int_m{s["idx"]}_{ch}ready;\n'
        for m in self.masters:
            wrapper += f'    // Internal wires for Interconnect Master Port {m["idx"]} ({m["name"]})\n'
            for ch, sigs in self.AXI_SIGNALS.items():
                for sig, width in sigs.items():
                    id_width = "AXI_SID_WIDTH" if sig == 'id' else width
                    wrapper += f'    wire [{id_width}-1:0] int_s{m["idx"]}_{ch}{sig};\n'
                wrapper += f'    wire int_s{m["idx"]}_{ch}valid, int_s{m["idx"]}_{ch}ready;\n'

        # CDC and Direct Connection Generation
        wrapper += "\n    // -- CDC Modules and Direct Connections --\n    genvar i;\n    generate\n"
        if num_slaves > 0:
            wrapper += f"        for (i = 0; i < {num_slaves}; i=i+1) begin : gen_slave_port_logic\n"
            for s in self.slaves:
                wrapper += f"            if (i == {s['idx']}) begin : port_logic_m{s['idx']}_{s['name'].lower()}\n"
                if s['clock'] == 'inter_bus_clk':
                    wrapper += self._get_direct_connection_logic('slave', s)
                else:
                    wrapper += self._get_full_cdc_module('slave', s)
                wrapper += "            end\n"
            wrapper += "        end\n\n"
        
        if num_masters > 0:
            wrapper += f"        for (i = 0; i < {num_masters}; i=i+1) begin : gen_master_port_logic\n"
            for m in self.masters:
                wrapper += f"            if (i == {m['idx']}) begin : port_logic_s{m['idx']}_{m['name'].lower()}\n"
                if m['clock'] == 'inter_bus_clk':
                    wrapper += self._get_direct_connection_logic('master', m)
                else:
                    wrapper += self._get_full_cdc_module('master', m)
                wrapper += "            end\n"
            wrapper += "        end\n"
        wrapper += "    endgenerate\n"

        # --- Interconnect Instantiation Logic ---
        interconnect_connections = []
        # Connections for Interconnect Slave Ports (M0, M1, ...) from external masters
        for s in self.slaves:
            for ch, sigs in self.AXI_SIGNALS.items():
                for sig in list(sigs.keys()) + ['valid', 'ready']:
                    port = f".M{s['idx']}_{ch.upper()}{sig.upper()}"
                    wire = f"int_m{s['idx']}_{ch}{sig}"
                    interconnect_connections.append(f"{port}({wire})")
        
        # Connections for Interconnect Master Ports (S0, S1, ...) to external slaves
        for m in self.masters:
            for ch, sigs in self.AXI_SIGNALS.items():
                for sig in list(sigs.keys()) + ['valid', 'ready']:
                    port = f".S{m['idx']}_{ch.upper()}{sig.upper()}"
                    wire = f"int_s{m['idx']}_{ch}{sig}"
                    interconnect_connections.append(f"{port}({wire})")

        # **FIX**: Iterate over `self.slaves` for address map parameters
        addr_params = "".join([f',\\n        .SLAVE_EN{s["idx"]}(1''b1), .ADDR_BASE{s["idx"]}(32''h{s["addr_base"]:08x}), .ADDR_LENGTH{s["idx"]}({s["addr_size"]})' for s in self.slaves if 'addr_base' in s])

        wrapper += f"""
    // -- AXI Interconnect Instance --
    amba_axi_m{num_masters}s{num_slaves} #(
        .NUM_MASTER({num_masters}), 
        .NUM_SLAVE({num_slaves}),
        .WIDTH_CID($clog2({max(1, num_masters)})),
        .WIDTH_ID(AXI_ID_WIDTH), 
        .WIDTH_AD(AXI_ADDR_WIDTH),
        .WIDTH_DA(AXI_DATA_WIDTH), 
        .WIDTH_DS(AXI_STRB_WIDTH), 
        .WIDTH_SID(AXI_SID_WIDTH)
        {addr_params}
    ) u_interconnect (
        .ARESETn(inter_bus_clk_resetn), 
        .ACLK(inter_bus_clk),
        // --- Complete Port Map ---
        {",\\n        ".join(interconnect_connections)}
    );

endmodule
"""
        return wrapper

    def generate_address_header(self) -> str:
        """Generates a Verilog header file with address map defines."""
        header = f"""// AXI Address Map Defines
// Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
`ifndef AXI_ADDR_MAP_SVH
`define AXI_ADDR_MAP_SVH

"""
        # **FIX**: Iterate over `self.slaves` (RAM, PERIPHERAL) not `self.masters`
        for slave in self.slaves:
            if 'addr_base' in slave:
                name = slave['name'].upper()
                header += f"`define ADDR_BASE_{name:<12} 32'h{slave['addr_base']:08x}\n"
                header += f"`define ADDR_BITS_{name:<12} {slave['addr_size']}\n\n"
        header += "`endif // AXI_ADDR_MAP_SVH\n"
        return header

    def generate_all(self):
        """Generate all output files (wrapper and header)."""
        print("\n" + "="*70)
        print("AXI Bus CDC Generator - File Content Generation")
        print("="*70 + "\n")

        print("Step 1: Generating AXI CDC wrapper content...")
        wrapper_code = self.generate_top_wrapper()
        wrapper_file = f"{self.output_dir}/rtl/axi_bus_cdc_top.sv"
        with open(wrapper_file, 'w') as f: f.write(wrapper_code)
        print(f"   -> Created: {wrapper_file}")

        print("\nStep 2: Generating address map header content...")
        header_code = self.generate_address_header()
        header_file = f"{self.output_dir}/include/axi_addr_map.svh"
        with open(header_file, 'w') as f: f.write(header_code)
        print(f"   -> Created: {header_file}")

        print("\n" + "="*70 + "\nGeneration Complete!\n" + "="*70)
        print("Next Step: Run 'make generate' to build the interconnect and wrapper.")

def main():
    """Main entry point for the script."""
    import argparse
    parser = argparse.ArgumentParser(description='Generate AXI Bus CDC Wrapper RTL and Headers')
    parser.add_argument('--config', '-c', default='switch_config.json', help='JSON configuration file')
    parser.add_argument('--output', '-o', default='./generated', help='Output directory for generated files')
    args = parser.parse_args()

    if not os.path.exists(args.config):
        print(f"Error: Config file '{args.config}' not found.", file=sys.stderr)
        sys.exit(1)
    try:
        generator = AXIBusCDCGenerator(args.config, args.output)
        generator.generate_all()
    except Exception as e:
        print(f"An error occurred: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()


