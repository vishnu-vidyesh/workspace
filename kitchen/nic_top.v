//---------------------------------------------------------------------------
// nic_top.v wrapper generated from switch_config.json
//---------------------------------------------------------------------------

module nic_top #(
    parameter WIDTH_CID = 1,
    parameter WIDTH_ID = 4,
    parameter WIDTH_AD = 32,
    parameter WIDTH_DA = 32,
    parameter WIDTH_DS = (WIDTH_DA/8),
    parameter WIDTH_SID = (WIDTH_CID+WIDTH_ID),
    parameter RAM_BASE = 32'h40000000,
    parameter RAM_LENGTH = 28,
    parameter PERIPHERAL_BASE = 32'h50000000,
    parameter PERIPHERAL_LENGTH = 28
) (
       input   wire                      nic_base_clk
     , input   wire                      resetn
     , input   wire                      dma_clk
     , input   wire                      dma_clk_resetn
     , input   wire                      low_clk
     , input   wire                      low_clk_resetn
     , input   wire                      main_clk
     , input   wire                      main_clk_resetn
     //--------------------------------------------------------------
     , input   wire  [WIDTH_ID-1:0]      CPU_AWID
     , input   wire  [WIDTH_AD-1:0]      CPU_AWADDR
     , input   wire  [ 7:0]              CPU_AWLEN
     , input   wire                      CPU_AWLOCK
     , input   wire  [ 2:0]              CPU_AWSIZE
     , input   wire  [ 1:0]              CPU_AWBURST
     `ifdef  AMBA_AXI_CACHE
     , input   wire  [ 3:0]              CPU_AWCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input   wire  [ 2:0]              CPU_AWPROT
     `endif
     , input   wire                      CPU_AWVALID
     , output  wire                      CPU_AWREADY
     `ifdef AMBA_QOS
     , input   wire  [ 3:0]              CPU_AWQOS
     , input   wire  [ 3:0]              CPU_AWREGION
     `endif
     `ifdef AMBA_AXI_AWUSER
     , input   wire  [WIDTH_AWUSER-1:0]  CPU_AWUSER
     `endif
     , input   wire  [WIDTH_DA-1:0]      CPU_WDATA
     , input   wire  [WIDTH_DS-1:0]      CPU_WSTRB
     , input   wire                      CPU_WLAST
     , input   wire                      CPU_WVALID
     , output  wire                      CPU_WREADY
     `ifdef AMBA_AXI_WUSER
     , input   wire  [WIDTH_WUSER-1:0]   CPU_WUSER
     `endif
     , output  wire  [WIDTH_ID-1:0]      CPU_BID
     , output  wire  [ 1:0]              CPU_BRESP
     , output  wire                      CPU_BVALID
     , input   wire                      CPU_BREADY
     `ifdef AMBA_AXI_BUSER
     , output  wire  [WIDTH_BUSER-1:0]   CPU_BUSER
     `endif
     , input   wire  [WIDTH_ID-1:0]      CPU_ARID
     , input   wire  [WIDTH_AD-1:0]      CPU_ARADDR
     , input   wire  [ 7:0]              CPU_ARLEN
     , input   wire                      CPU_ARLOCK
     , input   wire  [ 2:0]              CPU_ARSIZE
     , input   wire  [ 1:0]              CPU_ARBURST
     `ifdef  AMBA_AXI_CACHE
     , input   wire  [ 3:0]              CPU_ARCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input   wire  [ 2:0]              CPU_ARPROT
     `endif
     , input   wire                      CPU_ARVALID
     , output  wire                      CPU_ARREADY
     `ifdef AMBA_QOS
     , input   wire  [ 3:0]              CPU_ARQOS
     , input   wire  [ 3:0]              CPU_ARREGION
     `endif
     `ifdef AMBA_AXI_ARUSER
     , input   wire  [WIDTH_ARUSER-1:0]  CPU_ARUSER
     `endif
     , output  wire  [WIDTH_ID-1:0]      CPU_RID
     , output  wire  [WIDTH_DA-1:0]      CPU_RDATA
     , output  wire  [ 1:0]              CPU_RRESP
     , output  wire                      CPU_RLAST
     , output  wire                      CPU_RVALID
     , input   wire                      CPU_RREADY
     `ifdef AMBA_AXI_RUSER
     , output  wire  [WIDTH_RUSER-1:0]   CPU_RUSER
     `endif
     //--------------------------------------------------------------
     , input   wire  [WIDTH_ID-1:0]      DMA_AWID
     , input   wire  [WIDTH_AD-1:0]      DMA_AWADDR
     , input   wire  [ 7:0]              DMA_AWLEN
     , input   wire                      DMA_AWLOCK
     , input   wire  [ 2:0]              DMA_AWSIZE
     , input   wire  [ 1:0]              DMA_AWBURST
     `ifdef  AMBA_AXI_CACHE
     , input   wire  [ 3:0]              DMA_AWCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input   wire  [ 2:0]              DMA_AWPROT
     `endif
     , input   wire                      DMA_AWVALID
     , output  wire                      DMA_AWREADY
     `ifdef AMBA_QOS
     , input   wire  [ 3:0]              DMA_AWQOS
     , input   wire  [ 3:0]              DMA_AWREGION
     `endif
     `ifdef AMBA_AXI_AWUSER
     , input   wire  [WIDTH_AWUSER-1:0]  DMA_AWUSER
     `endif
     , input   wire  [WIDTH_DA-1:0]      DMA_WDATA
     , input   wire  [WIDTH_DS-1:0]      DMA_WSTRB
     , input   wire                      DMA_WLAST
     , input   wire                      DMA_WVALID
     , output  wire                      DMA_WREADY
     `ifdef AMBA_AXI_WUSER
     , input   wire  [WIDTH_WUSER-1:0]   DMA_WUSER
     `endif
     , output  wire  [WIDTH_ID-1:0]      DMA_BID
     , output  wire  [ 1:0]              DMA_BRESP
     , output  wire                      DMA_BVALID
     , input   wire                      DMA_BREADY
     `ifdef AMBA_AXI_BUSER
     , output  wire  [WIDTH_BUSER-1:0]   DMA_BUSER
     `endif
     , input   wire  [WIDTH_ID-1:0]      DMA_ARID
     , input   wire  [WIDTH_AD-1:0]      DMA_ARADDR
     , input   wire  [ 7:0]              DMA_ARLEN
     , input   wire                      DMA_ARLOCK
     , input   wire  [ 2:0]              DMA_ARSIZE
     , input   wire  [ 1:0]              DMA_ARBURST
     `ifdef  AMBA_AXI_CACHE
     , input   wire  [ 3:0]              DMA_ARCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , input   wire  [ 2:0]              DMA_ARPROT
     `endif
     , input   wire                      DMA_ARVALID
     , output  wire                      DMA_ARREADY
     `ifdef AMBA_QOS
     , input   wire  [ 3:0]              DMA_ARQOS
     , input   wire  [ 3:0]              DMA_ARREGION
     `endif
     `ifdef AMBA_AXI_ARUSER
     , input   wire  [WIDTH_ARUSER-1:0]  DMA_ARUSER
     `endif
     , output  wire  [WIDTH_ID-1:0]      DMA_RID
     , output  wire  [WIDTH_DA-1:0]      DMA_RDATA
     , output  wire  [ 1:0]              DMA_RRESP
     , output  wire                      DMA_RLAST
     , output  wire                      DMA_RVALID
     , input   wire                      DMA_RREADY
     `ifdef AMBA_AXI_RUSER
     , output  wire  [WIDTH_RUSER-1:0]   DMA_RUSER
     `endif
     //--------------------------------------------------------------
     , output  wire  [WIDTH_SID-1:0]     RAM_AWID
     , output  wire  [WIDTH_AD-1:0]      RAM_AWADDR
     , output  wire  [ 7:0]              RAM_AWLEN
     , output  wire                      RAM_AWLOCK
     , output  wire  [ 2:0]              RAM_AWSIZE
     , output  wire  [ 1:0]              RAM_AWBURST
     `ifdef  AMBA_AXI_CACHE
     , output  wire  [ 3:0]              RAM_AWCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , output  wire  [ 2:0]              RAM_AWPROT
     `endif
     , output  wire                      RAM_AWVALID
     , input   wire                      RAM_AWREADY
     `ifdef AMBA_QOS
     , output  wire  [ 3:0]              RAM_AWQOS
     , output  wire  [ 3:0]              RAM_AWREGION
     `endif
     `ifdef AMBA_AXI_AWUSER
     , output  wire  [WIDTH_AWUSER-1:0]  RAM_AWUSER
     `endif
     , output  wire   [WIDTH_DA-1:0]     RAM_WDATA
     , output  wire   [WIDTH_DS-1:0]     RAM_WSTRB
     , output  wire                      RAM_WLAST
     , output  wire                      RAM_WVALID
     , input   wire                      RAM_WREADY
     `ifdef AMBA_AXI_WUSER
     , output  wire   [WIDTH_WUSER-1:0]  RAM_WUSER
     `endif
     , input   wire   [WIDTH_SID-1:0]    RAM_BID
     , input   wire   [ 1:0]             RAM_BRESP
     , input   wire                      RAM_BVALID
     , output  wire                      RAM_BREADY
     `ifdef AMBA_AXI_BUSER
     , input   wire   [WIDTH_BUSER-1:0]  RAM_BUSER
     `endif
     , output  wire   [WIDTH_SID-1:0]    RAM_ARID
     , output  wire   [WIDTH_AD-1:0]     RAM_ARADDR
     , output  wire   [ 7:0]             RAM_ARLEN
     , output  wire                      RAM_ARLOCK
     , output  wire   [ 2:0]             RAM_ARSIZE
     , output  wire   [ 1:0]             RAM_ARBURST
     `ifdef  AMBA_AXI_CACHE
     , output  wire   [ 3:0]             RAM_ARCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , output  wire   [ 2:0]             RAM_ARPROT
     `endif
     , output  wire                      RAM_ARVALID
     , input   wire                      RAM_ARREADY
     `ifdef AMBA_QOS
     , output  wire   [ 3:0]             RAM_ARQOS
     , output  wire   [ 3:0]             RAM_ARREGION
     `endif
     `ifdef AMBA_AXI_ARUSER
     , output  wire   [WIDTH_ARUSER-1:0] RAM_ARUSER
     `endif
     , input   wire   [WIDTH_SID-1:0]    RAM_RID
     , input   wire   [WIDTH_DA-1:0]     RAM_RDATA
     , input   wire   [ 1:0]             RAM_RRESP
     , input   wire                      RAM_RLAST
     , input   wire                      RAM_RVALID
     , output  wire                      RAM_RREADY
     `ifdef AMBA_AXI_RUSER
     , input   wire   [WIDTH_RUSER-1:0]  RAM_RUSER
     `endif
     //--------------------------------------------------------------
     , output  wire  [WIDTH_SID-1:0]     PERIPHERAL_AWID
     , output  wire  [WIDTH_AD-1:0]      PERIPHERAL_AWADDR
     , output  wire  [ 7:0]              PERIPHERAL_AWLEN
     , output  wire                      PERIPHERAL_AWLOCK
     , output  wire  [ 2:0]              PERIPHERAL_AWSIZE
     , output  wire  [ 1:0]              PERIPHERAL_AWBURST
     `ifdef  AMBA_AXI_CACHE
     , output  wire  [ 3:0]              PERIPHERAL_AWCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , output  wire  [ 2:0]              PERIPHERAL_AWPROT
     `endif
     , output  wire                      PERIPHERAL_AWVALID
     , input   wire                      PERIPHERAL_AWREADY
     `ifdef AMBA_QOS
     , output  wire  [ 3:0]              PERIPHERAL_AWQOS
     , output  wire  [ 3:0]              PERIPHERAL_AWREGION
     `endif
     `ifdef AMBA_AXI_AWUSER
     , output  wire  [WIDTH_AWUSER-1:0]  PERIPHERAL_AWUSER
     `endif
     , output  wire   [WIDTH_DA-1:0]     PERIPHERAL_WDATA
     , output  wire   [WIDTH_DS-1:0]     PERIPHERAL_WSTRB
     , output  wire                      PERIPHERAL_WLAST
     , output  wire                      PERIPHERAL_WVALID
     , input   wire                      PERIPHERAL_WREADY
     `ifdef AMBA_AXI_WUSER
     , output  wire   [WIDTH_WUSER-1:0]  PERIPHERAL_WUSER
     `endif
     , input   wire   [WIDTH_SID-1:0]    PERIPHERAL_BID
     , input   wire   [ 1:0]             PERIPHERAL_BRESP
     , input   wire                      PERIPHERAL_BVALID
     , output  wire                      PERIPHERAL_BREADY
     `ifdef AMBA_AXI_BUSER
     , input   wire   [WIDTH_BUSER-1:0]  PERIPHERAL_BUSER
     `endif
     , output  wire   [WIDTH_SID-1:0]    PERIPHERAL_ARID
     , output  wire   [WIDTH_AD-1:0]     PERIPHERAL_ARADDR
     , output  wire   [ 7:0]             PERIPHERAL_ARLEN
     , output  wire                      PERIPHERAL_ARLOCK
     , output  wire   [ 2:0]             PERIPHERAL_ARSIZE
     , output  wire   [ 1:0]             PERIPHERAL_ARBURST
     `ifdef  AMBA_AXI_CACHE
     , output  wire   [ 3:0]             PERIPHERAL_ARCACHE
     `endif
     `ifdef AMBA_AXI_PROT
     , output  wire   [ 2:0]             PERIPHERAL_ARPROT
     `endif
     , output  wire                      PERIPHERAL_ARVALID
     , input   wire                      PERIPHERAL_ARREADY
     `ifdef AMBA_QOS
     , output  wire   [ 3:0]             PERIPHERAL_ARQOS
     , output  wire   [ 3:0]             PERIPHERAL_ARREGION
     `endif
     `ifdef AMBA_AXI_ARUSER
     , output  wire   [WIDTH_ARUSER-1:0] PERIPHERAL_ARUSER
     `endif
     , input   wire   [WIDTH_SID-1:0]    PERIPHERAL_RID
     , input   wire   [WIDTH_DA-1:0]     PERIPHERAL_RDATA
     , input   wire   [ 1:0]             PERIPHERAL_RRESP
     , input   wire                      PERIPHERAL_RLAST
     , input   wire                      PERIPHERAL_RVALID
     , output  wire                      PERIPHERAL_RREADY
     `ifdef AMBA_AXI_RUSER
     , input   wire   [WIDTH_RUSER-1:0]  PERIPHERAL_RUSER
     `endif
);

    // Internal wires for interfaces crossing clock domains
    wire [WIDTH_ID-1:0] CPU_internal_AWID;
    wire [WIDTH_AD-1:0] CPU_internal_AWADDR;
    wire [ 7:0] CPU_internal_AWLEN;
    wire  CPU_internal_AWLOCK;
    wire [ 2:0] CPU_internal_AWSIZE;
    wire [ 1:0] CPU_internal_AWBURST;
     `ifdef  AMBA_AXI_CACHE
    wire [ 3:0] CPU_internal_AWCACHE;
     `endif
     `ifdef AMBA_AXI_PROT
    wire [ 2:0] CPU_internal_AWPROT;
     `endif
    wire  CPU_internal_AWVALID;
    wire  CPU_internal_AWREADY;
     `ifdef AMBA_QOS
    wire [ 3:0] CPU_internal_AWQOS;
    wire [ 3:0] CPU_internal_AWREGION;
     `endif
     `ifdef AMBA_AXI_AWUSER
    wire [WIDTH_AWUSER-1:0] CPU_internal_AWUSER;
     `endif
    wire [WIDTH_DA-1:0] CPU_internal_WDATA;
    wire [WIDTH_DS-1:0] CPU_internal_WSTRB;
    wire  CPU_internal_WLAST;
    wire  CPU_internal_WVALID;
    wire  CPU_internal_WREADY;
     `ifdef AMBA_AXI_WUSER
    wire [WIDTH_WUSER-1:0] CPU_internal_WUSER;
     `endif
    wire [WIDTH_ID-1:0] CPU_internal_BID;
    wire [ 1:0] CPU_internal_BRESP;
    wire  CPU_internal_BVALID;
    wire  CPU_internal_BREADY;
     `ifdef AMBA_AXI_BUSER
    wire [WIDTH_BUSER-1:0] CPU_internal_BUSER;
     `endif
    wire [WIDTH_ID-1:0] CPU_internal_ARID;
    wire [WIDTH_AD-1:0] CPU_internal_ARADDR;
    wire [ 7:0] CPU_internal_ARLEN;
    wire  CPU_internal_ARLOCK;
    wire [ 2:0] CPU_internal_ARSIZE;
    wire [ 1:0] CPU_internal_ARBURST;
     `ifdef  AMBA_AXI_CACHE
    wire [ 3:0] CPU_internal_ARCACHE;
     `endif
     `ifdef AMBA_AXI_PROT
    wire [ 2:0] CPU_internal_ARPROT;
     `endif
    wire  CPU_internal_ARVALID;
    wire  CPU_internal_ARREADY;
     `ifdef AMBA_QOS
    wire [ 3:0] CPU_internal_ARQOS;
    wire [ 3:0] CPU_internal_ARREGION;
     `endif
     `ifdef AMBA_AXI_ARUSER
    wire [WIDTH_ARUSER-1:0] CPU_internal_ARUSER;
     `endif
    wire [WIDTH_ID-1:0] CPU_internal_RID;
    wire [WIDTH_DA-1:0] CPU_internal_RDATA;
    wire [ 1:0] CPU_internal_RRESP;
    wire  CPU_internal_RLAST;
    wire  CPU_internal_RVALID;
    wire  CPU_internal_RREADY;
     `ifdef AMBA_AXI_RUSER
    wire [WIDTH_RUSER-1:0] CPU_internal_RUSER;
     `endif
    wire [WIDTH_ID-1:0] DMA_internal_AWID;
    wire [WIDTH_AD-1:0] DMA_internal_AWADDR;
    wire [ 7:0] DMA_internal_AWLEN;
    wire  DMA_internal_AWLOCK;
    wire [ 2:0] DMA_internal_AWSIZE;
    wire [ 1:0] DMA_internal_AWBURST;
     `ifdef  AMBA_AXI_CACHE
    wire [ 3:0] DMA_internal_AWCACHE;
     `endif
     `ifdef AMBA_AXI_PROT
    wire [ 2:0] DMA_internal_AWPROT;
     `endif
    wire  DMA_internal_AWVALID;
    wire  DMA_internal_AWREADY;
     `ifdef AMBA_QOS
    wire [ 3:0] DMA_internal_AWQOS;
    wire [ 3:0] DMA_internal_AWREGION;
     `endif
     `ifdef AMBA_AXI_AWUSER
    wire [WIDTH_AWUSER-1:0] DMA_internal_AWUSER;
     `endif
    wire [WIDTH_DA-1:0] DMA_internal_WDATA;
    wire [WIDTH_DS-1:0] DMA_internal_WSTRB;
    wire  DMA_internal_WLAST;
    wire  DMA_internal_WVALID;
    wire  DMA_internal_WREADY;
     `ifdef AMBA_AXI_WUSER
    wire [WIDTH_WUSER-1:0] DMA_internal_WUSER;
     `endif
    wire [WIDTH_ID-1:0] DMA_internal_BID;
    wire [ 1:0] DMA_internal_BRESP;
    wire  DMA_internal_BVALID;
    wire  DMA_internal_BREADY;
     `ifdef AMBA_AXI_BUSER
    wire [WIDTH_BUSER-1:0] DMA_internal_BUSER;
     `endif
    wire [WIDTH_ID-1:0] DMA_internal_ARID;
    wire [WIDTH_AD-1:0] DMA_internal_ARADDR;
    wire [ 7:0] DMA_internal_ARLEN;
    wire  DMA_internal_ARLOCK;
    wire [ 2:0] DMA_internal_ARSIZE;
    wire [ 1:0] DMA_internal_ARBURST;
     `ifdef  AMBA_AXI_CACHE
    wire [ 3:0] DMA_internal_ARCACHE;
     `endif
     `ifdef AMBA_AXI_PROT
    wire [ 2:0] DMA_internal_ARPROT;
     `endif
    wire  DMA_internal_ARVALID;
    wire  DMA_internal_ARREADY;
     `ifdef AMBA_QOS
    wire [ 3:0] DMA_internal_ARQOS;
    wire [ 3:0] DMA_internal_ARREGION;
     `endif
     `ifdef AMBA_AXI_ARUSER
    wire [WIDTH_ARUSER-1:0] DMA_internal_ARUSER;
     `endif
    wire [WIDTH_ID-1:0] DMA_internal_RID;
    wire [WIDTH_DA-1:0] DMA_internal_RDATA;
    wire [ 1:0] DMA_internal_RRESP;
    wire  DMA_internal_RLAST;
    wire  DMA_internal_RVALID;
    wire  DMA_internal_RREADY;
     `ifdef AMBA_AXI_RUSER
    wire [WIDTH_RUSER-1:0] DMA_internal_RUSER;
     `endif
    wire [WIDTH_SID-1:0] RAM_internal_AWID;
    wire [WIDTH_AD-1:0] RAM_internal_AWADDR;
    wire [ 7:0] RAM_internal_AWLEN;
    wire  RAM_internal_AWLOCK;
    wire [ 2:0] RAM_internal_AWSIZE;
    wire [ 1:0] RAM_internal_AWBURST;
     `ifdef  AMBA_AXI_CACHE
    wire [ 3:0] RAM_internal_AWCACHE;
     `endif
     `ifdef AMBA_AXI_PROT
    wire [ 2:0] RAM_internal_AWPROT;
     `endif
    wire  RAM_internal_AWVALID;
    wire  RAM_internal_AWREADY;
     `ifdef AMBA_QOS
    wire [ 3:0] RAM_internal_AWQOS;
    wire [ 3:0] RAM_internal_AWREGION;
     `endif
     `ifdef AMBA_AXI_AWUSER
    wire [WIDTH_AWUSER-1:0] RAM_internal_AWUSER;
     `endif
    wire [WIDTH_DA-1:0] RAM_internal_WDATA;
    wire [WIDTH_DS-1:0] RAM_internal_WSTRB;
    wire  RAM_internal_WLAST;
    wire  RAM_internal_WVALID;
    wire  RAM_internal_WREADY;
     `ifdef AMBA_AXI_WUSER
    wire [WIDTH_WUSER-1:0] RAM_internal_WUSER;
     `endif
    wire [WIDTH_SID-1:0] RAM_internal_BID;
    wire [ 1:0] RAM_internal_BRESP;
    wire  RAM_internal_BVALID;
    wire  RAM_internal_BREADY;
     `ifdef AMBA_AXI_BUSER
    wire [WIDTH_BUSER-1:0] RAM_internal_BUSER;
     `endif
    wire [WIDTH_SID-1:0] RAM_internal_ARID;
    wire [WIDTH_AD-1:0] RAM_internal_ARADDR;
    wire [ 7:0] RAM_internal_ARLEN;
    wire  RAM_internal_ARLOCK;
    wire [ 2:0] RAM_internal_ARSIZE;
    wire [ 1:0] RAM_internal_ARBURST;
     `ifdef  AMBA_AXI_CACHE
    wire [ 3:0] RAM_internal_ARCACHE;
     `endif
     `ifdef AMBA_AXI_PROT
    wire [ 2:0] RAM_internal_ARPROT;
     `endif
    wire  RAM_internal_ARVALID;
    wire  RAM_internal_ARREADY;
     `ifdef AMBA_QOS
    wire [ 3:0] RAM_internal_ARQOS;
    wire [ 3:0] RAM_internal_ARREGION;
     `endif
     `ifdef AMBA_AXI_ARUSER
    wire [WIDTH_ARUSER-1:0] RAM_internal_ARUSER;
     `endif
    wire [WIDTH_SID-1:0] RAM_internal_RID;
    wire [WIDTH_DA-1:0] RAM_internal_RDATA;
    wire [ 1:0] RAM_internal_RRESP;
    wire  RAM_internal_RLAST;
    wire  RAM_internal_RVALID;
    wire  RAM_internal_RREADY;
     `ifdef AMBA_AXI_RUSER
    wire [WIDTH_RUSER-1:0] RAM_internal_RUSER;
     `endif
    wire [WIDTH_SID-1:0] PERIPHERAL_internal_AWID;
    wire [WIDTH_AD-1:0] PERIPHERAL_internal_AWADDR;
    wire [ 7:0] PERIPHERAL_internal_AWLEN;
    wire  PERIPHERAL_internal_AWLOCK;
    wire [ 2:0] PERIPHERAL_internal_AWSIZE;
    wire [ 1:0] PERIPHERAL_internal_AWBURST;
     `ifdef  AMBA_AXI_CACHE
    wire [ 3:0] PERIPHERAL_internal_AWCACHE;
     `endif
     `ifdef AMBA_AXI_PROT
    wire [ 2:0] PERIPHERAL_internal_AWPROT;
     `endif
    wire  PERIPHERAL_internal_AWVALID;
    wire  PERIPHERAL_internal_AWREADY;
     `ifdef AMBA_QOS
    wire [ 3:0] PERIPHERAL_internal_AWQOS;
    wire [ 3:0] PERIPHERAL_internal_AWREGION;
     `endif
     `ifdef AMBA_AXI_AWUSER
    wire [WIDTH_AWUSER-1:0] PERIPHERAL_internal_AWUSER;
     `endif
    wire [WIDTH_DA-1:0] PERIPHERAL_internal_WDATA;
    wire [WIDTH_DS-1:0] PERIPHERAL_internal_WSTRB;
    wire  PERIPHERAL_internal_WLAST;
    wire  PERIPHERAL_internal_WVALID;
    wire  PERIPHERAL_internal_WREADY;
     `ifdef AMBA_AXI_WUSER
    wire [WIDTH_WUSER-1:0] PERIPHERAL_internal_WUSER;
     `endif
    wire [WIDTH_SID-1:0] PERIPHERAL_internal_BID;
    wire [ 1:0] PERIPHERAL_internal_BRESP;
    wire  PERIPHERAL_internal_BVALID;
    wire  PERIPHERAL_internal_BREADY;
     `ifdef AMBA_AXI_BUSER
    wire [WIDTH_BUSER-1:0] PERIPHERAL_internal_BUSER;
     `endif
    wire [WIDTH_SID-1:0] PERIPHERAL_internal_ARID;
    wire [WIDTH_AD-1:0] PERIPHERAL_internal_ARADDR;
    wire [ 7:0] PERIPHERAL_internal_ARLEN;
    wire  PERIPHERAL_internal_ARLOCK;
    wire [ 2:0] PERIPHERAL_internal_ARSIZE;
    wire [ 1:0] PERIPHERAL_internal_ARBURST;
     `ifdef  AMBA_AXI_CACHE
    wire [ 3:0] PERIPHERAL_internal_ARCACHE;
     `endif
     `ifdef AMBA_AXI_PROT
    wire [ 2:0] PERIPHERAL_internal_ARPROT;
     `endif
    wire  PERIPHERAL_internal_ARVALID;
    wire  PERIPHERAL_internal_ARREADY;
     `ifdef AMBA_QOS
    wire [ 3:0] PERIPHERAL_internal_ARQOS;
    wire [ 3:0] PERIPHERAL_internal_ARREGION;
     `endif
     `ifdef AMBA_AXI_ARUSER
    wire [WIDTH_ARUSER-1:0] PERIPHERAL_internal_ARUSER;
     `endif
    wire [WIDTH_SID-1:0] PERIPHERAL_internal_RID;
    wire [WIDTH_DA-1:0] PERIPHERAL_internal_RDATA;
    wire [ 1:0] PERIPHERAL_internal_RRESP;
    wire  PERIPHERAL_internal_RLAST;
    wire  PERIPHERAL_internal_RVALID;
    wire  PERIPHERAL_internal_RREADY;
     `ifdef AMBA_AXI_RUSER
    wire [WIDTH_RUSER-1:0] PERIPHERAL_internal_RUSER;
     `endif

    // CDC crossing for CPU clock domain (main_clk <-> nic_base_clk)
    axi_cdc_wrapper #(
        .ID_WIDTH(WIDTH_ID),
        .ADDR_WIDTH(WIDTH_AD),
        .DATA_WIDTH(WIDTH_DA),
        .STRB_WIDTH(WIDTH_DS),
        .USER_WIDTH(1)
    ) u_cdc_CPU (
        .src_clk(main_clk),
        .src_rst_n(main_clk_resetn),
        .dst_clk(nic_base_clk),
        .dst_rst_n(resetn)
      , .s_awid(CPU_AWID)
      , .m_awid(CPU_internal_AWID)
      , .s_awaddr(CPU_AWADDR)
      , .m_awaddr(CPU_internal_AWADDR)
      , .s_awlen(CPU_AWLEN)
      , .m_awlen(CPU_internal_AWLEN)
      , .s_awlock(CPU_AWLOCK)
      , .m_awlock(CPU_internal_AWLOCK)
      , .s_awsize(CPU_AWSIZE)
      , .m_awsize(CPU_internal_AWSIZE)
      , .s_awburst(CPU_AWBURST)
      , .m_awburst(CPU_internal_AWBURST)
     `ifdef  AMBA_AXI_CACHE
      , .s_awcache(CPU_AWCACHE)
      , .m_awcache(CPU_internal_AWCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
      , .s_awprot(CPU_AWPROT)
      , .m_awprot(CPU_internal_AWPROT)
     `endif
      , .s_awvalid(CPU_AWVALID)
      , .m_awvalid(CPU_internal_AWVALID)
      , .s_awready(CPU_AWREADY)
      , .m_awready(CPU_internal_AWREADY)
     `ifdef AMBA_QOS
      , .s_awqos(CPU_AWQOS)
      , .m_awqos(CPU_internal_AWQOS)
      , .s_awregion(CPU_AWREGION)
      , .m_awregion(CPU_internal_AWREGION)
     `endif
     `ifdef AMBA_AXI_AWUSER
      , .s_awuser(CPU_AWUSER)
      , .m_awuser(CPU_internal_AWUSER)
     `endif
      , .s_wdata(CPU_WDATA)
      , .m_wdata(CPU_internal_WDATA)
      , .s_wstrb(CPU_WSTRB)
      , .m_wstrb(CPU_internal_WSTRB)
      , .s_wlast(CPU_WLAST)
      , .m_wlast(CPU_internal_WLAST)
      , .s_wvalid(CPU_WVALID)
      , .m_wvalid(CPU_internal_WVALID)
      , .s_wready(CPU_WREADY)
      , .m_wready(CPU_internal_WREADY)
     `ifdef AMBA_AXI_WUSER
      , .s_wuser(CPU_WUSER)
      , .m_wuser(CPU_internal_WUSER)
     `endif
      , .s_bid(CPU_BID)
      , .m_bid(CPU_internal_BID)
      , .s_bresp(CPU_BRESP)
      , .m_bresp(CPU_internal_BRESP)
      , .s_bvalid(CPU_BVALID)
      , .m_bvalid(CPU_internal_BVALID)
      , .s_bready(CPU_BREADY)
      , .m_bready(CPU_internal_BREADY)
     `ifdef AMBA_AXI_BUSER
      , .s_buser(CPU_BUSER)
      , .m_buser(CPU_internal_BUSER)
     `endif
      , .s_arid(CPU_ARID)
      , .m_arid(CPU_internal_ARID)
      , .s_araddr(CPU_ARADDR)
      , .m_araddr(CPU_internal_ARADDR)
      , .s_arlen(CPU_ARLEN)
      , .m_arlen(CPU_internal_ARLEN)
      , .s_arlock(CPU_ARLOCK)
      , .m_arlock(CPU_internal_ARLOCK)
      , .s_arsize(CPU_ARSIZE)
      , .m_arsize(CPU_internal_ARSIZE)
      , .s_arburst(CPU_ARBURST)
      , .m_arburst(CPU_internal_ARBURST)
     `ifdef  AMBA_AXI_CACHE
      , .s_arcache(CPU_ARCACHE)
      , .m_arcache(CPU_internal_ARCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
      , .s_arprot(CPU_ARPROT)
      , .m_arprot(CPU_internal_ARPROT)
     `endif
      , .s_arvalid(CPU_ARVALID)
      , .m_arvalid(CPU_internal_ARVALID)
      , .s_arready(CPU_ARREADY)
      , .m_arready(CPU_internal_ARREADY)
     `ifdef AMBA_QOS
      , .s_arqos(CPU_ARQOS)
      , .m_arqos(CPU_internal_ARQOS)
      , .s_arregion(CPU_ARREGION)
      , .m_arregion(CPU_internal_ARREGION)
     `endif
     `ifdef AMBA_AXI_ARUSER
      , .s_aruser(CPU_ARUSER)
      , .m_aruser(CPU_internal_ARUSER)
     `endif
      , .s_rid(CPU_RID)
      , .m_rid(CPU_internal_RID)
      , .s_rdata(CPU_RDATA)
      , .m_rdata(CPU_internal_RDATA)
      , .s_rresp(CPU_RRESP)
      , .m_rresp(CPU_internal_RRESP)
      , .s_rlast(CPU_RLAST)
      , .m_rlast(CPU_internal_RLAST)
      , .s_rvalid(CPU_RVALID)
      , .m_rvalid(CPU_internal_RVALID)
      , .s_rready(CPU_RREADY)
      , .m_rready(CPU_internal_RREADY)
     `ifdef AMBA_AXI_RUSER
      , .s_ruser(CPU_RUSER)
      , .m_ruser(CPU_internal_RUSER)
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_AWUSER
     `endif
     `ifdef AMBA_AXI_WUSER
     `endif
     `ifdef AMBA_AXI_BUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_ARUSER
     `endif
     `ifdef AMBA_AXI_RUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_AWUSER
     `endif
     `ifdef AMBA_AXI_WUSER
     `endif
     `ifdef AMBA_AXI_BUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_ARUSER
     `endif
     `ifdef AMBA_AXI_RUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_AWUSER
     `endif
     `ifdef AMBA_AXI_WUSER
     `endif
     `ifdef AMBA_AXI_BUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_ARUSER
     `endif
     `ifdef AMBA_AXI_RUSER
     `endif
    );

    // CDC crossing for DMA clock domain (dma_clk <-> nic_base_clk)
    axi_cdc_wrapper #(
        .ID_WIDTH(WIDTH_ID),
        .ADDR_WIDTH(WIDTH_AD),
        .DATA_WIDTH(WIDTH_DA),
        .STRB_WIDTH(WIDTH_DS),
        .USER_WIDTH(1)
    ) u_cdc_DMA (
        .src_clk(dma_clk),
        .src_rst_n(dma_clk_resetn),
        .dst_clk(nic_base_clk),
        .dst_rst_n(resetn)
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_AWUSER
     `endif
     `ifdef AMBA_AXI_WUSER
     `endif
     `ifdef AMBA_AXI_BUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_ARUSER
     `endif
     `ifdef AMBA_AXI_RUSER
     `endif
      , .s_awid(DMA_AWID)
      , .m_awid(DMA_internal_AWID)
      , .s_awaddr(DMA_AWADDR)
      , .m_awaddr(DMA_internal_AWADDR)
      , .s_awlen(DMA_AWLEN)
      , .m_awlen(DMA_internal_AWLEN)
      , .s_awlock(DMA_AWLOCK)
      , .m_awlock(DMA_internal_AWLOCK)
      , .s_awsize(DMA_AWSIZE)
      , .m_awsize(DMA_internal_AWSIZE)
      , .s_awburst(DMA_AWBURST)
      , .m_awburst(DMA_internal_AWBURST)
     `ifdef  AMBA_AXI_CACHE
      , .s_awcache(DMA_AWCACHE)
      , .m_awcache(DMA_internal_AWCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
      , .s_awprot(DMA_AWPROT)
      , .m_awprot(DMA_internal_AWPROT)
     `endif
      , .s_awvalid(DMA_AWVALID)
      , .m_awvalid(DMA_internal_AWVALID)
      , .s_awready(DMA_AWREADY)
      , .m_awready(DMA_internal_AWREADY)
     `ifdef AMBA_QOS
      , .s_awqos(DMA_AWQOS)
      , .m_awqos(DMA_internal_AWQOS)
      , .s_awregion(DMA_AWREGION)
      , .m_awregion(DMA_internal_AWREGION)
     `endif
     `ifdef AMBA_AXI_AWUSER
      , .s_awuser(DMA_AWUSER)
      , .m_awuser(DMA_internal_AWUSER)
     `endif
      , .s_wdata(DMA_WDATA)
      , .m_wdata(DMA_internal_WDATA)
      , .s_wstrb(DMA_WSTRB)
      , .m_wstrb(DMA_internal_WSTRB)
      , .s_wlast(DMA_WLAST)
      , .m_wlast(DMA_internal_WLAST)
      , .s_wvalid(DMA_WVALID)
      , .m_wvalid(DMA_internal_WVALID)
      , .s_wready(DMA_WREADY)
      , .m_wready(DMA_internal_WREADY)
     `ifdef AMBA_AXI_WUSER
      , .s_wuser(DMA_WUSER)
      , .m_wuser(DMA_internal_WUSER)
     `endif
      , .s_bid(DMA_BID)
      , .m_bid(DMA_internal_BID)
      , .s_bresp(DMA_BRESP)
      , .m_bresp(DMA_internal_BRESP)
      , .s_bvalid(DMA_BVALID)
      , .m_bvalid(DMA_internal_BVALID)
      , .s_bready(DMA_BREADY)
      , .m_bready(DMA_internal_BREADY)
     `ifdef AMBA_AXI_BUSER
      , .s_buser(DMA_BUSER)
      , .m_buser(DMA_internal_BUSER)
     `endif
      , .s_arid(DMA_ARID)
      , .m_arid(DMA_internal_ARID)
      , .s_araddr(DMA_ARADDR)
      , .m_araddr(DMA_internal_ARADDR)
      , .s_arlen(DMA_ARLEN)
      , .m_arlen(DMA_internal_ARLEN)
      , .s_arlock(DMA_ARLOCK)
      , .m_arlock(DMA_internal_ARLOCK)
      , .s_arsize(DMA_ARSIZE)
      , .m_arsize(DMA_internal_ARSIZE)
      , .s_arburst(DMA_ARBURST)
      , .m_arburst(DMA_internal_ARBURST)
     `ifdef  AMBA_AXI_CACHE
      , .s_arcache(DMA_ARCACHE)
      , .m_arcache(DMA_internal_ARCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
      , .s_arprot(DMA_ARPROT)
      , .m_arprot(DMA_internal_ARPROT)
     `endif
      , .s_arvalid(DMA_ARVALID)
      , .m_arvalid(DMA_internal_ARVALID)
      , .s_arready(DMA_ARREADY)
      , .m_arready(DMA_internal_ARREADY)
     `ifdef AMBA_QOS
      , .s_arqos(DMA_ARQOS)
      , .m_arqos(DMA_internal_ARQOS)
      , .s_arregion(DMA_ARREGION)
      , .m_arregion(DMA_internal_ARREGION)
     `endif
     `ifdef AMBA_AXI_ARUSER
      , .s_aruser(DMA_ARUSER)
      , .m_aruser(DMA_internal_ARUSER)
     `endif
      , .s_rid(DMA_RID)
      , .m_rid(DMA_internal_RID)
      , .s_rdata(DMA_RDATA)
      , .m_rdata(DMA_internal_RDATA)
      , .s_rresp(DMA_RRESP)
      , .m_rresp(DMA_internal_RRESP)
      , .s_rlast(DMA_RLAST)
      , .m_rlast(DMA_internal_RLAST)
      , .s_rvalid(DMA_RVALID)
      , .m_rvalid(DMA_internal_RVALID)
      , .s_rready(DMA_RREADY)
      , .m_rready(DMA_internal_RREADY)
     `ifdef AMBA_AXI_RUSER
      , .s_ruser(DMA_RUSER)
      , .m_ruser(DMA_internal_RUSER)
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_AWUSER
     `endif
     `ifdef AMBA_AXI_WUSER
     `endif
     `ifdef AMBA_AXI_BUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_ARUSER
     `endif
     `ifdef AMBA_AXI_RUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_AWUSER
     `endif
     `ifdef AMBA_AXI_WUSER
     `endif
     `ifdef AMBA_AXI_BUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_ARUSER
     `endif
     `ifdef AMBA_AXI_RUSER
     `endif
    );

    // CDC crossing for RAM clock domain (main_clk <-> nic_base_clk)
    axi_cdc_wrapper #(
        .ID_WIDTH(WIDTH_SID),
        .ADDR_WIDTH(WIDTH_AD),
        .DATA_WIDTH(WIDTH_DA),
        .STRB_WIDTH(WIDTH_DS),
        .USER_WIDTH(1)
    ) u_cdc_RAM (
        .src_clk(nic_base_clk),
        .src_rst_n(resetn),
        .dst_clk(main_clk),
        .dst_rst_n(main_clk_resetn)
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_AWUSER
     `endif
     `ifdef AMBA_AXI_WUSER
     `endif
     `ifdef AMBA_AXI_BUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_ARUSER
     `endif
     `ifdef AMBA_AXI_RUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_AWUSER
     `endif
     `ifdef AMBA_AXI_WUSER
     `endif
     `ifdef AMBA_AXI_BUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_ARUSER
     `endif
     `ifdef AMBA_AXI_RUSER
     `endif
      , .s_awid(RAM_internal_AWID)
      , .m_awid(RAM_AWID)
      , .s_awaddr(RAM_internal_AWADDR)
      , .m_awaddr(RAM_AWADDR)
      , .s_awlen(RAM_internal_AWLEN)
      , .m_awlen(RAM_AWLEN)
      , .s_awlock(RAM_internal_AWLOCK)
      , .m_awlock(RAM_AWLOCK)
      , .s_awsize(RAM_internal_AWSIZE)
      , .m_awsize(RAM_AWSIZE)
      , .s_awburst(RAM_internal_AWBURST)
      , .m_awburst(RAM_AWBURST)
     `ifdef  AMBA_AXI_CACHE
      , .s_awcache(RAM_internal_AWCACHE)
      , .m_awcache(RAM_AWCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
      , .s_awprot(RAM_internal_AWPROT)
      , .m_awprot(RAM_AWPROT)
     `endif
      , .s_awvalid(RAM_internal_AWVALID)
      , .m_awvalid(RAM_AWVALID)
      , .s_awready(RAM_internal_AWREADY)
      , .m_awready(RAM_AWREADY)
     `ifdef AMBA_QOS
      , .s_awqos(RAM_internal_AWQOS)
      , .m_awqos(RAM_AWQOS)
      , .s_awregion(RAM_internal_AWREGION)
      , .m_awregion(RAM_AWREGION)
     `endif
     `ifdef AMBA_AXI_AWUSER
      , .s_awuser(RAM_internal_AWUSER)
      , .m_awuser(RAM_AWUSER)
     `endif
      , .s_wdata(RAM_internal_WDATA)
      , .m_wdata(RAM_WDATA)
      , .s_wstrb(RAM_internal_WSTRB)
      , .m_wstrb(RAM_WSTRB)
      , .s_wlast(RAM_internal_WLAST)
      , .m_wlast(RAM_WLAST)
      , .s_wvalid(RAM_internal_WVALID)
      , .m_wvalid(RAM_WVALID)
      , .s_wready(RAM_internal_WREADY)
      , .m_wready(RAM_WREADY)
     `ifdef AMBA_AXI_WUSER
      , .s_wuser(RAM_internal_WUSER)
      , .m_wuser(RAM_WUSER)
     `endif
      , .s_bid(RAM_internal_BID)
      , .m_bid(RAM_BID)
      , .s_bresp(RAM_internal_BRESP)
      , .m_bresp(RAM_BRESP)
      , .s_bvalid(RAM_internal_BVALID)
      , .m_bvalid(RAM_BVALID)
      , .s_bready(RAM_internal_BREADY)
      , .m_bready(RAM_BREADY)
     `ifdef AMBA_AXI_BUSER
      , .s_buser(RAM_internal_BUSER)
      , .m_buser(RAM_BUSER)
     `endif
      , .s_arid(RAM_internal_ARID)
      , .m_arid(RAM_ARID)
      , .s_araddr(RAM_internal_ARADDR)
      , .m_araddr(RAM_ARADDR)
      , .s_arlen(RAM_internal_ARLEN)
      , .m_arlen(RAM_ARLEN)
      , .s_arlock(RAM_internal_ARLOCK)
      , .m_arlock(RAM_ARLOCK)
      , .s_arsize(RAM_internal_ARSIZE)
      , .m_arsize(RAM_ARSIZE)
      , .s_arburst(RAM_internal_ARBURST)
      , .m_arburst(RAM_ARBURST)
     `ifdef  AMBA_AXI_CACHE
      , .s_arcache(RAM_internal_ARCACHE)
      , .m_arcache(RAM_ARCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
      , .s_arprot(RAM_internal_ARPROT)
      , .m_arprot(RAM_ARPROT)
     `endif
      , .s_arvalid(RAM_internal_ARVALID)
      , .m_arvalid(RAM_ARVALID)
      , .s_arready(RAM_internal_ARREADY)
      , .m_arready(RAM_ARREADY)
     `ifdef AMBA_QOS
      , .s_arqos(RAM_internal_ARQOS)
      , .m_arqos(RAM_ARQOS)
      , .s_arregion(RAM_internal_ARREGION)
      , .m_arregion(RAM_ARREGION)
     `endif
     `ifdef AMBA_AXI_ARUSER
      , .s_aruser(RAM_internal_ARUSER)
      , .m_aruser(RAM_ARUSER)
     `endif
      , .s_rid(RAM_internal_RID)
      , .m_rid(RAM_RID)
      , .s_rdata(RAM_internal_RDATA)
      , .m_rdata(RAM_RDATA)
      , .s_rresp(RAM_internal_RRESP)
      , .m_rresp(RAM_RRESP)
      , .s_rlast(RAM_internal_RLAST)
      , .m_rlast(RAM_RLAST)
      , .s_rvalid(RAM_internal_RVALID)
      , .m_rvalid(RAM_RVALID)
      , .s_rready(RAM_internal_RREADY)
      , .m_rready(RAM_RREADY)
     `ifdef AMBA_AXI_RUSER
      , .s_ruser(RAM_internal_RUSER)
      , .m_ruser(RAM_RUSER)
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_AWUSER
     `endif
     `ifdef AMBA_AXI_WUSER
     `endif
     `ifdef AMBA_AXI_BUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_ARUSER
     `endif
     `ifdef AMBA_AXI_RUSER
     `endif
    );

    // CDC crossing for PERIPHERAL clock domain (low_clk <-> nic_base_clk)
    axi_cdc_wrapper #(
        .ID_WIDTH(WIDTH_SID),
        .ADDR_WIDTH(WIDTH_AD),
        .DATA_WIDTH(WIDTH_DA),
        .STRB_WIDTH(WIDTH_DS),
        .USER_WIDTH(1)
    ) u_cdc_PERIPHERAL (
        .src_clk(nic_base_clk),
        .src_rst_n(resetn),
        .dst_clk(low_clk),
        .dst_rst_n(low_clk_resetn)
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_AWUSER
     `endif
     `ifdef AMBA_AXI_WUSER
     `endif
     `ifdef AMBA_AXI_BUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_ARUSER
     `endif
     `ifdef AMBA_AXI_RUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_AWUSER
     `endif
     `ifdef AMBA_AXI_WUSER
     `endif
     `ifdef AMBA_AXI_BUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_ARUSER
     `endif
     `ifdef AMBA_AXI_RUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_AWUSER
     `endif
     `ifdef AMBA_AXI_WUSER
     `endif
     `ifdef AMBA_AXI_BUSER
     `endif
     `ifdef  AMBA_AXI_CACHE
     `endif
     `ifdef AMBA_AXI_PROT
     `endif
     `ifdef AMBA_QOS
     `endif
     `ifdef AMBA_AXI_ARUSER
     `endif
     `ifdef AMBA_AXI_RUSER
     `endif
      , .s_awid(PERIPHERAL_internal_AWID)
      , .m_awid(PERIPHERAL_AWID)
      , .s_awaddr(PERIPHERAL_internal_AWADDR)
      , .m_awaddr(PERIPHERAL_AWADDR)
      , .s_awlen(PERIPHERAL_internal_AWLEN)
      , .m_awlen(PERIPHERAL_AWLEN)
      , .s_awlock(PERIPHERAL_internal_AWLOCK)
      , .m_awlock(PERIPHERAL_AWLOCK)
      , .s_awsize(PERIPHERAL_internal_AWSIZE)
      , .m_awsize(PERIPHERAL_AWSIZE)
      , .s_awburst(PERIPHERAL_internal_AWBURST)
      , .m_awburst(PERIPHERAL_AWBURST)
     `ifdef  AMBA_AXI_CACHE
      , .s_awcache(PERIPHERAL_internal_AWCACHE)
      , .m_awcache(PERIPHERAL_AWCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
      , .s_awprot(PERIPHERAL_internal_AWPROT)
      , .m_awprot(PERIPHERAL_AWPROT)
     `endif
      , .s_awvalid(PERIPHERAL_internal_AWVALID)
      , .m_awvalid(PERIPHERAL_AWVALID)
      , .s_awready(PERIPHERAL_internal_AWREADY)
      , .m_awready(PERIPHERAL_AWREADY)
     `ifdef AMBA_QOS
      , .s_awqos(PERIPHERAL_internal_AWQOS)
      , .m_awqos(PERIPHERAL_AWQOS)
      , .s_awregion(PERIPHERAL_internal_AWREGION)
      , .m_awregion(PERIPHERAL_AWREGION)
     `endif
     `ifdef AMBA_AXI_AWUSER
      , .s_awuser(PERIPHERAL_internal_AWUSER)
      , .m_awuser(PERIPHERAL_AWUSER)
     `endif
      , .s_wdata(PERIPHERAL_internal_WDATA)
      , .m_wdata(PERIPHERAL_WDATA)
      , .s_wstrb(PERIPHERAL_internal_WSTRB)
      , .m_wstrb(PERIPHERAL_WSTRB)
      , .s_wlast(PERIPHERAL_internal_WLAST)
      , .m_wlast(PERIPHERAL_WLAST)
      , .s_wvalid(PERIPHERAL_internal_WVALID)
      , .m_wvalid(PERIPHERAL_WVALID)
      , .s_wready(PERIPHERAL_internal_WREADY)
      , .m_wready(PERIPHERAL_WREADY)
     `ifdef AMBA_AXI_WUSER
      , .s_wuser(PERIPHERAL_internal_WUSER)
      , .m_wuser(PERIPHERAL_WUSER)
     `endif
      , .s_bid(PERIPHERAL_internal_BID)
      , .m_bid(PERIPHERAL_BID)
      , .s_bresp(PERIPHERAL_internal_BRESP)
      , .m_bresp(PERIPHERAL_BRESP)
      , .s_bvalid(PERIPHERAL_internal_BVALID)
      , .m_bvalid(PERIPHERAL_BVALID)
      , .s_bready(PERIPHERAL_internal_BREADY)
      , .m_bready(PERIPHERAL_BREADY)
     `ifdef AMBA_AXI_BUSER
      , .s_buser(PERIPHERAL_internal_BUSER)
      , .m_buser(PERIPHERAL_BUSER)
     `endif
      , .s_arid(PERIPHERAL_internal_ARID)
      , .m_arid(PERIPHERAL_ARID)
      , .s_araddr(PERIPHERAL_internal_ARADDR)
      , .m_araddr(PERIPHERAL_ARADDR)
      , .s_arlen(PERIPHERAL_internal_ARLEN)
      , .m_arlen(PERIPHERAL_ARLEN)
      , .s_arlock(PERIPHERAL_internal_ARLOCK)
      , .m_arlock(PERIPHERAL_ARLOCK)
      , .s_arsize(PERIPHERAL_internal_ARSIZE)
      , .m_arsize(PERIPHERAL_ARSIZE)
      , .s_arburst(PERIPHERAL_internal_ARBURST)
      , .m_arburst(PERIPHERAL_ARBURST)
     `ifdef  AMBA_AXI_CACHE
      , .s_arcache(PERIPHERAL_internal_ARCACHE)
      , .m_arcache(PERIPHERAL_ARCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
      , .s_arprot(PERIPHERAL_internal_ARPROT)
      , .m_arprot(PERIPHERAL_ARPROT)
     `endif
      , .s_arvalid(PERIPHERAL_internal_ARVALID)
      , .m_arvalid(PERIPHERAL_ARVALID)
      , .s_arready(PERIPHERAL_internal_ARREADY)
      , .m_arready(PERIPHERAL_ARREADY)
     `ifdef AMBA_QOS
      , .s_arqos(PERIPHERAL_internal_ARQOS)
      , .m_arqos(PERIPHERAL_ARQOS)
      , .s_arregion(PERIPHERAL_internal_ARREGION)
      , .m_arregion(PERIPHERAL_ARREGION)
     `endif
     `ifdef AMBA_AXI_ARUSER
      , .s_aruser(PERIPHERAL_internal_ARUSER)
      , .m_aruser(PERIPHERAL_ARUSER)
     `endif
      , .s_rid(PERIPHERAL_internal_RID)
      , .m_rid(PERIPHERAL_RID)
      , .s_rdata(PERIPHERAL_internal_RDATA)
      , .m_rdata(PERIPHERAL_RDATA)
      , .s_rresp(PERIPHERAL_internal_RRESP)
      , .m_rresp(PERIPHERAL_RRESP)
      , .s_rlast(PERIPHERAL_internal_RLAST)
      , .m_rlast(PERIPHERAL_RLAST)
      , .s_rvalid(PERIPHERAL_internal_RVALID)
      , .m_rvalid(PERIPHERAL_RVALID)
      , .s_rready(PERIPHERAL_internal_RREADY)
      , .m_rready(PERIPHERAL_RREADY)
     `ifdef AMBA_AXI_RUSER
      , .s_ruser(PERIPHERAL_internal_RUSER)
      , .m_ruser(PERIPHERAL_RUSER)
     `endif
    );


    // Instantiate the base interconnect
    amba_axi_m2s2 #(
        .WIDTH_CID(WIDTH_CID),
        .WIDTH_ID(WIDTH_ID),
        .WIDTH_AD(WIDTH_AD),
        .WIDTH_DA(WIDTH_DA),
        .WIDTH_DS(WIDTH_DS),
        .WIDTH_SID(WIDTH_SID),
        .SLAVE_EN0(1),
        .ADDR_BASE0(RAM_BASE),
        .ADDR_LENGTH0(RAM_LENGTH),
        .SLAVE_EN1(1),
        .ADDR_BASE1(PERIPHERAL_BASE),
        .ADDR_LENGTH1(PERIPHERAL_LENGTH)
    ) u_interconnect (
       .ARESETn(resetn)
     , .ACLK(nic_base_clk)
     //--------------------------------------------------------------
     , .M0_AWID(CPU_internal_AWID)
     , .M0_AWADDR(CPU_internal_AWADDR)
     , .M0_AWLEN(CPU_internal_AWLEN)
     , .M0_AWLOCK(CPU_internal_AWLOCK)
     , .M0_AWSIZE(CPU_internal_AWSIZE)
     , .M0_AWBURST(CPU_internal_AWBURST)
     `ifdef  AMBA_AXI_CACHE
     , .M0_AWCACHE(CPU_internal_AWCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
     , .M0_AWPROT(CPU_internal_AWPROT)
     `endif
     , .M0_AWVALID(CPU_internal_AWVALID)
     , .M0_AWREADY(CPU_internal_AWREADY)
     `ifdef AMBA_QOS
     , .M0_AWQOS(CPU_internal_AWQOS)
     , .M0_AWREGION(CPU_internal_AWREGION)
     `endif
     `ifdef AMBA_AXI_AWUSER
     , .M0_AWUSER(CPU_internal_AWUSER)
     `endif
     , .M0_WDATA(CPU_internal_WDATA)
     , .M0_WSTRB(CPU_internal_WSTRB)
     , .M0_WLAST(CPU_internal_WLAST)
     , .M0_WVALID(CPU_internal_WVALID)
     , .M0_WREADY(CPU_internal_WREADY)
     `ifdef AMBA_AXI_WUSER
     , .M0_WUSER(CPU_internal_WUSER)
     `endif
     , .M0_BID(CPU_internal_BID)
     , .M0_BRESP(CPU_internal_BRESP)
     , .M0_BVALID(CPU_internal_BVALID)
     , .M0_BREADY(CPU_internal_BREADY)
     `ifdef AMBA_AXI_BUSER
     , .M0_BUSER(CPU_internal_BUSER)
     `endif
     , .M0_ARID(CPU_internal_ARID)
     , .M0_ARADDR(CPU_internal_ARADDR)
     , .M0_ARLEN(CPU_internal_ARLEN)
     , .M0_ARLOCK(CPU_internal_ARLOCK)
     , .M0_ARSIZE(CPU_internal_ARSIZE)
     , .M0_ARBURST(CPU_internal_ARBURST)
     `ifdef  AMBA_AXI_CACHE
     , .M0_ARCACHE(CPU_internal_ARCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
     , .M0_ARPROT(CPU_internal_ARPROT)
     `endif
     , .M0_ARVALID(CPU_internal_ARVALID)
     , .M0_ARREADY(CPU_internal_ARREADY)
     `ifdef AMBA_QOS
     , .M0_ARQOS(CPU_internal_ARQOS)
     , .M0_ARREGION(CPU_internal_ARREGION)
     `endif
     `ifdef AMBA_AXI_ARUSER
     , .M0_ARUSER(CPU_internal_ARUSER)
     `endif
     , .M0_RID(CPU_internal_RID)
     , .M0_RDATA(CPU_internal_RDATA)
     , .M0_RRESP(CPU_internal_RRESP)
     , .M0_RLAST(CPU_internal_RLAST)
     , .M0_RVALID(CPU_internal_RVALID)
     , .M0_RREADY(CPU_internal_RREADY)
     `ifdef AMBA_AXI_RUSER
     , .M0_RUSER(CPU_internal_RUSER)
     `endif
     //--------------------------------------------------------------
     , .M1_AWID(DMA_internal_AWID)
     , .M1_AWADDR(DMA_internal_AWADDR)
     , .M1_AWLEN(DMA_internal_AWLEN)
     , .M1_AWLOCK(DMA_internal_AWLOCK)
     , .M1_AWSIZE(DMA_internal_AWSIZE)
     , .M1_AWBURST(DMA_internal_AWBURST)
     `ifdef  AMBA_AXI_CACHE
     , .M1_AWCACHE(DMA_internal_AWCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
     , .M1_AWPROT(DMA_internal_AWPROT)
     `endif
     , .M1_AWVALID(DMA_internal_AWVALID)
     , .M1_AWREADY(DMA_internal_AWREADY)
     `ifdef AMBA_QOS
     , .M1_AWQOS(DMA_internal_AWQOS)
     , .M1_AWREGION(DMA_internal_AWREGION)
     `endif
     `ifdef AMBA_AXI_AWUSER
     , .M1_AWUSER(DMA_internal_AWUSER)
     `endif
     , .M1_WDATA(DMA_internal_WDATA)
     , .M1_WSTRB(DMA_internal_WSTRB)
     , .M1_WLAST(DMA_internal_WLAST)
     , .M1_WVALID(DMA_internal_WVALID)
     , .M1_WREADY(DMA_internal_WREADY)
     `ifdef AMBA_AXI_WUSER
     , .M1_WUSER(DMA_internal_WUSER)
     `endif
     , .M1_BID(DMA_internal_BID)
     , .M1_BRESP(DMA_internal_BRESP)
     , .M1_BVALID(DMA_internal_BVALID)
     , .M1_BREADY(DMA_internal_BREADY)
     `ifdef AMBA_AXI_BUSER
     , .M1_BUSER(DMA_internal_BUSER)
     `endif
     , .M1_ARID(DMA_internal_ARID)
     , .M1_ARADDR(DMA_internal_ARADDR)
     , .M1_ARLEN(DMA_internal_ARLEN)
     , .M1_ARLOCK(DMA_internal_ARLOCK)
     , .M1_ARSIZE(DMA_internal_ARSIZE)
     , .M1_ARBURST(DMA_internal_ARBURST)
     `ifdef  AMBA_AXI_CACHE
     , .M1_ARCACHE(DMA_internal_ARCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
     , .M1_ARPROT(DMA_internal_ARPROT)
     `endif
     , .M1_ARVALID(DMA_internal_ARVALID)
     , .M1_ARREADY(DMA_internal_ARREADY)
     `ifdef AMBA_QOS
     , .M1_ARQOS(DMA_internal_ARQOS)
     , .M1_ARREGION(DMA_internal_ARREGION)
     `endif
     `ifdef AMBA_AXI_ARUSER
     , .M1_ARUSER(DMA_internal_ARUSER)
     `endif
     , .M1_RID(DMA_internal_RID)
     , .M1_RDATA(DMA_internal_RDATA)
     , .M1_RRESP(DMA_internal_RRESP)
     , .M1_RLAST(DMA_internal_RLAST)
     , .M1_RVALID(DMA_internal_RVALID)
     , .M1_RREADY(DMA_internal_RREADY)
     `ifdef AMBA_AXI_RUSER
     , .M1_RUSER(DMA_internal_RUSER)
     `endif
     //--------------------------------------------------------------
     , .S0_AWID(RAM_internal_AWID)
     , .S0_AWADDR(RAM_internal_AWADDR)
     , .S0_AWLEN(RAM_internal_AWLEN)
     , .S0_AWLOCK(RAM_internal_AWLOCK)
     , .S0_AWSIZE(RAM_internal_AWSIZE)
     , .S0_AWBURST(RAM_internal_AWBURST)
     `ifdef  AMBA_AXI_CACHE
     , .S0_AWCACHE(RAM_internal_AWCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
     , .S0_AWPROT(RAM_internal_AWPROT)
     `endif
     , .S0_AWVALID(RAM_internal_AWVALID)
     , .S0_AWREADY(RAM_internal_AWREADY)
     `ifdef AMBA_QOS
     , .S0_AWQOS(RAM_internal_AWQOS)
     , .S0_AWREGION(RAM_internal_AWREGION)
     `endif
     `ifdef AMBA_AXI_AWUSER
     , .S0_AWUSER(RAM_internal_AWUSER)
     `endif
     , .S0_WDATA(RAM_internal_WDATA)
     , .S0_WSTRB(RAM_internal_WSTRB)
     , .S0_WLAST(RAM_internal_WLAST)
     , .S0_WVALID(RAM_internal_WVALID)
     , .S0_WREADY(RAM_internal_WREADY)
     `ifdef AMBA_AXI_WUSER
     , .S0_WUSER(RAM_internal_WUSER)
     `endif
     , .S0_BID(RAM_internal_BID)
     , .S0_BRESP(RAM_internal_BRESP)
     , .S0_BVALID(RAM_internal_BVALID)
     , .S0_BREADY(RAM_internal_BREADY)
     `ifdef AMBA_AXI_BUSER
     , .S0_BUSER(RAM_internal_BUSER)
     `endif
     , .S0_ARID(RAM_internal_ARID)
     , .S0_ARADDR(RAM_internal_ARADDR)
     , .S0_ARLEN(RAM_internal_ARLEN)
     , .S0_ARLOCK(RAM_internal_ARLOCK)
     , .S0_ARSIZE(RAM_internal_ARSIZE)
     , .S0_ARBURST(RAM_internal_ARBURST)
     `ifdef  AMBA_AXI_CACHE
     , .S0_ARCACHE(RAM_internal_ARCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
     , .S0_ARPROT(RAM_internal_ARPROT)
     `endif
     , .S0_ARVALID(RAM_internal_ARVALID)
     , .S0_ARREADY(RAM_internal_ARREADY)
     `ifdef AMBA_QOS
     , .S0_ARQOS(RAM_internal_ARQOS)
     , .S0_ARREGION(RAM_internal_ARREGION)
     `endif
     `ifdef AMBA_AXI_ARUSER
     , .S0_ARUSER(RAM_internal_ARUSER)
     `endif
     , .S0_RID(RAM_internal_RID)
     , .S0_RDATA(RAM_internal_RDATA)
     , .S0_RRESP(RAM_internal_RRESP)
     , .S0_RLAST(RAM_internal_RLAST)
     , .S0_RVALID(RAM_internal_RVALID)
     , .S0_RREADY(RAM_internal_RREADY)
     `ifdef AMBA_AXI_RUSER
     , .S0_RUSER(RAM_internal_RUSER)
     `endif
     //--------------------------------------------------------------
     , .S1_AWID(PERIPHERAL_internal_AWID)
     , .S1_AWADDR(PERIPHERAL_internal_AWADDR)
     , .S1_AWLEN(PERIPHERAL_internal_AWLEN)
     , .S1_AWLOCK(PERIPHERAL_internal_AWLOCK)
     , .S1_AWSIZE(PERIPHERAL_internal_AWSIZE)
     , .S1_AWBURST(PERIPHERAL_internal_AWBURST)
     `ifdef  AMBA_AXI_CACHE
     , .S1_AWCACHE(PERIPHERAL_internal_AWCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
     , .S1_AWPROT(PERIPHERAL_internal_AWPROT)
     `endif
     , .S1_AWVALID(PERIPHERAL_internal_AWVALID)
     , .S1_AWREADY(PERIPHERAL_internal_AWREADY)
     `ifdef AMBA_QOS
     , .S1_AWQOS(PERIPHERAL_internal_AWQOS)
     , .S1_AWREGION(PERIPHERAL_internal_AWREGION)
     `endif
     `ifdef AMBA_AXI_AWUSER
     , .S1_AWUSER(PERIPHERAL_internal_AWUSER)
     `endif
     , .S1_WDATA(PERIPHERAL_internal_WDATA)
     , .S1_WSTRB(PERIPHERAL_internal_WSTRB)
     , .S1_WLAST(PERIPHERAL_internal_WLAST)
     , .S1_WVALID(PERIPHERAL_internal_WVALID)
     , .S1_WREADY(PERIPHERAL_internal_WREADY)
     `ifdef AMBA_AXI_WUSER
     , .S1_WUSER(PERIPHERAL_internal_WUSER)
     `endif
     , .S1_BID(PERIPHERAL_internal_BID)
     , .S1_BRESP(PERIPHERAL_internal_BRESP)
     , .S1_BVALID(PERIPHERAL_internal_BVALID)
     , .S1_BREADY(PERIPHERAL_internal_BREADY)
     `ifdef AMBA_AXI_BUSER
     , .S1_BUSER(PERIPHERAL_internal_BUSER)
     `endif
     , .S1_ARID(PERIPHERAL_internal_ARID)
     , .S1_ARADDR(PERIPHERAL_internal_ARADDR)
     , .S1_ARLEN(PERIPHERAL_internal_ARLEN)
     , .S1_ARLOCK(PERIPHERAL_internal_ARLOCK)
     , .S1_ARSIZE(PERIPHERAL_internal_ARSIZE)
     , .S1_ARBURST(PERIPHERAL_internal_ARBURST)
     `ifdef  AMBA_AXI_CACHE
     , .S1_ARCACHE(PERIPHERAL_internal_ARCACHE)
     `endif
     `ifdef AMBA_AXI_PROT
     , .S1_ARPROT(PERIPHERAL_internal_ARPROT)
     `endif
     , .S1_ARVALID(PERIPHERAL_internal_ARVALID)
     , .S1_ARREADY(PERIPHERAL_internal_ARREADY)
     `ifdef AMBA_QOS
     , .S1_ARQOS(PERIPHERAL_internal_ARQOS)
     , .S1_ARREGION(PERIPHERAL_internal_ARREGION)
     `endif
     `ifdef AMBA_AXI_ARUSER
     , .S1_ARUSER(PERIPHERAL_internal_ARUSER)
     `endif
     , .S1_RID(PERIPHERAL_internal_RID)
     , .S1_RDATA(PERIPHERAL_internal_RDATA)
     , .S1_RRESP(PERIPHERAL_internal_RRESP)
     , .S1_RLAST(PERIPHERAL_internal_RLAST)
     , .S1_RVALID(PERIPHERAL_internal_RVALID)
     , .S1_RREADY(PERIPHERAL_internal_RREADY)
     `ifdef AMBA_AXI_RUSER
     , .S1_RUSER(PERIPHERAL_internal_RUSER)
     `endif
    );

endmodule
