// --- CÁC MODULE CON (SUB-MODULES) ---

module vedic2x2 (
    input  [1:0] A,
    input  [1:0] B,
    output [3:0] P
);
    wire p0, p1, p2, p3, c1, c2, c3;
    assign p0 = A[0] & B[0];
    assign p1 = (A[1] & B[0]) ^ (A[0] & B[1]);
    assign c1 = (A[1] & B[0]) & (A[0] & B[1]);
    assign p2 = (A[1] & B[1]) ^ c1;
    assign c2 = (A[1] & B[1]) & c1;
    assign P = {c2, p2, p1, p0};
endmodule

module vedic4x4 (
    input  [3:0] A,
    input  [3:0] B,
    output [7:0] P
);
    wire [3:0] q0, q1, q2, q3;
    wire [7:0] temp1, temp2;
    vedic2x2 m1(A[1:0], B[1:0], q0);
    vedic2x2 m2(A[3:2], B[1:0], q1);
    vedic2x2 m3(A[1:0], B[3:2], q2);
    vedic2x2 m4(A[3:2], B[3:2], q3);
    assign temp1 = {q2, 2'b00} + {q1, 2'b00};
    assign temp2 = {q3, 4'b0000};
    assign P = q0 + temp1 + temp2;
endmodule

module vedic8x8 (
    input  [7:0] A,
    input  [7:0] B,
    output [15:0] P
);
    wire [7:0] q0, q1, q2, q3;
    wire [15:0] temp1, temp2;
    vedic4x4 m1(A[3:0], B[3:0], q0);
    vedic4x4 m2(A[7:4], B[3:0], q1);
    vedic4x4 m3(A[3:0], B[7:4], q2);
    vedic4x4 m4(A[7:4], B[7:4], q3);
    assign temp1 = {q2, 4'b0000} + {q1, 4'b0000};
    assign temp2 = {q3, 8'b00000000};
    assign P = q0 + temp1 + temp2;
endmodule

// Module này bị thiếu trong code cũ của bạn -> Gây lỗi
module vedic16x8 (
    input  logic [15:0] A,
    input  logic [7:0]  B,
    output logic [23:0] P
);
    wire [15:0] q0, q1;
    vedic8x8 m1(A[7:0], B, q0);
    vedic8x8 m2(A[15:8], B, q1);
    assign P = {q1, 8'b00000000} + q0;
endmodule

module array_multiplier (
    input  [15:0] A,
    input  [15:0] B,
    output [31:0] P
);
    wire [15:0] q0, q1, q2, q3;
    wire [31:0] temp1, temp2;
    vedic8x8 m1(A[7:0],  B[7:0],  q0);
    vedic8x8 m2(A[15:8], B[7:0],  q1);
    vedic8x8 m3(A[7:0],  B[15:8], q2);
    vedic8x8 m4(A[15:8], B[15:8], q3);
    assign temp1 = {q2, 8'b00000000} + {q1, 8'b00000000};
    assign temp2 = {q3, 16'b0000000000000000};
    assign P = q0 + temp1 + temp2;
endmodule

// --- MODULE CHÍNH (TOP MODULE) ---

module Multiplier #(
    parameter SIZE_DATA = 24
)(
    input  logic [SIZE_DATA-1:0]        i_data_a    ,
    input  logic [SIZE_DATA-1:0]        i_data_b    ,
    output logic [2*SIZE_DATA - 1:0]    o_product   
);
    wire [31:0] q0;      // Kết quả 16x16
    wire [23:0] q1, q2;  // Kết quả 16x8
    wire [15:0] q3;      // Kết quả 8x8
    
    wire [47:0] temp1, temp2;

    // 1. A_low * B_low (16bit x 16bit)
    array_multiplier m1 (i_data_a[15:0], i_data_b[15:0], q0);

    // 2. A_low * B_high (16bit x 8bit)
    vedic16x8 m2(i_data_a[15:0], i_data_b[23:16], q1);

    // 3. B_low * A_high (16bit x 8bit) -> Lưu ý đảo vị trí input
    vedic16x8 m3(i_data_b[15:0], i_data_a[23:16], q2);

    // 4. A_high * B_high (8bit x 8bit)
    vedic8x8 m4(i_data_a[23:16], i_data_b[23:16], q3);

    // --- Cộng tổng kết quả ---
    assign temp1 = {q1, 16'b0} + {q2, 16'b0}; 
    assign temp2 = {q3, 32'b0};               
    
    assign o_product = q0 + temp1 + temp2;

endmodule
