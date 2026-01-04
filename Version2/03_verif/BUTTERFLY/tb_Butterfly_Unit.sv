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

    function automatic void butterfly_golden(
        input  complex_t x0,
        input  complex_t x1,
        input  complex_t w,
        output complex_t y0,
        output complex_t y1,
        output shortreal f_temp_1,
        output shortreal f_temp_2,
        output shortreal f_temp_3,
        output shortreal f_temp_4,
        output complex_t t
    );
        begin
            // t = w * x1
            f_temp_1 = w.re * x1.re;
            f_temp_2 = w.im * x1.im;
            t.re = f_temp_1 - f_temp_2;
            f_temp_3 = w.re * x1.im;
            f_temp_4 = w.im * x1.re;
            t.im = f_temp_3 + f_temp_4;

            // y0 = x0 + t
            y0.re = x0.re + t.re;
            y0.im = x0.im + t.im;

            // y1 = x0 - t
            y1.re = x0.re - t.re;
            y1.im = x0.im - t.im;
        end
    endfunction

    function automatic bit cmp_complex(
        input complex_t dut,
        input complex_t ref_val
    );
        real diff_re, diff_im;

        diff_re = dut.re - ref_val.re;
        diff_im = dut.im - ref_val.im;

        return ((diff_re <  EPS && diff_re > -EPS) &&
                (diff_im <  EPS && diff_im > -EPS));
    endfunction

    task automatic run_corner_test(
    input complex_t a_in,
    input complex_t b_in,
    input complex_t w_in,
    input string    name
    );
        shortreal temp_1, temp_2, temp_3, temp_4;
    begin
        complex_t temp_exp;
        complex_to_fp(a_in, a_re, a_im);
        complex_to_fp(b_in, b_re, b_im);
        complex_to_fp(w_in, w_re, w_im);
    
        #1;

        butterfly_golden(a_in, b_in, w_in, y0_ref, y1_ref, temp_1, temp_2, temp_3, temp_4, temp_exp);

        y0_dut = fp_to_complex(y0_re, y0_im);
        y1_dut = fp_to_complex(y1_re, y1_im);

        count++;

        $display("--------------------------------------------------");
            $display("INPUTS:");
            $display("  a = (%h , %h) = (%f , %f)",
                    a_re, a_im,
                    $bitstoshortreal(a_re),
                    $bitstoshortreal(a_im));

            $display("  b = (%h , %h) = (%f , %f)",
                    b_re, b_im,
                    $bitstoshortreal(b_re),
                    $bitstoshortreal(b_im));

            $display("  w = (%h , %h) = (%f , %f)",
                    w_re, w_im,
                    $bitstoshortreal(w_re),
                    $bitstoshortreal(w_im));

            $display("OUTPUTS (DUT):");
            $display("  y0 = (%h , %h) = (%f , %f)",
                    y0_re, y0_im,
                    $bitstoshortreal(y0_re),
                    $bitstoshortreal(y0_im));

            $display("  y1 = (%h , %h) = (%f , %f)",
                    y1_re, y1_im,
                    $bitstoshortreal(y1_re),
                    $bitstoshortreal(y1_im));
            
            $display(" [EXPECTED] temp_w = (%f , %f)",
                    temp_exp.re,
                    temp_exp.im);
            $display(" [EXPECTED] temp_1 = %f \t temp_2 = %f \t temp_3 = %f \t temp_4 = %f ",
                    temp_1, temp_2, temp_3, temp_4);
            $display(" [DUT] temp_w = (%f , %f)",
                    $bitstoshortreal(dut.bi_twiddle_re),
                    $bitstoshortreal(dut.bi_twiddle_im));
            $display(" [DUT] temp_1 = %f \t temp_2 = %f \t temp_3 = %f \t temp_4 = %f ",
                    $bitstoshortreal(dut.temp1), $bitstoshortreal(dut.temp2), $bitstoshortreal(dut.temp3), $bitstoshortreal(dut.temp4));
            $display("--------------------------------------------------");

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
