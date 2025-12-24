module MUL_MAN_mul #(
    parameter SIZE_DATA = 24    
)(
    input logic [SIZE_DATA-1:0]         i_data_a    ,
    input logic [SIZE_DATA-1:0]         i_data_b    ,
    output logic [SIZE_DATA-1:0]        o_data_mul  ,
    output logic                        o_over_flag ,
    output logic                        o_rounding      
);
logic w_guard_bit, w_round_bit, w_sticky_bit;
logic [(2*SIZE_DATA)-1:0] w_data_mul;
assign w_data_mul = i_data_a * i_data_b;

assign o_over_flag  = w_data_mul[47];
assign o_data_mul   = w_data_mul[46:23];
assign w_guard_bit  = w_data_mul[22];
assign w_round_bit  = w_data_mul[21];
assign w_sticky_bit = |w_data_mul[20:0];
assign o_rounding   = (w_guard_bit & w_round_bit) | (w_round_bit & w_sticky_bit);
endmodule
