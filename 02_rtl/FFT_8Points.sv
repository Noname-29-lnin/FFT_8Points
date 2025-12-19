module FFT_8Points #(
    parameter NUM_POINTS    = 8 ,
    parameter SIZE_DATA     = 32
)(
    input logic                                     i_clk       ,
    input logic                                     i_rst_n     ,
    input logic                                     i_start     ,

    input wire  [NUM_POINTS-1:0][SIZE_DATA-1:0]     i_data_re   ,
    input wire  [NUM_POINTS-1:0][SIZE_DATA-1:0]     i_data_im   ,
    
    output reg [NUM_POINTS-1:0][SIZE_DATA-1:0]      o_data_re   ,
    output reg [NUM_POINTS-1:0][SIZE_DATA-1:0]      o_data_im   ,
    output logic                                    o_done              
);

// Twiddle factors (IEEE 754 single-precision)
localparam W2_0_REAL = 32'h3F800000; // 1.0
localparam W2_0_IMAG = 32'h00000000; // 0.0
localparam W2_1_REAL = 32'h3F800000; // 1.0
localparam W2_1_IMAG = 32'h00000000; // 0.0
localparam W4_0_REAL = 32'h3F800000; // 1.0
localparam W4_0_IMAG = 32'h00000000; // 0.0
localparam W4_1_REAL = 32'h00000000; // 0.0
localparam W4_1_IMAG = 32'hBF800000; // -1.0
localparam W8_0_REAL = 32'h3F800000; // 1.0
localparam W8_0_IMAG = 32'h00000000; // 0.0
localparam W8_1_REAL = 32'h3F3504F3; // 0.707107
localparam W8_1_IMAG = 32'hBF3504F3; // -0.707107
localparam W8_2_REAL = 32'h00000000; // 0.0
localparam W8_2_IMAG = 32'hBF800000; // -1.0
localparam W8_3_REAL = 32'hBF3504F3; // -0.707107
localparam W8_3_IMAG = 32'hBF3504F3; // -0.707107

endmodule
