module ADD_SUB_EXP_comp #(
    parameter SIZE_DATA = 8
)(
    input logic [SIZE_DATA-1:0]     i_data_a        ,
    input logic [SIZE_DATA-1:0]     i_data_b        ,
    output logic                    o_compare           // a < b
);

COMP_8bit #(
    .SIZE_DATA      (SIZE_DATA)
) COMP_LESS_UNIT (
    .i_data_a       (i_data_a),
    .i_data_b       (i_data_b),
    .o_less         (o_compare)
);

endmodule
