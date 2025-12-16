module EXP_sub #(
    parameter SIZE_EXP_SUB  = 8
)(
    input logic [SIZE_EXP_SUB-1:0]   i_data_a,
    input logic [SIZE_EXP_SUB-1:0]   i_data_b,
    output logic [SIZE_EXP_SUB-1:0]  o_sub        
);

logic [SIZE_EXP_SUB-1:0] w_data_b;
assign w_data_b = ~(i_data_b);

CLA_8bit CLA_8BIT_UNIT (
    .i_carry    (1'b1),
    .i_data_a   (i_data_a),
    .i_data_b   (w_data_b),
    .o_sum      (o_sub),
    .o_carry    ()
);

endmodule
