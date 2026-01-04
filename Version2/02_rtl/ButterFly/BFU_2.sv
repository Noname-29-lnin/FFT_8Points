module BFU_2 #(
    parameter SIZE_DATA = 32
)(
    input logic [SIZE_DATA-1:0]     i_data_0_re ,
    input logic [SIZE_DATA-1:0]     i_data_0_im ,
    input logic [SIZE_DATA-1:0]     i_data_1_re ,
    input logic [SIZE_DATA-1:0]     i_data_1_im ,
    output logic [SIZE_DATA-1:0]    o_data_0_re ,
    output logic [SIZE_DATA-1:0]    o_data_0_im ,
    output logic [SIZE_DATA-1:0]    o_data_1_re ,
    output logic [SIZE_DATA-1:0]    o_data_1_im  
);

FPU_add_sub #(
    .NUM_OP(1)
) DATA_A_RE (
    .i_add_sub      (1'b0),
    .i_32_a         (i_data_0_re),
    .i_32_b         (i_data_1_re),
    .o_32_s         (o_data_0_re)
);
FPU_add_sub #(
    .NUM_OP(1)
) DATA_A_IM (
    .i_add_sub      (1'b0),
    .i_32_a         (i_data_0_im),
    .i_32_b         (i_data_1_im),
    .o_32_s         (o_data_0_im)
);

FPU_add_sub #(
    .NUM_OP(1)
) DATA_B_RE (
    .i_add_sub      (1'b1),
    .i_32_a         (i_data_0_re),
    .i_32_b         (i_data_1_re),
    .o_32_s         (o_data_1_re)
);
FPU_add_sub #(
    .NUM_OP(1)
) DATA_B_IM (
    .i_add_sub      (1'b1),
    .i_32_a         (i_data_0_im),
    .i_32_b         (i_data_1_im),
    .o_32_s         (o_data_1_im)
);


endmodule
