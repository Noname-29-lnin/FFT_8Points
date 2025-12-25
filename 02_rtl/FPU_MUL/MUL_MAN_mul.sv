// module MUL_MAN_mul #(
//     parameter SIZE_DATA = 24    
// )(
//     input logic [SIZE_DATA-1:0]         i_data_a    ,
//     input logic [SIZE_DATA-1:0]         i_data_b    ,
//     output logic [SIZE_DATA-1:0]        o_data_mul  ,
//     output logic                        o_over_flag ,
//     output logic                        o_rounding      
// );
// logic w_guard_bit, w_round_bit, w_sticky_bit;
// logic [(2*SIZE_DATA)-1:0] w_data_mul;
// assign w_data_mul = i_data_a * i_data_b;

// // assign o_over_flag  = w_data_mul[47];
// assign o_over_flag  = 1'b0;
// assign o_data_mul   = w_data_mul[47:24];
// assign w_guard_bit  = w_data_mul[23];
// assign w_round_bit  = w_data_mul[22];
// assign w_sticky_bit = |w_data_mul[21:0];
// assign o_rounding   = (w_guard_bit & w_round_bit) | (w_round_bit & w_sticky_bit);
// endmodule
module MUL_MAN_mul #(
    parameter int SIZE_DATA = 24
)(
    input  logic [SIZE_DATA-1:0]  i_data_a,
    input  logic [SIZE_DATA-1:0]  i_data_b,
    output logic [SIZE_DATA-1:0]  o_data_mul,   // 24-bit mantissa normalized (includes hidden 1)
    output logic                  o_over_flag,  // actually "need_shift" to increment exponent
    output logic                  o_under_flag,
    output logic                  o_rounding    // rounding increment applied (optional info)
);

    logic [(2*SIZE_DATA)-1:0] w_data_mul;
    assign w_data_mul = i_data_a * i_data_b; // 48-bit

    // Normalize decision: if MSB=1 => product in [2,4) => shift right 1 and exp+1
    logic norm_shift;
    assign norm_shift  = w_data_mul[47];
    assign o_over_flag = norm_shift;

    // Pick mantissa and GRS depending on normalization
    logic [SIZE_DATA-1:0] mant_pre;
    logic guard, roundb, sticky;
    logic lsb_kept;

    assign o_under_flag = norm_shift;
    always_comb begin
        if (norm_shift) begin
            // keep [47:24], G=[23], R=[22], S=OR[21:0]
            mant_pre = w_data_mul[47:24];
            guard    = w_data_mul[23];
            roundb   = w_data_mul[22];
            sticky   = |w_data_mul[21:0];
        end else begin
            // keep [46:23], G=[22], R=[21], S=OR[20:0]
            mant_pre = w_data_mul[46:23];
            guard    = w_data_mul[22];
            roundb   = w_data_mul[21];
            sticky   = |w_data_mul[20:0];
        end
    end

    assign lsb_kept = mant_pre[0];

    // IEEE754 round-to-nearest-even (RNE)
    logic inc;
    assign inc = guard & (roundb | sticky | lsb_kept);

    // Apply rounding; if it overflows (all 1s + 1), it creates another normalization case.
    // Simple handling: add and let carry drop; usually you'd also bump exponent if carry-out.
    logic [SIZE_DATA:0] mant_rounded; // one extra bit for carry
    assign mant_rounded = {1'b0, mant_pre} + inc;

    // If rounding caused carry into bit SIZE_DATA, mantissa becomes 10.000... => shift and exp+1
    // That means exponent should be incremented again.
    logic round_carry;
    assign round_carry = mant_rounded[SIZE_DATA];

    // Final mantissa output
    // If carry, shift right 1 to return to 1.xxx and signal exponent increment.
    always_comb begin
        if (round_carry) begin
            o_data_mul = mant_rounded[SIZE_DATA:1]; // shift right 1
        end else begin
            o_data_mul = mant_rounded[SIZE_DATA-1:0];
        end
    end

    // Optional: report whether rounding increment happened (not carry)
    assign o_rounding = inc;

    // NOTE: If round_carry=1, you must also increment exponent (in exponent stage),
    // and potentially update o_over_flag to reflect it:
    // exp_inc = norm_shift + round_carry;
endmodule
