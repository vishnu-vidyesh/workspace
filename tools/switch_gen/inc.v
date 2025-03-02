
`timescale 1ns / 1ps

module axi_interconnect #( 
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter NUM_MASTERS = 2,
    parameter NUM_SLAVES = 1
)(
    input wire clk,
    input wire reset,

    // Master Interfaces

    input wire [ADDR_WIDTH-1:0] RAM_awaddr,
    input wire                  RAM_awvalid,
    output wire                 RAM_awready,
    input wire [DATA_WIDTH-1:0] RAM_wdata,
    input wire                  RAM_wvalid,
    output wire                 RAM_wready,
    output wire [1:0]           RAM_bresp,
    output wire                 RAM_bvalid,
    input wire                  RAM_bready,
    input wire [ADDR_WIDTH-1:0] RAM_araddr,
    input wire                  RAM_arvalid,
    output wire                 RAM_arready,
    output wire [DATA_WIDTH-1:0] RAM_rdata,
    output wire [1:0]           RAM_rresp,
    output wire                 RAM_rvalid,
    input wire                  RAM_rready,

    input wire [ADDR_WIDTH-1:0] PERIPHERAL_awaddr,
    input wire                  PERIPHERAL_awvalid,
    output wire                 PERIPHERAL_awready,
    input wire [DATA_WIDTH-1:0] PERIPHERAL_wdata,
    input wire                  PERIPHERAL_wvalid,
    output wire                 PERIPHERAL_wready,
    output wire [1:0]           PERIPHERAL_bresp,
    output wire                 PERIPHERAL_bvalid,
    input wire                  PERIPHERAL_bready,
    input wire [ADDR_WIDTH-1:0] PERIPHERAL_araddr,
    input wire                  PERIPHERAL_arvalid,
    output wire                 PERIPHERAL_arready,
    output wire [DATA_WIDTH-1:0] PERIPHERAL_rdata,
    output wire [1:0]           PERIPHERAL_rresp,
    output wire                 PERIPHERAL_rvalid,
    input wire                  PERIPHERAL_rready,
// Slave Interfaces

    output wire [ADDR_WIDTH-1:0] CPU_awaddr,
    output wire                  CPU_awvalid,
    input wire                   CPU_awready,
    output wire [DATA_WIDTH-1:0] CPU_wdata,
    output wire                  CPU_wvalid,
    input wire                   CPU_wready,
    input wire [1:0]             CPU_bresp,
    input wire                   CPU_bvalid,
    output wire                  CPU_bready,
    output wire [ADDR_WIDTH-1:0] CPU_araddr,
    output wire                  CPU_arvalid,
    input wire                   CPU_arready,
    input wire [DATA_WIDTH-1:0]  CPU_rdata,
    input wire [1:0]             CPU_rresp,
    input wire                   CPU_rvalid,
    output wire                  CPU_rready,

    // Address decoding logic
    always @(*) begin
        case(RAM_awaddr) // Address Mapping
            0x40000000: begin CPU_awaddr = RAM_awaddr; CPU_awvalid = RAM_awvalid; end
            default: begin end
        endcase
        case(PERIPHERAL_awaddr) // Address Mapping
            0x50000000: begin CPU_awaddr = PERIPHERAL_awaddr; CPU_awvalid = PERIPHERAL_awvalid; end
            default: begin end
        endcase
    end
endmodule
