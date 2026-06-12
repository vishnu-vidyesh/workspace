//---------------------------------------------------------------------------
// axi_cdc_wrapper.v
// Wrapper for AXI CDC using async_fifo_gray
//---------------------------------------------------------------------------

module axi_cdc_wrapper #(
    parameter ID_WIDTH = 4,
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    parameter USER_WIDTH = 1,
    parameter FIFO_DEPTH_AW = 4,
    parameter FIFO_DEPTH_W  = 4,
    parameter FIFO_DEPTH_B  = 4,
    parameter FIFO_DEPTH_AR = 4,
    parameter FIFO_DEPTH_R  = 4
) (
    // Clock & Reset for source domain
    input wire src_clk,
    input wire src_rst_n,
    
    // Clock & Reset for destination domain
    input wire dst_clk,
    input wire dst_rst_n,
    
    // AXI Slave interface (src clock domain)
    input  wire [ID_WIDTH-1:0]     s_awid,
    input  wire [ADDR_WIDTH-1:0]   s_awaddr,
    input  wire [7:0]              s_awlen,
    input  wire                    s_awlock,
    input  wire [2:0]              s_awsize,
    input  wire [1:0]              s_awburst,
    `ifdef AMBA_AXI_CACHE
    input  wire [3:0]              s_awcache,
    `endif
    `ifdef AMBA_AXI_PROT
    input  wire [2:0]              s_awprot,
    `endif
    input  wire                    s_awvalid,
    output wire                    s_awready,
    `ifdef AMBA_QOS
    input  wire [3:0]              s_awqos,
    input  wire [3:0]              s_awregion,
    `endif
    `ifdef AMBA_AXI_AWUSER
    input  wire [USER_WIDTH-1:0]   s_awuser,
    `endif
    
    input  wire [DATA_WIDTH-1:0]   s_wdata,
    input  wire [STRB_WIDTH-1:0]   s_wstrb,
    input  wire                    s_wlast,
    input  wire                    s_wvalid,
    output wire                    s_wready,
    `ifdef AMBA_AXI_WUSER
    input  wire [USER_WIDTH-1:0]   s_wuser,
    `endif
    
    output wire [ID_WIDTH-1:0]     s_bid,
    output wire [1:0]              s_bresp,
    output wire                    s_bvalid,
    input  wire                    s_bready,
    `ifdef AMBA_AXI_BUSER
    output wire [USER_WIDTH-1:0]   s_buser,
    `endif
    
    input  wire [ID_WIDTH-1:0]     s_arid,
    input  wire [ADDR_WIDTH-1:0]   s_araddr,
    input  wire [7:0]              s_arlen,
    input  wire                    s_arlock,
    input  wire [2:0]              s_arsize,
    input  wire [1:0]              s_arburst,
    `ifdef AMBA_AXI_CACHE
    input  wire [3:0]              s_arcache,
    `endif
    `ifdef AMBA_AXI_PROT
    input  wire [2:0]              s_arprot,
    `endif
    input  wire                    s_arvalid,
    output wire                    s_arready,
    `ifdef AMBA_QOS
    input  wire [3:0]              s_arqos,
    input  wire [3:0]              s_arregion,
    `endif
    `ifdef AMBA_AXI_ARUSER
    input  wire [USER_WIDTH-1:0]   s_aruser,
    `endif
    
    output wire [ID_WIDTH-1:0]     s_rid,
    output wire [DATA_WIDTH-1:0]   s_rdata,
    output wire [1:0]              s_rresp,
    output wire                    s_rlast,
    output wire                    s_rvalid,
    input  wire                    s_rready,
    `ifdef AMBA_AXI_RUSER
    output wire [USER_WIDTH-1:0]   s_ruser,
    `endif

    // AXI Master interface (dst clock domain)
    output wire [ID_WIDTH-1:0]     m_awid,
    output wire [ADDR_WIDTH-1:0]   m_awaddr,
    output wire [7:0]              m_awlen,
    output wire                    m_awlock,
    output wire [2:0]              m_awsize,
    output wire [1:0]              m_awburst,
    `ifdef AMBA_AXI_CACHE
    output wire [3:0]              m_awcache,
    `endif
    `ifdef AMBA_AXI_PROT
    output wire [2:0]              m_awprot,
    `endif
    output wire                    m_awvalid,
    input  wire                    m_awready,
    `ifdef AMBA_QOS
    output wire [3:0]              m_awqos,
    output wire [3:0]              m_awregion,
    `endif
    `ifdef AMBA_AXI_AWUSER
    output wire [USER_WIDTH-1:0]   m_awuser,
    `endif
    
    output wire [DATA_WIDTH-1:0]   m_wdata,
    output wire [STRB_WIDTH-1:0]   m_wstrb,
    output wire                    m_wlast,
    output wire                    m_wvalid,
    input  wire                    m_wready,
    `ifdef AMBA_AXI_WUSER
    output wire [USER_WIDTH-1:0]   m_wuser,
    `endif
    
    input  wire [ID_WIDTH-1:0]     m_bid,
    input  wire [1:0]              m_bresp,
    input  wire                    m_bvalid,
    output wire                    m_bready,
    `ifdef AMBA_AXI_BUSER
    input  wire [USER_WIDTH-1:0]   m_buser,
    `endif
    
    output wire [ID_WIDTH-1:0]     m_arid,
    output wire [ADDR_WIDTH-1:0]   m_araddr,
    output wire [7:0]              m_arlen,
    output wire                    m_arlock,
    output wire [2:0]              m_arsize,
    output wire [1:0]              m_arburst,
    `ifdef AMBA_AXI_CACHE
    output wire [3:0]              m_arcache,
    `endif
    `ifdef AMBA_AXI_PROT
    output wire [2:0]              m_arprot,
    `endif
    output wire                    m_arvalid,
    input  wire                    m_arready,
    `ifdef AMBA_QOS
    output wire [3:0]              m_arqos,
    output wire [3:0]              m_arregion,
    `endif
    `ifdef AMBA_AXI_ARUSER
    output wire [USER_WIDTH-1:0]   m_aruser,
    `endif
    
    input  wire [ID_WIDTH-1:0]     m_rid,
    input  wire [DATA_WIDTH-1:0]   m_rdata,
    input  wire [1:0]              m_rresp,
    input  wire                    m_rlast,
    input  wire                    m_rvalid,
    output wire                    m_rready
    `ifdef AMBA_AXI_RUSER
    , input  wire [USER_WIDTH-1:0]   m_ruser
    `endif
);

    `ifdef AMBA_AXI_CACHE
        localparam AW_CACHE_W = 4;
    `else
        localparam AW_CACHE_W = 0;
    `endif
    `ifdef AMBA_AXI_PROT
        localparam AW_PROT_W = 3;
    `else
        localparam AW_PROT_W = 0;
    `endif
    `ifdef AMBA_QOS
        localparam AW_QOS_W = 8;
    `else
        localparam AW_QOS_W = 0;
    `endif
    `ifdef AMBA_AXI_AWUSER
        localparam AW_USER_W = USER_WIDTH;
    `else
        localparam AW_USER_W = 0;
    `endif
    localparam AW_PAYLOAD_W = ID_WIDTH + ADDR_WIDTH + 8 + 1 + 3 + 2 + AW_CACHE_W + AW_PROT_W + AW_QOS_W + AW_USER_W;

    `ifdef AMBA_AXI_WUSER
        localparam W_USER_W = USER_WIDTH;
    `else
        localparam W_USER_W = 0;
    `endif
    localparam W_PAYLOAD_W = DATA_WIDTH + STRB_WIDTH + 1 + W_USER_W;

    `ifdef AMBA_AXI_BUSER
        localparam B_USER_W = USER_WIDTH;
    `else
        localparam B_USER_W = 0;
    `endif
    localparam B_PAYLOAD_W = ID_WIDTH + 2 + B_USER_W;

    `ifdef AMBA_AXI_CACHE
        localparam AR_CACHE_W = 4;
    `else
        localparam AR_CACHE_W = 0;
    `endif
    `ifdef AMBA_AXI_PROT
        localparam AR_PROT_W = 3;
    `else
        localparam AR_PROT_W = 0;
    `endif
    `ifdef AMBA_QOS
        localparam AR_QOS_W = 8;
    `else
        localparam AR_QOS_W = 0;
    `endif
    `ifdef AMBA_AXI_ARUSER
        localparam AR_USER_W = USER_WIDTH;
    `else
        localparam AR_USER_W = 0;
    `endif
    localparam AR_PAYLOAD_W = ID_WIDTH + ADDR_WIDTH + 8 + 1 + 3 + 2 + AR_CACHE_W + AR_PROT_W + AR_QOS_W + AR_USER_W;

    `ifdef AMBA_AXI_RUSER
        localparam R_USER_W = USER_WIDTH;
    `else
        localparam R_USER_W = 0;
    `endif
    localparam R_PAYLOAD_W = ID_WIDTH + DATA_WIDTH + 2 + 1 + R_USER_W;

    //-----------------------------------------------------------------------
    // AW Channel: Slave (src) -> Master (dst)
    //-----------------------------------------------------------------------
    wire [AW_PAYLOAD_W-1:0] s_aw_payload;
    assign s_aw_payload = {
        s_awid,
        s_awaddr,
        s_awlen,
        s_awlock,
        s_awsize,
        s_awburst
        `ifdef AMBA_AXI_CACHE , s_awcache `endif
        `ifdef AMBA_AXI_PROT  , s_awprot  `endif
        `ifdef AMBA_QOS       , s_awqos, s_awregion `endif
        `ifdef AMBA_AXI_AWUSER, s_awuser `endif
    };
    
    wire [AW_PAYLOAD_W-1:0] m_aw_payload;
    assign {
        m_awid,
        m_awaddr,
        m_awlen,
        m_awlock,
        m_awsize,
        m_awburst
        `ifdef AMBA_AXI_CACHE , m_awcache `endif
        `ifdef AMBA_AXI_PROT  , m_awprot  `endif
        `ifdef AMBA_QOS       , m_awqos, m_awregion `endif
        `ifdef AMBA_AXI_AWUSER, m_awuser `endif
    } = m_aw_payload;

    wire aw_full, aw_empty;
    async_fifo_gray #(
        .DATA_W(AW_PAYLOAD_W),
        .ADDR_W(FIFO_DEPTH_AW)
    ) fifo_aw (
        .wclk(src_clk),
        .wrst_n(src_rst_n),
        .winc(s_awvalid),
        .wdata(s_aw_payload),
        .wfull(aw_full),
        .rclk(dst_clk),
        .rrst_n(dst_rst_n),
        .rinc(m_awready),
        .rdata(m_aw_payload),
        .rempty(aw_empty)
    );
    assign s_awready = ~aw_full;
    assign m_awvalid = ~aw_empty;

    //-----------------------------------------------------------------------
    // W Channel: Slave (src) -> Master (dst)
    //-----------------------------------------------------------------------
    wire [W_PAYLOAD_W-1:0] s_w_payload;
    assign s_w_payload = {
        s_wdata,
        s_wstrb,
        s_wlast
        `ifdef AMBA_AXI_WUSER , s_wuser `endif
    };
    
    wire [W_PAYLOAD_W-1:0] m_w_payload;
    assign {
        m_wdata,
        m_wstrb,
        m_wlast
        `ifdef AMBA_AXI_WUSER , m_wuser `endif
    } = m_w_payload;

    wire w_full, w_empty;
    async_fifo_gray #(
        .DATA_W(W_PAYLOAD_W),
        .ADDR_W(FIFO_DEPTH_W)
    ) fifo_w (
        .wclk(src_clk),
        .wrst_n(src_rst_n),
        .winc(s_wvalid),
        .wdata(s_w_payload),
        .wfull(w_full),
        .rclk(dst_clk),
        .rrst_n(dst_rst_n),
        .rinc(m_wready),
        .rdata(m_w_payload),
        .rempty(w_empty)
    );
    assign s_wready = ~w_full;
    assign m_wvalid = ~w_empty;

    //-----------------------------------------------------------------------
    // B Channel: Master (dst) -> Slave (src)
    //-----------------------------------------------------------------------
    wire [B_PAYLOAD_W-1:0] m_b_payload;
    assign m_b_payload = {
        m_bid,
        m_bresp
        `ifdef AMBA_AXI_BUSER , m_buser `endif
    };
    
    wire [B_PAYLOAD_W-1:0] s_b_payload;
    assign {
        s_bid,
        s_bresp
        `ifdef AMBA_AXI_BUSER , s_buser `endif
    } = s_b_payload;

    wire b_full, b_empty;
    async_fifo_gray #(
        .DATA_W(B_PAYLOAD_W),
        .ADDR_W(FIFO_DEPTH_B)
    ) fifo_b (
        .wclk(dst_clk),
        .wrst_n(dst_rst_n),
        .winc(m_bvalid),
        .wdata(m_b_payload),
        .wfull(b_full),
        .rclk(src_clk),
        .rrst_n(src_rst_n),
        .rinc(s_bready),
        .rdata(s_b_payload),
        .rempty(b_empty)
    );
    assign m_bready = ~b_full;
    assign s_bvalid = ~b_empty;

    //-----------------------------------------------------------------------
    // AR Channel: Slave (src) -> Master (dst)
    //-----------------------------------------------------------------------
    wire [AR_PAYLOAD_W-1:0] s_ar_payload;
    assign s_ar_payload = {
        s_arid,
        s_araddr,
        s_arlen,
        s_arlock,
        s_arsize,
        s_arburst
        `ifdef AMBA_AXI_CACHE , s_arcache `endif
        `ifdef AMBA_AXI_PROT  , s_arprot  `endif
        `ifdef AMBA_QOS       , s_arqos, s_arregion `endif
        `ifdef AMBA_AXI_ARUSER, s_aruser `endif
    };
    
    wire [AR_PAYLOAD_W-1:0] m_ar_payload;
    assign {
        m_arid,
        m_araddr,
        m_arlen,
        m_arlock,
        m_arsize,
        m_arburst
        `ifdef AMBA_AXI_CACHE , m_arcache `endif
        `ifdef AMBA_AXI_PROT  , m_arprot  `endif
        `ifdef AMBA_QOS       , m_arqos, m_arregion `endif
        `ifdef AMBA_AXI_ARUSER, m_aruser `endif
    } = m_ar_payload;

    wire ar_full, ar_empty;
    async_fifo_gray #(
        .DATA_W(AR_PAYLOAD_W),
        .ADDR_W(FIFO_DEPTH_AR)
    ) fifo_ar (
        .wclk(src_clk),
        .wrst_n(src_rst_n),
        .winc(s_arvalid),
        .wdata(s_ar_payload),
        .wfull(ar_full),
        .rclk(dst_clk),
        .rrst_n(dst_rst_n),
        .rinc(m_arready),
        .rdata(m_ar_payload),
        .rempty(ar_empty)
    );
    assign s_arready = ~ar_full;
    assign m_arvalid = ~ar_empty;

    //-----------------------------------------------------------------------
    // R Channel: Master (dst) -> Slave (src)
    //-----------------------------------------------------------------------
    wire [R_PAYLOAD_W-1:0] m_r_payload;
    assign m_r_payload = {
        m_rid,
        m_rdata,
        m_rresp,
        m_rlast
        `ifdef AMBA_AXI_RUSER , m_ruser `endif
    };
    
    wire [R_PAYLOAD_W-1:0] s_r_payload;
    assign {
        s_rid,
        s_rdata,
        s_rresp,
        s_rlast
        `ifdef AMBA_AXI_RUSER , s_ruser `endif
    } = s_r_payload;

    wire r_full, r_empty;
    async_fifo_gray #(
        .DATA_W(R_PAYLOAD_W),
        .ADDR_W(FIFO_DEPTH_R)
    ) fifo_r (
        .wclk(dst_clk),
        .wrst_n(dst_rst_n),
        .winc(m_rvalid),
        .wdata(m_r_payload),
        .wfull(r_full),
        .rclk(src_clk),
        .rrst_n(src_rst_n),
        .rinc(s_rready),
        .rdata(s_r_payload),
        .rempty(r_empty)
    );
    assign m_rready = ~r_full;
    assign s_rvalid = ~r_empty;

endmodule
