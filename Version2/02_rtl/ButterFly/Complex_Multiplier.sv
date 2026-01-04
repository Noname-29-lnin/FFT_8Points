module Complex_Multiplier #(
    parameter SIZE_DATA = 32
)(
    input logic [SIZE_DATA-1:0]     i_data_0_re ,
    input logic [SIZE_DATA-1:0]     i_data_0_im ,
    
    output logic [SIZE_DATA-1:0]    o_data_0_re ,
    output logic [SIZE_DATA-1:0]    o_data_0_im  
);

logic [SIZE_DATA-1:0] w_data_add, w_data_sub;
parameter SQUARE_TWO = 32'h3F3504F3; // 0.707107

FPU_add_sub #(
    .NUM_OP(1)
) DATA_A_RE (
    .i_add_sub      (1'b0), // a + b
    .i_32_a         (i_data_0_re),
    .i_32_b         (i_data_0_im),
    .o_32_s         (w_data_add)
);
FPU_add_sub #(
    .NUM_OP(1)
) DATA_A_IM (
    .i_add_sub      (1'b1), // a - b
    .i_32_a         (i_data_0_re),
    .i_32_b         (i_data_0_im),
    .o_32_s         (w_data_sub)
);

fpu_mul #(
    .SIZE_DATA(SIZE_DATA)
) mul1_add (
    .i_32_a         (w_data_add),
    .i_32_b         (SQUARE_TWO),
    .o_32_mul       (o_data_0_re)
);
fpu_mul #(
    .SIZE_DATA(SIZE_DATA)
) mul1_sub (
    .i_32_a         (w_data_sub),
    .i_32_b         (SQUARE_TWO),
    .o_32_mul       (o_data_0_im)
);

endmodule
