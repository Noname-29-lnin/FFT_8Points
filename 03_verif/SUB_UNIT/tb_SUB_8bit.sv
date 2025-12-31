`timescale 1ns/1ps
module tb_SUB_8bit;

    logic        i_carry;
    logic [7:0]  i_data_a;
    logic [7:0]  i_data_b;
    logic [7:0]  o_sub;
    logic        o_borrow;

    logic [8:0]  ref_result;   // 9-bit để bắt borrow

    // ================= DUT =================
    SUB_8bit DUT (
        .i_carry   (i_carry),
        .i_data_a  (i_data_a),
        .i_data_b  (i_data_b),
        .o_sub     (o_sub),
        .o_borrow  (o_borrow)
    );

    initial begin 
        $shm_open("tb_SUB_8bit.shm");
        $shm_probe("ASM");
    end

    // ================= TASK CHECK =================
    task automatic check_result;
        begin
            // phép trừ chuẩn
            ref_result = {1'b0, i_data_a} - {1'b0, i_data_b} - i_carry;

            if (o_sub !== ref_result[7:0] || o_borrow !== ref_result[8]) begin
                $display("[FAIL] A=%0d B=%0d Bin=%0d | SUB=%0d Borrow=%0d | EXP_SUB=%0d EXP_BOR=%0d",
                         i_data_a, i_data_b, i_carry,
                         o_sub, o_borrow,
                         ref_result[7:0], ref_result[8]);
                $stop;
            end
            else begin
                $display("[PASS] A=%0d B=%0d Bin=%0d | SUB=%0d Borrow=%0d",
                         i_data_a, i_data_b, i_carry,
                         o_sub, o_borrow);
            end
        end
    endtask

    // ================= TEST =================
    initial begin
        $display("===== START SUB_8bit TEST =====");

        // --------- Test cơ bản ---------
        i_data_a = 8'd10; i_data_b = 8'd3; i_carry = 0; #5; check_result();
        i_data_a = 8'd10; i_data_b = 8'd3; i_carry = 1; #5; check_result();
        i_data_a = 8'd3;  i_data_b = 8'd10;i_carry = 0; #5; check_result();
        i_data_a = 8'd0;  i_data_b = 8'd0; i_carry = 0; #5; check_result();
        i_data_a = 8'd0;  i_data_b = 8'd1; i_carry = 0; #5; check_result();
        i_data_a = 8'hFF; i_data_b = 8'd1; i_carry = 0; #5; check_result();

        // --------- Test ngẫu nhiên ---------
        repeat (100) begin
            i_data_a = $urandom_range(0,255);
            i_data_b = $urandom_range(0,255);
            i_carry  = $urandom_range(0,1);
            #5;
            check_result();
        end

        $display("===== ALL TESTS PASSED =====");
        $finish;
    end

endmodule
