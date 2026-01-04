module BFU_8 #(
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
    input logic [SIZE_DATA-1:0]     i_data_4_re ,
    input logic [SIZE_DATA-1:0]     i_data_4_im ,
    input logic [SIZE_DATA-1:0]     i_data_5_re ,
    input logic [SIZE_DATA-1:0]     i_data_5_im ,
    input logic [SIZE_DATA-1:0]     i_data_6_re ,
    input logic [SIZE_DATA-1:0]     i_data_6_im ,
    input logic [SIZE_DATA-1:0]     i_data_7_re ,
    input logic [SIZE_DATA-1:0]     i_data_7_im ,
    
    output logic [SIZE_DATA-1:0]    o_data_0_re ,
    output logic [SIZE_DATA-1:0]    o_data_0_im ,
    output logic [SIZE_DATA-1:0]    o_data_1_re ,
    output logic [SIZE_DATA-1:0]    o_data_1_im ,
    output logic [SIZE_DATA-1:0]    o_data_2_re ,
    output logic [SIZE_DATA-1:0]    o_data_2_im ,
    output logic [SIZE_DATA-1:0]    o_data_3_re ,
    output logic [SIZE_DATA-1:0]    o_data_3_im ,
    output logic [SIZE_DATA-1:0]    o_data_4_re ,
    output logic [SIZE_DATA-1:0]    o_data_4_im ,
    output logic [SIZE_DATA-1:0]    o_data_5_re ,
    output logic [SIZE_DATA-1:0]    o_data_5_im ,
    output logic [SIZE_DATA-1:0]    o_data_6_re ,
    output logic [SIZE_DATA-1:0]    o_data_6_im ,
    output logic [SIZE_DATA-1:0]    o_data_7_re ,
    output logic [SIZE_DATA-1:0]    o_data_7_im  
);

logic [SIZE_DATA-1:0]     w_data_4_re;
logic [SIZE_DATA-1:0]     w_data_4_im;
logic [SIZE_DATA-1:0]     w_i_data_5_re;
logic [SIZE_DATA-1:0]     w_i_data_5_im;
logic [SIZE_DATA-1:0]     w_data_5_re;
logic [SIZE_DATA-1:0]     w_data_5_im;
logic [SIZE_DATA-1:0]     w_data_6_re;
logic [SIZE_DATA-1:0]     w_data_6_im;
logic [SIZE_DATA-1:0]     w_i_data_7_re;
logic [SIZE_DATA-1:0]     w_i_data_7_im;
logic [SIZE_DATA-1:0]     w_data_7_re;
logic [SIZE_DATA-1:0]     w_data_7_im;

assign w_data_4_re = i_data_4_re; // (a + jb) *W^0_N = a + jb
assign w_data_4_im = i_data_4_im; // 
Complex_Multiplier #(
    .SIZE_DATA      (SIZE_DATA)
) INPUT_DATA_5 (
    .i_data_0_re    (i_data_5_re),
    .i_data_0_im    (i_data_5_im),
    .o_data_0_re    (w_i_data_5_re),
    .o_data_0_im    (w_i_data_5_im) 
);
assign w_data_5_re = w_i_data_5_re; // (a + jb)*W^1_N = 0.707(a+b) - j*0.707*(a-b)
assign w_data_5_im = {w_i_data_5_im[SIZE_DATA-1]^1'b1, w_i_data_5_im[SIZE_DATA-2:0]};
assign w_data_6_re = i_data_6_im;                                              // (a+jb)*W^2_N => b - ja
assign w_data_6_im = {i_data_6_re[SIZE_DATA-1]^1, i_data_6_re[SIZE_DATA-2:0]}; // 
Complex_Multiplier #(
    .SIZE_DATA      (SIZE_DATA)
) INPUT_DATA_7 (
    .i_data_0_re    (i_data_7_re),
    .i_data_0_im    (i_data_7_im),
    .o_data_0_re    (w_i_data_7_re),
    .o_data_0_im    (w_i_data_7_im) 
);
assign w_data_7_re = {w_i_data_7_im[SIZE_DATA-1]^1'b1, w_i_data_7_im[SIZE_DATA-2:0]}; // (a + jb)*W^3_N = -0.707(a-b) - j*0.707*(a+b)
assign w_data_7_im = {w_i_data_7_re[SIZE_DATA-1]^1'b1, w_i_data_7_re[SIZE_DATA-2:0]};


BFU_2 #(
    .SIZE_DATA      (SIZE_DATA)
) BFU2_UNIT0 (
    .i_data_0_re    (i_data_0_re),
    .i_data_0_im    (i_data_0_im),
    .i_data_1_re    (w_data_4_re),
    .i_data_1_im    (w_data_4_im),
    .o_data_0_re    (o_data_0_re),
    .o_data_0_im    (o_data_0_im),
    .o_data_1_re    (o_data_4_re),
    .o_data_1_im    (o_data_4_im) 
);
BFU_2 #(
    .SIZE_DATA      (SIZE_DATA)
) BFU2_UNIT1 (
    .i_data_0_re    (i_data_1_re),
    .i_data_0_im    (i_data_1_im),
    .i_data_1_re    (w_data_5_re),
    .i_data_1_im    (w_data_5_im),
    .o_data_0_re    (o_data_1_re),
    .o_data_0_im    (o_data_1_im),
    .o_data_1_re    (o_data_5_re),
    .o_data_1_im    (o_data_5_im) 
);

BFU_2 #(
    .SIZE_DATA      (SIZE_DATA)
) BFU2_UNIT2 (
    .i_data_0_re    (i_data_2_re),
    .i_data_0_im    (i_data_2_im),
    .i_data_1_re    (w_data_6_re),
    .i_data_1_im    (w_data_6_im),
    .o_data_0_re    (o_data_2_re),
    .o_data_0_im    (o_data_2_im),
    .o_data_1_re    (o_data_6_re),
    .o_data_1_im    (o_data_6_im) 
);
BFU_2 #(
    .SIZE_DATA      (SIZE_DATA)
) BFU2_UNIT3 (
    .i_data_0_re    (i_data_3_re),
    .i_data_0_im    (i_data_3_im),
    .i_data_1_re    (w_data_7_re),
    .i_data_1_im    (w_data_7_im),
    .o_data_0_re    (o_data_3_re),
    .o_data_0_im    (o_data_3_im),
    .o_data_1_re    (o_data_7_re),
    .o_data_1_im    (o_data_7_im) 
);

endmodule
