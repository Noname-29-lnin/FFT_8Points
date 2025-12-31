module wallace_final_merge #(
    parameter WIDTH = 48
)(
    input  wire [WIDTH-1:0] Final_Sum,
    input  wire [WIDTH-1:0] Final_Carry,
    input  wire [WIDTH-1:0] Vector_M,
    output wire [WIDTH-1:0] Product_A, // Đây sẽ là vector TỔNG (Sum)
    output wire [WIDTH-1:0] Product_B  // Đây sẽ là vector NHỚ (Carry) - DỊCH TRÁI 1 BIT
);

    genvar i;
    
    // Carry outputs từ FA
    wire [WIDTH-1:0] carry_out;
    
    generate
        for (i = 0; i < WIDTH; i++) begin : csa_row
            // Chỉ cần 1 FA để nén 3 bit thành 2 bit
            FA_1bit u_fa (
                .A   (Final_Sum[i]),
                .B   (Final_Carry[i]),
                .C   (Vector_M[i]),
                .S   (Product_A[i]),     // Bit Sum giữ nguyên vị trí i
                .C_o (carry_out[i])      // Bit Carry sinh ra từ i
            );
        end
    endgenerate

    // Shift carry left 1 bit: carry_out[i] → Product_B[i+1]
    assign Product_B[0] = 1'b0;  // Không có carry đi vào bit 0
    generate
        for (i = 0; i < WIDTH-1; i++) begin : shift_carry
            assign Product_B[i+1] = carry_out[i];
        end
    endgenerate
    
endmodule