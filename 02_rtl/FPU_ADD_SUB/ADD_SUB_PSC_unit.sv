module ADD_SUB_PSC_unit(
    input logic                     i_add_sub   ,

    input logic                     i_sign_a    ,
    input logic [7:0]               i_exp_a     ,
    input logic [23:0]              i_man_a     ,

    input logic                     i_sign_b    ,
    input logic [7:0]               i_exp_b     ,
    input logic [23:0]              i_man_b     ,

    output logic                    o_sel_exp   ,
    output logic [1:0]              o_sel_man    
);

logic w_E_one_A, w_E_one_B;
logic w_M_zero_A, w_M_zero_B;

assign w_E_one_A    = &i_exp_a;
assign w_E_one_B    = &i_exp_b;
assign w_M_zero_A   = ~|i_man_a[22:0];
assign w_M_zero_B   = ~|i_man_b[22:0];

assign o_sel_exp = (~i_sign_b & w_E_one_B & ~w_M_zero_B) | (~i_sign_a & w_E_one_A & ~w_M_zero_A) | (w_E_one_A & w_M_zero_A & w_E_one_B & w_M_zero_B);
assign o_sel_man[1] = w_E_one_A | w_E_one_B;
assign o_sel_man[0] = (w_E_one_B & ~w_M_zero_B) | (w_E_one_A & ~w_M_zero_A) | (~i_add_sub & ~i_sign_a & w_E_one_A & i_sign_b & w_E_one_B) | (~i_add_sub & i_sign_a & w_E_one_A & ~i_sign_b & w_E_one_B) | (i_add_sub & ~i_sign_a & w_E_one_A & ~i_sign_b & w_E_one_B) | (i_add_sub & i_sign_a & w_E_one_A & i_sign_b & w_E_one_B);
endmodule
