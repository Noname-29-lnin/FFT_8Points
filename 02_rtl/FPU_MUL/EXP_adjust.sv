module EXP_adjust #(
    parameter SIZE_DATA = 8,
    parameter SIZE_LOPD =8  
)(
    input logic                     i_un_flag   ,
    input logic                     i_ov_flag   ,
    input logic [SIZE_LOPD-1:0]     i_one_pos   ,
    input logic [SIZE_DATA-1:0]     i_data_exp  ,
    output logic [SIZE_DATA-1:0]    o_exp_adjust
);



endmodule
