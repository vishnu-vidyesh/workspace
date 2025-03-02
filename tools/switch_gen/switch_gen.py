import sys
import json

def generate_axi_interconnect(config_file, output_file):
    with open(config_file, "r") as f:
        config = json.load(f)

    addr_width = config["Address Width"]
    data_width = config["Data Width"]
    ports = config["Ports"]
    
    masters = [p for p in ports if p["Port Type"].lower() == "master"]
    slaves = [p for p in ports if p["Port Type"].lower() == "slave"]
    
    with open(output_file, "w") as f:
        f.write(f"""
`timescale 1ns / 1ps

module axi_interconnect #( 
    parameter ADDR_WIDTH = {addr_width},
    parameter DATA_WIDTH = {data_width},
    parameter NUM_MASTERS = {len(masters)},
    parameter NUM_SLAVES = {len(slaves)}
)(
    input wire clk,
    input wire reset,

    // Master Interfaces
""")

        for master in masters:
            name = master["Port Name"]
            f.write(f"""
    input wire [ADDR_WIDTH-1:0] {name}_awaddr,
    input wire                  {name}_awvalid,
    output wire                 {name}_awready,
    input wire [DATA_WIDTH-1:0] {name}_wdata,
    input wire                  {name}_wvalid,
    output wire                 {name}_wready,
    output wire [1:0]           {name}_bresp,
    output wire                 {name}_bvalid,
    input wire                  {name}_bready,
    input wire [ADDR_WIDTH-1:0] {name}_araddr,
    input wire                  {name}_arvalid,
    output wire                 {name}_arready,
    output wire [DATA_WIDTH-1:0] {name}_rdata,
    output wire [1:0]           {name}_rresp,
    output wire                 {name}_rvalid,
    input wire                  {name}_rready,
""")

        f.write("// Slave Interfaces\n")

        for slave in slaves:
            name = slave["Port Name"]
            f.write(f"""
    output wire [ADDR_WIDTH-1:0] {name}_awaddr,
    output wire                  {name}_awvalid,
    input wire                   {name}_awready,
    output wire [DATA_WIDTH-1:0] {name}_wdata,
    output wire                  {name}_wvalid,
    input wire                   {name}_wready,
    input wire [1:0]             {name}_bresp,
    input wire                   {name}_bvalid,
    output wire                  {name}_bready,
    output wire [ADDR_WIDTH-1:0] {name}_araddr,
    output wire                  {name}_arvalid,
    input wire                   {name}_arready,
    input wire [DATA_WIDTH-1:0]  {name}_rdata,
    input wire [1:0]             {name}_rresp,
    input wire                   {name}_rvalid,
    output wire                  {name}_rready,
""")

        f.write("\n    // Address decoding logic\n")
        f.write("    always @(*) begin\n")
        for master in masters:
            name = master["Port Name"]
            f.write(f"        case({name}_awaddr) // Address Mapping\n")
            for slave in slaves:
                slave_name = slave["Port Name"]
                if "Address Map" in master:
                    addr_start, addr_end = master["Address Map"].split(" to ")
                    f.write(f"            {addr_start}: begin {slave_name}_awaddr = {name}_awaddr; {slave_name}_awvalid = {name}_awvalid; end\n")
            f.write("            default: begin end\n")
            f.write("        endcase\n")
        f.write("    end\n")

        f.write("endmodule\n")
    print(f"Generated {output_file} based on {config_file}.")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python generate_axi_interconnect.py <config_file> <output_file>")
    else:
        config_file = sys.argv[1]
        output_file = sys.argv[2]
        generate_axi_interconnect(config_file, output_file)

