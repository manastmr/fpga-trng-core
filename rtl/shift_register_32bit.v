`timescale 1ns/1ps

module shift_register_32bit (
    input clk,
    input rst,
    input bit_in,
    input valid_in,
    
    output reg [31:0] random_word,
    output reg word_valid
);

    reg [31:0] shift_reg;
    reg [5:0] bit_count;

    always @(posedge clk) begin
        if (rst) begin
            shift_reg <= 0;
            random_word <= 0;
            bit_count <= 0;
            word_valid <= 0;
        end else begin
            word_valid <= 0;

            if (valid_in) begin
                shift_reg <= {shift_reg[30:0], bit_in};
                bit_count <= bit_count + 1;

                if (bit_count == 31) begin
                    random_word <= {shift_reg[30:0], bit_in};
                    word_valid <= 1;
                    bit_count <= 0;
                end
            end
        end
    end
endmodule