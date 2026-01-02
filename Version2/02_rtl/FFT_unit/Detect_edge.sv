// POS_EDGE = 0 -> detect negedge edge
// POS_EDGE = 1 -> detect posedge edge
module Detect_edge #(
    parameter POS_EDGE = 1   // 1: posedge, 0: negedge
)(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic i_signal,
    output logic o_signal
);

logic w_p_signal, w_n_signal;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n)
        w_p_signal <= 1'b0;
    else
        w_p_signal <= i_signal;
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n)
        w_n_signal <= 1'b0;
    else
        w_n_signal <= w_p_signal;
end

generate
    if (POS_EDGE) begin
        assign o_signal = (~w_n_signal) & (w_p_signal);
    end else begin
        assign o_signal = (w_n_signal) & (~w_p_signal);
    end
endgenerate


endmodule
