`timescale 1ns/1ps

module ro_sampler (

    input wire clk,
    input wire rst,
    input wire ro_in,
    output reg sampled_bit
);


    reg sync_ff1;
    
    always @(posedge clk) begin
        if (rst) begin
            sync_ff1 <= 1'b0;
            sampled_bit <= 1'b0;
        end else begin
            sync_ff1 <= ro_in;
            sampled_bit <= sync_ff1;
        end
    end
endmodule