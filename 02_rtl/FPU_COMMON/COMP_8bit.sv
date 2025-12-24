module COMP_8bit #(
    parameter SIZE_DATA = 8
)(
    input  logic [SIZE_DATA-1:0] i_data_a,
    input  logic [SIZE_DATA-1:0] i_data_b,
    output logic                 o_less
);
    logic w_less_low, w_equal_low;
    logic w_less_high, w_equal_high;

    COMP_4bit u_low (
        .i_data_a (i_data_a[3:0]),
        .i_data_b (i_data_b[3:0]),
        .o_less   (w_less_low),
        .o_equal  (w_equal_low)
    );

    COMP_4bit u_high (
        .i_data_a (i_data_a[7:4]),
        .i_data_b (i_data_b[7:4]),
        .o_less   (w_less_high),
        .o_equal  (w_equal_high)
    );

    assign o_less = w_less_high | (w_equal_high & w_less_low);
endmodule
