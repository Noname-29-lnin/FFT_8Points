module FPU_top (
    input logic                 i_clk           ,
    input logic                 i_rst_n         ,
    input logic [31:0]          i_32_a          ,
    input logic [31:0]          i_32_b          ,
    output logic [31:0]         o_32_m           
);

logic [31:0]          w_i_32_a;
logic [31:0]          w_i_32_b;
logic [31:0]          w_o_32_m;    

always_ff @( posedge i_clk or negedge i_rst_n ) begin : proc_est_time
    if(~i_rst_n) begin
        w_i_32_a            <= '0;
        w_i_32_b            <= '0;
        o_32_m              <= '0;
    end else begin
        w_i_32_a            <= i_32_a;
        w_i_32_b            <= i_32_b;
        o_32_m              <= w_o_32_m;
    end
end

 fpu_mul #(
    .SIZE_DATA  (32)
) FPU_MUL_TOP (
    .i_32_a     (w_i_32_a),
    .i_32_b     (w_i_32_b),
    .o_32_mul   (w_o_32_m) 
);

endmodule
