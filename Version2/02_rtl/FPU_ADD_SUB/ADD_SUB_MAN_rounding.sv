module ADD_SUB_MAN_rounding #(
    parameter SIZE_MAN          = 32,
    parameter SIZE_MAN_RESULT   = 23
)(
    input logic [SIZE_MAN-1:0]          i_man           ,
    output logic [SIZE_MAN_RESULT-1:0]  o_man_result    ,
    output logic                        o_ov_flow       
);

logic [SIZE_MAN_RESULT-1:0] w_man_temp;
assign w_man_temp = i_man[SIZE_MAN-1:SIZE_MAN-SIZE_MAN_RESULT];

logic w_guard_bit, w_round_bit, w_sticky_bit;
assign w_guard_bit = i_man[7];
assign w_round_bit = i_man[6];
assign w_sticky_bit= |i_man[5:0];

logic w_rounding_result;
assign w_rounding_result = (w_guard_bit & w_round_bit) | (w_round_bit & w_sticky_bit);

logic [SIZE_MAN_RESULT-1:0] w_carry;
assign w_carry[0] = w_rounding_result;
genvar i;
generate
    for (i = 1; i < SIZE_MAN_RESULT; i++) begin : proc_propage_one
        assign w_carry[i] = (&w_man_temp[i-1:0]) & w_carry[0];
    end
endgenerate
assign o_man_result = w_man_temp ^ w_carry;
assign o_ov_flow = (&w_man_temp) & w_carry[0];

endmodule
