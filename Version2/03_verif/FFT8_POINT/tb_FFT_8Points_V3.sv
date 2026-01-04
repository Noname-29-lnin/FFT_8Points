module tb_FFT_8Points;

    // =============================
    // Parameters
    // =============================
    parameter int SIZE_DATA = 32;
    parameter int NUM_TEST  = 4;

    // Tolerance
    parameter real REAL_TOL = 1e-3;
    parameter real IMAG_TOL = 1e-3;
    parameter real ZERO_TOL = 1e-6;

    // =============================
    // Clock & control
    // =============================
    logic i_clk;
    logic i_rst_n;
    logic i_start;
    logic o_done;

    // =============================
    // Inputs / Outputs
    // =============================
    logic [31:0] x_real [7:0];
    logic [31:0] x_imag [7:0];
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

    // =============================
    // Test vectors
    // =============================
    logic [31:0] input_real [8*NUM_TEST-1:0];
    logic [31:0] input_imag [8*NUM_TEST-1:0];
    logic [31:0] exp_real   [8*NUM_TEST-1:0];
    logic [31:0] exp_imag   [8*NUM_TEST-1:0];

    initial begin
        $readmemh("./../../08_hex/input_real.hex"       , input_real);
        $readmemh("./../../08_hex/input_imag.hex"       , input_imag);
        $readmemh("./../../08_hex/fft_expected_real.hex", exp_real);
        $readmemh("./../../08_hex/fft_expected_imag.hex", exp_imag);
    end

    // =============================
    // Utility functions
    // =============================

    

    function automatic real fabs(input real x);
        begin
            if (x < 0.0)
                fabs = -x;
            else
                fabs = x;
        end
    endfunction

    function automatic logic close_real_bits(
        input logic [31:0] a,
        input logic [31:0] b,
        input real tol
    );
        real ra, rb;
        begin
            ra = $bitstoshortreal(a);
            rb = $bitstoshortreal(b);
            close_real_bits = (fabs(ra - rb) <= tol);
        end
    endfunction

    // =============================
    // Latch test_id
    // =============================
    int test_id;
    int test_id_lat;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n)
            test_id_lat <= 0;
        else if (i_start)
            test_id_lat <= test_id;
    end

    // =============================
    // Assertions
    // =============================

    logic done_d;
    always_ff @(posedge i_clk) done_d <= o_done;

    genvar g;
    generate
        for (g = 0; g < 8; g++) begin : FFT_ASSERT
            property fft_bin_correct;
                @(posedge i_clk);
                o_done && !done_d |-> (
                       close_real_bits(X_real[g], exp_real[test_id_lat*8 + g], REAL_TOL)
                    && close_real_bits(X_imag[g], exp_imag[test_id_lat*8 + g], IMAG_TOL)
                );
            endproperty

            assert property (fft_bin_correct) begin
                $display("FFT PASS: Test=%0d Bin=%0d", test_id_lat, g);
                $display("  REAL DUT=%f EXP=%f", $bitstoshortreal(X_real[g]), $bitstoshortreal(exp_real[test_id_lat*8 + g]));
                $display("  IMAG DUT=%f EXP=%f", $bitstoshortreal(X_imag[g]), $bitstoshortreal(exp_imag[test_id_lat*8 + g]));
                $display("\n");
            end else begin
                $error("FFT FAIL: Test=%0d Bin=%0d", test_id_lat, g);
                $display("  REAL DUT=%f EXP=%f", $bitstoshortreal(X_real[g]), $bitstoshortreal(exp_real[test_id_lat*8 + g]));
                $display("  IMAG DUT=%f EXP=%f", $bitstoshortreal(X_imag[g]), $bitstoshortreal(exp_imag[test_id_lat*8 + g]));
                $display("\n");
            end

        end
    endgenerate

    // =============================
    // Test procedure
    // =============================
    integer i, k;

    initial begin
        i_clk   = 0;
        i_rst_n = 0;
        i_start = 0;
        test_id = 0;

        repeat (3) @(posedge i_clk);
        i_rst_n = 1;

        for (i = 0; i < NUM_TEST; i++) begin
            test_id = i;

            for (k = 0; k < 8; k++) begin
                x_real[k] = input_real[i*8 + k];
                x_imag[k] = input_imag[i*8 + k];
            end

            @(posedge i_clk);
            i_start = 1;
            @(posedge i_clk);
            i_start = 0;

            wait (o_done);
            @(posedge i_clk);
        end

        $display("================================");
        $display("FFT TEST COMPLETED (%0d vectors)", NUM_TEST);
        $display("================================");
        #50;
        $finish;
    end

endmodule
