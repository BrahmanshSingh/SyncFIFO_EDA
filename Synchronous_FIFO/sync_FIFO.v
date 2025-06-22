// File: sync_fifo.v
// Description: Synchronous FIFO with 3-entry depth, 8-bit width

module sync_fifo (
    input        clk,
    input        rst,
    input        wr_en,        // Write enable
    input        rd_en,        // Read enable
    input  [7:0] data_in,      // Data to write
    output reg [7:0] data_out, // Data read
    output       full,
    output       empty
);

    // 3-slot FIFO memory (each 8 bits)
    reg [7:0] mem [0:2];   // FIFO storage
    reg [1:0] wr_ptr = 0;  // Write pointer
    reg [1:0] rd_ptr = 0;  // Read pointer
    reg [2:0] count  = 0;  // Number of items in FIFO

    // Full and empty flags
    assign full  = (count == 3);
    assign empty = (count == 0);

    // Write logic
    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr] <= data_in;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Read logic
    always @(posedge clk) begin
        if (rst) begin
            rd_ptr <= 0;
            data_out <= 8'b0;
        end else if (rd_en && !empty) begin
            data_out <= mem[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
    end

    // Counter logic to track FIFO occupancy
    always @(posedge clk) begin
        if (rst)
            count <= 0;
        else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1; // write only
                2'b01: count <= count - 1; // read only
                default: count <= count;   // no change or both
            endcase
        end
    end

endmodule
