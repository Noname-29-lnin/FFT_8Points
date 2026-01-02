module wallace_stage #(
    parameter int NUM_COLS = 48,
    // --- KEY CHANGE: PARAMETER ARRAY ---
    // Mảng này chứa chiều cao của từng cột.
    // Vì là parameter, nó có giá trị CỐ ĐỊNH lúc biên dịch -> Dùng tính số FA được!
    parameter int COL_HEIGHTS [0:NUM_COLS-1] = '{default:0},
    
    // Chiều cao dây (chỉ để khai báo port)
    parameter int MAX_H_IN  = 16, 
    parameter int MAX_H_OUT = 16 
)(
    // Input: Dây tín hiệu (Runtime)
    input  logic [MAX_H_IN-1:0]  bits_in   [0:NUM_COLS-1],

    // Output: Tách Sum và Carry (để module cha gom dây)
    output logic [MAX_H_OUT-1:0] sum_out   [0:NUM_COLS-1],
    output logic [MAX_H_OUT-1:0] carry_out [0:NUM_COLS-1] 
);
    import wallace_pkg::*;

    generate
        for (genvar c = 0; c < NUM_COLS; c++) begin : COL
            // 1. LẤY CHIỀU CAO TỪ PARAMETER (Hợp lệ 100%)
            localparam int H = COL_HEIGHTS[c]; 

            // 2. TÍNH TOÁN SỐ LƯỢNG LINH KIỆN (Dùng hàm trong PKG)
            localparam int N_FA   = get_num_fa(H);
            localparam int N_HA   = get_num_ha(H);
            localparam int N_PASS = get_num_pass(H);

            // Xóa output thừa
            assign sum_out[c]   = '0;
            assign carry_out[c] = '0;

            // 3. XÂY DỰNG PHẦN CỨNG
            // --- FULL ADDERS ---
            for (genvar k = 0; k < N_FA; k++) begin : FA
                wire x = bits_in[c][3*k];
                wire y = bits_in[c][3*k+1];
                wire z = bits_in[c][3*k+2];
                assign sum_out[c][k]   = x ^ y ^ z;
                assign carry_out[c][k] = (x&y)|(y&z)|(z&x);
            end

            // --- HALF ADDER ---
            if (N_HA) begin : HA
                wire x = bits_in[c][3*N_FA];
                wire y = bits_in[c][3*N_FA+1];
                assign sum_out[c][N_FA]   = x ^ y;
                assign carry_out[c][N_FA] = x & y;
            end

            // --- PASS ---
            if (N_PASS) begin : PASS
                assign sum_out[c][N_FA+N_HA] = bits_in[c][3*N_FA + 2*N_HA];
            end
        end
    endgenerate
endmodule