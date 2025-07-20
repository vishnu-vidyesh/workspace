module async_fifo #(
    parameter W = 8,                // Data width
    parameter DP = 4,               // FIFO depth (power of 2)
    parameter WR_FAST = 1'b1,       // Fast write mode
    parameter RD_FAST = 1'b1,       // Fast read mode
    parameter FULL_DP = DP,         // Full threshold
    parameter EMPTY_DP = 1'b0,      // Empty threshold
    
    // Calculated parameters
    parameter AW = (DP == 2)   ? 1 : 
                  (DP == 4)   ? 2 :
                  (DP == 8)   ? 3 :
                  (DP == 16)  ? 4 :
                  (DP == 32)  ? 5 :
                  (DP == 64)  ? 6 :
                  (DP == 128) ? 7 :
                  (DP == 256) ? 8 : 0
) (
    // Write interface
    input wire wr_clk,
    input wire wr_reset_n,
    input wire wr_en,
    input wire [W-1:0] wr_data,
    output wire wr_empty,           // sync'ed to wr_clk
    output wire wr_full,            // sync'ed to wr_clk
    output wire wr_afull,           // sync'ed to wr_clk
    output wire [AW:0] wr_total_free_space,
    
    // Read interface
    input wire rd_clk,
    input wire rd_reset_n,
    input wire rd_en,
    output wire rd_full,             // sync'ed to rd_clk
    output wire rd_empty,           // sync'ed to rd_clk
    output wire rd_aempty,          // sync'ed to rd_clk
    output wire [AW:0] rd_total_aval,
    output wire [W-1:0] rd_data
);

    // FIFO memory
    reg [W-1:0] mem [0:DP-1];
    
    // Pointers
    reg [AW:0] wr_ptr = 0;         // MSB for full/empty detection
    reg [AW:0] rd_ptr = 0;
    
    // Synchronized pointers (4-stage for better MTBF)
    reg [AW:0] wr_ptr_gray_sync1 = 0;
    reg [AW:0] wr_ptr_gray_sync2 = 0;
    reg [AW:0] wr_ptr_gray_sync3 = 0;
    reg [AW:0] rd_ptr_gray_sync1 = 0;
    reg [AW:0] rd_ptr_gray_sync2 = 0;
    reg [AW:0] rd_ptr_gray_sync3 = 0;
    
    // Gray code conversion functions
    function [AW:0] bin2gray;
        input [AW:0] bin;
        begin
            bin2gray = bin ^ (bin >> 1);
        end
    endfunction
    
    function [AW:0] gray2bin;
        input [AW:0] gray;
        integer i;
        begin
            gray2bin[AW] = gray[AW];
            for (i = AW-1; i >= 0; i = i-1)
                gray2bin[i] = gray2bin[i+1] ^ gray[i];
        end
    endfunction
    
    // Write domain logic
    wire [AW:0] wr_ptr_next = wr_ptr + (wr_en && !wr_full);
    wire [AW:0] rd_ptr_gray_bin = gray2bin(rd_ptr_gray_sync3);
    wire [AW:0] wr_free_space = (rd_ptr_gray_bin[AW] == wr_ptr[AW]) ? 
                               (rd_ptr_gray_bin[AW-1:0] - wr_ptr[AW-1:0]) : 
                               (DP - wr_ptr[AW-1:0] + rd_ptr_gray_bin[AW-1:0]);
    
    always @(posedge wr_clk or negedge wr_reset_n) begin
        if (!wr_reset_n) begin
            wr_ptr <= 0;
        end else if (wr_en && !wr_full) begin
            mem[wr_ptr[AW-1:0]] <= wr_data;
            wr_ptr <= wr_ptr_next;
        end
    end
    
    // Read domain logic
    wire [AW:0] rd_ptr_next = rd_ptr + (rd_en && !rd_empty);
    wire [AW:0] wr_ptr_gray_bin = gray2bin(wr_ptr_gray_sync3);
    wire [AW:0] rd_avail_space = (wr_ptr_gray_bin[AW] == rd_ptr[AW]) ? 
                                (wr_ptr_gray_bin[AW-1:0] - rd_ptr[AW-1:0]) : 
                                (DP - rd_ptr[AW-1:0] + wr_ptr_gray_bin[AW-1:0]);
    
    always @(posedge rd_clk or negedge rd_reset_n) begin
        if (!rd_reset_n) begin
            rd_ptr <= 0;
        end else if (rd_en && !rd_empty) begin
            rd_data <= mem[rd_ptr[AW-1:0]];
            rd_ptr <= rd_ptr_next;
        end
    end
    
    // Pointer synchronization (write to read) - 3 stages for better MTBF
    always @(posedge rd_clk or negedge rd_reset_n) begin
        if (!rd_reset_n) begin
            wr_ptr_gray_sync1 <= 0;
            wr_ptr_gray_sync2 <= 0;
            wr_ptr_gray_sync3 <= 0;
        end else begin
            wr_ptr_gray_sync1 <= bin2gray(wr_ptr);
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
            wr_ptr_gray_sync3 <= wr_ptr_gray_sync2;
        end
    end
    
    // Pointer synchronization (read to write) - 3 stages for better MTBF
    always @(posedge wr_clk or negedge wr_reset_n) begin
        if (!wr_reset_n) begin
            rd_ptr_gray_sync1 <= 0;
            rd_ptr_gray_sync2 <= 0;
            rd_ptr_gray_sync3 <= 0;
        end else begin
            rd_ptr_gray_sync1 <= bin2gray(rd_ptr);
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
            rd_ptr_gray_sync3 <= rd_ptr_gray_sync2;
        end
    end
    
    // Write domain status signals
    assign wr_full = (wr_free_space == 0);
    assign wr_afull = (wr_free_space <= (DP - FULL_DP));
    assign wr_empty = (wr_free_space == DP);
    assign wr_total_free_space = wr_free_space;
    
    // Read domain status signals
    assign rd_empty = (rd_avail_space == 0);
    assign rd_aempty = (rd_avail_space <= EMPTY_DP);
    assign rd_full = (rd_avail_space == DP);
    assign rd_total_aval = rd_avail_space;
    
    // Fast mode outputs (bypass synchronization when possible)
    generate
        if (WR_FAST) begin
            assign wr_full = (wr_ptr_next == {~rd_ptr_gray_sync3[AW], rd_ptr_gray_sync3[AW-1:0]});
        end
        
        if (RD_FAST) begin
            assign rd_empty = (rd_ptr == wr_ptr_gray_sync3);
        end
    endgenerate

endmodule
