##clc; clear;
##
##% Input giống testbench Verilog
##x = [1 2 3 4 4 3 2 1];      % real
##x_imag = zeros(1,8);       % imag = 0
##
##% Tạo số phức
##xin = complex(x, x_imag);
##
##% FFT 8-point
##X = fft(xin, 8);
##
##disp('FFT Output (decimal):');
##for k = 1:8
##    fprintf('X(%d) = %.6f + %.6fj\n', k-1, real(X(k)), imag(X(k)));
##end

clc; clear; close all;

% Input giống testbench Verilog
x = single([1 2 3 4 4 3 2 1]);
xin = complex(x, zeros(1,8,'single'));

% FFT 8-point
X = fft(xin, 8);

k = 0:7;

%% 1 Magnitude
figure;
stem(k, abs(X), 'filled');
grid on;
xlabel('k');
ylabel('|X(k)|');
title('FFT 8-point Magnitude');

%% 2 Real part
figure;
stem(k, real(X), 'filled');
grid on;
xlabel('k');
ylabel('Real{X(k)}');
title('FFT 8-point Real Part');

%% 3️Imag part
figure;
stem(k, imag(X), 'filled');
grid on;
xlabel('k');
ylabel('Imag{X(k)}');
title('FFT 8-point Imaginary Part');
