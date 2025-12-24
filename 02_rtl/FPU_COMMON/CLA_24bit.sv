module CLA_24bit(
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
            CLA_4bit CLA_4BIT_UNIT (
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
// module CLA_24bit(
//     input  logic        i_carry,      // carry-in
//     input  logic [23:0] i_data_a,
//     input  logic [23:0] i_data_b,
//     output logic [23:0] o_sum,
//     output logic        o_carry
// );

//     logic [24:0] w_temp;
//     assign w_temp = {24'b0, i_carry} + {1'b0, i_data_a} + {1'b0, i_data_b};
//     assign o_sum = w_temp[23:0];
//     assign o_carry = w_temp[24];

// endmodule
