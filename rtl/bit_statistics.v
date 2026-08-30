`timescale 1ns/1ps

module bit_statistics (
    input wire clk,
    input wire rst,
    input wire bit_in,
    input wire enable,
    output reg [31:0] total_bits,
    output reg [31:0] ones_count,
    output reg [31:0] zeros_count,
    output reg [31:0] runs_count,
    output reg [31:0] longest_run
);

reg previous_bit;
reg [31:0] current_run;

always @(posedge clk) begin
    if (rst) begin
        total_bits   <= 32'd0;
        ones_count   <= 32'd0;
        zeros_count  <= 32'd0;
        runs_count   <= 32'd0;
        longest_run  <= 32'd0;
        current_run  <= 32'd0;
        previous_bit <= 1'b0;
    end
    else if (enable) begin
        total_bits <= total_bits + 1'b1;

        if (bit_in)
            ones_count <= ones_count + 1'b1;
        else
            zeros_count <= zeros_count + 1'b1;

        if (total_bits == 32'd0) begin
            // First valid bit setup
            runs_count   <= 32'd1;
            current_run  <= 32'd1;
            longest_run  <= 32'd1;
            previous_bit <= bit_in;
        end
        else begin
            if (bit_in == previous_bit) begin
                // Extend current run
                current_run <= current_run + 1'b1;
                
                // Update longest_run immediately if current run exceeds it
                if ((current_run + 1'b1) > longest_run) begin
                    longest_run <= current_run + 1'b1;
                end
            end 
            else begin
                // Bit transition: start new run
                runs_count   <= runs_count + 1'b1;
                current_run  <= 32'd1;
                previous_bit <= bit_in;
            end
        end
    end
end
endmodule