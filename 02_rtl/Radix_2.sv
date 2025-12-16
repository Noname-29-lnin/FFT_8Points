module Radix_2 #(
    parameter SIZE_DATA = 32
)(
    input logic                     i_clk       ,
    input logic                     i_rst_n     ,
    input logic [SIZE_DATA-1:0]     i_data_0    ,
    input logic [SIZE_DATA-1:0]     i_data_1    ,
    output logic [SIZE_DATA-1:0]    o_data_0    ,
    output logic [SIZE_DATA-1:0]    o_data_1     
);

logic [SIZE_DATA-1:0] w_data_0;
logic [SIZE_DATA-1:0] w_data_1;

FPU_add_sub #(
    .NUM_OP         (1)
) FPU_CAL_ADD_SUB_UNIT (
    .i_add_sub      (1'b0),
    .i_32_a         (i_data_0),
    .i_32_b         (i_data_0),
    .o_32_s         (w_data_0) 
);
FPU_add_sub #(
    .NUM_OP         (1)
) FPU_CAL_ADD_SUB_UNIT_1 (
    .i_add_sub      (1'b1),
    .i_32_a         (i_data_0),
    .i_32_b         (i_data_0),
    .o_32_s         (w_data_1) 
);

always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_outptu
    if(~i_rst_n) begin
        o_data_0    <= '0;
        o_data_1    <= '0;
    end else begin
        o_data_0    <= w_data_0;
        o_data_1    <= w_data_1;
    end
end

endmodule
