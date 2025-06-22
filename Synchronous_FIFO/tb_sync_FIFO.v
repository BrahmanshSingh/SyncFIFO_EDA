`timescale 1ns / 1ps

module tb_sync_fifo;

    // Inputs
    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [7:0] data_in;

    // Outputs
    wire [7:0] data_out;
    wire full;
    wire empty;

    // Instantiate the FIFO
    sync_fifo uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        $dumpfile("fifo.vcd");   // For GTKWave
        $dumpvars(0, tb_sync_fifo);

        // Initialize inputs
        clk = 0;
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        data_in = 8'b0;

        // Reset
        #10 rst = 0;

        // Write 3 bytes
        @(posedge clk); wr_en = 1; data_in = 8'hA1;
        @(posedge clk); data_in = 8'hB2;
        @(posedge clk); data_in = 8'hC3;
        @(posedge clk); wr_en = 0; // FIFO now full

        // Try writing when full (should be ignored)
        @(posedge clk); wr_en = 1; data_in = 8'hD4;
        @(posedge clk); wr_en = 0;

        // Read 3 bytes
        @(posedge clk); rd_en = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk); rd_en = 0;

        // Try reading when empty (should be ignored)
        @(posedge clk); rd_en = 1;
        @(posedge clk); rd_en = 0;

        // Finish simulation
        #20 $finish;
    end

endmodule
