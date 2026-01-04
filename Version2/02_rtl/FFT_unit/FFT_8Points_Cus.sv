module FFT_8Points #(
    parameter SIZE_DATA = 32
)(
    input logic                     i_clk,
    input logic                     i_rst_n,
    input logic                     i_start,
    input logic [SIZE_DATA-1:0]     x0_real, x0_imag,
    input logic [SIZE_DATA-1:0]     x1_real, x1_imag,
    input logic [SIZE_DATA-1:0]     x2_real, x2_imag,
    input logic [SIZE_DATA-1:0]     x3_real, x3_imag,
    input logic [SIZE_DATA-1:0]     x4_real, x4_imag,
    input logic [SIZE_DATA-1:0]     x5_real, x5_imag,
    input logic [SIZE_DATA-1:0]     x6_real, x6_imag,
    input logic [SIZE_DATA-1:0]     x7_real, x7_imag,

    output logic [SIZE_DATA-1:0]    X0_real, X0_imag,
    output logic [SIZE_DATA-1:0]    X1_real, X1_imag,
    output logic [SIZE_DATA-1:0]    X2_real, X2_imag,
    output logic [SIZE_DATA-1:0]    X3_real, X3_imag,
    output logic [SIZE_DATA-1:0]    X4_real, X4_imag,
    output logic [SIZE_DATA-1:0]    X5_real, X5_imag,
    output logic [SIZE_DATA-1:0]    X6_real, X6_imag,
    output logic [SIZE_DATA-1:0]    X7_real, X7_imag,
    output logic                    o_done
);
// Twiddle factors (IEEE 754 single-precision)
logic w_start;
parameter W2_0_REAL = 32'h3F800000; // 1.0
parameter W2_0_IMAG = 32'h00000000; // 0.0
parameter W2_1_REAL = 32'h3F800000; // 1.0
parameter W2_1_IMAG = 32'h00000000; // 0.0
parameter W4_0_REAL = 32'h3F800000; // 1.0
parameter W4_0_IMAG = 32'h00000000; // 0.0
parameter W4_1_REAL = 32'h00000000; // 0.0
parameter W4_1_IMAG = 32'hBF800000; // -1.0
parameter W8_0_REAL = 32'h3F800000; // 1.0
parameter W8_0_IMAG = 32'h00000000; // 0.0
parameter W8_1_REAL = 32'h3F3504F3; // 0.707107
parameter W8_1_IMAG = 32'hBF3504F3; // -0.707107
parameter W8_2_REAL = 32'h00000000; // 0.0
parameter W8_2_IMAG = 32'hBF800000; // -1.0
parameter W8_3_REAL = 32'hBF3504F3; // -0.707107
parameter W8_3_IMAG = 32'hBF3504F3; // -0.707107
// Stage 1
logic S1_start;
logic [SIZE_DATA-1:0]     s1_x0_real, s1_x0_imag;
logic [SIZE_DATA-1:0]     s1_x1_real, s1_x1_imag;
logic [SIZE_DATA-1:0]     s1_x2_real, s1_x2_imag;
logic [SIZE_DATA-1:0]     s1_x3_real, s1_x3_imag;
logic [SIZE_DATA-1:0]     s1_x4_real, s1_x4_imag;
logic [SIZE_DATA-1:0]     s1_x5_real, s1_x5_imag;
logic [SIZE_DATA-1:0]     s1_x6_real, s1_x6_imag;
logic [SIZE_DATA-1:0]     s1_x7_real, s1_x7_imag;

Detect_edge #(
    .POS_EDGE       (1)   // 1: posedge, 0: negedge
) DETECT_START_STAGE1 (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_signal       (i_start),
    .o_signal       (w_start)
);


endmodule
