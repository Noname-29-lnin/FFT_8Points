module MUL_EXP_unit #(
    parameter SIZE_EXP  = 8
)(
    input logic [SIZE_EXP-1:0]      i_exp_a     ,
    input logic [SIZE_EXP-1:0]      i_exp_b     ,
    output logic [SIZE_EXP-1:0]     o_exp_pre    
);

// logic [SIZE_EXP-1:0] w_add_exp_sum;
// logic w_carry_sub;
// logic w_carry_sum;
// logic [SIZE_EXP-1:0]     w_exp_pre;
// CLA_8bit ADD_EXP_UNIT(
//     .i_carry            (1'b0),
//     .i_data_a           (i_exp_a),
//     .i_data_b           (i_exp_b),
//     .o_sum              (w_add_exp_sum),
//     .o_carry            (w_carry_sum)
// );

// // CLA_8bit SUB_EXP_UNIT(
// //     .i_carry            (1'b1),
// //     .i_data_a           (w_add_exp_sum),
// //     .i_data_b           (8'h80),
// //     .o_sum              (w_exp_pre),
// //     .o_carry            (w_carry_sub)
// // );
// SUB_8bit SUB_EXP_UNIT(
//     .i_carry            (1'b0),
//     .i_data_a           (w_add_exp_sum),
//     .i_data_b           (8'h7F),
//     .o_sub              (w_exp_pre),
//     .o_borrow           (w_carry_sub)
// );

// assign o_exp_pre = w_carry_sub ? '0 : w_exp_pre;
// assign o_exp_pre = w_exp_pre;

logic [SIZE_EXP:0] w_add_exp_sum;
logic [SIZE_EXP:0] w_sub_exp_sum;
assign w_add_exp_sum = {1'b0, i_exp_a} + {1'b0, i_exp_b};
assign w_sub_exp_sum = w_add_exp_sum - 127;
assign o_exp_pre = w_sub_exp_sum[SIZE_EXP] ? '0 : w_sub_exp_sum[SIZE_EXP-1:0];

endmodule
