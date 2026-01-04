module BFU_4 #(
    parameter SIZE_DATA = 32
)(
    input logic [SIZE_DATA-1:0]     i_data_0_re ,
    input logic [SIZE_DATA-1:0]     i_data_0_im ,
    input logic [SIZE_DATA-1:0]     i_data_1_re ,
    input logic [SIZE_DATA-1:0]     i_data_1_im ,
    input logic [SIZE_DATA-1:0]     i_data_2_re ,
    input logic [SIZE_DATA-1:0]     i_data_2_im ,
    input logic [SIZE_DATA-1:0]     i_data_3_re ,
    input logic [SIZE_DATA-1:0]     i_data_3_im ,
    
    output logic [SIZE_DATA-1:0]    o_data_0_re ,
    output logic [SIZE_DATA-1:0]    o_data_0_im ,
    output logic [SIZE_DATA-1:0]    o_data_1_re ,
    output logic [SIZE_DATA-1:0]    o_data_1_im ,
    output logic [SIZE_DATA-1:0]    o_data_2_re ,
    output logic [SIZE_DATA-1:0]    o_data_2_im ,
    output logic [SIZE_DATA-1:0]    o_data_3_re ,
    output logic [SIZE_DATA-1:0]    o_data_3_im  
);

logic [SIZE_DATA-1:0]     w_data_2_re;
logic [SIZE_DATA-1:0]     w_data_2_im;
logic [SIZE_DATA-1:0]     w_data_3_re;
logic [SIZE_DATA-1:0]     w_data_3_im;

assign w_data_2_re = i_data_2_re; // (a + jb) *W^0_N = a + jb
assign w_data_2_im = i_data_2_im; // 
assign w_data_3_re = i_data_3_im;                                              // (a+jb)*W^2_N => b - ja
assign w_data_3_im = {~i_data_3_re[SIZE_DATA-1], i_data_3_re[SIZE_DATA-2:0]}; // 

BFU_2 #(
    .SIZE_DATA      (SIZE_DATA)
) BFU2_UNIT0 (
    .i_data_0_re    (i_data_0_re),
    .i_data_0_im    (i_data_0_im),
    .i_data_1_re    (w_data_2_re),
    .i_data_1_im    (w_data_2_im),
    .o_data_0_re    (o_data_0_re),
    .o_data_0_im    (o_data_0_im),
    .o_data_1_re    (o_data_2_re),
    .o_data_1_im    (o_data_2_im) 
);
BFU_2 #(
    .SIZE_DATA      (SIZE_DATA)
) BFU2_UNIT1 (
    .i_data_0_re    (i_data_1_re),
    .i_data_0_im    (i_data_1_im),
    .i_data_1_re    (w_data_3_re),
    .i_data_1_im    (w_data_3_im),
    .o_data_0_re    (o_data_1_re),
    .o_data_0_im    (o_data_1_im),
    .o_data_1_re    (o_data_3_re),
    .o_data_1_im    (o_data_3_im) 
);

endmodule
