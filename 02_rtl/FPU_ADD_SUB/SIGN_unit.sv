module SIGN_unit (
    input logic             i_add_sub       ,
    input logic             i_comp_man      ,
    input logic             i_sign_man_a    ,
    input logic             i_sign_man_b    ,
    output logic            o_sign_s        
);

assign o_sign_s = (~i_add_sub & i_sign_man_b & i_comp_man) | (i_add_sub & ~i_sign_man_b & i_comp_man) | (i_sign_man_a & ~i_comp_man);

endmodule
