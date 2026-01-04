module MUL_MAN_mul #(
    parameter int SIZE_DATA = 24
)(
    input  logic [SIZE_DATA-1:0]  i_data_a,
    input  logic [SIZE_DATA-1:0]  i_data_b,
    output logic [SIZE_DATA-1:0]  o_data_mul,
    output logic                  o_over_flag,
    output logic                  o_under_flag,
    output logic                  o_rounding    
);

    logic [(2*SIZE_DATA)-1:0] w_data_mul;
    // assign w_data_mul = i_data_a * i_data_b; // 48-bit
    Multiplier MUL_UNIT_MAN_UNIT (
        .A          (i_data_a),
        .B          (i_data_b),
        .Product    (w_data_mul)
    );

    logic norm_shift;
    assign o_over_flag = w_data_mul[47];
    assign o_under_flag = w_data_mul[46];

    logic [SIZE_DATA-1:0] mant_pre;
    logic guard, roundb, sticky;
    assign guard = w_data_mul[22];
    assign roundb = w_data_mul[21];
    assign sticky   = |w_data_mul[20:0];

    assign o_rounding = guard & (roundb | sticky);
    assign o_data_mul = w_data_mul[46:23];

endmodule
