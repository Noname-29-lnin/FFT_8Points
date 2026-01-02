// ============================================================================
// FILE: wallace_pkg.sv
// DESC: Thư viện tính toán cấu trúc Wallace Tree (Compile-Time)
//       Hỗ trợ tính số lượng FA/HA và định vị slot dây (Bucketing)
// ============================================================================

`ifndef _WALLACE_PKG_
`define _WALLACE_PKG_

package wallace_pkg;

    // ========================================================================
    // 1. RESOURCE PLANNING (QUY HOẠCH TÀI NGUYÊN)
    // ========================================================================

    // Tính số lượng Full Adder: Cứ 3 bit gom thành 1 FA
    function automatic int get_num_fa(int h);
        return h / 3;
    endfunction

    // Tính số lượng Half Adder: Nếu dư 2 bit thì dùng 1 HA
    function automatic int get_num_ha(int h);
        return (h % 3 == 2) ? 1 : 0;
    endfunction

    // Tính số lượng Pass (Nối thẳng): CHỈ KHI DƯ ĐÚNG 1 BIT
    // Lưu ý: Nếu dư 2 bit thì đã dùng HA rồi -> Pass = 0
    function automatic int get_num_pass(int h);
        return (h % 3 == 1) ? 1 : 0;
    endfunction

    // ========================================================================
    // 2. HEIGHT CALCULATION (TÍNH CHIỀU CAO CỘT)
    // ========================================================================

    // Tính tổng số bit (PP + CZ) tại cột 'col'
    function automatic int calc_total_height(
        int col, int NUM_PP, int PP_WIDTH, int NUM_CZ, int CZ_WIDTH
    );
        int h = 0;
        // Đếm số bit PP đi qua cột này
        for (int i = 0; i < NUM_PP; i++) begin
            if (col >= 2*i && col < 2*i + PP_WIDTH) h++;
        end
        
        // Đếm số bit CZ đi qua cột này
        for (int i = 0; i < NUM_CZ; i++) begin
            if (col >= 2*i && col < 2*i + CZ_WIDTH) h++;
        end
        
        return h;
    endfunction

    // ========================================================================
    // 3. SLOT INDEXING (ĐỊNH VỊ VỊ TRÍ TRONG BUCKET) - [CRITICAL LOGIC]
    // ========================================================================

    // Hàm trả về index (thứ tự) của một bit cụ thể trong mảng 'column_bits'
    // Nguyên lý xếp gạch:
    // - Các bit PP được xếp trước (nằm dưới đáy).
    // - Các bit CZ được xếp sau (nằm đè lên trên tất cả các bit PP).
    
    function automatic int get_slot_idx(
        int col, 
        int target_row_idx, 
        int is_cz, // 0 = PP, 1 = CZ
        int NUM_PP, int PP_WIDTH, 
        int NUM_CZ, int CZ_WIDTH
    );
        int slot = 0;
        
        if (is_cz == 0) begin
            // CASE 1: Đang tính vị trí cho một bit PP
            // Chỉ cần đếm xem có bao nhiêu hàng PP đứng TRƯỚC nó (index < target)
            // cũng đóng góp vào cột này.
            for (int i = 0; i < target_row_idx; i++) begin
                if (col >= 2*i && col < 2*i + PP_WIDTH) slot++;
            end
            
        end else begin
            // CASE 2: Đang tính vị trí cho một bit CZ
            // Phải đếm tổng 2 phần:
            // Phần A: TẤT CẢ các bit PP tại cột này (vì CZ nằm trên PP)
            for (int i = 0; i < NUM_PP; i++) begin
                if (col >= 2*i && col < 2*i + PP_WIDTH) slot++;
            end
            
            // Phần B: Các bit CZ đứng TRƯỚC nó
            for (int i = 0; i < target_row_idx; i++) begin
                if (col >= 2*i && col < 2*i + CZ_WIDTH) slot++;
            end
        end
        
        return slot;
    endfunction

    // HÀM MỚI: Dự đoán chiều cao bit tại cột 'col' của tầng tiếp theo (Next Stage)
    // Dựa trên chiều cao hiện tại của cột này (h_curr) và cột trước đó (h_prev)
    function automatic int predict_next_height(int h_curr, int h_prev);
        // 1. Bit Sum sinh ra từ chính cột này
        int n_fa_curr   = h_curr / 3;
        int n_ha_curr   = (h_curr % 3 == 2) ? 1 : 0;
        int n_pass_curr = (h_curr % 3 == 1) ? 1 : 0;
        int sum_bits    = n_fa_curr + n_ha_curr + n_pass_curr;

        // 2. Bit Carry bay từ cột trước (col-1) sang
        int n_fa_prev   = h_prev / 3;
        int n_ha_prev   = (h_prev % 3 == 2) ? 1 : 0;
        int carry_bits  = n_fa_prev + n_ha_prev;

        return sum_bits + carry_bits;
    endfunction

endpackage

`endif