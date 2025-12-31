// ============================================================
//  Top Module: Complete 24x24 Unsigned Multiplier (Using Signed Logic)
// ============================================================

module Multiplier (
    input  logic [23:0] A,
    input  logic [23:0] B,
    output logic [47:0] Product
);

    // --------------------------------------------------------
    // PARAMETERS CONFIGURATION
    // --------------------------------------------------------
    localparam int N       = 24;     // Input width
    localparam int NUM_PP  = 13;     // Number of partial products
    localparam int NUM_CZ  = 12;     // NUM_PP - 1
    localparam int WIDTH   = 48;     // 2 * N

    // --------------------------------------------------------
    // INTERNAL SIGNALS
    // --------------------------------------------------------
    // PP rộng 26 bit [25:0] từ Modified_booth
    logic [25:0] PP [0:NUM_PP-1]; 
    logic [1:0]  CZ [0:NUM_CZ-1];
    
    logic [WIDTH-1:0] Final_Sum, Final_Carry, Vector_M;
    logic [WIDTH-1:0] Product_A, Product_B;
    logic [WIDTH-1:0] Product_Full;
    
    // ========================================
    // 1. BOOTH ENCODER
    // ========================================
    Modified_booth #(
        .N(N),
        .NUM_PP(NUM_PP)
    ) u_booth (
        .A(A),
        .B(B),
        .PP(PP),
        .CZ(CZ)
    );
    
    // ========================================
    // 2. WALLACE TREE
    // ========================================
    // wallace_tree expects PP_WIDTH = N+1 = 25 but receives 26-bit PP
    // Need to pass only bits [24:0] to wallace_tree
    wallace_tree #(
        .N(N),
        .NUM_PP(NUM_PP),
        .NUM_CZ(NUM_CZ)
    ) u_wallace (
        .PP_in(PP),
        .CZ(CZ),
        .final_sum(Final_Sum),
        .final_carry(Final_Carry)
    );
    
    // ========================================
    // 3. SIGNED AREA COMPUTATION
    // ========================================
    // Extract sign bits from PP (bit 25) and generate Vector_M
    signed_area_computation #(
        .N(N),          // N=24
        .NUM_PP(NUM_PP),
        .WIDTH(WIDTH)
    ) u_signed (
        .PP(PP),        // Full 26-bit PP
        .CZ(CZ),
        .Vector_M(Vector_M)
    );
    
    // ========================================
    // 4. FINAL MERGE (3->2)
    // ========================================
    // Merge Sum, Carry, and Vector_M into two rows using Full Adders
    wallace_final_merge #(
        .WIDTH(WIDTH)
    ) u_merge (
        .Final_Sum(Final_Sum),
        .Final_Carry(Final_Carry),
        .Vector_M(Vector_M),
        .Product_A(Product_A),
        .Product_B(Product_B)
    );
    
    // ========================================
    // 5. FINAL CLA (Full Width)
    // ========================================
    CLA_adder_top #(
        .WIDTH(WIDTH),
        .FANIN(4)
    ) u_cla (
        .A(Product_A),
        .B(Product_B),
        .C_in(1'b0),
        .Sum(Product_Full),
        .C_out() 
    );
    
    // ========================================
    // 6. OUTPUT
    // ========================================
    assign Product = Product_Full[47:0];
    
endmodule