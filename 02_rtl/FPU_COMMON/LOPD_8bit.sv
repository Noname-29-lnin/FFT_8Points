module LOPD_8bit(
    input logic [7:0]       i_data  ,
    output logic [2:0]      o_pos_one,
    output logic            o_zero_flag
);

////////////////////////////////////////////////////////////
// LOPD_4bit_unit_0
////////////////////////////////////////////////////////////
// logic w_zero_flag_0;
// logic [1:0] w_pos_one_0;
// LOPD_4bit LOPD_4bit_unit_0 (
//     .i_data         (i_data[3:0]),
//     .o_pos_one      (w_pos_one_0),
//     .o_zero_flag    (w_zero_flag_0)
// );

////////////////////////////////////////////////////////////
// LOPD_4bit_unit_1
////////////////////////////////////////////////////////////
// logic w_zero_flag_1;
// logic [1:0] w_pos_one_1;
// LOPD_4bit LOPD_4bit_unit_1 (
//     .i_data         (i_data[7:4]),
//     .o_pos_one      (w_pos_one_1),
//     .o_zero_flag    (w_zero_flag_1)
// );

////////////////////////////////////////////////////////////
// LOD_8bit_unit
////////////////////////////////////////////////////////////
logic [2:0] w_o_pos_one;
// assign o_zero_flag = w_zero_flag_0 & w_zero_flag_1;
// assign w_o_pos_one[2] = w_zero_flag_1;
// assign w_o_pos_one[1] = w_zero_flag_1 ? w_pos_one_0[1] : w_pos_one_1[1];
// assign w_o_pos_one[0] = w_zero_flag_1 ? w_pos_one_0[0] : w_pos_one_1[0];
assign w_o_pos_one[0] = (~i_data[7] & ~i_data[5] & ~i_data[3] & ~i_data[1] & i_data[0]) | (~i_data[7] & ~i_data[5] & ~i_data[3] & i_data[2]) | (~i_data[7] & ~i_data[5] & i_data[4]) | (~i_data[7] & i_data[6]);
assign w_o_pos_one[1] = (~i_data[7] & ~i_data[6] & ~i_data[3] & ~i_data[2] & i_data[0]) | (~i_data[7] & ~i_data[6] & ~i_data[3] & ~i_data[2] & i_data[1]) | (~i_data[7] & ~i_data[6] & i_data[4]) | (~i_data[7] & ~i_data[6] & i_data[5]);
assign w_o_pos_one[2] = (~i_data[7] & ~i_data[6] & ~i_data[5] & ~i_data[4] & i_data[0]) | (~i_data[7] & ~i_data[6] & ~i_data[5] & ~i_data[4] & i_data[1]) | (~i_data[7] & ~i_data[6] & ~i_data[5] & ~i_data[4] & i_data[2]) | (~i_data[7] & ~i_data[6] & ~i_data[5] & ~i_data[4] & i_data[3]);
assign o_zero_flag = ~(i_data[7] | i_data[6] | i_data[5] | i_data[4] | i_data[3] | i_data[2] | i_data[1] | i_data[0] );
// assign o_pos_one = o_zero_flag ? '0 : w_o_pos_one;
assign o_pos_one = w_o_pos_one;
endmodule