module ADD_SUB_LOPD_8bit(
    input logic [7:0]       i_data  ,
    output logic [2:0]      o_pos_one,
    output logic            o_zero_flag
);

////////////////////////////////////////////////////////////
// LOD_8bit_unit
////////////////////////////////////////////////////////////
logic [2:0] w_o_pos_one;
assign w_o_pos_one[0] = (~i_data[7] & ~i_data[5] & ~i_data[3] & ~i_data[1] & i_data[0]) | (~i_data[7] & ~i_data[5] & ~i_data[3] & i_data[2]) | (~i_data[7] & ~i_data[5] & i_data[4]) | (~i_data[7] & i_data[6]);
assign w_o_pos_one[1] = (~i_data[7] & ~i_data[6] & ~i_data[3] & ~i_data[2] & i_data[0]) | (~i_data[7] & ~i_data[6] & ~i_data[3] & ~i_data[2] & i_data[1]) | (~i_data[7] & ~i_data[6] & i_data[4]) | (~i_data[7] & ~i_data[6] & i_data[5]);
assign w_o_pos_one[2] = (~i_data[7] & ~i_data[6] & ~i_data[5] & ~i_data[4] & i_data[0]) | (~i_data[7] & ~i_data[6] & ~i_data[5] & ~i_data[4] & i_data[1]) | (~i_data[7] & ~i_data[6] & ~i_data[5] & ~i_data[4] & i_data[2]) | (~i_data[7] & ~i_data[6] & ~i_data[5] & ~i_data[4] & i_data[3]);
assign o_zero_flag = ~(i_data[7] | i_data[6] | i_data[5] | i_data[4] | i_data[3] | i_data[2] | i_data[1] | i_data[0] );
assign o_pos_one = w_o_pos_one;

endmodule