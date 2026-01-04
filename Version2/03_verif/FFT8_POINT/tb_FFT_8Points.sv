`timescale 1ns/1ps

module tb_FFT_8Points;

    // =============================
    // Parameters
    // =============================
    parameter int SIZE_DATA = 32;
    parameter int NUM_TEST  =  4;
    parameter real EPSILON  = 1e-3;

    // =============================
    // Clock & control
    // =============================
    logic i_clk;
    logic i_rst_n;
    logic i_start;
    logic o_done;

    // =============================
    // Inputs (8 complex)
    // =============================
    logic [31:0] x_real [7:0];
    logic [31:0] x_imag [7:0];

    // =============================
    // Outputs (8 complex)
    // =============================
    logic [31:0] X_real [7:0];
    logic [31:0] X_imag [7:0];

    // =============================
    // DUT
    // =============================
    FFT_8Points #(.SIZE_DATA(SIZE_DATA)) dut (
        .i_clk   (i_clk),
        .i_rst_n (i_rst_n),
        .i_start (i_start),

        .x0_real (x_real[0]), .x0_imag (x_imag[0]),
        .x1_real (x_real[1]), .x1_imag (x_imag[1]),
        .x2_real (x_real[2]), .x2_imag (x_imag[2]),
        .x3_real (x_real[3]), .x3_imag (x_imag[3]),
        .x4_real (x_real[4]), .x4_imag (x_imag[4]),
        .x5_real (x_real[5]), .x5_imag (x_imag[5]),
        .x6_real (x_real[6]), .x6_imag (x_imag[6]),
        .x7_real (x_real[7]), .x7_imag (x_imag[7]),

        .X0_real (X_real[0]), .X0_imag (X_imag[0]),
        .X1_real (X_real[1]), .X1_imag (X_imag[1]),
        .X2_real (X_real[2]), .X2_imag (X_imag[2]),
        .X3_real (X_real[3]), .X3_imag (X_imag[3]),
        .X4_real (X_real[4]), .X4_imag (X_imag[4]),
        .X5_real (X_real[5]), .X5_imag (X_imag[5]),
        .X6_real (X_real[6]), .X6_imag (X_imag[6]),
        .X7_real (X_real[7]), .X7_imag (X_imag[7]),

        .o_done  (o_done)
    );

    // =============================
    // Clock
    // =============================
    always #5 i_clk = ~i_clk;

    initial begin
        $shm_open("tb_FFT_8Points.shm");
        $shm_probe("ASM");
    end

    // =============================
    // Test vectors
    // =============================
    logic [31:0] input_real  [8*NUM_TEST - 1:0];
    logic [31:0] input_imag  [8*NUM_TEST - 1:0];
    logic [31:0] exp_real    [8*NUM_TEST - 1:0];
    logic [31:0] exp_imag    [8*NUM_TEST - 1:0];

    initial begin
        $readmemh("./../../03_verif/FFT8_POINT/08_hex/fft_expected_imag.hex", exp_imag  );
        $readmemh("./../../03_verif/FFT8_POINT/08_hex/fft_expected_real.hex", exp_real  );
        $readmemh("./../../03_verif/FFT8_POINT/08_hex/input_imag.hex"       , input_imag);
        $readmemh("./../../03_verif/FFT8_POINT/08_hex/input_real.hex"       , input_real);
    end

    // =============================
    // Floating-point helpers
    // =============================
    function real fp(input logic [31:0] b);
        fp = $bitstoshortreal(b);
    endfunction

    function real abs(input real x);
        abs = (x < 0) ? -x : x;
    endfunction

    // =============================
    // Done edge detect
    // =============================
    logic done_d;
    always_ff @(posedge i_clk)
        done_d <= o_done;

    // =============================
    // Test procedure
    // =============================
    integer i, k;
    integer error_cnt = 0;

    initial begin
        // Init
        i_clk   = 0;
        i_rst_n = 0;
        i_start = 0;

        repeat (3) @(posedge i_clk);
        i_rst_n = 1;

        for (i = 0; i < NUM_TEST; i++) begin
    // Apply inputs (8 samples per FFT)
    for (k = 0; k < 8; k++) begin
        x_real[k] = input_real[i*8 + k];
        x_imag[k] = input_imag[i*8 + k];
    end

    // Start FFT
    @(posedge i_clk);
    i_start = 1;
    @(posedge i_clk);
    i_start = 0;

    // Wait done
    wait (!done_d && o_done);
    #1;

    // Check outputs
        for (k = 0; k < 8; k++) begin
            real dr, di;
            dr = abs(fp(X_real[k]) - fp(exp_real[i*8 + k]));
            di = abs(fp(X_imag[k]) - fp(exp_imag[i*8 + k]));
        
            if (dr > EPSILON || di > EPSILON) begin
                error_cnt++;
                $display(
                    "ERROR test=%0d bin=%0d | DUT=(%f,%f) EXP=(%f,%f)",
                    i, k,
                    fp(X_real[k]), fp(X_imag[k]),
                    fp(exp_real[i*8 + k]), fp(exp_imag[i*8 + k])
                );
            end
        end
    end

        // Summary
        if (error_cnt == 0)
            $display("ALL FFT TESTS PASSED (%0d vectors)", NUM_TEST);
        else
            $display("FFT FAILED: %0d errors", error_cnt);

        $finish;
    end

endmodule
