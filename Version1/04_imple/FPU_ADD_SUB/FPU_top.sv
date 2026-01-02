module FPU_top  #(
    parameter NUM_OP    = 1
)(
    input logic                 i_clk           ,
    input logic                 i_rst_n         ,
    input logic [NUM_OP-1:0]    i_add_sub       ,
    input logic [31:0]          i_32_a          ,
    input logic [31:0]          i_32_b          ,
    output logic [31:0]         o_32_s           
);

logic [NUM_OP-1:0]    w_i_add_sub;
logic [31:0]          w_i_32_a;
logic [31:0]          w_i_32_b;
logic [31:0]          w_o_32_s;    

always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_est_time
    if(~i_rst_n) begin
        w_i_add_sub         <= '0;
        w_i_32_a            <= '0;
        w_i_32_b            <= '0;
        o_32_s              <= '0;
    end else begin
        w_i_add_sub         <= i_add_sub;
        w_i_32_a            <= i_32_a;
        w_i_32_b            <= i_32_b;
        o_32_s              <= w_o_32_s;
    end
end

FPU_add_sub #(
    .NUM_OP      (NUM_OP)
) FPU_ADD_SUB_UNIT (
    .i_add_sub          (w_i_add_sub),
    .i_32_a             (w_i_32_a),
    .i_32_b             (w_i_32_b),
    .o_32_s             (w_o_32_s)
);

endmodule
