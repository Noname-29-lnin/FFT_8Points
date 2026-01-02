module ADD_SUB_COMP_4bit(
    input  logic [3:0] i_data_a,
    input  logic [3:0] i_data_b,
    output logic       o_less,
    output logic       o_equal
);
    logic w_less_low, w_equal_low;
    logic w_less_high, w_equal_high;

    assign o_less = (~i_data_a[3] & ~i_data_a[2] & ~i_data_a[1] & ~i_data_a[0] & i_data_b[0]) | (~i_data_a[3] & ~i_data_a[2] & ~i_data_a[1] & i_data_b[1]) | (~i_data_a[3] & ~i_data_a[2] & i_data_b[2]) | (~i_data_a[3] & i_data_b[3]) | (~i_data_a[3] & ~i_data_a[2] & ~i_data_a[0] & i_data_b[1] & i_data_b[0]) | (~i_data_a[3] & ~i_data_a[1] & ~i_data_a[0] & i_data_b[2] & i_data_b[0]) | (~i_data_a[3] & ~i_data_a[1] & i_data_b[2] & i_data_b[1]) | (~i_data_a[3] & ~i_data_a[0] & i_data_b[2] & i_data_b[1] & i_data_b[0]) | (~i_data_a[2] & ~i_data_a[1] & ~i_data_a[0] & i_data_b[3] & i_data_b[0]) | (~i_data_a[2] & ~i_data_a[1] & i_data_b[3] & i_data_b[1]) | (~i_data_a[2] & i_data_b[3] & i_data_b[2]) | (~i_data_a[2] & ~i_data_a[0] & i_data_b[3] & i_data_b[1] & i_data_b[0]) | (~i_data_a[1] & ~i_data_a[0] & i_data_b[3] & i_data_b[2] & i_data_b[0]) | (~i_data_a[1] & i_data_b[3] & i_data_b[2] & i_data_b[1]) | (~i_data_a[0] & i_data_b[3] & i_data_b[2] & i_data_b[1] & i_data_b[0]);
    assign o_equal = ~|(i_data_a ^ i_data_b);
endmodule
