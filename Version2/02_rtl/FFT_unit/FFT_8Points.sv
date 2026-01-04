module FFT_8Points #(
    parameter SIZE_DATA = 32
)(
    input logic                     i_clk,
    input logic                     i_rst_n,
    input logic                     i_start,
    input logic [SIZE_DATA-1:0]     x0_real, x0_imag,
    input logic [SIZE_DATA-1:0]     x1_real, x1_imag,
    input logic [SIZE_DATA-1:0]     x2_real, x2_imag,
    input logic [SIZE_DATA-1:0]     x3_real, x3_imag,
    input logic [SIZE_DATA-1:0]     x4_real, x4_imag,
    input logic [SIZE_DATA-1:0]     x5_real, x5_imag,
    input logic [SIZE_DATA-1:0]     x6_real, x6_imag,
    input logic [SIZE_DATA-1:0]     x7_real, x7_imag,

    output logic [SIZE_DATA-1:0]    X0_real, X0_imag,
    output logic [SIZE_DATA-1:0]    X1_real, X1_imag,
    output logic [SIZE_DATA-1:0]    X2_real, X2_imag,
    output logic [SIZE_DATA-1:0]    X3_real, X3_imag,
    output logic [SIZE_DATA-1:0]    X4_real, X4_imag,
    output logic [SIZE_DATA-1:0]    X5_real, X5_imag,
    output logic [SIZE_DATA-1:0]    X6_real, X6_imag,
    output logic [SIZE_DATA-1:0]    X7_real, X7_imag,
    output logic                    o_done
);
// Stage 1
logic S1_start;
logic [SIZE_DATA-1:0]   s1_x0_real, s1_x0_imag;
logic [SIZE_DATA-1:0]   s1_x1_real, s1_x1_imag;
logic [SIZE_DATA-1:0]   s1_x2_real, s1_x2_imag;
logic [SIZE_DATA-1:0]   s1_x3_real, s1_x3_imag;
logic [SIZE_DATA-1:0]   s1_x4_real, s1_x4_imag;
logic [SIZE_DATA-1:0]   s1_x5_real, s1_x5_imag;
logic [SIZE_DATA-1:0]   s1_x6_real, s1_x6_imag;
logic [SIZE_DATA-1:0]   s1_x7_real, s1_x7_imag;
logic [SIZE_DATA-1:0]   S1_0_real, S1_0_imag, S1_1_real, S1_1_imag;
logic [SIZE_DATA-1:0]   S1_2_real, S1_2_imag, S1_3_real, S1_3_imag;
logic [SIZE_DATA-1:0]   S1_4_real, S1_4_imag, S1_5_real, S1_5_imag;
logic [SIZE_DATA-1:0]   S1_6_real, S1_6_imag, S1_7_real, S1_7_imag;

Detect_edge #(
    .POS_EDGE       (1)   // 1: posedge, 0: negedge
) DETECT_START_STAGE1 (
    .i_clk          (i_clk),
    .i_rst_n        (i_rst_n),
    .i_signal       (i_start),
    .o_signal       (w_start)
);
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        s1_x0_real      <= '0;
        s1_x0_imag      <= '0;
        s1_x1_real      <= '0;
        s1_x1_imag      <= '0;
        s1_x2_real      <= '0;
        s1_x2_imag      <= '0;
        s1_x3_real      <= '0;
        s1_x3_imag      <= '0;
        s1_x4_real      <= '0;
        s1_x4_imag      <= '0;
        s1_x5_real      <= '0;
        s1_x5_imag      <= '0;
        s1_x6_real      <= '0;
        s1_x6_imag      <= '0;
        s1_x7_real      <= '0;
        s1_x7_imag      <= '0;
    end else if(w_start) begin
        s1_x0_real      <= x0_real;
        s1_x0_imag      <= x0_imag;
        s1_x1_real      <= x1_real;
        s1_x1_imag      <= x1_imag;
        s1_x2_real      <= x2_real;
        s1_x2_imag      <= x2_imag;
        s1_x3_real      <= x3_real;
        s1_x3_imag      <= x3_imag;
        s1_x4_real      <= x4_real;
        s1_x4_imag      <= x4_imag;
        s1_x5_real      <= x5_real;
        s1_x5_imag      <= x5_imag;
        s1_x6_real      <= x6_real;
        s1_x6_imag      <= x6_imag;
        s1_x7_real      <= x7_real;
        s1_x7_imag      <= x7_imag;
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        S1_start    <= '0;
    end else begin
        S1_start    <= w_start;
    end
