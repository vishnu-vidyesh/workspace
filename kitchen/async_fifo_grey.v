module async_fifo_gray #(
    parameter DATA_W = 32,
    parameter ADDR_W = 4   // FIFO depth = 2^ADDR_W
)(
    input  wire                wclk,
    input  wire                wrst_n,
    input  wire                winc,
    input  wire [DATA_W-1:0]   wdata,
    output reg                 wfull,

    input  wire                rclk,
    input  wire                rrst_n,
    input  wire                rinc,
    output reg  [DATA_W-1:0]   rdata,
    output reg                 rempty
);

    localparam DEPTH = (1 << ADDR_W);

    // Memory
    reg [DATA_W-1:0] mem [0:DEPTH-1];

    // Binary and Gray pointers
    reg [ADDR_W:0] wbin, wgray;
    reg [ADDR_W:0] rbin, rgray;

    // Cross-domain synchronized Gray pointers
    reg [ADDR_W:0] wq1_rgray, wq2_rgray;
    reg [ADDR_W:0] rq1_wgray, rq2_wgray;

    // Next-state pointers
    wire [ADDR_W:0] wbin_next  = wbin + (winc & ~wfull);
    wire [ADDR_W:0] rbin_next  = rbin + (rinc & ~rempty);

    wire [ADDR_W:0] wgray_next = (wbin_next >> 1) ^ wbin_next;
    wire [ADDR_W:0] rgray_next = (rbin_next >> 1) ^ rbin_next;

    // Next-state flags
    wire wfull_next  = (wgray_next ==
                        {~wq2_rgray[ADDR_W:ADDR_W-1], wq2_rgray[ADDR_W-2:0]});

    wire rempty_next = (rgray_next == rq2_wgray);

    // Write clock domain
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wbin     <= { (ADDR_W+1){1'b0} };
            wgray    <= { (ADDR_W+1){1'b0} };
            wq1_rgray <= { (ADDR_W+1){1'b0} };
            wq2_rgray <= { (ADDR_W+1){1'b0} };
            wfull    <= 1'b0;
        end else begin
            if (winc & ~wfull)
                mem[wbin[ADDR_W-1:0]] <= wdata;

            wbin  <= wbin_next;
            wgray <= wgray_next;

            // Two-flop sync of read Gray pointer into write clock domain
            wq1_rgray <= rgray;
            wq2_rgray <= wq1_rgray;

            wfull <= wfull_next;
        end
    end

    // Read clock domain
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rbin      <= { (ADDR_W+1){1'b0} };
            rgray     <= { (ADDR_W+1){1'b0} };
            rq1_wgray <= { (ADDR_W+1){1'b0} };
            rq2_wgray <= { (ADDR_W+1){1'b0} };
            rdata     <= { DATA_W{1'b0} };
            rempty    <= 1'b1;
        end else begin
            // Read the current location when a valid read happens
            if (rinc & ~rempty)
                rdata <= mem[rbin[ADDR_W-1:0]];

            rbin  <= rbin_next;
            rgray <= rgray_next;

            // Two-flop sync of write Gray pointer into read clock domain
            rq1_wgray <= wgray;
            rq2_wgray <= rq1_wgray;

            rempty <= rempty_next;
        end
    end

endmodule
