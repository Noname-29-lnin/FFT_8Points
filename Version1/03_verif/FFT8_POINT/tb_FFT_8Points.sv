`timescale 1ns/1ps
module tb_FFT_8Points();

parameter SIZE_DATA = 32;
logic                     i_clk;
logic                     i_rst_n;
logic                     i_start;
logic [SIZE_DATA-1:0]     x0_real, x0_imag;
logic [SIZE_DATA-1:0]     x1_real, x1_imag;
logic [SIZE_DATA-1:0]     x2_real, x2_imag;
logic [SIZE_DATA-1:0]     x3_real, x3_imag;
logic [SIZE_DATA-1:0]     x4_real, x4_imag;
logic [SIZE_DATA-1:0]     x5_real, x5_imag;
logic [SIZE_DATA-1:0]     x6_real, x6_imag;
logic [SIZE_DATA-1:0]     x7_real, x7_imag;

logic [SIZE_DATA-1:0]    X0_real, X0_imag;
logic [SIZE_DATA-1:0]    X1_real, X1_imag;
logic [SIZE_DATA-1:0]    X2_real, X2_imag;
logic [SIZE_DATA-1:0]    X3_real, X3_imag;
logic [SIZE_DATA-1:0]    X4_real, X4_imag;
logic [SIZE_DATA-1:0]    X5_real, X5_imag;
logic [SIZE_DATA-1:0]    X6_real, X6_imag;
logic [SIZE_DATA-1:0]    X7_real, X7_imag;
logic                    o_done;


FFT_8Points #(
    .SIZE_DATA          (SIZE_DATA)
) DUT (
    .i_clk              (i_clk),
    .i_rst_n            (i_rst_n),
    .i_start            (i_start),
    .x0_real            (x0_real), 
    .x0_imag            (x0_imag),
    .x1_real            (x1_real), 
    .x1_imag            (x1_imag),
    .x2_real            (x2_real), 
    .x2_imag            (x2_imag),
    .x3_real            (x3_real), 
    .x3_imag            (x3_imag),
    .x4_real            (x4_real), 
    .x4_imag            (x4_imag),
    .x5_real            (x5_real), 
    .x5_imag            (x5_imag),
    .x6_real            (x6_real), 
    .x6_imag            (x6_imag),
    .x7_real            (x7_real), 
    .x7_imag            (x7_imag),
    .X0_real            (X0_real), 
    .X0_imag            (X0_imag),
    .X1_real            (X1_real), 
    .X1_imag            (X1_imag),
    .X2_real            (X2_real), 
    .X2_imag            (X2_imag),
    .X3_real            (X3_real), 
    .X3_imag            (X3_imag),
    .X4_real            (X4_real), 
    .X4_imag            (X4_imag),
    .X5_real            (X5_real), 
    .X5_imag            (X5_imag),
    .X6_real            (X6_real), 
    .X6_imag            (X6_imag),
    .X7_real            (X7_real), 
    .X7_imag            (X7_imag),
    .o_done             (o_done)
);

initial begin
    $shm_open("tb_FFT_8Points.shm");
    $shm_probe("ASM");
end

initial begin
    i_clk = 0;
    forever begin
        #10 i_clk = ~i_clk;
    end
end

initial begin
    i_rst_n = 0;
    i_start = 0;
    
    x0_real = 0; x0_imag = 0;
    x1_real = 0; x1_imag = 0;
    x2_real = 0; x2_imag = 0;
    x3_real = 0; x3_imag = 0;
    x4_real = 0; x4_imag = 0;
    x5_real = 0; x5_imag = 0;
    x6_real = 0; x6_imag = 0;
    x7_real = 0; x7_imag = 0;

    #100;
    @(negedge i_clk);
    i_rst_n = 1;
    $display("--- System Reset Released ---");
    #20;

    // ============================================================
    // TEST CASE 1: Tín hiệu DC (Constant)
    // Input: x[n] = 1.0 + j0.0 với mọi n
    // Expected Output: X[0] = 8.0, X[1..7] = 0.0
    // ============================================================
    $display("\n--- Test Case 1: DC Input (All inputs = 1.0) ---");
    
    // 1.0 trong IEEE 754 là 32'h3F800000
    x0_real = 32'h3F800000; x0_imag = 0;
    x1_real = 32'h3F800000; x1_imag = 0;
    x2_real = 32'h3F800000; x2_imag = 0;
    x3_real = 32'h3F800000; x3_imag = 0;
    x4_real = 32'h3F800000; x4_imag = 0;
    x5_real = 32'h3F800000; x5_imag = 0;
    x6_real = 32'h3F800000; x6_imag = 0;
    x7_real = 32'h3F800000; x7_imag = 0;

    @(negedge i_clk);
    i_start = 1;
    @(negedge i_clk);
    i_start = 0;
    wait(o_done);
    #5;
    
    $display("Result Test Case 1:");
    $display("X0 (Real/Imag): %h / %h (Expect: 41000000 / 00000000 - Value 8.0)", X0_real, X0_imag);
    $display("X1 (Real/Imag): %h / %h", X1_real, X1_imag);
    $display("X4 (Real/Imag): %h / %h", X4_real, X4_imag);
    #100;
    $display("\n--- Test Case 2: Impulse Input (Only x0 = 1.0) ---");
    x0_real = 32'h3F800000; x0_imag = 0; // x0 = 1.0
    x1_real = 0; x1_imag = 0;
    x2_real = 0; x2_imag = 0;
    x3_real = 0; x3_imag = 0;
    x4_real = 0; x4_imag = 0;
    x5_real = 0; x5_imag = 0;
    x6_real = 0; x6_imag = 0;
    x7_real = 0; x7_imag = 0;

    // Kích hoạt lại
    @(negedge i_clk);
    i_start = 1;
    @(negedge i_clk);
    i_start = 0;

    wait(o_done);
    #5;

    $display("Result Test Case 2:");
    $display("X0: %h (Expect ~3F800000)", X0_real);
    $display("X1: %h (Expect ~3F800000)", X1_real);
    $display("X2: %h (Expect ~3F800000)", X2_real);
    $display("X7: %h (Expect ~3F800000)", X7_real);

    #100;
    $display("\n--- Simulation Finished ---");
    $finish;
end

endmodule
