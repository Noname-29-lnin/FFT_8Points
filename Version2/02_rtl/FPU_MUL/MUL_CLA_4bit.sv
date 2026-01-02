module MUL_CLA_4bit (
    input  logic [3:0]  a,
    input  logic [3:0]  b,
    input  logic        cin,
    output logic [3:0]  sum,
    output logic        o_p,
    output logic        o_g
);
    logic [3:0] w_g, w_p;
    logic [3:0] w_c;

    assign w_g = a & b;
    assign w_p = a ^ b;

    // always_comb begin
        assign w_c[0] = cin;
        assign w_c[1] = w_g[0] | (w_p[0] & w_c[0]);
        assign w_c[2] = w_g[1] | (w_p[1] & w_g[0]) | (w_p[1] & w_p[0] & w_c[0]);
        assign w_c[3] = w_g[2] | (w_p[2] & w_g[1]) | (w_p[2] & w_p[1] & w_g[0]) | (w_p[2] & w_p[1] & w_p[0] & w_c[0]);
    // end
    
    assign sum = w_p ^ w_c;
    assign o_p = &w_p;
    assign o_g = w_g[3] | (w_p[3] & w_g[2]) | (w_p[3] & w_p[2] & w_g[1]) | (w_p[3] & w_p[2] & w_p[1] & w_g[0]) | (w_p[3] & w_p[2] & w_p[1] & w_p[0] & w_c[0]);

endmodule
