module COMP_CLA_24bit #(
    parameter SIZE_DATA = 24
)(
    input  logic [SIZE_DATA-1:0] i_data_a,
    input  logic [SIZE_DATA-1:0] i_data_b,
    output logic                 o_less
);

logic [5:0] GP, GG;
logic [5:0] Bgrp;
assign Bgrp[0] = GG[0];

COMP_CLA_4bit u0 (.A(i_data_a[ 3: 0]), .B(i_data_b[ 3: 0]), .Bin(1'b0),
              .Bout(), .GP(GP[0]), .GG(GG[0]));

COMP_CLA_4bit u1 (.A(i_data_a[ 7: 4]), .B(i_data_b[ 7: 4]), .Bin(Bgrp[0]),
              .Bout(), .GP(GP[1]), .GG(GG[1]));

COMP_CLA_4bit u2 (.A(i_data_a[11: 8]), .B(i_data_b[11: 8]), .Bin(Bgrp[1]),
              .Bout(), .GP(GP[2]), .GG(GG[2]));

COMP_CLA_4bit u3 (.A(i_data_a[15:12]), .B(i_data_b[15:12]), .Bin(Bgrp[2]),
              .Bout(), .GP(GP[3]), .GG(GG[3]));

COMP_CLA_4bit u4 (.A(i_data_a[19:16]), .B(i_data_b[19:16]), .Bin(Bgrp[3]),
              .Bout(), .GP(GP[4]), .GG(GG[4]));

COMP_CLA_4bit u5 (.A(i_data_a[23:20]), .B(i_data_b[23:20]), .Bin(Bgrp[4]),
              .Bout(), .GP(GP[5]), .GG(GG[5]));

assign Bgrp[1] = GG[1] |
                 (GP[1] & GG[0]);
assign Bgrp[2] = GG[2] |
                 (GP[2] & GG[1]) |
                 (GP[2] & GP[1] & GG[0]);
assign Bgrp[3] = GG[3] |
                 (GP[3] & GG[2]) |
                 (GP[3] & GP[2] & GG[1]) |
                 (GP[3] & GP[2] & GP[1] & GG[0]);
assign Bgrp[4] = GG[4] |
                 (GP[4] & GG[3]) |
                 (GP[4] & GP[3] & GG[2]) |
                 (GP[4] & GP[3] & GP[2] & GG[1]) |
                 (GP[4] & GP[3] & GP[2] & GP[1] & GG[0]);
assign Bgrp[5] = GG[5] |
                 (GP[5] & GG[4]) |
                 (GP[5] & GP[4] & GG[3]) |
                 (GP[5] & GP[4] & GP[3] & GG[2]) |
                 (GP[5] & GP[4] & GP[3] & GP[2] & GG[1]) |
                 (GP[5] & GP[4] & GP[3] & GP[2] & GP[1] & GG[0]);
assign o_less = Bgrp[5];

endmodule

module COMP_CLA_4bit (
    input  logic [3:0] A        ,
    input  logic [3:0] B        ,
    input  logic       Bin      ,
    output logic       Bout     ,
    output logic       GP       ,
    output logic       GG        
);

logic [3:0] g, p, b;
assign g = ~A &  B;
assign p = ~(A & ~B);
assign b[0] = g[0] | (p[0] & Bin);
assign b[1] = g[1] | (p[1] & b[0]);
assign b[2] = g[2] | (p[2] & b[1]);
assign b[3] = g[3] | (p[3] & b[2]);
assign Bout = b[3];
assign GP = &p;
assign GG = g[3] |
            (p[3] & g[2]) |
            (p[3] & p[2] & g[1]) |
            (p[3] & p[2] & p[1] & g[0]);

endmodule
