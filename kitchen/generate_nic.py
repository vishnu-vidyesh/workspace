#!/usr/bin/env python3
import json
import os
import re
import math
import subprocess

def main():
    # 1. Read switch_config.json
    config_path = "switch_config.json"
    if not os.path.exists(config_path):
        print(f"Error: {config_path} not found.")
        return
        
    with open(config_path, "r") as f:
        config = json.load(f)
    
    ports = config.get("Ports", [])
    
    # 2. Count masters and slaves
    # 'slave' in Port Type means interconnect port is slave (connects to master CPU/DMA)
    # 'master' in Port Type means interconnect port is master (connects to slave RAM/PERIPHERAL)
    slave_ports = [p for p in ports if p.get("Port Type") == "slave"]
    master_ports = [p for p in ports if p.get("Port Type") == "master"]
    
    num_masters = len(slave_ports)
    num_slaves = len(master_ports)
    
    print(f"Detected {num_masters} master interfaces (slave ports of interconnect) and {num_slaves} slave interfaces (master ports of interconnect).")
    
    # 3. Generate the base interconnect
    module_name = f"amba_axi_m{num_masters}s{num_slaves}"
    interconnect_file = f"{module_name}.v"
    
    # Executable path
    gen_dir = os.path.join("gen_amba_2021", "gen_amba_axi")
    executable = os.path.join(gen_dir, "gen_amba_axi")
    
    # Output path in kitchen directory
    output_interconnect_path = os.path.abspath(interconnect_file)
    
    # Run the gen_amba_axi command
    cmd = [
        executable,
        f"--master={num_masters}",
        f"--slave={num_slaves}",
        f"--output={output_interconnect_path}"
    ]
    print(f"Running command: {' '.join(cmd)}")
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        print("Error generating interconnect:")
        print(result.stderr)
        return
    print(f"Base interconnect generated successfully at {interconnect_file}.")
    
    # 4. Parse the generated interconnect file to extract ports
    with open(output_interconnect_path, "r") as f:
        interconnect_content = f.read()
        
    lines = interconnect_content.splitlines()
    
    # Locate module declaration and start of port list
    module_start_idx = -1
    for i, line in enumerate(lines):
        if line.strip().startswith(f"module {module_name}"):
            module_start_idx = i
            break
            
    if module_start_idx == -1:
        print(f"Error: Could not find module declaration for {module_name}")
        return
        
    paren_level = 0
    in_params = False
    in_ports = False
    ports_start_idx = -1
    ports_end_idx = -1
    
    for i in range(module_start_idx, len(lines)):
        line = lines[i]
        char_idx = 0
        while char_idx < len(line):
            c = line[char_idx]
            if c == '#':
                if char_idx + 1 < len(line) and line[char_idx + 1] == '(':
                    in_params = True
                    paren_level = 1
                    char_idx += 2
                    continue
            elif c == '(':
                if in_params:
                    paren_level += 1
                else:
                    in_ports = True
                    ports_start_idx = i
                    break
            elif c == ')':
                if in_params:
                    paren_level -= 1
                    if paren_level == 0:
                        in_params = False
                elif in_ports:
                    if char_idx + 1 < len(line) and line[char_idx + 1] == ';':
                        ports_end_idx = i
                        in_ports = False
                        break
            char_idx += 1
        if ports_end_idx != -1:
            break
            
    if ports_start_idx == -1 or ports_end_idx == -1:
        print("Error: Could not locate port list in the generated interconnect file.")
        return
        
    port_lines = lines[ports_start_idx+1 : ports_end_idx]
    
    # 5. Build the replacements mapping
    replacements = {}
    slave_idx = 0
    master_idx = 0
    
    for port in ports:
        name = port["Port Name"]
        ptype = port["Port Type"]
        if ptype == "slave":
            replacements[f"M{slave_idx}_"] = f"{name}_"
            slave_idx += 1
        elif ptype == "master":
            replacements[f"S{master_idx}_"] = f"{name}_"
            master_idx += 1
            
    replacements["ACLK"] = "nic_base_clk"
    replacements["ARESETn"] = "resetn"
    
    print("Port replacements mapping:")
    for k, v in replacements.items():
        print(f"  {k} -> {v}")
        
    # Helper to apply replacements
    def apply_replacements(text, mapping):
        sorted_keys = sorted(mapping.keys(), key=len, reverse=True)
        for k in sorted_keys:
            text = text.replace(k, mapping[k])
        return text
        
    # 6. Parse and transform ports
    # Regex to extract: 1. prefix (indentation/comma), 2. direction (input/output), 3. width, 4. port name
    port_pat = re.compile(r'^(\s*(?:,\s*)?)\b(input|output|inout)\b\s*(?:wire|reg)?\s*(\[.*?\])?\s*([A-Za-z0-9_]+)\s*(?:$|//|/\*)')
    
    parsed_lines = []
    for line in port_lines:
        stripped = line.strip()
        if not stripped:
            parsed_lines.append({
                'type': 'empty',
                'line': line
            })
            continue
            
        if stripped.startswith("`"):
            parsed_lines.append({
                'type': 'directive',
                'line': line
            })
            continue
            
        m = port_pat.match(line)
        if m:
            prefix = m.group(1)
            direction = m.group(2)
            width = m.group(3) if m.group(3) else ""
            port_name = m.group(4)
            parsed_lines.append({
                'type': 'port',
                'prefix': prefix,
                'direction': direction,
                'width': width,
                'name': port_name,
                'line': line
            })
        else:
            parsed_lines.append({
                'type': 'other',
                'line': line
            })
            
    # Map prefix to config dict
    prefix_to_config = {}
    for idx, p in enumerate(slave_ports):
        prefix_to_config[f"M{idx}_"] = p
    for idx, p in enumerate(master_ports):
        prefix_to_config[f"S{idx}_"] = p
        
    # 7. Generate top wrapper ports
    unique_clk_groups = sorted(list(set(
        p["Clock Group"] for p in ports if p["Clock Group"] != "nic_clk"
    )))
    
    clk_ports = [
        "       input   wire                      nic_base_clk",
        "     , input   wire                      resetn"
    ]
    for cg in unique_clk_groups:
        clk_ports.append(f"     , input   wire                      {cg}")
        clk_ports.append(f"     , input   wire                      {cg}_resetn")
        
    wrapper_ports = []
    wrapper_ports.extend(clk_ports)
    
    for pl in parsed_lines:
        if pl['type'] == 'directive':
            wrapper_ports.append(pl['line'])
        elif pl['type'] == 'port':
            port_name = pl['name']
            if port_name in ["ACLK", "ARESETn"]:
                continue # Clock and reset are defined manually
            # Apply replacements to the line
            new_line = apply_replacements(pl['line'], replacements)
            wrapper_ports.append(new_line)
        else:
            wrapper_ports.append(pl['line'])
            
    # 8. Generate internal wires for CDC
    internal_wires = []
    internal_wires.append("    // Internal wires for interfaces crossing clock domains")
    
    for pl in parsed_lines:
        if pl['type'] == 'directive':
            internal_wires.append(pl['line'])
        elif pl['type'] == 'port':
            port_name = pl['name']
            # Find prefix
            matched_prefix = None
            for pfx in prefix_to_config.keys():
                if port_name.startswith(pfx):
                    matched_prefix = pfx
                    break
            if matched_prefix:
                p = prefix_to_config[matched_prefix]
                clk_group = p["Clock Group"]
                if clk_group != "nic_clk":
                    custom_name = p["Port Name"]
                    base_name = port_name[len(matched_prefix):]
                    width = pl['width']
                    internal_wires.append(f"    wire {width} {custom_name}_internal_{base_name};")
                    
    # 9. Generate CDC wrapper instantiations
    cdc_insts = []
    for prefix, p in prefix_to_config.items():
        clk_group = p["Clock Group"]
        if clk_group == "nic_clk":
            continue
            
        custom_name = p["Port Name"]
        ptype = p["Port Type"]
        
        # Determine ID width parameter
        id_width_param = "WIDTH_ID" if ptype == "slave" else "WIDTH_SID"
        
        # Determine clocks and resets
        if ptype == "slave":
            src_clk = clk_group
            src_rst_n = f"{clk_group}_resetn"
            dst_clk = "nic_base_clk"
            dst_rst_n = "resetn"
        else:
            src_clk = "nic_base_clk"
            src_rst_n = "resetn"
            dst_clk = clk_group
            dst_rst_n = f"{clk_group}_resetn"
            
        cdc_insts.append(f"    // CDC crossing for {custom_name} clock domain ({clk_group} <-> nic_base_clk)")
        cdc_insts.append(f"    axi_cdc_wrapper #(")
        cdc_insts.append(f"        .ID_WIDTH({id_width_param}),")
        cdc_insts.append(f"        .ADDR_WIDTH(WIDTH_AD),")
        cdc_insts.append(f"        .DATA_WIDTH(WIDTH_DA),")
        cdc_insts.append(f"        .STRB_WIDTH(WIDTH_DS),")
        cdc_insts.append(f"        .USER_WIDTH(1)")
        cdc_insts.append(f"    ) u_cdc_{custom_name} (")
        cdc_insts.append(f"        .src_clk({src_clk}),")
        cdc_insts.append(f"        .src_rst_n({src_rst_n}),")
        cdc_insts.append(f"        .dst_clk({dst_clk}),")
        cdc_insts.append(f"        .dst_rst_n({dst_rst_n})")
        
        for pl in parsed_lines:
            if pl['type'] == 'directive':
                cdc_insts.append(pl['line'])
            elif pl['type'] == 'port' and pl['name'].startswith(prefix):
                base_name = pl['name'][len(prefix):]
                wrapper_port_name = base_name.lower()
                
                if ptype == "slave":
                    s_conn = f"{custom_name}_{base_name}"
                    m_conn = f"{custom_name}_internal_{base_name}"
                else:
                    s_conn = f"{custom_name}_internal_{base_name}"
                    m_conn = f"{custom_name}_{base_name}"
                    
                cdc_insts.append(f"      , .s_{wrapper_port_name}({s_conn})")
                cdc_insts.append(f"      , .m_{wrapper_port_name}({m_conn})")
                
        cdc_insts.append(f"    );")
        cdc_insts.append("")
        
    # 10. Generate interconnect connections
    inst_connections = []
    for pl in parsed_lines:
        if pl['type'] == 'directive':
            inst_connections.append(pl['line'])
        elif pl['type'] == 'port':
            prefix = pl['prefix']
            port_name = pl['name']
            
            if port_name == "ACLK":
                inst_connections.append(f"{prefix}.ACLK(nic_base_clk)")
                continue
            elif port_name == "ARESETn":
                inst_connections.append(f"{prefix}.ARESETn(resetn)")
                continue
                
            matched_prefix = None
            for pfx in prefix_to_config.keys():
                if port_name.startswith(pfx):
                    matched_prefix = pfx
                    break
                    
            if matched_prefix:
                p = prefix_to_config[matched_prefix]
                clk_group = p["Clock Group"]
                custom_name = p["Port Name"]
                base_name = port_name[len(matched_prefix):]
                
                if clk_group != "nic_clk":
                    conn_name = f"{custom_name}_internal_{base_name}"
                else:
                    conn_name = f"{custom_name}_{base_name}"
                    
                inst_connections.append(f"{prefix}.{port_name}({conn_name})")
            else:
                inst_connections.append(pl['line'])
        else:
            inst_connections.append(pl['line'])
            
    # 11. Build parameters list
    top_params = [
        "    parameter WIDTH_CID = 1,",
        "    parameter WIDTH_ID = 4,",
        "    parameter WIDTH_AD = 32,",
        "    parameter WIDTH_DA = 32,",
        "    parameter WIDTH_DS = (WIDTH_DA/8),",
        "    parameter WIDTH_SID = (WIDTH_CID+WIDTH_ID),"
    ]
    
    inst_params = [
        "        .WIDTH_CID(WIDTH_CID),",
        "        .WIDTH_ID(WIDTH_ID),",
        "        .WIDTH_AD(WIDTH_AD),",
        "        .WIDTH_DA(WIDTH_DA),",
        "        .WIDTH_DS(WIDTH_DS),",
        "        .WIDTH_SID(WIDTH_SID),"
    ]
    
    for idx, p in enumerate(master_ports):
        name = p["Port Name"]
        addr_map = p.get("Address Map", "0x0")
        addr_range = p.get("Address Range", "0x1000")
        
        # Parse base address
        if " to " in addr_map:
            base_str = addr_map.split(" to ")[0].strip()
        else:
            base_str = addr_map.strip()
            
        base_val = int(base_str, 16) if base_str.lower().startswith("0x") else int(base_str)
        range_val = int(addr_range, 16) if addr_range.lower().startswith("0x") else int(addr_range)
        
        length_val = int(math.log2(range_val))
        base_hex = f"32'h{base_val:08X}"
        
        top_params.append(f"    parameter {name}_BASE = {base_hex},")
        top_params.append(f"    parameter {name}_LENGTH = {length_val},")
        
        inst_params.append(f"        .SLAVE_EN{idx}(1),")
        inst_params.append(f"        .ADDR_BASE{idx}({name}_BASE),")
        inst_params.append(f"        .ADDR_LENGTH{idx}({name}_LENGTH),")
        
    # Remove trailing commas
    if top_params:
        top_params[-1] = top_params[-1].rstrip(",")
    if inst_params:
        inst_params[-1] = inst_params[-1].rstrip(",")
        
    # Join lists
    top_params_str = "\n".join(top_params)
    inst_params_str = "\n".join(inst_params)
    wrapper_ports_str = "\n".join(wrapper_ports)
    inst_connections_str = "\n".join(inst_connections)
    internal_wires_str = "\n".join(internal_wires)
    cdc_insts_str = "\n".join(cdc_insts)
    
    # 12. Write nic_top.v
    nic_top_content = f"""//---------------------------------------------------------------------------
// nic_top.v wrapper generated from switch_config.json
//---------------------------------------------------------------------------

module nic_top #(
{top_params_str}
) (
{wrapper_ports_str}
);

{internal_wires_str}

{cdc_insts_str}

    // Instantiate the base interconnect
    {module_name} #(
{inst_params_str}
    ) u_interconnect (
{inst_connections_str}
    );

endmodule
"""
    
    nic_top_path = "nic_top.v"
    with open(nic_top_path, "w") as f:
        f.write(nic_top_content)
        
    print(f"Wrapper module nic_top.v generated successfully at {os.path.abspath(nic_top_path)}.")

if __name__ == "__main__":
    main()