end

BFU_2 #(
    .SIZE_DATA      (SIZE_DATA)
) BFU2_S1_04 (
    .i_data_0_re    (s1_x0_real),
    .i_data_0_im    (s1_x0_imag),
    .i_data_1_re    (s1_x4_real),
    .i_data_1_im    (s1_x4_imag),
    .o_data_0_re    (S1_0_real),
    .o_data_0_im    (S1_0_imag),
    .o_data_1_re    (S1_4_real),
    .o_data_1_im    (S1_4_imag) 
);
BFU_2 #(
    .SIZE_DATA      (SIZE_DATA)
) BFU2_S1_26 (
    .i_data_0_re    (s1_x2_real),
    .i_data_0_im    (s1_x2_imag),
    .i_data_1_re    (s1_x6_real),
    .i_data_1_im    (s1_x6_imag),
    .o_data_0_re    (S1_2_real),
    .o_data_0_im    (S1_2_imag),
    .o_data_1_re    (S1_6_real),
    .o_data_1_im    (S1_6_imag) 
);
BFU_2 #(
    .SIZE_DATA      (SIZE_DATA)
) BFU2_S1_15 (
    .i_data_0_re    (s1_x1_real),
    .i_data_0_im    (s1_x1_imag),
    .i_data_1_re    (s1_x5_real),
    .i_data_1_im    (s1_x5_imag),
    .o_data_0_re    (S1_1_real),
    .o_data_0_im    (S1_1_imag),
    .o_data_1_re    (S1_5_real),
    .o_data_1_im    (S1_5_imag) 
);
BFU_2 #(
    .SIZE_DATA      (SIZE_DATA)
) BFU2_S1_37 (
    .i_data_0_re    (s1_x3_real),
    .i_data_0_im    (s1_x3_imag),
    .i_data_1_re    (s1_x7_real),
    .i_data_1_im    (s1_x7_imag),
    .o_data_0_re    (S1_3_real),
    .o_data_0_im    (S1_3_imag),
    .o_data_1_re    (S1_7_real),
    .o_data_1_im    (S1_7_imag) 
);

// Stage 2

logic S2_start; 
logic [SIZE_DATA-1:0] s2_S1_0_real, s2_S1_0_imag, s2_S1_1_real, s2_S1_1_imag;
logic [SIZE_DATA-1:0] s2_S1_2_real, s2_S1_2_imag, s2_S1_3_real, s2_S1_3_imag;
logic [SIZE_DATA-1:0] s2_S1_4_real, s2_S1_4_imag, s2_S1_5_real, s2_S1_5_imag;
logic [SIZE_DATA-1:0] s2_S1_6_real, s2_S1_6_imag, s2_S1_7_real, s2_S1_7_imag;

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        s2_S1_0_real    <= '0;
        s2_S1_0_imag    <= '0;
        s2_S1_1_real    <= '0;
        s2_S1_1_imag    <= '0;
        s2_S1_2_real    <= '0;
        s2_S1_2_imag    <= '0;
        s2_S1_3_real    <= '0;
        s2_S1_3_imag    <= '0;
        s2_S1_4_real    <= '0;
        s2_S1_4_imag    <= '0;
        s2_S1_5_real    <= '0;
        s2_S1_5_imag    <= '0;
        s2_S1_6_real    <= '0;
        s2_S1_6_imag    <= '0;
        s2_S1_7_real    <= '0;
        s2_S1_7_imag    <= '0;
    end else begin
        s2_S1_0_real    <= S1_0_real;
        s2_S1_0_imag    <= S1_0_imag;
        s2_S1_1_real    <= S1_1_real;
        s2_S1_1_imag    <= S1_1_imag;
        s2_S1_2_real    <= S1_2_real;
        s2_S1_2_imag    <= S1_2_imag;
        s2_S1_3_real    <= S1_3_real;
        s2_S1_3_imag    <= S1_3_imag;
        s2_S1_4_real    <= S1_4_real;
        s2_S1_4_imag    <= S1_4_imag;
        s2_S1_5_real    <= S1_5_real;
        s2_S1_5_imag    <= S1_5_imag;
        s2_S1_6_real    <= S1_6_real;
        s2_S1_6_imag    <= S1_6_imag;
        s2_S1_7_real    <= S1_7_real;
        s2_S1_7_imag    <= S1_7_imag;
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        S2_start    <= '0;
    end else begin
        S2_start    <= S1_start;
    end
