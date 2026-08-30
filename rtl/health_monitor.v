module health_monitor #(
    parameter CUTOFF_LIMIT = 32  
)(
    input  wire clk,
    input  wire rst_n,
    input  wire extracted_bit,
    input  wire extractor_valid,
    output reg  health_alarm
);

    reg prev_bit;
    reg [5:0] rep_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            prev_bit  <= 1'b0;
            rep_count <= 6'd0;
            health_alarm <= 1'b0;
        end else if (extractor_valid) begin
            prev_bit <= extracted_bit;
            
            if (extracted_bit == prev_bit) begin
                if (rep_count >= CUTOFF_LIMIT) begin
                    health_alarm <= 1'b1; 
                end else begin
                    rep_count <= rep_count + 1'b1;
                end
            end else begin
                rep_count <= 6'd1; 
            end
        end
    end
endmodule