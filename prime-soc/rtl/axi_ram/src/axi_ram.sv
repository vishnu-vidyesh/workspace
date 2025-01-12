module axi_bfm_ram #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH = 4,   // ID width for transactions
    parameter RAM_DEPTH = 1024 // Number of words in RAM
) (
    input wire                  ACLK,
    input wire                  ARESETn,

    // AXI Write Address Channel
    input wire                  AWVALID,
    output reg                  AWREADY,
    input wire [ADDR_WIDTH-1:0] AWADDR,
    input wire [7:0]            AWLEN,   // Burst length
    input wire [2:0]            AWSIZE,  // Burst size
    input wire [1:0]            AWBURST, // Burst type
    input wire                  AWLOCK,  // Lock type
    input wire [3:0]            AWCACHE, // Cache type
    input wire [2:0]            AWPROT,  // Protection type
    input wire [ID_WIDTH-1:0]   AWID,    // Write transaction ID

    // AXI Write Data Channel
    input wire                  WVALID,
    output reg                  WREADY,
    input wire [DATA_WIDTH-1:0] WDATA,
    input wire [3:0]            WSTRB,   // Byte enable
    input wire                  WLAST,   // Last transfer in burst

    // AXI Write Response Channel
    output reg                  BVALID,
    input wire                  BREADY,
    output reg [1:0]            BRESP,   // Response: OKAY=2'b00, SLVERR=2'b10
    output reg [ID_WIDTH-1:0]   BID,     // Write response ID

    // AXI Read Address Channel
    input wire                  ARVALID,
    output reg                  ARREADY,
    input wire [ADDR_WIDTH-1:0] ARADDR,
    input wire [7:0]            ARLEN,   // Burst length
    input wire [2:0]            ARSIZE,  // Burst size
    input wire [1:0]            ARBURST, // Burst type
    input wire                  ARLOCK,  // Lock type
    input wire [3:0]            ARCACHE, // Cache type
    input wire [2:0]            ARPROT,  // Protection type
    input wire [ID_WIDTH-1:0]   ARID,    // Read transaction ID

    // AXI Read Data Channel
    output reg                  RVALID,
    input wire                  RREADY,
    output reg [DATA_WIDTH-1:0] RDATA,
    output reg                  RLAST,   // Last transfer in burst
    output reg [1:0]            RRESP,   // Response: OKAY=2'b00, SLVERR=2'b10
    output reg [ID_WIDTH-1:0]   RID      // Read response ID
);

    // RAM memory
    reg [DATA_WIDTH-1:0] ram [0:RAM_DEPTH-1];

    // Address decoding
    wire [$clog2(RAM_DEPTH)-1:0] initial_write_addr = AWADDR[$clog2(RAM_DEPTH)+1:2];
    wire [$clog2(RAM_DEPTH)-1:0] initial_read_addr  = ARADDR[$clog2(RAM_DEPTH)+1:2];

    // Burst counters
    reg [7:0] write_burst_counter;
    reg [7:0] read_burst_counter;

    // Transaction ID storage
    reg [ID_WIDTH-1:0] active_write_id;
    reg [ID_WIDTH-1:0] active_read_id;

    // Burst address increment
    function [ADDR_WIDTH-1:0] calc_next_address;
        input [ADDR_WIDTH-1:0] current_addr;
        input [2:0]            burst_size;
        input [1:0]            burst_type;
        input integer          increment;
        reg [ADDR_WIDTH-1:0]   addr_increment;
        begin
            addr_increment = (1 << burst_size) * increment;
            case (burst_type)
                2'b01: calc_next_address = current_addr + addr_increment; // INCR
                2'b10: calc_next_address = current_addr + ((current_addr + addr_increment) % (AWLEN + 1)); // WRAP
                default: calc_next_address = current_addr; // FIXED
            endcase
        end
    endfunction

    reg [$clog2(RAM_DEPTH)-1:0] current_write_addr;
    reg [$clog2(RAM_DEPTH)-1:0] current_read_addr;

    // Reset logic
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            AWREADY <= 1'b0;
            WREADY  <= 1'b0;
            BVALID  <= 1'b0;
            BRESP   <= 2'b00;
            BID     <= {ID_WIDTH{1'b0}};
            ARREADY <= 1'b0;
            RVALID  <= 1'b0;
            RRESP   <= 2'b00;
            RDATA   <= {DATA_WIDTH{1'b0}};
            RLAST   <= 1'b0;
            RID     <= {ID_WIDTH{1'b0}};
            write_burst_counter <= 8'b0;
            read_burst_counter  <= 8'b0;
            active_write_id <= {ID_WIDTH{1'b0}};
            active_read_id  <= {ID_WIDTH{1'b0}};
        end else begin
            // Write Address Channel
            if (AWVALID && !AWREADY) begin
                AWREADY <= 1'b1;
                write_burst_counter <= AWLEN;
                active_write_id <= AWID;
                current_write_addr <= initial_write_addr;
            end else begin
                AWREADY <= 1'b0;
            end

            // Write Data Channel
            if (WVALID && !WREADY) begin
                WREADY <= 1'b1;
                if (AWREADY) begin
                    // Perform write operation
                    if (WSTRB[0]) ram[current_write_addr][7:0]   <= WDATA[7:0];
                    if (WSTRB[1]) ram[current_write_addr][15:8]  <= WDATA[15:8];
                    if (WSTRB[2]) ram[current_write_addr][23:16] <= WDATA[23:16];
                    if (WSTRB[3]) ram[current_write_addr][31:24] <= WDATA[31:24];

                    if (write_burst_counter > 0) begin
                        write_burst_counter <= write_burst_counter - 1;
                        current_write_addr <= calc_next_address(current_write_addr, AWSIZE, AWBURST, 1);
                    end
                end
            end else begin
                WREADY <= 1'b0;
            end

            // Write Response Channel
            if (WREADY && WVALID && WLAST && !BVALID) begin
                BVALID <= 1'b1;
                BRESP  <= 2'b00; // OKAY
                BID    <= active_write_id;
            end else if (BVALID && BREADY) begin
                BVALID <= 1'b0;
            end

            // Read Address Channel
            if (ARVALID && !ARREADY) begin
                ARREADY <= 1'b1;
                read_burst_counter <= ARLEN;
                active_read_id <= ARID;
                current_read_addr <= initial_read_addr;
            end else begin
                ARREADY <= 1'b0;
            end

            // Read Data Channel
            if (ARVALID && ARREADY && !RVALID) begin
                RVALID <= 1'b1;
                RDATA  <= ram[current_read_addr];
                RRESP  <= 2'b00; // OKAY
                RID    <= active_read_id;
                if (read_burst_counter > 0) begin
                    read_burst_counter <= read_burst_counter - 1;
                    current_read_addr <= calc_next_address(current_read_addr, ARSIZE, ARBURST, 1);
                    RLAST <= (read_burst_counter == 1);
                end else begin
                    RLAST <= 1'b1;
                end
            end else if (RVALID && RREADY) begin
                RVALID <= 1'b0;
                RLAST  <= 1'b0;
            end
        end
    end
endmodule

