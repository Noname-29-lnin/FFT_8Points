module MUL_EXP_unit #(
    parameter SIZE_EXP  = 8
)(
    input logic [SIZE_EXP-1:0]      i_exp_a     ,
    input logic [SIZE_EXP-1:0]      i_exp_b     ,
    output logic [SIZE_EXP-1:0]     o_exp_pre    
);

logic [SIZE_EXP:0] w_add_exp_sum;
logic [SIZE_EXP:0] w_sub_exp_sum;
assign w_add_exp_sum = {1'b0, i_exp_a} + {1'b0, i_exp_b};
assign w_sub_exp_sum = w_add_exp_sum - 127;
assign o_exp_pre = w_sub_exp_sum[SIZE_EXP] ? '0 : w_sub_exp_sum[SIZE_EXP-1:0];

endmodule
