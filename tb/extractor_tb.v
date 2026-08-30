`timescale 1ns/1ps

module extractor_tb;
    reg clk = 0;
    reg rst;
    reg enable;
    reg noisy_bit;

    wire clean_bit;
    wire bit_valid;

    wire [31:0] total_bits;
    wire [31:0] ones_count;
    wire [31:0] zeros_count;
    wire [31:0] runs_count;
    wire [31:0] longest_run;

    von_neumann_extractor my_extractor (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .bit_in(noisy_bit),
        .bit_out(clean_bit),
        .valid_out(bit_valid)
    );

    bit_statistics my_stats (
        .clk(clk),
        .rst(rst),
        .enable(bit_valid), 
        .bit_in(clean_bit),
        .total_bits(total_bits),
        .ones_count(ones_count),
        .zeros_count(zeros_count),
        .runs_count(runs_count),
        .longest_run(longest_run)
    );

    always #5 clk = ~clk;

    integer i;
    integer random_val;
    integer raw_ones_sent = 0;

    initial begin
        rst = 1;
        enable = 0;
        noisy_bit = 0;
        #20;

        rst = 0;
        enable = 1;

        for (i = 0; i < 100000; i = i + 1) begin
            @(negedge clk);
            
            random_val = $urandom_range(1, 100);
            
            if (random_val <= 75) begin
                noisy_bit = 1;
                raw_ones_sent = raw_ones_sent + 1;
            end else begin
                noisy_bit = 0;
            end
        end

        @(negedge clk);
        enable = 0;
        #20;

        $display("--- SIMULATION RESULTS ---");
        $display("Raw garbage bits sent: 100000");
        $display("Raw ones sent (should be ~75k): %d", raw_ones_sent);
        $display("");
        $display("--- AFTER EXTRACTION ---");
        $display("Total valid bits kept: %d", total_bits);
        $display("Ones: %d", ones_count);
        $display("Zeros: %d", zeros_count);
        $display("Runs: %d", runs_count);
        $display("Longest Run: %d", longest_run);
        $display("--------------------------");

        $finish;
    end
endmodule