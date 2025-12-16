% M_FFT_8points.m - Chương trình mô phỏng lý thuyết DIT FFT 8 điểm
% Dùng để tạo Golden Reference cho thiết kế Verilog/SystemVerilog.

clc
clear all
close all

function [X_dit_simulated, X_ideal_reference, x_input_reordered] = M_FFT_8points()

    % --- 1. Thiết lập các thông số cơ bản ---
    N = 8; % Số điểm FFT

    % Giả định: Dữ liệu là Fixed-Point Q1.15 (1 bit dấu, 1 bit nguyên, 15 bit thập phân)
    % Tổng 16 bit cho Real, 16 bit cho Imag -> 32 bit/điểm (SIZE_DATA=32)


    % --- 2. Tạo Tín hiệu Đầu vào (Input Signal Generation) ---
    % Tạo tín hiệu đầu vào phức tạp ngẫu nhiên (hoặc một sóng sin/cos chuẩn)
    Fs = 1000; % Tần số lấy mẫu
    t = (0:N-1)/Fs;
    f1 = 125; % Tần số tín hiệu (nên là bội số của Fs/N = 125Hz để tránh Leakage)

    % Tạo 8 điểm dữ liệu: một sóng sin phức tạp
    x_real = 0.8 * sin(2*pi*f1*t);
    x_imag = 0.5 * cos(2*pi*f1*t + pi/4);

    x = complex(x_real, x_imag); % Tín hiệu phức 8 điểm

    disp('--- 1. Tín hiệu đầu vào x[n] (Tự nhiên) ---');
    disp(x');

    % --- 3. Tính toán FFT Tham chiếu bằng MATLAB (Golden Reference) ---

    % Sử dụng hàm FFT chuẩn của MATLAB (Floating Point)
    X_ideal_reference = fft(x, N);

    disp('--- 2. Kết quả FFT lý tưởng X[k] (Golden Reference) ---');
    disp(X_ideal_reference');

    % --- 4. Mô phỏng Quá trình Decimation-In-Time (DIT) 8 điểm ---

    % 4.1. Bit Reversal (Sắp xếp lại đầu vào) - Chuẩn bị cho DIT
    % Trong Verilog, đây là bước tiền xử lý cho i_data
    input_indices = 0:N-1;
    bit_reversed_indices = bitrevorder(input_indices);
    x_input_reordered = x(bit_reversed_indices + 1); % +1 vì MATLAB bắt đầu từ 1

    disp('--- 3. Đầu vào đã đảo Bit (x_reordered) ---');
    disp(x_input_reordered');

    % Khởi tạo dữ liệu cho Tầng 1 (Stage 1)
    X_current = x_input_reordered;

    % Thừa số xoay (Twiddle Factors)
    W_N = exp(-1j * 2 * pi / N);


    % ******************************************************
    % Tầng 1 (Stage 1) - Khoảng cách 1 (N/8 = 1)
    % Butterfly Distance: 1
    % ******************************************************

    X_next = zeros(1, N);
    stride = 1; % Khoảng cách giữa A và B
    W_list = [W_N^0]; % Chỉ cần W^0 = 1

    for k_group = 0:(N/2 - 1) % 4 khối bướm (Butterfly)
        i1 = 2*k_group + 1; % Chỉ số A (MATLAB: index 1-based)
        i2 = 2*k_group + 2; % Chỉ số B

        A = X_current(i1);
        B = X_current(i2);
        W = W_list(1); % W_8^0

        X_next(i1) = A + B * W;
        X_next(i2) = A - B * W;
    end
    X_stg1 = X_next;

    disp('--- 4. Kết quả Tầng 1 ---');


    % ******************************************************
    % Tầng 2 (Stage 2) - Khoảng cách 2 (N/4 = 2)
    % Butterfly Distance: 2
    % ******************************************************

    X_current = X_stg1;
    X_next = zeros(1, N);
    stride = 2; % Khoảng cách giữa A và B
    W_list = [W_N^0, W_N^2]; % Chỉ số k = 0, 2

    for k_group = 0:(N/4 - 1) % 2 nhóm (Group 0 và Group 1)
        for k_idx = 0:(stride - 1) % 2 khối bướm trong mỗi nhóm
            i1 = 4*k_group + k_idx + 1; % Chỉ số A
            i2 = i1 + stride; % Chỉ số B

            A = X_current(i1);
            B = X_current(i2);
            W = W_list(k_idx + 1); % W_8^0 và W_8^2

            X_next(i1) = A + B * W;
            X_next(i2) = A - B * W;
        end
    end
    X_stg2 = X_next;

    disp('--- 5. Kết quả Tầng 2 ---');

    % ******************************************************
    % Tầng 3 (Stage 3) - Khoảng cách 4 (N/2 = 4)
    % Butterfly Distance: 4
    % ******************************************************

    X_current = X_stg2;
    X_next = zeros(1, N);
    stride = 4; % Khoảng cách giữa A và B
    W_list = [W_N^0, W_N^1, W_N^2, W_N^3]; % Tất cả các W_8^k

    for k_idx = 0:(N/2 - 1) % 4 khối bướm (k=0 đến 3)
        i1 = k_idx + 1; % Chỉ số A
        i2 = i1 + stride; % Chỉ số B

        A = X_current(i1);
        B = X_current(i2);
        W = W_list(k_idx + 1); % W_8^0, W_8^1, W_8^2, W_8^3

        X_next(i1) = A + B * W;
        X_next(i2) = A - B * W;
    end
    X_stg3 = X_next;
    X_dit_simulated = X_stg3;

    disp('--- 6. Kết quả DIT mô phỏng (Output o_data) ---');
    disp(X_dit_simulated');


    % --- 5. So sánh và Đánh giá ---

    error_abs = max(abs(X_ideal_reference - X_dit_simulated));
    fprintf('\n---> Sai số tuyệt đối Max giữa FFT chuẩn và DIT mô phỏng (lý tưởng): %e\n', error_abs);

    % Liên kết logic của 3 tầng xử lý trong kiến trúc DIT FFT 8 điểm với công thức đã học.
    [Image of Radix-2 DIT FFT 8-point signal flow graph]

end
