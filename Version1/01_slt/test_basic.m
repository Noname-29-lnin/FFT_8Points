% test_basic.m
% Chuong trinh MATLAB / Octave co ban de test

clc;        % xoa man hinh
clear;      % xoa bien
close all;  % dong cac cua so do thi

disp('=== MATLAB / GNU Octave TEST ===');

% 1. Tao truc thoi gian
fs = 10000;          % tan so lay mau (Hz)
t  = 0:1/fs:0.01;   % 10 ms

% 2. Tao tin hieu sin
f = 500;             % tan so tin hieu (Hz)
x = sin(2*pi*f*t);

% 3. Ve tin hieu theo thoi gian
figure;
plot(t, x);
grid on;
xlabel('Time (s)');
ylabel('Amplitude');
title('Sine signal in time domain');

% 4. Tinh FFT
N = length(x);
X = fft(x);

% 5. Tao truc tan so
f_axis = (0:N-1)*fs/N;

% 6. Ve pho tan so
figure;
plot(f_axis, abs(X));
grid on;
xlabel('Frequency (Hz)');
ylabel('|X(f)|');
title('Frequency spectrum (FFT)');

disp('=== DONE ===');
