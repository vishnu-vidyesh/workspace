// ==============================================================================
// AXI Clock Domain Crossing Module
// ==============================================================================
// This module converts AXI signals from one clock domain to another clock domain
// Uses modules from: https://github.com/pulp-platform/axi.git
//
// Features:
// - Gray-coded FIFO-based CDC for all 5 AXI channels (AW, W, B, AR, R)
// - Parameterizable FIFO depth and synchronizer stages
// - Supports full AXI4 protocol
// - Independent clock domains for master and slave sides
// ==============================================================================

`include "axi/assign.svh"
`include "axi/typedef.svh"

module axi_cdc #(
    // AXI Bus Parameters
    parameter int unsigned AXI_ADDR_WIDTH = 32,
    parameter int unsigned AXI_DATA_WIDTH = 64,
    parameter int unsigned AXI_ID_WIDTH   = 4,
    parameter int unsigned AXI_USER_WIDTH = 1,
    
    // CDC Parameters
    parameter int unsigned LOG_DEPTH   = 2,  // FIFO depth = 2^LOG_DEPTH
    parameter int unsigned SYNC_STAGES = 2   // Number of synchronization stages
) (
    // Master Clock Domain (Source side - receives requests)
    input  logic master_clk,
    input  logic master_reset,  // Active high
    
    // Slave Clock Domain (Destination side - forwards requests)
    input  logic slave_clk,
    input  logic slave_reset,   // Active high
    
    // =========================================================================
    // AXI Master Interface (in master_clk domain)
    // =========================================================================
    // Write Address Channel
    input  logic [AXI_ID_WIDTH-1:0]     m_axi_awid,
    input  logic [AXI_ADDR_WIDTH-1:0]   m_axi_awaddr,
    input  logic [7:0]                  m_axi_awlen,
    input  logic [2:0]                  m_axi_awsize,
    input  logic [1:0]                  m_axi_awburst,
    input  logic                        m_axi_awlock,
    input  logic [3:0]                  m_axi_awcache,
    input  logic [2:0]                  m_axi_awprot,
    input  logic [3:0]                  m_axi_awqos,
    input  logic [3:0]                  m_axi_awregion,
    input  logic [5:0]                  m_axi_awatop,
    input  logic [AXI_USER_WIDTH-1:0]   m_axi_awuser,
    input  logic                        m_axi_awvalid,
    output logic                        m_axi_awready,
    
    // Write Data Channel
    input  logic [AXI_DATA_WIDTH-1:0]   m_axi_wdata,
    input  logic [AXI_DATA_WIDTH/8-1:0] m_axi_wstrb,
    input  logic                        m_axi_wlast,
    input  logic [AXI_USER_WIDTH-1:0]   m_axi_wuser,
    input  logic                        m_axi_wvalid,
    output logic                        m_axi_wready,
    
    // Write Response Channel
    output logic [AXI_ID_WIDTH-1:0]     m_axi_bid,
    output logic [1:0]                  m_axi_bresp,
    output logic [AXI_USER_WIDTH-1:0]   m_axi_buser,
    output logic                        m_axi_bvalid,
    input  logic                        m_axi_bready,
    
    // Read Address Channel
    input  logic [AXI_ID_WIDTH-1:0]     m_axi_arid,
    input  logic [AXI_ADDR_WIDTH-1:0]   m_axi_araddr,
    input  logic [7:0]                  m_axi_arlen,
    input  logic [2:0]                  m_axi_arsize,
    input  logic [1:0]                  m_axi_arburst,
    input  logic                        m_axi_arlock,
    input  logic [3:0]                  m_axi_arcache,
    input  logic [2:0]                  m_axi_arprot,
    input  logic [3:0]                  m_axi_arqos,
    input  logic [3:0]                  m_axi_arregion,
    input  logic [AXI_USER_WIDTH-1:0]   m_axi_aruser,
    input  logic                        m_axi_arvalid,
    output logic                        m_axi_arready,
    
    // Read Data Channel
    output logic [AXI_ID_WIDTH-1:0]     m_axi_rid,
    output logic [AXI_DATA_WIDTH-1:0]   m_axi_rdata,
    output logic [1:0]                  m_axi_rresp,
    output logic                        m_axi_rlast,
    output logic [AXI_USER_WIDTH-1:0]   m_axi_ruser,
    output logic                        m_axi_rvalid,
    input  logic                        m_axi_rready,
    
    // =========================================================================
    // AXI Slave Interface (in slave_clk domain)
    // =========================================================================
    // Write Address Channel
    output logic [AXI_ID_WIDTH-1:0]     s_axi_awid,
    output logic [AXI_ADDR_WIDTH-1:0]   s_axi_awaddr,
    output logic [7:0]                  s_axi_awlen,
    output logic [2:0]                  s_axi_awsize,
    output logic [1:0]                  s_axi_awburst,
    output logic                        s_axi_awlock,
    output logic [3:0]                  s_axi_awcache,
    output logic [2:0]                  s_axi_awprot,
    output logic [3:0]                  s_axi_awqos,
    output logic [3:0]                  s_axi_awregion,
    output logic [5:0]                  s_axi_awatop,
    output logic [AXI_USER_WIDTH-1:0]   s_axi_awuser,
    output logic                        s_axi_awvalid,
    input  logic                        s_axi_awready,
    
    // Write Data Channel
    output logic [AXI_DATA_WIDTH-1:0]   s_axi_wdata,
    output logic [AXI_DATA_WIDTH/8-1:0] s_axi_wstrb,
    output logic                        s_axi_wlast,
    output logic [AXI_USER_WIDTH-1:0]   s_axi_wuser,
    output logic                        s_axi_wvalid,
    input  logic                        s_axi_wready,
    
    // Write Response Channel
    input  logic [AXI_ID_WIDTH-1:0]     s_axi_bid,
    input  logic [1:0]                  s_axi_bresp,
    input  logic [AXI_USER_WIDTH-1:0]   s_axi_buser,
    input  logic                        s_axi_bvalid,
    output logic                        s_axi_bready,
    
    // Read Address Channel
    output logic [AXI_ID_WIDTH-1:0]     s_axi_arid,
    output logic [AXI_ADDR_WIDTH-1:0]   s_axi_araddr,
    output logic [7:0]                  s_axi_arlen,
    output logic [2:0]                  s_axi_arsize,
    output logic [1:0]                  s_axi_arburst,
    output logic                        s_axi_arlock,
    output logic [3:0]                  s_axi_arcache,
    output logic [2:0]                  s_axi_arprot,
    output logic [3:0]                  s_axi_arqos,
    output logic [3:0]                  s_axi_arregion,
    output logic [AXI_USER_WIDTH-1:0]   s_axi_aruser,
    output logic                        s_axi_arvalid,
    input  logic                        s_axi_arready,
    
    // Read Data Channel
    input  logic [AXI_ID_WIDTH-1:0]     s_axi_rid,
    input  logic [AXI_DATA_WIDTH-1:0]   s_axi_rdata,
    input  logic [1:0]                  s_axi_rresp,
    input  logic                        s_axi_rlast,
    input  logic [AXI_USER_WIDTH-1:0]   s_axi_ruser,
    input  logic                        s_axi_rvalid,
    output logic                        s_axi_rready
);

    // ===========================================================================
    // Type Definitions for PULP AXI CDC Module
    // ===========================================================================
    typedef logic [AXI_ID_WIDTH-1:0]     id_t;
    typedef logic [AXI_ADDR_WIDTH-1:0]   addr_t;
    typedef logic [AXI_DATA_WIDTH-1:0]   data_t;
    typedef logic [AXI_DATA_WIDTH/8-1:0] strb_t;
    typedef logic [AXI_USER_WIDTH-1:0]   user_t;
    
    // Define channel types using AXI typedef macros
    `AXI_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t, id_t, user_t)
    `AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)
    `AXI_TYPEDEF_B_CHAN_T(b_chan_t, id_t, user_t)
    `AXI_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t, id_t, user_t)
    `AXI_TYPEDEF_R_CHAN_T(r_chan_t, data_t, id_t, user_t)
    
    // Define request and response types
    `AXI_TYPEDEF_REQ_T(axi_req_t, aw_chan_t, w_chan_t, ar_chan_t)
    `AXI_TYPEDEF_RESP_T(axi_resp_t, b_chan_t, r_chan_t)
    
    // ===========================================================================
    // Internal Signals - Request and Response Structs
    // ===========================================================================
    axi_req_t  src_req;
    axi_resp_t src_resp;
    axi_req_t  dst_req;
    axi_resp_t dst_resp;
    
    // Reset polarity conversion (input is active high, PULP uses active low)
    logic master_rst_n;
    logic slave_rst_n;
    
    assign master_rst_n = ~master_reset;
    assign slave_rst_n  = ~slave_reset;
    
    // ===========================================================================
    // Pack Master Interface Signals into Request/Response Structs
    // ===========================================================================
    
    // Pack Write Address Channel
    assign src_req.aw.id      = m_axi_awid;
    assign src_req.aw.addr    = m_axi_awaddr;
    assign src_req.aw.len     = m_axi_awlen;
    assign src_req.aw.size    = m_axi_awsize;
    assign src_req.aw.burst   = axi_pkg::burst_t'(m_axi_awburst);
    assign src_req.aw.lock    = m_axi_awlock;
    assign src_req.aw.cache   = axi_pkg::cache_t'(m_axi_awcache);
    assign src_req.aw.prot    = axi_pkg::prot_t'(m_axi_awprot);
    assign src_req.aw.qos     = axi_pkg::qos_t'(m_axi_awqos);
    assign src_req.aw.region  = axi_pkg::region_t'(m_axi_awregion);
    assign src_req.aw.atop    = axi_pkg::atop_t'(m_axi_awatop);
    assign src_req.aw.user    = m_axi_awuser;
    assign src_req.aw_valid   = m_axi_awvalid;
    assign m_axi_awready      = src_resp.aw_ready;
    
    // Pack Write Data Channel
    assign src_req.w.data     = m_axi_wdata;
    assign src_req.w.strb     = m_axi_wstrb;
    assign src_req.w.last     = m_axi_wlast;
    assign src_req.w.user     = m_axi_wuser;
    assign src_req.w_valid    = m_axi_wvalid;
    assign m_axi_wready       = src_resp.w_ready;
    
    // Unpack Write Response Channel
    assign m_axi_bid          = src_resp.b.id;
    assign m_axi_bresp        = src_resp.b.resp;
    assign m_axi_buser        = src_resp.b.user;
    assign m_axi_bvalid       = src_resp.b_valid;
    assign src_req.b_ready    = m_axi_bready;
    
    // Pack Read Address Channel
    assign src_req.ar.id      = m_axi_arid;
    assign src_req.ar.addr    = m_axi_araddr;
    assign src_req.ar.len     = m_axi_arlen;
    assign src_req.ar.size    = m_axi_arsize;
    assign src_req.ar.burst   = axi_pkg::burst_t'(m_axi_arburst);
    assign src_req.ar.lock    = m_axi_arlock;
    assign src_req.ar.cache   = axi_pkg::cache_t'(m_axi_arcache);
    assign src_req.ar.prot    = axi_pkg::prot_t'(m_axi_arprot);
    assign src_req.ar.qos     = axi_pkg::qos_t'(m_axi_arqos);
    assign src_req.ar.region  = axi_pkg::region_t'(m_axi_arregion);
    assign src_req.ar.user    = m_axi_aruser;
    assign src_req.ar_valid   = m_axi_arvalid;
    assign m_axi_arready      = src_resp.ar_ready;
    
    // Unpack Read Data Channel
    assign m_axi_rid          = src_resp.r.id;
    assign m_axi_rdata        = src_resp.r.data;
    assign m_axi_rresp        = src_resp.r.resp;
    assign m_axi_rlast        = src_resp.r.last;
    assign m_axi_ruser        = src_resp.r.user;
    assign m_axi_rvalid       = src_resp.r_valid;
    assign src_req.r_ready    = m_axi_rready;
    
    // ===========================================================================
    // Unpack Slave Interface Signals from Request/Response Structs
    // ===========================================================================
    
    // Unpack Write Address Channel
    assign s_axi_awid         = dst_req.aw.id;
    assign s_axi_awaddr       = dst_req.aw.addr;
    assign s_axi_awlen        = dst_req.aw.len;
    assign s_axi_awsize       = dst_req.aw.size;
    assign s_axi_awburst      = dst_req.aw.burst;
    assign s_axi_awlock       = dst_req.aw.lock;
    assign s_axi_awcache      = dst_req.aw.cache;
    assign s_axi_awprot       = dst_req.aw.prot;
    assign s_axi_awqos        = dst_req.aw.qos;
    assign s_axi_awregion     = dst_req.aw.region;
    assign s_axi_awatop       = dst_req.aw.atop;
    assign s_axi_awuser       = dst_req.aw.user;
    assign s_axi_awvalid      = dst_req.aw_valid;
    assign dst_resp.aw_ready  = s_axi_awready;
    
    // Unpack Write Data Channel
    assign s_axi_wdata        = dst_req.w.data;
    assign s_axi_wstrb        = dst_req.w.strb;
    assign s_axi_wlast        = dst_req.w.last;
    assign s_axi_wuser        = dst_req.w.user;
    assign s_axi_wvalid       = dst_req.w_valid;
    assign dst_resp.w_ready   = s_axi_wready;
    
    // Pack Write Response Channel
    assign dst_resp.b.id      = s_axi_bid;
    assign dst_resp.b.resp    = s_axi_bresp;
    assign dst_resp.b.user    = s_axi_buser;
    assign dst_resp.b_valid   = s_axi_bvalid;
    assign s_axi_bready       = dst_req.b_ready;
    
    // Unpack Read Address Channel
    assign s_axi_arid         = dst_req.ar.id;
    assign s_axi_araddr       = dst_req.ar.addr;
    assign s_axi_arlen        = dst_req.ar.len;
    assign s_axi_arsize       = dst_req.ar.size;
    assign s_axi_arburst      = dst_req.ar.burst;
    assign s_axi_arlock       = dst_req.ar.lock;
    assign s_axi_arcache      = dst_req.ar.cache;
    assign s_axi_arprot       = dst_req.ar.prot;
    assign s_axi_arqos        = dst_req.ar.qos;
    assign s_axi_arregion     = dst_req.ar.region;
    assign s_axi_aruser       = dst_req.ar.user;
    assign s_axi_arvalid      = dst_req.ar_valid;
    assign dst_resp.ar_ready  = s_axi_arready;
    
    // Pack Read Data Channel
    assign dst_resp.r.id      = s_axi_rid;
    assign dst_resp.r.data    = s_axi_rdata;
    assign dst_resp.r.resp    = s_axi_rresp;
    assign dst_resp.r.last    = s_axi_rlast;
    assign dst_resp.r.user    = s_axi_ruser;
    assign dst_resp.r_valid   = s_axi_rvalid;
    assign s_axi_rready       = dst_req.r_ready;
    
    // ===========================================================================
    // Instantiate PULP Platform AXI CDC Module
    // ===========================================================================
    // This module implements the actual clock domain crossing using Gray-coded FIFOs
    // IMPORTANT: You must properly constrain three paths through each FIFO
    // See the header of cdc_fifo_gray for timing constraint instructions
    // ===========================================================================
    
    axi_cdc #(
        .aw_chan_t   ( aw_chan_t   ),
        .w_chan_t    ( w_chan_t    ),
        .b_chan_t    ( b_chan_t    ),
        .ar_chan_t   ( ar_chan_t   ),
        .r_chan_t    ( r_chan_t    ),
        .axi_req_t   ( axi_req_t   ),
        .axi_resp_t  ( axi_resp_t  ),
        .LogDepth    ( LOG_DEPTH   ),
        .SyncStages  ( SYNC_STAGES )
    ) i_axi_cdc (
        // Source clock domain (master side)
        .src_clk_i   ( master_clk   ),
        .src_rst_ni  ( master_rst_n ),
        .src_req_i   ( src_req      ),
        .src_resp_o  ( src_resp     ),
        
        // Destination clock domain (slave side)
        .dst_clk_i   ( slave_clk    ),
        .dst_rst_ni  ( slave_rst_n  ),
        .dst_req_o   ( dst_req      ),
        .dst_resp_i  ( dst_resp     )
    );

endmodule
