module Butterfly_Unit #(
    parameter SIZE_DATA = 32
)(
    input logic [SIZE_DATA-1:0]         i_data_0_re ,
    input logic [SIZE_DATA-1:0]         i_data_0_im ,
    input logic [SIZE_DATA-1:0]         i_data_1_re ,
    input logic [SIZE_DATA-1:0]         i_data_1_im ,
    input logic [SIZE_DATA-1:0]         i_twiddle_re,
    input logic [SIZE_DATA-1:0]         i_twiddle_im,

    output logic [SIZE_DATA-1:0]        o_data_0_re ,
    output logic [SIZE_DATA-1:0]        o_data_0_im ,    
    output logic [SIZE_DATA-1:0]        o_data_1_re ,
    output logic [SIZE_DATA-1:0]        o_data_1_im      
);

wire [31:0] bi_twiddle_re, bi_twiddle_im;
wire [31:0] temp1, temp2, temp3, temp4;
// Complex multiplication: bw = b * w
// bi_twiddle_re = i_data_1_re * i_twiddle_re - i_data_1_im * i_twiddle_im
// fp_multiplier mult1 (.a(i_data_1_re), .b(i_twiddle_re), .result(temp1)); // i_data_1_re * i_twiddle_re
fpu_mul #(
    .SIZE_DATA      (SIZE_DATA)
) FPU_MUL_0 (
    .i_32_a         (i_data_1_re),
    .i_32_b         (i_twiddle_re),
    .o_32_mul       (temp1) 
);
// fp_multiplier mult2 (.a(i_data_1_im), .b(i_twiddle_im), .result(temp2)); // i_data_1_im * i_twiddle_im
fpu_mul #(
    .SIZE_DATA      (SIZE_DATA)
) FPU_MUL_1 (
    .i_32_a         (i_data_1_im),
    .i_32_b         (i_twiddle_im),
    .o_32_mul       (temp2) 
);
// fp_adder_combined sub1 (.a(temp1), .b({~temp2[31], temp2[30:0]}), .result(bi_twiddle_re)); // temp1 - temp
FPU_add_sub #(
    .NUM_OP     (1)
) SUB_UNIT_1 (
    .i_add_sub  (1'b1),
    .i_32_a     (temp1),
    .i_32_b     (temp2),
    .o_32_s     (bi_twiddle_re) 
);
// bi_twiddle_im = i_data_1_re * i_twiddle_im + i_data_1_im * i_twiddle_re
fp_multiplier mult3 (.a(i_data_1_re), .b(i_twiddle_im), .result(temp3)); // i_data_1_re * i_twiddle_im
fpu_mul #(
    .SIZE_DATA      (SIZE_DATA)
) FPU_MUL_2 (
    .i_32_a         (i_data_1_re),
    .i_32_b         (i_twiddle_im),
    .o_32_mul       (temp3) 
);
// fp_multiplier mult4 (.a(i_data_1_im), .b(i_twiddle_re), .result(temp4)); // i_data_1_im * i_twiddle_re
fpu_mul #(
    .SIZE_DATA      (SIZE_DATA)
) FPU_MUL_3 (
    .i_32_a         (i_data_1_im),
    .i_32_b         (i_twiddle_re),
    .o_32_mul       (temp4) 
);
// fp_adder_combined add1 (.a(temp3), .b(temp4), .result(bi_twiddle_im)); // temp3 + temp4
FPU_add_sub #(
    .NUM_OP     (1)
) ADD_UNIT_1 (
    .i_add_sub  (1'b0),
    .i_32_a     (temp3),
    .i_32_b     (temp4),
    .o_32_s     (bi_twiddle_im) 
);
// y0 = a + bw
// fp_adder_combined add2 (.a(i_data_0_re), .b(bi_twiddle_re), .result(y0_real));
FPU_add_sub #(
    .NUM_OP     (1)
) ADD_UNIT_2 (
    .i_add_sub  (1'b0),
    .i_32_a     (i_data_0_re),
    .i_32_b     (bi_twiddle_re),
    .o_32_s     (o_data_0_re) 
);
// fp_adder_combined add3 (.a(i_data_0_im), .b(bi_twiddle_im), .result(y0_imag));
FPU_add_sub #(
    .NUM_OP     (1)
) ADD_UNIT_3 (
    .i_add_sub  (1'b0),
    .i_32_a     (i_data_0_im),
    .i_32_b     (bi_twiddle_im),
    .o_32_s     (o_data_0_im) 
);
// y1 = a - bw
// fp_adder_combined sub2 (.a(i_data_0_re), .b({~bi_twiddle_re[31], bi_twiddle_re[30:0]}), .result(y1_real));
FPU_add_sub #(
    .NUM_OP     (1)
) SUB_UNIT_2 (
    .i_add_sub  (1'b0),
    .i_32_a     (i_data_0_re),
    .i_32_b     (bi_twiddle_re),
    .o_32_s     (o_data_1_re) 
);
// fp_adder_combined sub3 (.a(i_data_0_im), .b({~bi_twiddle_im[31], bi_twiddle_im[30:0]}), .result(y1_imag));
FPU_add_sub #(
    .NUM_OP     (1)
) SUB_UNIT_3 (
    .i_add_sub  (1'b1),
    .i_32_a     (i_data_0_im),
    .i_32_b     (bi_twiddle_im),
    .o_32_s     (o_data_1_im) 
);

endmodule