end

logic [31:0] S2_0_real, S2_0_imag, S2_1_real, S2_1_imag;
logic [31:0] S2_2_real, S2_2_imag, S2_3_real, S2_3_imag;
logic [31:0] S2_4_real, S2_4_imag, S2_5_real, S2_5_imag;
logic [31:0] S2_6_real, S2_6_imag, S2_7_real, S2_7_imag;

BFU_4 #(
    .SIZE_DATA      (SIZE_DATA)
) BFU4_06 (
    .i_data_0_re    (s2_S1_0_real),
    .i_data_0_im    (s2_S1_0_imag),
    .i_data_1_re    (s2_S1_4_real),
    .i_data_1_im    (s2_S1_4_imag),
    .i_data_2_re    (s2_S1_2_real),
    .i_data_2_im    (s2_S1_2_imag),
    .i_data_3_re    (s2_S1_6_real),
    .i_data_3_im    (s2_S1_6_imag),
    .o_data_0_re    (S2_0_real),
    .o_data_0_im    (S2_0_imag),
    .o_data_1_re    (S2_4_real),
    .o_data_1_im    (S2_4_imag),
    .o_data_2_re    (S2_2_real),
    .o_data_2_im    (S2_2_imag),
    .o_data_3_re    (S2_6_real),
    .o_data_3_im    (S2_6_imag) 
);
BFU_4 #(
    .SIZE_DATA      (SIZE_DATA)
) BFU4_17 (
    .i_data_0_re    (s2_S1_1_real),
    .i_data_0_im    (s2_S1_1_imag),
    .i_data_1_re    (s2_S1_5_real),
    .i_data_1_im    (s2_S1_5_imag),
    .i_data_2_re    (s2_S1_3_real),
    .i_data_2_im    (s2_S1_3_imag),
    .i_data_3_re    (s2_S1_7_real),
    .i_data_3_im    (s2_S1_7_imag),
    .o_data_0_re    (S2_1_real),
    .o_data_0_im    (S2_1_imag),
    .o_data_1_re    (S2_5_real),
    .o_data_1_im    (S2_5_imag),
    .o_data_2_re    (S2_3_real),
    .o_data_2_im    (S2_3_imag),
    .o_data_3_re    (S2_7_real),
    .o_data_3_im    (S2_7_imag) 
);

// Stage 3 (final output)
logic S3_start;
logic [31:0] s3_S2_0_real, s3_S2_0_imag, s3_S2_1_real, s3_S2_1_imag;
logic [31:0] s3_S2_2_real, s3_S2_2_imag, s3_S2_3_real, s3_S2_3_imag;
logic [31:0] s3_S2_4_real, s3_S2_4_imag, s3_S2_5_real, s3_S2_5_imag;
logic [31:0] s3_S2_6_real, s3_S2_6_imag, s3_S2_7_real, s3_S2_7_imag;

always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        s3_S2_0_real    <= '0;
        s3_S2_0_imag    <= '0;
        s3_S2_1_real    <= '0;
        s3_S2_1_imag    <= '0;
        s3_S2_2_real    <= '0;
        s3_S2_2_imag    <= '0;
        s3_S2_3_real    <= '0;
        s3_S2_3_imag    <= '0;
        s3_S2_4_real    <= '0;
        s3_S2_4_imag    <= '0;
        s3_S2_5_real    <= '0;
        s3_S2_5_imag    <= '0;
        s3_S2_6_real    <= '0;
        s3_S2_6_imag    <= '0;
        s3_S2_7_real    <= '0;
        s3_S2_7_imag    <= '0;
    end else begin
        s3_S2_0_real    <= S2_0_real;
        s3_S2_0_imag    <= S2_0_imag;
        s3_S2_1_real    <= S2_1_real;
        s3_S2_1_imag    <= S2_1_imag;
        s3_S2_2_real    <= S2_2_real;
        s3_S2_2_imag    <= S2_2_imag;
        s3_S2_3_real    <= S2_3_real;
        s3_S2_3_imag    <= S2_3_imag;
        s3_S2_4_real    <= S2_4_real;
        s3_S2_4_imag    <= S2_4_imag;
        s3_S2_5_real    <= S2_5_real;
        s3_S2_5_imag    <= S2_5_imag;
        s3_S2_6_real    <= S2_6_real;
        s3_S2_6_imag    <= S2_6_imag;
        s3_S2_7_real    <= S2_7_real;
        s3_S2_7_imag    <= S2_7_imag;
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        S3_start    <= '0;
    end else begin
        S3_start    <= S2_start;
    end
