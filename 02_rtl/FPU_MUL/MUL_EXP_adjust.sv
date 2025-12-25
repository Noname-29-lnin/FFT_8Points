module MUL_EXP_adjust #(
    parameter SIZE_DATA = 8,
    parameter SIZE_LOPD =8  
)(
    input logic                     i_un_flag   ,
    input logic                     i_ov_flag   ,
    input logic                     i_zero_flag ,
    input logic [SIZE_LOPD-1:0]     i_one_pos   ,
    input logic [SIZE_DATA-1:0]     i_data_exp  ,
    output logic [SIZE_DATA-1:0]    o_exp_adjust
);

//////////////////////////////////////////////////////////////////////////////////
// Internal Signal
//////////////////////////////////////////////////////////////////////////////////
logic [SIZE_DATA-1:0] w_exp_result;
logic w_i_carry;
assign w_i_carry = ~(i_ov_flag | i_un_flag);

logic [SIZE_DATA-1:0] w_data_b;
assign w_data_b = i_ov_flag ? 8'b0000_0001 : (i_un_flag ? '0 : ~(i_one_pos));
//////////////////////////////////////////////////////////////////////////////////
// Submodule
//////////////////////////////////////////////////////////////////////////////////
CLA_8bit CLA_8BIT_UNIT (
    .i_carry    (w_i_carry),
    .i_data_a   (i_data_exp),
    .i_data_b   (w_data_b),
    .o_sum      (w_exp_result),
    .o_carry    ()
);

assign o_exp_adjust = i_zero_flag ? 8'h00 : w_exp_result;

endmodule
