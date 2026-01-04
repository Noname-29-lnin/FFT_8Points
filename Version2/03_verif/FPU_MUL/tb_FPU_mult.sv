`timescale 1ns/1ps

module tb_FPU_mult;

  localparam int NTEST = 100;

  // -------------------------
  // DUT I/O
  // -------------------------
  logic [31:0] i_32_a, i_32_b;
  logic [31:0] o_32_m;
  logic        o_ov_flag, o_un_flag;

  // -------------------------
  // DUT
  // -------------------------
  FPU_mult dut (
    .i_32_a   (i_32_a),
    .i_32_b   (i_32_b),
    .o_32_m   (o_32_m),
    .o_ov_flag(o_ov_flag),
    .o_un_flag(o_un_flag)
  );

  // -------------------------
  // Helpers: classify FP32 by bits
  // -------------------------
  function automatic logic is_zero(input logic [31:0] f);
    return (f[30:23] == 8'h00) && (f[22:0] == 23'd0);
  endfunction

  function automatic logic is_subnormal(input logic [31:0] f);
    return (f[30:23] == 8'h00) && (f[22:0] != 23'd0);
  endfunction

  function automatic logic is_inf(input logic [31:0] f);
    return (f[30:23] == 8'hFF) && (f[22:0] == 23'd0);
  endfunction

  function automatic logic is_nan(input logic [31:0] f);
    return (f[30:23] == 8'hFF) && (f[22:0] != 23'd0);
  endfunction

  // -------------------------
  // Convert bits <-> shortreal
  // -------------------------
  function automatic shortreal bits_to_sr(input logic [31:0] b);
    int tmp;
    begin
      tmp = int'(b);
      bits_to_sr = $bitstoshortreal(tmp);
    end
  endfunction

  function automatic logic [31:0] sr_to_bits(input shortreal x);
    sr_to_bits = $shortrealtobits(x);
  endfunction

  // -------------------------
  // Random FP32 generator (biased to hit special cases often)
  // NOTE: NO SUBNORMAL INPUTS are generated.
  //       (exp==0 => mant==0 only, i.e. zero)
  // -------------------------
  function automatic logic [31:0] rand_fp32_biased_no_sub();
    int sel;
    logic s;
    logic [7:0]  e;
    logic [22:0] m;
    begin
      sel = $urandom_range(0, 9);
      s   = $urandom_range(0, 1);

      unique case (sel)
        0: begin // +/-0 (allowed)
          e = 8'h00; m = 23'd0;
        end
        1: begin // +/-Inf
          e = 8'hFF; m = 23'd0;
        end
        2: begin // NaN (payload !=0)
          e = 8'hFF; m = 23'h000001 | $urandom_range(0, 23'h7FFFFE);
        end
        default: begin // normal only
          e = $urandom_range(1, 254);
          m = $urandom();
        end
      endcase

      rand_fp32_biased_no_sub = {s, e, m};
    end
  endfunction

  // -------------------------
  // Reference model:
  // - expected result bits using shortreal multiply
  // - force special-case encoding to match DUT policy:
  //   * NaN -> {sign_xor, 8'hFF, 23'h800000}
  //   * Inf -> {sign_xor, 8'hFF, 23'h000000}
  //   * Zero -> {sign_xor, 8'h00, 23'h000000}
  // - flags: ov = (Inf||NaN), un = (exp==0 && not Inf/NaN)
  // -------------------------
  task automatic calc_expected(
    input  logic [31:0] a_bits,
    input  logic [31:0] b_bits,
    output logic [31:0] exp_bits,
    output logic        exp_ov,
    output logic        exp_un,

    output logic        aZ, aI, aN, aS,
    output logic        bZ, bI, bN, bS
  );
    shortreal a_sr, b_sr, p_sr;
    logic [31:0] p_bits;
    logic sign_xor;
    logic p_is_nan, p_is_inf, p_is_zero;
    begin
      sign_xor = a_bits[31] ^ b_bits[31];

      aZ = is_zero(a_bits);
      aS = is_subnormal(a_bits);
      aI = is_inf(a_bits);
      aN = is_nan(a_bits);

      bZ = is_zero(b_bits);
      bS = is_subnormal(b_bits);
      bI = is_inf(b_bits);
      bN = is_nan(b_bits);

      // compute multiply in shortreal domain
      a_sr   = bits_to_sr(a_bits);
      b_sr   = bits_to_sr(b_bits);
      p_sr   = a_sr * b_sr;
      p_bits = sr_to_bits(p_sr);

      // classify product per IEEE bit pattern
      p_is_nan  = is_nan(p_bits);
      p_is_inf  = is_inf(p_bits);
      p_is_zero = is_zero(p_bits);

      // Force special encodings to match DUT muxing policy
      if (p_is_nan) begin
        exp_bits = {sign_xor, 8'hFF, 23'h800000}; // chosen NaN payload
      end
      else if (p_is_inf) begin
        exp_bits = {sign_xor, 8'hFF, 23'h000000};
      end
      else if (p_is_zero) begin
        exp_bits = {sign_xor, 8'h00, 23'h000000}; // keeps +/-0 via sign_xor
      end
      else begin
        // normal or subnormal finite: keep computed bits
        exp_bits = p_bits;
      end

      // flags per your spec
      exp_ov = is_inf(exp_bits) || is_nan(exp_bits);
      exp_un = (exp_bits[30:23] == 8'h00) && !exp_ov; // includes zero + subnormal
    end
  endtask

  // -------------------------
  // Test runner
  // -------------------------
  int pass_cnt, fail_cnt;
  int i;

  // for printing
  logic [31:0] exp_bits;
  logic        exp_ov, exp_un;

  logic aZ, aI, aN, aS;
  logic bZ, bI, bN, bS;

  initial begin
    $dumpfile("tb_FPU_mult.vcd");
    $dumpvars(0, tb_FPU_mult);

    pass_cnt = 0;
    fail_cnt = 0;

    $display("============================================================");
    $display(" TB: FPU_mult - %0d random tests", NTEST);
    $display(" Input constraint: NO subnormal inputs (exp==0 => mant==0 only)");
    $display(" Flags spec: ov=Inf/NaN, un=subnormal/zero");
    $display("============================================================");

    for (i = 0; i < NTEST; i++) begin
      // Generate inputs, explicitly exclude subnormal
      do begin
        i_32_a = rand_fp32_biased_no_sub();
      end while (is_subnormal(i_32_a));

      do begin
        i_32_b = rand_fp32_biased_no_sub();
      end while (is_subnormal(i_32_b));

      // settle combinational
      #1;

      // expected
      calc_expected(i_32_a, i_32_b, exp_bits, exp_ov, exp_un,
                    aZ, aI, aN, aS,
                    bZ, bI, bN, bS);

      // compare
      if ((o_32_m    === exp_bits) &&
          (o_ov_flag === exp_ov  ) &&
          (o_un_flag === exp_un  )) begin
        pass_cnt++;
        $display("TEST %0d: PASS", i);
      end
      else begin
        fail_cnt++;
        $display("TEST %0d: FAIL", i);
      end

      // Print separate blocks
      $display("  IN     : A=0x%08h  B=0x%08h", i_32_a, i_32_b);
      $display("           A{Z=%0b Sub=%0b Inf=%0b NaN=%0b}  B{Z=%0b Sub=%0b Inf=%0b NaN=%0b}",
               aZ, aS, aI, aN, bZ, bS, bI, bN);

      $display("  EXPECT : M=0x%08h  ov=%0b  un=%0b  (M{Z=%0b Sub=%0b Inf=%0b NaN=%0b})",
               exp_bits, exp_ov, exp_un,
               is_zero(exp_bits), is_subnormal(exp_bits), is_inf(exp_bits), is_nan(exp_bits));

      $display("  DUT    : M=0x%08h  ov=%0b  un=%0b  (M{Z=%0b Sub=%0b Inf=%0b NaN=%0b})",
               o_32_m, o_ov_flag, o_un_flag,
               is_zero(o_32_m), is_subnormal(o_32_m), is_inf(o_32_m), is_nan(o_32_m));

      $display("------------------------------------------------------------");
    end

    $display("============================================================");
    $display(" SUMMARY: PASS=%0d / %0d, FAIL=%0d / %0d",
             pass_cnt, NTEST, fail_cnt, NTEST);
    $display("============================================================");

    $finish;
  end

endmodule
