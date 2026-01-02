module MUL_CLA_24bit(
    input  logic        i_carry,
    input  logic [23:0] i_data_a,
    input  logic [23:0] i_data_b,
    output logic [23:0] o_sum,
    output logic        o_carry
);

    logic [6:0] w_c;
    logic [5:0] w_p;
    logic [5:0] w_g;

    genvar i;
    generate
        for (i = 0; i < 6; i = i + 1) begin : CLA_BLOCK_GEN
            MUL_CLA_4bit CLA_4BIT_UNIT (
                .a      (i_data_a[(i*4)+3 : i*4]),
                .b      (i_data_b[(i*4)+3 : i*4]),
                .cin    (w_c[i]),
                .sum    (o_sum[(i*4)+3 : i*4]),
                .o_p    (w_p[i]),
                .o_g    (w_g[i])
            );
        end
    endgenerate

    assign w_c[0] = i_carry;

    assign w_c[1] = w_g[0] 
                    | (w_p[0] & w_c[0]);

    assign w_c[2] = w_g[1] 
                    | (w_p[1] & w_g[0]) 
                    | (w_p[1] & w_p[0] & w_c[0]);

    assign w_c[3] = w_g[2] 
                    | (w_p[2] & w_g[1]) 
                    | (w_p[2] & w_p[1] & w_g[0])
                    | (w_p[2] & w_p[1] & w_p[0] & w_c[0]);

    assign w_c[4] = w_g[3] 
                    | (w_p[3] & w_g[2]) 
                    | (w_p[3] & w_p[2] & w_g[1])
                    | (w_p[3] & w_p[2] & w_p[1] & w_g[0])
                    | (w_p[3] & w_p[2] & w_p[1] & w_p[0] & w_c[0]);

    assign w_c[5] = w_g[4] 
                    | (w_p[4] & w_g[3]) 
                    | (w_p[4] & w_p[3] & w_g[2])
                    | (w_p[4] & w_p[3] & w_p[2] & w_g[1])
                    | (w_p[4] & w_p[3] & w_p[2] & w_p[1] & w_g[0])
                    | (w_p[4] & w_p[3] & w_p[2] & w_p[1] & w_p[0] & w_c[0]);

    assign w_c[6] = w_g[5] 
                    | (w_p[5] & w_g[4]) 
                    | (w_p[5] & w_p[4] & w_g[3])
                    | (w_p[5] & w_p[4] & w_p[3] & w_g[2])
                    | (w_p[5] & w_p[4] & w_p[3] & w_p[2] & w_g[1])
                    | (w_p[5] & w_p[4] & w_p[3] & w_p[2] & w_p[1] & w_g[0])
                    | (w_p[5] & w_p[4] & w_p[3] & w_p[2] & w_p[1] & w_p[0] & w_c[0]);

    assign o_carry = w_c[6];

endmodule
