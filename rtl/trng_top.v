`timescale 1ns/1ps

module trng_top (
    input clk,
    input rst,
    input enable,
    
    output wire [31:0] random_word,
    output wire word_valid,
    
    output wire [31:0] total_bits,
    output wire [31:0] ones_count,
    output wire [31:0] zeros_count,
    output wire [31:0] runs_count,
    output wire [31:0] longest_run,
    output wire health_alarm
);

    wire raw_ro_signal;
    wire sampled_bit;
    wire extracted_bit;
    wire extractor_valid;

    ro_bank entropy_source (
        .enable(enable),
        .combined_ro_out(raw_ro_signal)
    );

    ro_sampler sampler (
        .clk(clk),
        .rst(rst),
        .ro_in(raw_ro_signal),
        .sampled_bit(sampled_bit)
    );

    von_neumann_extractor extractor (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .bit_in(sampled_bit),
        .bit_out(extracted_bit),
        .valid_out(extractor_valid)
    );

    shift_register_32bit output_formatter (
        .clk(clk),
        .rst(rst),
        .bit_in(extracted_bit),
        .valid_in(extractor_valid),
        .random_word(random_word),
        .word_valid(word_valid)
    );

    bit_statistics stats_engine (
        .clk(clk),
        .rst(rst),
        .enable(extractor_valid), 
        .bit_in(extracted_bit),
        .total_bits(total_bits),
        .ones_count(ones_count),
        .zeros_count(zeros_count),
        .runs_count(runs_count),
        .longest_run(longest_run)
    );
    
    health_monitor #( .CUTOFF_LIMIT(32)) u_health_monitor (
        .clk(clk),
        .rst_n(rst_n),
        .extracted_bit(extracted_bit),
        .extractor_valid(extractor_valid),
        .health_alarm(health_alarm)
    );

endmodule