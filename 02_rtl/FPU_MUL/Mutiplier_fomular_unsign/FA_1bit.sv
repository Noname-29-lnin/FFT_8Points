// 1-bit Full Adder
module FA_1bit (
    input  wire A,
    input  wire B,
    input  wire C,    // Cin (third Bit in CSA)
    output wire S,    // sum (sAme Column)
    output wire C_o    // CArry (to next Column)
);
    assign S = A ^ B ^ C;
    assign C_o = (A & B) | (A & C) | (B & C);
endmodule