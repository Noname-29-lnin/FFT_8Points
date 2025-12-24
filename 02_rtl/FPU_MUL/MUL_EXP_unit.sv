module MUL_EXP_unit #(
    parameter SIZE_EXP  = 8
)(
    input logic [SIZE_EXP-1:0]      i_exp_a     ,
    input logic [SIZE_EXP-1:0]      i_exp_b     ,
    output logic [SIZE_EXP-1:0]     o_exp_pre    
);

logic [SIZE_EXP-1:0] w_add_exp_sum;

CLA_8bit ADD_EXP_UNIT(
    .i_carry            (1'b0),
    .i_data_a           (i_exp_a),
    .i_data_b           (i_exp_b),
    .o_sum              (w_add_exp_sum),
    .o_carry            ()
);

CLA_8bit SUB_EXP_UNIT(
    .i_carry            (1'b1),
    .i_data_a           (w_add_exp_sum),
    .i_data_b           (8'h80),
    .o_sum              (o_exp_pre),
    .o_carry            ()
);

endmodule
