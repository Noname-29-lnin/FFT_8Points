module fp_multiplier (
    input [31:0] a, // IEEE 754 float A
    input [31:0] b, // IEEE 754 float B
    output [31:0] result // IEEE 754 float result
);
// Extract fields
wire sign_a = a[31];
wire sign_b = b[31];
wire [7:0] exp_a = a[30:23];
wire [7:0] exp_b = b[30:23];
wire [22:0] frac_a = a[22:0];
wire [22:0] frac_b = b[22:0];
// Add implicit leading 1
wire [23:0] mant_a = (exp_a == 0) ? {1'b0, frac_a} : {1'b1, frac_a};
wire [23:0] mant_b = (exp_b == 0) ? {1'b0, frac_b} : {1'b1, frac_b};
// Multiply mantissas (24 x 24 = 48 bits)
wire [47:0] mant_mult = mant_a * mant_b;
// Add exponents and subtract bias
wire [9:0] exp_sum = exp_a + exp_b - 127;
// Normalize result
wire norm_shift = mant_mult[47]; // If MSB is 1, shift right
wire [22:0] final_mant = norm_shift ? mant_mult[46:24] :
mant_mult[45:23];
wire [7:0] final_exp = norm_shift ? exp_sum + 1 : exp_sum;
// Compute final sign
wire sign_result = sign_a ^ sign_b;
// Handle special cases (zero input)
wire zero_a = (a[30:0] == 31'b0);
wire zero_b = (b[30:0] == 31'b0);
wire is_zero = zero_a | zero_b;
// Result construction
assign result = is_zero ? 32'b0 : {sign_result, final_exp, final_mant};
endmodule
