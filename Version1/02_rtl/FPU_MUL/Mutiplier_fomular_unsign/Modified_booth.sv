module Modified_booth #(
    parameter N = 24,
    parameter int NUM_PP = (N/2) + 1
)(
    input  logic [N-1:0] A,
    input  logic [N-1:0] B,
    output logic [1:0]   CZ [0:NUM_PP-2],
    output logic [N+1:0] PP [0:NUM_PP-1]
);

    localparam int TOTAL = N + 3;

    logic [2:0] compare_bits [0:NUM_PP-1];
    logic [N:0] A_ext, A_ext_inv;
    logic [TOTAL-1:0] B_ext;
    logic [1:0] CZ_internal [0:NUM_PP-1];

    // ========================================================
    // Sign Extension for A
    // ========================================================
    assign A_ext     = {1'b0, A};      // Unsigned extend: prepend 0
    assign A_ext_inv = ~A_ext;         // Invert for negative

    // B padding for Radix-4 grouping
    assign B_ext     = {2'b0, B, 1'b0};

    // ========================================================
    // Generate 3-bit groups
    // ========================================================
    genvar f;
    generate
        for (f = 0; f < NUM_PP; f++) begin : GEN_COMPARE
            assign compare_bits[f] = {
                B_ext[2*f+2],
                B_ext[2*f+1],
                B_ext[2*f]
            };
        end
    endgenerate

    // ========================================================
    // Booth Encoding Logic
    // ========================================================
    always_comb begin
        for (int i = 0; i < NUM_PP; i++) begin
            case (compare_bits[i])

                // 000, 111: Y × 0
                3'b000, 3'b111: begin
                    PP[i] = '0;
                    CZ_internal[i] = 2'b00;
                end

                // 001, 010: Y × +1
                // Output: {MSB of A (sign), A_ext}
                3'b001, 3'b010: begin
                    PP[i] = {1'b0, A_ext};
                    CZ_internal[i] = 2'b00;
                end

                // 011: Y × +2 (shift left 1)
                // Output: {MSB of A, A_ext[23:0], 1'b0}
                3'b011: begin
                    PP[i] = {1'b0, A_ext[N-1:0], 1'b0};
                    CZ_internal[i] = 2'b00;
                end

                // 100: Y × -2 (inverted, shift left 1, + correction)
                // Output: {MSB of A_ext_inv, A_ext_inv[23:0], 1'b0}
                3'b100: begin
                    PP[i] = {1'b1, A_ext_inv[N-1:0], 1'b0};
                    CZ_internal[i] = 2'b10;
                end

                // 101, 110: Y × -1 (inverted, sign extended)
                // Output: {~MSB of A, A_ext_inv}
                // Correction: CZ = +1 (added in Wallace tree)
                3'b101, 3'b110: begin
                    PP[i] = {1'b1, A_ext_inv};
                    CZ_internal[i] = 2'b01;
                end

                default: begin
                    PP[i] = '0;
                    CZ_internal[i] = 2'b00;
                end

            endcase
        end
    end

    // Output CZ
    always_comb begin
        for (int k = 0; k < NUM_PP-1; k++) begin
            CZ[k] = CZ_internal[k];
        end
    end

endmodule