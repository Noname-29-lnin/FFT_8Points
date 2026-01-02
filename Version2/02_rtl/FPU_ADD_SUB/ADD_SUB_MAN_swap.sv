module ADD_SUB_MAN_swap #(
    parameter SIZE_MAN  = 24
)(
    input logic [SIZE_MAN-1:0]          i_man_a     ,
    input logic [SIZE_MAN-1:0]          i_man_b     ,
    input logic                         i_compare   ,
    output logic [SIZE_MAN-1:0]         o_man_max   ,
    output logic [SIZE_MAN-1:0]         o_man_min   
);

assign o_man_max    = i_compare ? i_man_b : i_man_a;
assign o_man_min    = i_compare ? i_man_a : i_man_b;

endmodule