end

logic [SIZE_DATA-1:0]    S3_X0_real, S3_X0_imag;
logic [SIZE_DATA-1:0]    S3_X1_real, S3_X1_imag;
logic [SIZE_DATA-1:0]    S3_X2_real, S3_X2_imag;
logic [SIZE_DATA-1:0]    S3_X3_real, S3_X3_imag;
logic [SIZE_DATA-1:0]    S3_X4_real, S3_X4_imag;
logic [SIZE_DATA-1:0]    S3_X5_real, S3_X5_imag;
logic [SIZE_DATA-1:0]    S3_X6_real, S3_X6_imag;
logic [SIZE_DATA-1:0]    S3_X7_real, S3_X7_imag;

BFU_8 #(
    .SIZE_DATA      (SIZE_DATA)
) BFU8_07 (
    .i_data_0_re    (s3_S2_0_real),
    .i_data_0_im    (s3_S2_0_imag),
    .i_data_1_re    (s3_S2_4_real),
    .i_data_1_im    (s3_S2_4_imag),
    .i_data_2_re    (s3_S2_2_real),
    .i_data_2_im    (s3_S2_2_imag),
    .i_data_3_re    (s3_S2_6_real),
    .i_data_3_im    (s3_S2_6_imag),
    .i_data_4_re    (s3_S2_1_real),
    .i_data_4_im    (s3_S2_1_imag),
    .i_data_5_re    (s3_S2_5_real),
    .i_data_5_im    (s3_S2_5_imag),
    .i_data_6_re    (s3_S2_3_real),
    .i_data_6_im    (s3_S2_3_imag),
    .i_data_7_re    (s3_S2_7_real),
    .i_data_7_im    (s3_S2_7_imag),
    .o_data_0_re    (S3_X0_real),
    .o_data_0_im    (S3_X0_imag),
    .o_data_1_re    (S3_X1_real),
    .o_data_1_im    (S3_X1_imag),
    .o_data_2_re    (S3_X2_real),
    .o_data_2_im    (S3_X2_imag),
    .o_data_3_re    (S3_X3_real),
    .o_data_3_im    (S3_X3_imag),
    .o_data_4_re    (S3_X4_real),
    .o_data_4_im    (S3_X4_imag),
    .o_data_5_re    (S3_X5_real),
    .o_data_5_im    (S3_X5_imag),
    .o_data_6_re    (S3_X6_real),
    .o_data_6_im    (S3_X6_imag),
    .o_data_7_re    (S3_X7_real),
    .o_data_7_im    (S3_X7_imag) 
);
logic w_done;
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        w_done    <= '0;
    end else begin
        w_done    <= S3_start;
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        X0_real     <= '0;
        X0_imag     <= '0;
        X1_real     <= '0;
        X1_imag     <= '0;
        X2_real     <= '0;
        X2_imag     <= '0;
        X3_real     <= '0;
        X3_imag     <= '0;
        X4_real     <= '0;
        X4_imag     <= '0;
        X5_real     <= '0;
        X5_imag     <= '0;
        X6_real     <= '0;
        X6_imag     <= '0;
        X7_real     <= '0;
        X7_imag     <= '0;
    end else if(w_done) begin
        X0_real     <= S3_X0_real;
        X0_imag     <= S3_X0_imag;
        X1_real     <= S3_X1_real;
        X1_imag     <= S3_X1_imag;
        X2_real     <= S3_X2_real;
        X2_imag     <= S3_X2_imag;
        X3_real     <= S3_X3_real;
        X3_imag     <= S3_X3_imag;
        X4_real     <= S3_X4_real;
        X4_imag     <= S3_X4_imag;
        X5_real     <= S3_X5_real;
        X5_imag     <= S3_X5_imag;
        X6_real     <= S3_X6_real;
        X6_imag     <= S3_X6_imag;
        X7_real     <= S3_X7_real;
        X7_imag     <= S3_X7_imag;
    end
end
always_ff @( posedge i_clk or negedge i_rst_n ) begin
    if(~i_rst_n) begin
        o_done    <= '0;
    end else begin
        o_done    <= w_done;
    end
end

endmodule
