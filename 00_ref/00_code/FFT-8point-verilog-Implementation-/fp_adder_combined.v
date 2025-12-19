module fp_adder_combined(
    input [31:0] a,
    input [31:0] b,
    output [31:0] result
);
// Field extraction
wire sign_a = a[31];
wire sign_b = b[31];
wire [7:0] exp_a = a[30:23];
wire [7:0] exp_b = b[30:23];
wire [22:0] frac_a = a[22:0];
wire [22:0] frac_b = b[22:0];
// Hidden bit
wire [23:0] mant_a = (exp_a == 0) ? {1'b0, frac_a} : {1'b1, frac_a};
wire [23:0] mant_b = (exp_b == 0) ? {1'b0, frac_b} : {1'b1, frac_b};
// Exponent alignment
wire [7:0] exp_diff = (exp_a > exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);
wire [23:0] mant_a_shifted = (exp_b > exp_a) ? (mant_a >> exp_diff) : mant_a;
wire [23:0] mant_b_shifted = (exp_a > exp_b) ? (mant_b >> exp_diff) : mant_b;
wire [7:0] max_exp = (exp_a > exp_b) ? exp_a : exp_b;
reg [31:0] result_reg;
assign result = result_reg;
// Internal registers
integer i;
reg [4:0] shift_amt;
reg [23:0] norm_mant;
reg [7:0] norm_exp;
reg [24:0] mant_sum;
reg [22:0] final_frac;
reg [7:0] final_exp;
reg sign_out;
reg [24:0] diff;
reg [23:0] mant_large, mant_small;
reg a_gt_b;
always @(*) begin
    if (sign_a == sign_b) begin
        // Case I: Same sign (Add)
        mant_sum = {1'b0, mant_a_shifted} + {1'b0, mant_b_shifted};
        if (mant_sum[24]) begin
            final_exp = max_exp + 1;
            final_frac = mant_sum[23:1];
        end else begin
            final_exp = max_exp;
            final_frac = mant_sum[22:0];
        end
        sign_out = sign_a;
        result_reg = {sign_out, final_exp, final_frac};
    end else begin
        // Case II: Different sign (Subtract)
        a_gt_b = (mant_a_shifted >= mant_b_shifted);
        mant_large = a_gt_b ? mant_a_shifted : mant_b_shifted;
        mant_small = a_gt_b ? mant_b_shifted : mant_a_shifted;
        sign_out = a_gt_b ? sign_a : sign_b;
        diff = {1'b0, mant_large} - {1'b0, mant_small};
        // Normalize
        if (diff[23:0] == 0) begin
            norm_mant = 0;
            norm_exp = 0;
            end else begin
            shift_amt = 0;
            // for (i = 23; i >= 0; i = i - 1) begin
            //     if (diff[i]) begin
            //         shift_amt = 23 - i;
            //         // disable_found = 1'b1;
            //         i = -1; // break manually
            //     end
            // end
            if (diff[23])      shift_amt = 0;
            else if (diff[22]) shift_amt = 1;
            else if (diff[21]) shift_amt = 2;
            else if (diff[20]) shift_amt = 3;
            else if (diff[19]) shift_amt = 4;
            else if (diff[18]) shift_amt = 5;
            else if (diff[17]) shift_amt = 6;
            else if (diff[16]) shift_amt = 7;
            else if (diff[15]) shift_amt = 8;
            else if (diff[14]) shift_amt = 9;
            else if (diff[13]) shift_amt = 10;
            else if (diff[12]) shift_amt = 11;
            else if (diff[11]) shift_amt = 12;
            else if (diff[10]) shift_amt = 13;
            else if (diff[9])  shift_amt = 14;
            else if (diff[8])  shift_amt = 15;
            else if (diff[7])  shift_amt = 16;
            else if (diff[6])  shift_amt = 17;
            else if (diff[5])  shift_amt = 18;
            else if (diff[4])  shift_amt = 19;
            else if (diff[3])  shift_amt = 20;
            else if (diff[2])  shift_amt = 21;
            else if (diff[1])  shift_amt = 22;
            else if (diff[0])  shift_amt = 23;
            else               shift_amt = 0;

            norm_mant = diff[23:0] << shift_amt;
            norm_exp = max_exp - shift_amt;
            end
        result_reg = {sign_out, norm_exp, norm_mant[22:0]};
    end
end
endmodule

