// 1-Bit HAlf Adder
module HA_1bit (
    input  wire A,
    input  wire B,
    output wire S,
    output wire C_o
);
    assign S  = A ^ B;
    assign C_o = A & B;
endmodule