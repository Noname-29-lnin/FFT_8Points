`timescale 1ns/1ps
module tb_Butterfly_Unit ();

logic [31:0] a_re, a_im, b_re, b_im;
logic [31:0] w_re, w_im;
logic [31:0] y0_re, y0_im, y1_re, y1_im;

Butterfly_Unit dut (
    .i_data_0_re(a_re),
    .i_data_0_im(a_im),
    .i_data_1_re(b_re),
    .i_data_1_im(b_im),
    .i_twiddle_re(w_re),
    .i_twiddle_im(w_im),
    .o_data_0_re(y0_re),
    .o_data_0_im(y0_im),
    .o_data_1_re(y1_re),
    .o_data_1_im(y1_im)
);

initial begin
    // TEST 1: W = 1
    a_re = 32'h3F800000; // 1.0
    a_im = 32'h40000000; // 2.0
    b_re = 32'h40400000; // 3.0
    b_im = 32'h40800000; // 4.0
    w_re = 32'h3F800000; // 1.0
    w_im = 32'h00000000; // 0.0
    #100;

    // TEST 2: W = -j
    a_re = 32'h00000000;
    a_im = 32'h00000000;
    b_re = 32'h3F800000; // 1.0
    b_im = 32'h00000000;
    w_re = 32'h00000000;
    w_im = 32'hBF800000; // -1.0
    #100;

    // TEST 3: b = 0
    a_re = 32'h3FC00000; // 1.5
    a_im = 32'hC0200000; // -2.5
    b_re = 32'h00000000;
    b_im = 32'h00000000;
    w_re = 32'h3F800000;
    w_im = 32'h00000000;
    #100;

    $stop;
end

endmodule
