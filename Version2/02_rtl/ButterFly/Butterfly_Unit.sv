module Butterfly_Unit #(
    parameter SIZE_DATA = 32
)(
    input  logic [SIZE_DATA-1:0] i_data_0_re,
    input  logic [SIZE_DATA-1:0] i_data_0_im,
    input  logic [SIZE_DATA-1:0] i_data_1_re,
    input  logic [SIZE_DATA-1:0] i_data_1_im,
    input  logic [SIZE_DATA-1:0] i_twiddle_re,
    input  logic [SIZE_DATA-1:0] i_twiddle_im,

    output logic [SIZE_DATA-1:0] o_data_0_re,
    output logic [SIZE_DATA-1:0] o_data_0_im,
    output logic [SIZE_DATA-1:0] o_data_1_re,
    output logic [SIZE_DATA-1:0] o_data_1_im
);

wire [31:0] temp1, temp2, temp3, temp4;
wire [31:0] bi_twiddle_re, bi_twiddle_im;

// temp1 = b_re * w_re
fpu_mul #(.SIZE_DATA(SIZE_DATA)) mul0 (
    .i_32_a(i_data_1_re),
    .i_32_b(i_twiddle_re),
    .o_32_mul(temp1)
);

// temp2 = b_im * w_im
fpu_mul #(.SIZE_DATA(SIZE_DATA)) mul1 (
    .i_32_a(i_data_1_im),
    .i_32_b(i_twiddle_im),
    .o_32_mul(temp2)
);

// t_re = temp1 - temp2
FPU_add_sub #(.NUM_OP(1)) sub0 (
    .i_add_sub(1'b1),
    .i_32_a(temp1),
    .i_32_b(temp2),
    .o_32_s(bi_twiddle_re)
);

// temp3 = b_re * w_im
fpu_mul #(.SIZE_DATA(SIZE_DATA)) mul2 (
    .i_32_a(i_data_1_re),
    .i_32_b(i_twiddle_im),
    .o_32_mul(temp3)
);

// temp4 = b_im * w_re
fpu_mul #(.SIZE_DATA(SIZE_DATA)) mul3 (
    .i_32_a(i_data_1_im),
    .i_32_b(i_twiddle_re),
    .o_32_mul(temp4)
);

// t_im = temp3 + temp4
FPU_add_sub #(.NUM_OP(1)) add0 (
    .i_add_sub(1'b0),
    .i_32_a(temp3),
    .i_32_b(temp4),
    .o_32_s(bi_twiddle_im)
);

// y0 = a + t
FPU_add_sub #(.NUM_OP(1)) add1 (
    .i_add_sub(1'b0),
    .i_32_a(i_data_0_re),
    .i_32_b(bi_twiddle_re),
    .o_32_s(o_data_0_re)
);

FPU_add_sub #(.NUM_OP(1)) add2 (
    .i_add_sub(1'b0),
    .i_32_a(i_data_0_im),
    .i_32_b(bi_twiddle_im),
    .o_32_s(o_data_0_im)
);

// y1 = a - t
FPU_add_sub #(.NUM_OP(1)) sub1 (
    .i_add_sub(1'b1),
    .i_32_a(i_data_0_re),
    .i_32_b(bi_twiddle_re),
    .o_32_s(o_data_1_re)
);

FPU_add_sub #(.NUM_OP(1)) sub2 (
    .i_add_sub(1'b1),
    .i_32_a(i_data_0_im),
    .i_32_b(bi_twiddle_im),
    .o_32_s(o_data_1_im)
);

endmodule
