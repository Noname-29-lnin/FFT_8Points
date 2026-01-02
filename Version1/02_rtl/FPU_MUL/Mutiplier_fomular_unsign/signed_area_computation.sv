// ============================================================
// Module: signed_area_computation - Mul_32bit prefix method
// Function:
//   Reconstruct the sign-area correction vector (Vector_M) using the
//   prefix-based algorithm described in Mul_32bit: track sign-bit
//   activity per partial product and materialize the required fill
//   bits between successive "mark" positions (2*i + N + 1).
// ============================================================

module signed_area_computation #(
    parameter int N       = 24,
    parameter int NUM_PP  = 13,
    parameter int WIDTH   = 2*N
)(
    input  wire [N+1:0]     PP [0:NUM_PP-1],   // 26-bit PP from Booth encoder
    input  wire [1:0]       CZ [0:NUM_PP-2],   // Reserved (kept for interface compatibility)
    output logic [WIDTH-1:0] Vector_M
);

    // Extract sign indicator for each partial product (bit N+1).
    logic sign_bits [0:NUM_PP-1];

    logic dummy_cz_or;

    always_comb begin
        dummy_cz_or = 1'b0;
        for (int i = 0; i < NUM_PP; i++) begin
            sign_bits[i] = PP[i][N+1];
            if (i < NUM_PP-1) begin
                dummy_cz_or |= |CZ[i];
            end
        end
    end

    // Generate Vector_M using local prefix-style logic per Mul_32bit reference.
    // For each partial product i, its sign bit occupies column mark_i = 2*i + (N+1).
    // Following the algorithm from Mul_32bit:
    //   - Vector_M[mark_i] = prev_or ^ sign_bits[i]
    //   - Columns between mark_i and mark_{i+1} inherit prev_or | sign_bits[i]
    // where prev_or accumulates sign activity up to PP[i-1].
    always_comb begin
        logic prefix_acc;  // Di chuyển lên đây
        Vector_M = '0;
 // OR of sign bits before current PP
        prefix_acc = 1'b0;

        for (int i = 0; i < NUM_PP; i++) begin
            int mark_i;
            int mark_next;
            logic mark_bit;
            logic fill_bit;

            mark_i   = 2*i + N + 1  ;          // Column of PP[i]'s sign bit
            mark_next = 2*(i+1) + N + 1 ;     // Next mark boundary

            mark_bit = prefix_acc ^ sign_bits[i];
            fill_bit = prefix_acc | sign_bits[i];

            if (mark_i < WIDTH) begin
                Vector_M[mark_i] = mark_bit;
            end

            for (int col = mark_i + 1; col < WIDTH && col < mark_next; col++) begin
                Vector_M[col] = fill_bit;
            end

            prefix_acc = fill_bit;
        end
    end

endmodule

