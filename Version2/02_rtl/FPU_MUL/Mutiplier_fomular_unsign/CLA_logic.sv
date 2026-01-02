module CLA_logic #(
    parameter int WIDTH = 4
)(
    input  wire              C_in,
    input  wire [WIDTH-1:0]  G,
    input  wire [WIDTH-1:0]  P,
    output wire [WIDTH:0]    C_i
);

    assign C_i[0] = C_in;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i++) begin : GEN_C
            logic term_G_i;
            logic p_chain_to_cin;
            logic term_C_in;
            logic term_G_sum;
            
            // 1. Các Term đơn giản
            assign term_G_i = G[i];

            // SỬA: Dùng +: để tránh lỗi NOTPAR với genvar i
            assign p_chain_to_cin = &P[0 +: (i + 1)]; 
            assign term_C_in = p_chain_to_cin & C_in;

            // 2. Term phức tạp (Sum of Products)
            // SỬA: Dùng thuật toán tích lũy (Accumulator) thay vì cắt bit P[i:j+1]
            always_comb begin
                // Khai báo biến TRƯỚC khi thực thi (tránh lỗi BADDCL)
                logic p_chain;
                
                // Khởi tạo
                p_chain = 1'b1;
                term_G_sum = 1'b0;

                // Vòng lặp chạy ngược từ i-1 về 0
                // Tại mỗi bước j, p_chain sẽ tích lũy: P[i], P[i]P[i-1], ...
                for (int j = i - 1; j >= 0; j--) begin
                    // Cập nhật chuỗi P: Nhân thêm bit P[j+1]
                    p_chain = p_chain & P[j+1];

                    // Cộng dồn vào tổng G
                    term_G_sum |= G[j] & p_chain;
                end
            end
            
            assign C_i[i+1] = term_G_i | term_C_in | term_G_sum;
        end
    endgenerate

endmodule