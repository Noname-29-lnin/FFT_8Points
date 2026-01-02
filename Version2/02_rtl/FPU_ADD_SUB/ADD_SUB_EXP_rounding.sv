module ADD_SUB_EXP_rounding #(
    parameter SIZE_DATA     = 8 
)(
    input logic                     i_carry_rounding    ,
    input logic [SIZE_DATA-1:0]     i_exp_result        ,
    output logic [SIZE_DATA-1:0]    o_exp_result         
);

    logic [SIZE_DATA-1:0] w_carry;
    assign w_carry[0] = i_carry_rounding;
    genvar i;
    generate
        for (i = 1; i < 8; i++) begin : proc_propage_one
            assign w_carry[i] = (&i_exp_result[i-1:0]) & w_carry[0];
        end
    endgenerate
    assign o_exp_result = i_exp_result ^ w_carry;

endmodule
