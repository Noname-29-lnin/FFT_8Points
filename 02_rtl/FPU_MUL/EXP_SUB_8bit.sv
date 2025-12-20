module EXP_SUB_8bit #(
    parameter SIZE_DATA = 8 
)(
    input logic [SIZE_DATA-1:0]     i_data_a    ,
    input logic [SIZE_DATA-1:0]     i_data_b    ,
    output logic [SIZE_DATA-1:0]    o_data_sub   
);

assign o_data_sub = i_data_a - i_data_b;

endmodule
