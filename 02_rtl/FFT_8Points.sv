module FFT_8Points #(
    parameter NUM_POINTS    = 8 ,
    parameter WIDTH         = 32  // Dùng 32-bit Fixed Point Q16.16
)(
    input logic                                     i_clk,
    input logic                                     i_rst_n,
    input logic                                     i_start,

    // Input Arrays
    input wire  signed [NUM_POINTS-1:0][WIDTH-1:0]  i_data_re,
    input wire  signed [NUM_POINTS-1:0][WIDTH-1:0]  i_data_im,
    
    // Output Arrays
    output logic signed [NUM_POINTS-1:0][WIDTH-1:0] o_data_re,
    output logic signed [NUM_POINTS-1:0][WIDTH-1:0] o_data_im,
    output logic                                    o_done
);

    // --- CONSTANTS: Twiddle Factors (Fixed Point Q16.16) ---
    // 1.0  = 65536 (0x00010000)
    // 0.0  = 0
    // -1.0 = -65536 (0xFFFF0000)
    // 0.7071 (1/sqrt(2)) = 46341 (0x0000B505)
    // -0.7071            = -46341 (0xFFFF4AFB)
    
    localparam signed [31:0] ONE      = 32'h00010000;
    localparam signed [31:0] ZERO     = 32'h00000000;
    localparam signed [31:0] NEG_ONE  = 32'hFFFF0000;
    localparam signed [31:0] P_0707   = 32'h0000B505;
    localparam signed [31:0] N_0707   = 32'hFFFF4AFB;

    // --- PIPELINE REGISTERS ---
    logic signed [NUM_POINTS-1:0][WIDTH-1:0] s1_reg_re, s1_reg_im; // Sau Stage 1
    logic signed [NUM_POINTS-1:0][WIDTH-1:0] s2_reg_re, s2_reg_im; // Sau Stage 2
    
    // --- WIRES FROM BUTTERFLIES ---
    logic signed [NUM_POINTS-1:0][WIDTH-1:0] s1_comb_re, s1_comb_im;
    logic signed [NUM_POINTS-1:0][WIDTH-1:0] s2_comb_re, s2_comb_im;
    logic signed [NUM_POINTS-1:0][WIDTH-1:0] s3_comb_re, s3_comb_im;

    // --- CONTROL PIPELINE ---
    logic [2:0] valid_pipe;

    // ====================================================================
    // STAGE 1: Bit-Reversed Inputs
    // ====================================================================
    // Twiddle cho Stage 1 luôn là W_2^0 = 1
    Butterfly_Unit #(.SIZE_DATA(WIDTH)) bfly1_0 (.i_data_0_re(i_data_re[0]), .i_data_0_im(i_data_im[0]), .i_data_1_re(i_data_re[4]), .i_data_1_im(i_data_im[4]), .i_twiddle_re(ONE), .i_twiddle_im(ZERO), .o_data_0_re(s1_comb_re[0]), .o_data_0_im(s1_comb_im[0]), .o_data_1_re(s1_comb_re[1]), .o_data_1_im(s1_comb_im[1]));
    Butterfly_Unit #(.SIZE_DATA(WIDTH)) bfly1_1 (.i_data_0_re(i_data_re[2]), .i_data_0_im(i_data_im[2]), .i_data_1_re(i_data_re[6]), .i_data_1_im(i_data_im[6]), .i_twiddle_re(ONE), .i_twiddle_im(ZERO), .o_data_0_re(s1_comb_re[2]), .o_data_0_im(s1_comb_im[2]), .o_data_1_re(s1_comb_re[3]), .o_data_1_im(s1_comb_im[3]));
    Butterfly_Unit #(.SIZE_DATA(WIDTH)) bfly1_2 (.i_data_0_re(i_data_re[1]), .i_data_0_im(i_data_im[1]), .i_data_1_re(i_data_re[5]), .i_data_1_im(i_data_im[5]), .i_twiddle_re(ONE), .i_twiddle_im(ZERO), .o_data_0_re(s1_comb_re[4]), .o_data_0_im(s1_comb_im[4]), .o_data_1_re(s1_comb_re[5]), .o_data_1_im(s1_comb_im[5]));
    Butterfly_Unit #(.SIZE_DATA(WIDTH)) bfly1_3 (.i_data_0_re(i_data_re[3]), .i_data_0_im(i_data_im[3]), .i_data_1_re(i_data_re[7]), .i_data_1_im(i_data_im[7]), .i_twiddle_re(ONE), .i_twiddle_im(ZERO), .o_data_0_re(s1_comb_re[6]), .o_data_0_im(s1_comb_im[6]), .o_data_1_re(s1_comb_re[7]), .o_data_1_im(s1_comb_im[7]));

    // Register Stage 1
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin s1_reg_re <= '0; s1_reg_im <= '0; end
        else         begin s1_reg_re <= s1_comb_re; s1_reg_im <= s1_comb_im; end
    end

    // ====================================================================
    // STAGE 2
    // ====================================================================
    // W4^0 = 1, W4^1 = -j
    Butterfly_Unit #(.SIZE_DATA(WIDTH)) bfly2_0 (.i_data_0_re(s1_reg_re[0]), .i_data_0_im(s1_reg_im[0]), .i_data_1_re(s1_reg_re[2]), .i_data_1_im(s1_reg_im[2]), .i_twiddle_re(ONE), .i_twiddle_im(ZERO), .o_data_0_re(s2_comb_re[0]), .o_data_0_im(s2_comb_im[0]), .o_data_1_re(s2_comb_re[2]), .o_data_1_im(s2_comb_im[2]));
    Butterfly_Unit #(.SIZE_DATA(WIDTH)) bfly2_1 (.i_data_0_re(s1_reg_re[1]), .i_data_0_im(s1_reg_im[1]), .i_data_1_re(s1_reg_re[3]), .i_data_1_im(s1_reg_im[3]), .i_twiddle_re(ZERO), .i_twiddle_im(NEG_ONE), .o_data_0_re(s2_comb_re[1]), .o_data_0_im(s2_comb_im[1]), .o_data_1_re(s2_comb_re[3]), .o_data_1_im(s2_comb_im[3]));
    Butterfly_Unit #(.SIZE_DATA(WIDTH)) bfly2_2 (.i_data_0_re(s1_reg_re[4]), .i_data_0_im(s1_reg_im[4]), .i_data_1_re(s1_reg_re[6]), .i_data_1_im(s1_reg_im[6]), .i_twiddle_re(ONE), .i_twiddle_im(ZERO), .o_data_0_re(s2_comb_re[4]), .o_data_0_im(s2_comb_im[4]), .o_data_1_re(s2_comb_re[6]), .o_data_1_im(s2_comb_im[6]));
    Butterfly_Unit #(.SIZE_DATA(WIDTH)) bfly2_3 (.i_data_0_re(s1_reg_re[5]), .i_data_0_im(s1_reg_im[5]), .i_data_1_re(s1_reg_re[7]), .i_data_1_im(s1_reg_im[7]), .i_twiddle_re(ZERO), .i_twiddle_im(NEG_ONE), .o_data_0_re(s2_comb_re[5]), .o_data_0_im(s2_comb_im[5]), .o_data_1_re(s2_comb_re[7]), .o_data_1_im(s2_comb_im[7]));

    // Register Stage 2
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin s2_reg_re <= '0; s2_reg_im <= '0; end
        else         begin s2_reg_re <= s2_comb_re; s2_reg_im <= s2_comb_im; end
    end

    // ====================================================================
    // STAGE 3 (Final)
    // ====================================================================
    // W8^0=1, W8^1=(0.707 -j0.707), W8^2=-j, W8^3=(-0.707 -j0.707)
    Butterfly_Unit #(.SIZE_DATA(WIDTH)) bfly3_0 (.i_data_0_re(s2_reg_re[0]), .i_data_0_im(s2_reg_im[0]), .i_data_1_re(s2_reg_re[4]), .i_data_1_im(s2_reg_im[4]), .i_twiddle_re(ONE),    .i_twiddle_im(ZERO),    .o_data_0_re(s3_comb_re[0]), .o_data_0_im(s3_comb_im[0]), .o_data_1_re(s3_comb_re[4]), .o_data_1_im(s3_comb_im[4]));
    Butterfly_Unit #(.SIZE_DATA(WIDTH)) bfly3_1 (.i_data_0_re(s2_reg_re[1]), .i_data_0_im(s2_reg_im[1]), .i_data_1_re(s2_reg_re[5]), .i_data_1_im(s2_reg_im[5]), .i_twiddle_re(P_0707), .i_twiddle_im(N_0707),  .o_data_0_re(s3_comb_re[1]), .o_data_0_im(s3_comb_im[1]), .o_data_1_re(s3_comb_re[5]), .o_data_1_im(s3_comb_im[5]));
    Butterfly_Unit #(.SIZE_DATA(WIDTH)) bfly3_2 (.i_data_0_re(s2_reg_re[2]), .i_data_0_im(s2_reg_im[2]), .i_data_1_re(s2_reg_re[6]), .i_data_1_im(s2_reg_im[6]), .i_twiddle_re(ZERO),    .i_twiddle_im(NEG_ONE), .o_data_0_re(s3_comb_re[2]), .o_data_0_im(s3_comb_im[2]), .o_data_1_re(s3_comb_re[6]), .o_data_1_im(s3_comb_im[6]));
    Butterfly_Unit #(.SIZE_DATA(WIDTH)) bfly3_3 (.i_data_0_re(s2_reg_re[3]), .i_data_0_im(s2_reg_im[3]), .i_data_1_re(s2_reg_re[7]), .i_data_1_im(s2_reg_im[7]), .i_twiddle_re(N_0707), .i_twiddle_im(N_0707),  .o_data_0_re(s3_comb_re[3]), .o_data_0_im(s3_comb_im[3]), .o_data_1_re(s3_comb_re[7]), .o_data_1_im(s3_comb_im[7]));

    // Output Register
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin o_data_re <= '0; o_data_im <= '0; end
        else         begin o_data_re <= s3_comb_re; o_data_im <= s3_comb_im; end
    end

    // ====================================================================
    // CONTROL LOGIC
    // ====================================================================
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) valid_pipe <= 3'b0;
        else         valid_pipe <= {valid_pipe[1:0], i_start};
    end
    
    assign o_done = valid_pipe[2];

endmodule