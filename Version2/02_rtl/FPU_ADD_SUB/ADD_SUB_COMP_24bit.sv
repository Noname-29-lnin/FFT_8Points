module ADD_SUB_COMP_24bit #(
    parameter SIZE_DATA = 24
)(
    input  logic [SIZE_DATA-1:0] i_data_a,
    input  logic [SIZE_DATA-1:0] i_data_b,
    output logic                 o_less //,
    // output logic                 o_equal
);

    logic w_less_0_0, w_less_0_1, w_less_0_2, w_less_0_3, w_less_0_4, w_less_0_5;
    logic w_equal_0_0, w_equal_0_1, w_equal_0_2, w_equal_0_3, w_equal_0_4, w_equal_0_5;

    ADD_SUB_COMP_4bit u_i_data_0 (
        .i_data_a (i_data_a[3:0]),
        .i_data_b (i_data_b[3:0]),
        .o_less   (w_less_0_0),
        .o_equal  (w_equal_0_0)
    );

    ADD_SUB_COMP_4bit u_i_data_1 (
        .i_data_a (i_data_a[7:4]),
        .i_data_b (i_data_b[7:4]),
        .o_less   (w_less_0_1),
        .o_equal  (w_equal_0_1)
    );

    ADD_SUB_COMP_4bit u_i_data_2 (
        .i_data_a (i_data_a[11:8]),
        .i_data_b (i_data_b[11:8]),
        .o_less   (w_less_0_2),
        .o_equal  (w_equal_0_2)
    );

    ADD_SUB_COMP_4bit u_i_data_3 (
        .i_data_a (i_data_a[15:12]),
        .i_data_b (i_data_b[15:12]),
        .o_less   (w_less_0_3),
        .o_equal  (w_equal_0_3)
    );

    ADD_SUB_COMP_4bit u_i_data_4 (
        .i_data_a (i_data_a[19:16]),
        .i_data_b (i_data_b[19:16]),
        .o_less   (w_less_0_4),
        .o_equal  (w_equal_0_4)
    );

    ADD_SUB_COMP_4bit u_i_data_5 (
        .i_data_a (i_data_a[23:20]),
        .i_data_b (i_data_b[23:20]),
        .o_less   (w_less_0_5),
        .o_equal  (w_equal_0_5)
    );

    assign o_less = (w_less_0_5)
                  | (w_equal_0_5 & w_less_0_4)
                  | (w_equal_0_5 & w_equal_0_4 & w_less_0_3)
                  | (w_equal_0_5 & w_equal_0_4 & w_equal_0_3 & w_less_0_2)
                  | (w_equal_0_5 & w_equal_0_4 & w_equal_0_3 & w_equal_0_2 & w_less_0_1)
                  | (w_equal_0_5 & w_equal_0_4 & w_equal_0_3 & w_equal_0_2 & w_equal_0_1 & w_less_0_0);

endmodule
