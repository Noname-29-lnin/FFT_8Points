module tb_Butterfly_Unit ();

    parameter real EPS = 1.0e-3;

    logic [31:0] a_re, a_im, b_re, b_im;
    logic [31:0] w_re, w_im;
    logic [31:0] y0_re, y0_im, y1_re, y1_im;

    int count = 0;
    int pass  = 0;

    Butterfly_Unit dut (
        .i_data_0_re (a_re),
        .i_data_0_im (a_im),
        .i_data_1_re (b_re),
        .i_data_1_im (b_im),
        .i_twiddle_re(w_re),
        .i_twiddle_im(w_im),
        .o_data_0_re (y0_re),
        .o_data_0_im (y0_im),
        .o_data_1_re (y1_re),
        .o_data_1_im (y1_im)
    );

    typedef struct {
        shortreal re;
        shortreal im;
    } complex_t;

    complex_t a, b, w;
    complex_t y0_ref, y1_ref;
    complex_t y0_dut, y1_dut;

    // ===============================
    // Convert FP bits -> complex
    // ===============================
    function automatic complex_t fp_to_complex(
        input logic [31:0] re_bits,
        input logic [31:0] im_bits
    );
        complex_t c;
        begin
            c.re = $bitstoshortreal(re_bits);
            c.im = $bitstoshortreal(im_bits);
            return c;
        end
    endfunction

    // ===============================
    // Convert complex -> FP bits
    // ===============================
    function automatic void complex_to_fp(
        input  complex_t c,
        output logic [31:0] re_bits,
        output logic [31:0] im_bits
    );
        begin
            re_bits = $shortrealtobits(c.re);
            im_bits = $shortrealtobits(c.im);
        end
    endfunction

    // ===============================
    // Golden butterfly
    // ===============================
    function automatic void butterfly_golden(
        input  complex_t x0,
        input  complex_t x1,
        input  complex_t w,
        output complex_t y0,
        output complex_t y1
    );
        complex_t t;
        begin
            // t = w * x1
            t.re = w.re * x1.re - w.im * x1.im;
            t.im = w.re * x1.im + w.im * x1.re;

            // y0 = x0 + t
            y0.re = x0.re + t.re;
            y0.im = x0.im + t.im;

            // y1 = x0 - t
            y1.re = x0.re - t.re;
            y1.im = x0.im - t.im;
        end
    endfunction

    // ===============================
    // Compare complex
    // ===============================
    function automatic bit cmp_complex(
        input complex_t dut,
        input complex_t ref
    );
        return ( $fabs(dut.re - ref.re) < EPS ) &&
               ( $fabs(dut.im - ref.im) < EPS );
    endfunction

    task automatic run_corner_test(
    input complex_t a_in,
    input complex_t b_in,
    input complex_t w_in,
    input string    name
    );
    begin
        complex_to_fp(a_in, a_re, a_im);
        complex_to_fp(b_in, b_re, b_im);
        complex_to_fp(w_in, w_re, w_im);

        #1;

        butterfly_golden(a_in, b_in, w_in, y0_ref, y1_ref);

        y0_dut = fp_to_complex(y0_re, y0_im);
        y1_dut = fp_to_complex(y1_re, y1_im);

        count++;

        if (cmp_complex(y0_dut, y0_ref) &&
            cmp_complex(y1_dut, y1_ref)) begin
            pass++;
            $display("[PASS] %s", name);
        end else begin
            $error(
                "[FAIL] %s\nY0 DUT=(%f,%f) REF=(%f,%f)\nY1 DUT=(%f,%f) REF=(%f,%f)",
                name,
                y0_dut.re, y0_dut.im,
                y0_ref.re, y0_ref.im,
                y1_dut.re, y1_dut.im,
                y1_ref.re, y1_ref.im
            );
        end

        #5;
    end
endtask

    // ===============================
    // Test sequence
    // ===============================
    initial begin
        // 1. W = 1
        run_corner_test(
            '{re:1.0, im:0.0},
            '{re:3.0, im:4.0},
            '{re:1.0, im:0.0},
            "W = 1"
        );

        // 2. W = -1
        run_corner_test(
            '{re:2.0, im:-1.0},
            '{re:1.0, im:2.0},
            '{re:-1.0, im:0.0},
            "W = -1"
        );

        // 3. W = j
        run_corner_test(
            '{re:1.0, im:1.0},
            '{re:2.0, im:3.0},
            '{re:0.0, im:1.0},
            "W = j"
        );

        // 4. W = -j
        run_corner_test(
            '{re:0.0, im:0.0},
            '{re:1.0, im:0.0},
            '{re:0.0, im:-1.0},
            "W = -j"
        );

        // 5. b = 0
        run_corner_test(
            '{re:1.5, im:-2.5},
            '{re:0.0, im:0.0},
            '{re:1.0, im:0.0},
            "b = 0"
        );

        // 6. a = 0
        run_corner_test(
            '{re:0.0, im:0.0},
            '{re:2.5, im:-1.5},
            '{re:0.7, im:-0.3},
            "a = 0"
        );

        // 7. a = b
        run_corner_test(
            '{re:1.2, im:3.4},
            '{re:1.2, im:3.4},
            '{re:0.5, im:-0.5},
            "a = b"
        );

        // 8. Twiddle = 0
        run_corner_test(
            '{re:2.0, im:3.0},
            '{re:4.0, im:5.0},
            '{re:0.0, im:0.0},
            "W = 0"
        );

        // 9. Large values
        run_corner_test(
            '{re:1000.0, im:-1000.0},
            '{re:-1000.0, im:1000.0},
            '{re:0.707, im:-0.707},
            "Large values"
        );

        for (int i = 0; i < 100; i++) begin

            // Random input (safe range)
            a.re = ($signed($urandom_range(0,2000)) - 1000) / 100.0;
            a.im = ($signed($urandom_range(0,2000)) - 1000) / 100.0;

            b.re = ($signed($urandom_range(0,2000)) - 1000) / 100.0;
            b.im = ($signed($urandom_range(0,2000)) - 1000) / 100.0;

            w.re = ($signed($urandom_range(0,2000)) - 1000) / 1000.0;
            w.im = ($signed($urandom_range(0,2000)) - 1000) / 1000.0;

            complex_to_fp(a, a_re, a_im);
            complex_to_fp(b, b_re, b_im);
            complex_to_fp(w, w_re, w_im);

            #1;

            butterfly_golden(a, b, w, y0_ref, y1_ref);

            y0_dut = fp_to_complex(y0_re, y0_im);
            y1_dut = fp_to_complex(y1_re, y1_im);

            count++;

            if (cmp_complex(y0_dut, y0_ref) &&
                cmp_complex(y1_dut, y1_ref)) begin
                pass++;
            end else begin
                $error(
                    "[%0d]\nY0 DUT=(%f,%f) REF=(%f,%f)\nY1 DUT=(%f,%f) REF=(%f,%f)",
                    i,
                    y0_dut.re, y0_dut.im,
                    y0_ref.re, y0_ref.im,
                    y1_dut.re, y1_dut.im,
                    y1_ref.re, y1_ref.im
                );
            end

            #5;
        end

        $display("=================================");
        $display(" Total vectors : %0d", count);
        $display(" Passed        : %0d", pass);
        $display(" Failed        : %0d", count - pass);
        $finish;
    end

endmodule
