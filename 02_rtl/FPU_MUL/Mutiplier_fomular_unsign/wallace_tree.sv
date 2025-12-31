
    module wallace_tree #(
    parameter int N          = 24,
    parameter int NUM_PP     = (N/2) + 1,
    parameter int NUM_CZ     = NUM_PP - 1,
    parameter int PP_WIDTH   = N +1,
    // Width of incoming PP signals (Modified_booth produces N+2 bits)
    parameter int PP_IN_WIDTH = N + 2,
    parameter int CZ_WIDTH   = 2,
    parameter int NUM_COLS   = 2 * N,
    parameter int MAX_STAGES = 6,
    parameter int MAX_H      = 32
)(
    // Accept possibly wider PP from Modified_booth, then trim internally
    input  wire [PP_IN_WIDTH-1:0] PP_in [0:NUM_PP-1],
    input  wire [CZ_WIDTH-1:0] CZ [0:NUM_CZ-1],
    output logic [NUM_COLS-1:0] final_sum,
    output logic [NUM_COLS-1:0] final_carry
);
    import wallace_pkg::*;

    // ------------------------------------------------------------------
    // Trim incoming partial-products to internal width (PP_WIDTH)
    // We keep the lower PP_WIDTH bits and discard the MSB (sign) bit.
    // ------------------------------------------------------------------
    logic [PP_WIDTH-1:0] PP_int [0:NUM_PP-1];

    generate
        for (genvar ti = 0; ti < NUM_PP; ti++) begin : TRIM_PP
            assign PP_int[ti] = PP_in[ti][PP_WIDTH-1:0];
        end
    endgenerate

    // ============================================================
    // 1. HEIGHT MAP (COMPILE-TIME, TOOL-SAFE)
    // ============================================================
    typedef int height_map_t [0:MAX_STAGES][0:NUM_COLS-1];

    function automatic height_map_t calc_height_map();
        height_map_t map;

        // --- STAGE 0 ---
        for (int c = 0; c < NUM_COLS; c++) begin
            map[0][c] = calc_total_height(c, NUM_PP, PP_WIDTH, NUM_CZ, CZ_WIDTH);
        end

        // --- NEXT STAGES ---
        for (int s = 0; s < MAX_STAGES; s++) begin
            for (int c = 0; c < NUM_COLS; c++) begin
                int h_curr = map[s][c];
                int h_prev = (c > 0) ? map[s][c-1] : 0;
                map[s+1][c] = predict_next_height(h_curr, h_prev);
            end
        end

        return map;
    endfunction

    localparam height_map_t H = calc_height_map();

    // ============================================================
    // 2. WIRES BUFFER
    // ============================================================
    logic [MAX_H-1:0] wires [0:MAX_STAGES][0:NUM_COLS-1];

    // ============================================================
    // 3. STAGE 0 MAPPING (PP + CZ) – TỐI ƯU
    // ============================================================
    generate
        for (genvar c = 0; c < NUM_COLS; c++) begin
            assign wires[0][c] = '0;
        end
    endgenerate

    // --- MAP PP (use trimmed internal PP_int) ---
    generate
        for (genvar i = 0; i < NUM_PP; i++) begin : MAP_PP
            for (genvar b = 0; b < PP_WIDTH; b++) begin : BIT_PP
                localparam int col = 2*i + b;
                if (col < NUM_COLS) begin
                    localparam int SLOT =
                        get_slot_idx(col, i, 0, NUM_PP, PP_WIDTH, NUM_CZ, CZ_WIDTH);
                    assign wires[0][col][SLOT] = PP_int[i][b];
                end
            end
        end
    endgenerate

    // --- MAP CZ ---
    generate
        for (genvar i = 0; i < NUM_CZ; i++) begin : MAP_CZ
            for (genvar b = 0; b < CZ_WIDTH; b++) begin : BIT_CZ
                localparam int col = 2*i + b;
                if (col < NUM_COLS) begin
                    localparam int SLOT =
                        get_slot_idx(col, i, 1, NUM_PP, PP_WIDTH, NUM_CZ, CZ_WIDTH);
                    assign wires[0][col][SLOT] = CZ[i][b];
                end
            end
        end
    endgenerate

    // ============================================================
    // 4. WALLACE STAGES
    // ============================================================
    generate
        for (genvar s = 0; s < MAX_STAGES; s++) begin : STAGE_GEN

            logic [MAX_H-1:0] sum_tmp   [0:NUM_COLS-1];
            logic [MAX_H-1:0] carry_tmp [0:NUM_COLS-1];

            wallace_stage #(
                .NUM_COLS    (NUM_COLS),
                .COL_HEIGHTS (H[s]),
                .MAX_H_IN    (MAX_H),
                .MAX_H_OUT   (MAX_H)
            ) u_stage (
                .bits_in     (wires[s]),
                .sum_out     (sum_tmp),
                .carry_out   (carry_tmp)
            );

            // -------- PACKING (RESET + SUM + CARRY) --------
            for (genvar c = 0; c < NUM_COLS; c++) begin : PACKING
                localparam int H_CURR  = H[s][c];
                localparam int N_SUM   = get_num_fa(H_CURR)
                                       + get_num_ha(H_CURR)
                                       + get_num_pass(H_CURR);

                localparam int H_PREV  = (c > 0) ? H[s][c-1] : 0;
                localparam int N_CARRY = get_num_fa(H_PREV)
                                       + get_num_ha(H_PREV);

                // RESET
                assign wires[s+1][c] = '0;

                if (N_SUM > 0)
                    assign wires[s+1][c][N_SUM-1:0] =
                           sum_tmp[c][N_SUM-1:0];

                if (N_CARRY > 0 && c > 0)
                    assign wires[s+1][c][N_SUM + N_CARRY - 1 : N_SUM] =
                           carry_tmp[c-1][N_CARRY-1:0];
            end
        end
    endgenerate

    // ============================================================
    // 5. OUTPUT (FINAL 2 ROWS)
    // ============================================================
    // Giả định sau MAX_STAGES còn ≤ 2 bit / cột
    generate
        for (genvar c = 0; c < NUM_COLS; c++) begin
            assign final_sum[c]   = wires[MAX_STAGES][c][0];
            assign final_carry[c] = wires[MAX_STAGES][c][1];
        end
    endgenerate

endmodule
