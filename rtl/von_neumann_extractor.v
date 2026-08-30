`timescale 1ns/1ps

module von_neumann_extractor (
    input clk,
    input rst,
    input enable,
    input bit_in,
    
    output reg bit_out,
    output reg valid_out
);

    reg prev_bit; 
    reg got_first_bit; 

    always @(posedge clk) begin
        if (rst) begin
            prev_bit <= 0;
            got_first_bit <= 0;
            bit_out <= 0;
            valid_out <= 0;
        end 
        else if (enable) begin
            if (!got_first_bit) begin
                prev_bit <= bit_in;
                got_first_bit <= 1;
                valid_out <= 0;
            end 
            else begin
                got_first_bit <= 0;
                
                if (prev_bit != bit_in) begin
                    bit_out <= prev_bit;
                    valid_out <= 1;
                end 
                else begin
                    valid_out <= 0;
                end
            end
        end 
        else begin
            valid_out <= 0;
        end
    end
endmodule