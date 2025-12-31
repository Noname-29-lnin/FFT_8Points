module MUL_PSC_unit #(
    parameter SIZE_EXP = 8,
    parameter SIZE_MAN = 24
)(
    input logic [SIZE_EXP-1:0]  i_exp_a     ,
    input logic [SIZE_EXP-1:0]  i_exp_b     ,
    input logic [SIZE_MAN-1:0]  i_man_a     ,
    input logic [SIZE_MAN-1:0]  i_man_b     ,
    output logic [1:0]          o_sel_exp   ,
    output logic [1:0]          o_sel_man       
);

logic is_E_one_a;
logic is_E_one_b;
logic is_E_zero_a;
logic is_E_zero_b;
logic is_M_zero_a;
logic is_M_zero_b;

assign is_E_one_a     = &(i_exp_a);
assign is_E_one_b     = &(i_exp_b);
assign is_E_zero_a    = ~|(i_exp_a); 
assign is_E_zero_b    = ~|(i_exp_b); 
assign is_M_zero_a    = ~|(i_man_a[SIZE_MAN-2:0]); 
assign is_M_zero_b    = ~|(i_man_b[SIZE_MAN-2:0]);

// assign o_sel_exp[1] = (~is_E_one_a & ~is_E_one_b & is_E_zero_b & is_M_zero_b) | (~is_E_one_a & is_E_one_b & ~is_E_zero_b) | (is_E_one_a & ~is_E_zero_a & ~is_M_zero_a) | (is_E_one_a & ~is_E_zero_a & ~is_E_one_b) | (is_E_one_b & ~is_E_zero_b & ~is_M_zero_b) | (~is_E_zero_a & is_E_one_b & ~is_E_zero_b);
assign o_sel_exp[1] = (~is_E_one_a & ~is_E_one_b & is_E_zero_b & is_M_zero_b) | (~is_E_one_a & is_E_one_b & ~is_E_zero_b) | (~is_E_one_a & is_E_zero_a & is_M_zero_a & ~is_E_one_b) | (is_E_one_a & ~is_E_zero_a & ~is_M_zero_a) | (is_E_one_a & ~is_E_zero_a & ~is_E_one_b) | (is_E_one_b & ~is_E_zero_b & ~is_M_zero_b) | (~is_E_zero_a & is_E_one_b & ~is_E_zero_b);

// assign o_sel_exp[0] = (~is_E_one_a & is_E_one_b & ~is_E_zero_b) | (is_E_one_a & ~is_E_zero_a & ~is_M_zero_a) | (is_E_one_a & ~is_E_zero_a & ~is_E_one_b) | (is_E_one_b & ~is_E_zero_b & ~is_M_zero_b) | (~is_E_zero_a & is_E_one_b & ~is_E_zero_b);
// assign o_sel_exp[0] = (is_E_one_b & ~is_E_zero_b & ~is_M_zero_b) | (~is_E_one_a & is_E_zero_a & is_M_zero_a & is_E_one_b & ~is_E_zero_b) | (is_E_one_a & ~is_E_zero_a & ~is_M_zero_a) | (is_E_one_a & ~is_E_zero_a & ~is_E_one_b & is_E_zero_b & is_M_zero_b) | (is_E_one_a & ~is_E_zero_a & is_E_one_b & ~is_E_zero_b);
assign o_sel_exp[0] = (~is_E_one_a & is_E_one_b & ~is_E_zero_b) | (is_E_one_a & ~is_E_zero_a & ~is_M_zero_a) | (is_E_one_a & ~is_E_zero_a & ~is_E_one_b) | (is_E_one_b & ~is_E_zero_b & ~is_M_zero_b) | (~is_E_zero_a & is_E_one_b & ~is_E_zero_b);

assign o_sel_man[1] = (~is_E_one_a & ~is_E_one_b & is_E_zero_b & is_M_zero_b) | (~is_E_one_a & is_E_one_b & ~is_E_zero_b) | (~is_E_one_a & is_E_zero_a & is_M_zero_a & ~is_E_one_b) | (is_E_one_a & ~is_E_zero_a & ~is_M_zero_a) | (is_E_one_a & ~is_E_zero_a & ~is_E_one_b) | (is_E_one_b & ~is_E_zero_b & ~is_M_zero_b) | (~is_E_zero_a & is_E_one_b & ~is_E_zero_b);
// assign o_sel_man[0] = (~is_E_zero_a & is_E_one_a & ~is_M_zero_a & ~is_E_one_b) | (~is_E_zero_a & is_E_one_a & is_E_zero_b & ~is_E_one_b & is_M_zero_b) | (is_E_zero_a & ~is_E_one_a & ~is_M_zero_a & ~is_E_zero_b & ~is_E_one_b & ~is_M_zero_b) | (is_E_zero_a & ~is_E_one_a & is_M_zero_a & ~is_E_zero_b & is_E_one_b) | (~is_E_zero_a & ~is_E_one_a & ~is_E_zero_b & is_E_one_b & ~is_M_zero_b) | (~is_E_zero_a & ~is_M_zero_a & ~is_E_zero_b & is_E_one_b & ~is_M_zero_b);
assign o_sel_man[0] = (is_E_one_b & ~is_E_zero_b & ~is_M_zero_b) | (~is_E_one_a & is_E_zero_a & is_M_zero_a & is_E_one_b & ~is_E_zero_b) | (is_E_one_a & ~is_E_zero_a & ~is_M_zero_a) | (is_E_one_a & ~is_E_zero_a & ~is_E_one_b & is_E_zero_b & is_M_zero_b);
// assign o_sel_man[0] = (~is_E_one_a & is_E_one_b & ~is_E_zero_b) | (is_E_one_a & ~is_E_zero_a & ~is_M_zero_a) | (is_E_one_a & ~is_E_zero_a & ~is_E_one_b) | (is_E_one_b & ~is_E_zero_b & ~is_M_zero_b);

endmodule
