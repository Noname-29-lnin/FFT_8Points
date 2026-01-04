`timescale 1ns / 1ns
module tb_Multiplier;

    // 1. Khai báo tham số và tín hiệu
    parameter SIZE_DATA = 24;

    logic [SIZE_DATA-1:0]   i_data_a;
    logic [SIZE_DATA-1:0]   i_data_b;
    wire [2*SIZE_DATA-1:0]  o_product;

    // Biến lưu kết quả mong đợi (Golden Model) để so sánh
    logic [2*SIZE_DATA-1:0] expected_product;
    
    // Biến đếm lỗi
    int error_count = 0;

    // 2. Gọi module cần test (DUT - Device Under Test)
    Multiplier #(
        .SIZE_DATA(SIZE_DATA)
    ) dut (
        .i_data_a (i_data_a),
        .i_data_b (i_data_b),
        .o_product(o_product)
    );

    // 3. Khối điều khiển kiểm tra
    initial begin
        $display("--------------------------------------------------");
        $display("--- BẮT ĐẦU MÔ PHỎNG BỘ NHÂN 24-BIT ---");
        $display("--------------------------------------------------");

        // --- TRƯỜNG HỢP 1: Kiểm tra cơ bản (Reset / Zero) ---
        i_data_a = 0; i_data_b = 0;
        #10;
        check_result();

        // --- TRƯỜNG HỢP 2: Số nhỏ ---
        i_data_a = 10; i_data_b = 20;
        #10;
        check_result();

        // --- TRƯỜNG HỢP 3: Giá trị lớn nhất (Corner Case) ---
        // '1 trong SystemVerilog gán tất cả các bit thành 1 (Max Value)
        i_data_a = '1; i_data_b = '1; 
        #10;
        check_result();

        // --- TRƯỜNG HỢP 4: Kiểm tra ngẫu nhiên (Randomized Test) ---
        $display("--- Chạy 100 mẫu thử ngẫu nhiên... ---");
        
        repeat (100) begin
            // $urandom() trả về 32-bit unsigned, ta gán vào 24-bit
            i_data_a = $urandom(); 
            i_data_b = $urandom();
            
            // Đợi tín hiệu ổn định
            #10;
            
            // Kiểm tra
            check_result();
        end

        // --- KẾT THÚC ---
        $display("--------------------------------------------------");
        if (error_count == 0) begin
            $display("--- PASSED: Tất cả các test đều chính xác! ---");
        end else begin
            $display("--- FAILED: Phát hiện %0d lỗi! ---", error_count);
        end
        $display("--------------------------------------------------");
        $finish;
    end

    // 4. Task tự động kiểm tra kết quả
    task check_result();
        // Tính toán kết quả chuẩn bằng toán tử nhân của SystemVerilog (*)
        expected_product = i_data_a * i_data_b;

        // So sánh kết quả DUT với kết quả chuẩn
        if (o_product !== expected_product) begin
            $display("ERROR tại thời điểm %0t:", $time);
            $display("  Input A : %h (%d)", i_data_a, i_data_a);
            $display("  Input B : %h (%d)", i_data_b, i_data_b);
            $display("  DUT Out : %h (Sai)", o_product);
            $display("  Expected: %h (Đúng)", expected_product);
            error_count++;
        end
    endtask

endmodule