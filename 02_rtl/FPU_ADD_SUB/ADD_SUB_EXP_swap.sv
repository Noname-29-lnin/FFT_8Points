module ADD_SUB_EXP_swap #(
    parameter SIZE_DATA = 8
)(
    input logic [SIZE_DATA-1:0]     i_data_a        ,
    input logic [SIZE_DATA-1:0]     i_data_b        ,
    input logic                     i_compare       ,   // a < b
    output logic [SIZE_DATA-1:0]    o_less_data     ,
    output logic [SIZE_DATA-1:0]    o_greater_data  
);

assign o_greater_data  = (i_compare) ? i_data_b : i_data_a;
assign o_less_data     = (i_compare) ? i_data_a : i_data_b;

endmodule
