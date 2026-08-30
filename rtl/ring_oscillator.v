module ring_oscillator #(
    parameter STAGES = 3
)(
    
    input wire enable,
    output wire ro_out
);


    (* ALLOW_COMBINATORIAL_LOOPS = "true",
       KEEP = "true",
       DONT_TOUCH = "true"
     *)
     
     wire [STAGES-1:0] delay_chain;
     
     assign #1 delay_chain[0] = ~(enable & delay_chain [STAGES-1]);
     
     genvar i;
     
     generate
        for (i = 1; i < STAGES; i = i+1)
        begin : ro_stages
            assign #1 delay_chain[i] = ~delay_chain[i-1];
        end
    endgenerate
    
    
    assign ro_out = delay_chain[STAGES - 1];
endmodule