`timescale 1ns/1ps

module ro_bank (
    input wire enable,
    output wire combined_ro_out
);

    wire ro1_out, ro2_out, ro3_out;
    
    ring_oscillator #(.STAGES(3)) ro_3 (
    
        .enable(enable),
        .ro_out(ro1_out)
    );
    
    ring_oscillator #(.STAGES(5)) ro_5 (
        .enable(enable),
        .ro_out(ro2_out)
    );
    
    ring_oscillator #(.STAGES(7)) ro_7 (
        .enable (enable),
        .ro_out (ro3_out)
    );
    
    
    assign combined_ro_out = ro1_out ^ ro2_out ^ ro3_out;
endmodule