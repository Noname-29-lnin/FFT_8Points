module fpu_mul #(
    parameter SIZE_DATA = 32
)(
    input logic [SIZE_DATA-1:0]     i_32_a  ,
    input logic [SIZE_DATA-1:0]     i_32_b  ,
    output logic [SIZE_DATA-1:0]    o_32_mul 
);

localparam EXP_ZERO = 8'h00;
localparam EXP_INF  = 8'hFF;
localparam MAN_ZERO = 24'h800000;
localparam MAN_NAN  = 24'hC00000;

logic w_sign_a, w_sign_b;
logic [7:0] w_exp_a, w_exp_b;
logic [23:0] w_man_a, w_man_b;
assign w_sign_a     = i_32_a[31];
assign w_sign_b     = i_32_b[31];
assign w_exp_a      = i_32_a[30:23];
assign w_exp_b      = i_32_b[30:23];
assign w_man_a      = {1'b1, i_32_a[22:0]};
assign w_man_b      = {1'b1, i_32_b[22:0]};

logic [7:0]     w_sub_exp_sub;
logic [23:0]    w_man_mul;
logic           w_man_over_flag;
logic           w_man_rounding;
logic [4:0]     w_lopd_one_pos;
logic           w_lopd_zero_flag;
logic [23:0]    w_nor_man;
logic           w_man_mul_un_flag;
logic           w_rounding_man_over_flag;
logic [7:0]     w_exp_adjustion;
logic [7:0]     w_exp_rnd;
logic [23:0]    w_man_rnd;
logic [1:0]     w_sel_exp;
logic [1:0]     w_sel_man;
logic           w_sign_result;
logic [7:0]     w_exp_result;
logic [23:0]    w_man_result;

MUL_EXP_unit #(
    .SIZE_EXP       (8)
) MUL_EXP_UNIT (
    .i_exp_a        (w_exp_a),
    .i_exp_b        (w_exp_b),
    .o_exp_pre      (w_sub_exp_sub) 
);

MUL_MAN_mul #(
    .SIZE_DATA          (24)    
) MAN_MUL_UNIT (
    .i_data_a           (w_man_a),
    .i_data_b           (w_man_b),
    .o_data_mul         (w_man_mul),
    .o_over_flag        (w_man_over_flag),
    .o_under_flag       (w_man_mul_un_flag),
    .o_rounding         (w_man_rounding)
);

LOPD_24bit #(
    .SIZE_DATA          (24),
    .SIZE_LOPD          (5)      
) LOPD_UNIT (
    .i_data             (w_man_mul),
    .o_one_position     (w_lopd_one_pos),
    .o_zero_flag        (w_lopd_zero_flag) 
);

MUL_NOR_unit #(
    .SIZE_LOPD          (5) ,
    .SIZE_DATA          (24)
) NOR_UNIT (
    .i_overflow         (w_man_over_flag),
    .i_zero_flag        (w_lopd_zero_flag),
    .i_one_position     (w_lopd_one_pos),
    .i_mantissa         (w_man_mul),
    .o_mantissa         (w_nor_man) 
);
MUL_MAN_rounding #(
    .SIZE_MAN           (24)
) MAN_ROUNDING_UNIT (
    .i_rounding_bit     (w_man_rounding),
    .i_man              (w_nor_man),
    .o_man_result       (w_man_rnd),
    .o_ov_flow          (w_rounding_man_over_flag) 
);
MUL_EXP_adjust #(
    .SIZE_DATA      (8),
    .SIZE_LOPD      (8)  
) MUL_EXP_ADJUST_UNIT (
    .i_un_flag      (w_man_mul_un_flag),
    .i_ov_flag      (w_man_over_flag),
    .i_zero_flag    (w_lopd_zero_flag),
    .i_one_pos      ({3'b0, w_lopd_one_pos}),
    .i_data_exp     (w_sub_exp_sub),
    .o_exp_adjust   (w_exp_adjustion)
);
MUL_EXP_rounding #(
    .SIZE_DATA      (8) 
) EXP_ROUNDING_UNIT (
    .i_carry_rounding   (w_rounding_man_over_flag),
    .i_exp_result       (w_exp_adjustion),
    .o_exp_result       (w_exp_rnd) 
);

MUL_PSC_unit #(
    .SIZE_EXP           (8),
    .SIZE_MAN           (24)
) PSC_UNIT (
    .i_exp_a            (w_exp_a),
    .i_exp_b            (w_exp_b),
    .i_man_a            (w_man_a),
    .i_man_b            (w_man_b),
    .o_sel_exp          (w_sel_exp),
    .o_sel_man          (w_sel_man) 
);
logic w_zero_A, w_zero_B;
assign w_zero_A = (~|w_exp_a) & (~|w_man_a[22:0]);
assign w_zero_B = (~|w_exp_b) & (~|w_man_b[22:0]);

assign w_sign_result    = w_sign_a ^ w_sign_b;
assign w_exp_result     = w_sel_exp[1] ? (w_sel_exp[0] ? EXP_INF : EXP_ZERO) : (w_zero_A | w_zero_B ? '0 : w_exp_rnd);
assign w_man_result     = w_sel_man[1] ? (w_sel_man[0] ? MAN_NAN : MAN_ZERO) : (w_zero_A | w_zero_B ? '0 : w_man_rnd);
assign o_32_mul = {w_sign_result, w_exp_result, w_man_result[22:0]};

endmodule
