`timescale 1ns/1ps

module trng_top_tb;
    reg clk;
    reg rst;
    reg enable;
    
    wire random_bit_out;
    wire [31:0] total_bits;
    wire [31:0] ones_count;
    wire [31:0] zeros_count;
    wire [31:0] runs_count;
    wire [31:0] longest_run;

    trng_top uut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .random_bit_out(random_bit_out),
        .total_bits(total_bits),
        .ones_count(ones_count),
        .zeros_count(zeros_count),
        .runs_count(runs_count),
        .longest_run(longest_run)
    );

    // 10ns clock (100 MHz)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        enable = 0;
        #20;
        
        @(posedge clk);
        rst <= 0;
        enable <= 1;
        
        // Run for 1,000,000 ns (100,000 clock cycles)
        #1000000;
        
        @(negedge clk);
        enable <= 0;
        @(posedge clk);
        #20;
        
        $display("\n========== TRNG TOP SIMULATION RESULTS ==========");
        $display("Total bits  = %d", total_bits);
        $display("Ones count  = %d", ones_count);
        $display("Zeros count = %d", zeros_count);
        $display("Runs count  = %d", runs_count);
        $display("Longest run = %d", longest_run);
        $display("=================================================\n");
        
        $finish;
    end
endmodule