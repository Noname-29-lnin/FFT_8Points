module LOPD_4bit(
    input logic [3:0]       i_data  ,
    output logic [1:0]      o_pos_one,
    output logic            o_zero_flag
);

/////////////////// LDOD ///////////////////
// D[3] | D[2] | D[1] | D[0] | PO[1] | PO[0] | ZERO_FLAG |
//   0  |   0  |   0  |   0  |   0   |   0   |     1     |
//   1  |   X  |   X  |   X  |   0   |   0   |     0     |
//   0  |   1  |   X  |   X  |   0   |   1   |     0     |
//   0  |   0  |   1  |   X  |   1   |   0   |     0     |
//   0  |   0  |   0  |   1  |   1   |   1   |     0     |

assign o_zero_flag = ~(i_data[3]|i_data[2]|(i_data[1]|i_data[0])) ;
assign o_pos_one[1] = (i_data[0] | i_data[1])&(~i_data[2])&(~i_data[3]);
assign o_pos_one[0] = ((~i_data[3])&i_data[2]) | ((~i_data[3])&(~i_data[1])&(i_data[0]));

endmodule