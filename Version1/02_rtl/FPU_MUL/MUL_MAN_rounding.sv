module MUL_MAN_rounding #(
    parameter SIZE_MAN   = 24
)(
    input logic                 i_rounding_bit  ,
    input logic [SIZE_MAN-1:0]  i_man           ,
    output logic [SIZE_MAN-1:0] o_man_result    ,
    output logic                o_ov_flow       
);

logic [SIZE_MAN-1:0] w_carry;
assign w_carry[0] = i_rounding_bit;
genvar i;
generate
    for (i = 1; i < SIZE_MAN; i++) begin : proc_propage_one
        assign w_carry[i] = (&i_man[i-1:0]) & w_carry[0];
    end
endgenerate
assign o_man_result = i_man ^ w_carry;
assign o_ov_flow = i_man[SIZE_MAN-1] & w_carry[SIZE_MAN-1];

endmodule
