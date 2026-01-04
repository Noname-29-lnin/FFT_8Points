clear; clc;

N = 8;              % So mau moi FFT
A = 10;             % Bien do

% ================== TAO 4 DOAN SIN ==================
% tan so tinh theo "so chu ky / 8 mau"
f1 = 1;      % Block 1
f2 = 2;      % Block 2
f3 = 3;      % Block 3
f4 = 1.5;    % Block 4 (leakage)

% index tung block (32 mau)
n1 = 0:N-1;
n2 = 8:15;
n3 = 16:23;
n4 = 24:31;

% tao tin hieu tung block
x1 = A*cos(2*pi*f1*n1/N);
x2 = A*cos(2*pi*f2*n2/N);
x3 = A*cos(2*pi*f3*n3/N);
x4 = A*cos(2*pi*f4*n4/N);

% gop lai
x = [x1 x2 x3 x4];

% ================== FFT 8-POINT TUNG BLOCK ==================
X1 = fft(x1);
X2 = fft(x2);
X3 = fft(x3);
X4 = fft(x4);

% ================== HEX IEEE754 (OCTAVE) ==================
tohex = @(v) upper(cellstr(dec2hex(typecast(single(v),'uint32'),8)));

xr_hex = tohex(real(x));
xi_hex = tohex(imag(x));

X1r_hex = tohex(real(X1));  X1i_hex = tohex(imag(X1));
X2r_hex = tohex(real(X2));  X2i_hex = tohex(imag(X2));
X3r_hex = tohex(real(X3));  X3i_hex = tohex(imag(X3));
X4r_hex = tohex(real(X4));  X4i_hex = tohex(imag(X4));

% ================== IN RA ==================
disp('===== 32 MAU INPUT =====');
disp(x)

disp('===== HEX INPUT REAL =====');
disp(xr_hex)

disp('===== FFT REAL (BLOCK 1..4) =====');
disp([real(X1); real(X2); real(X3); real(X4)])

disp('===== FFT IMAG (BLOCK 1..4) =====');
disp([imag(X1); imag(X2); imag(X3); imag(X4)])

% ================== LUU FILE ==================
fid = fopen('./fft8_input_hex_re.txt','w');
for i = 1:length(xr_hex)
    fprintf(fid, '%s\n', xr_hex{i});
end
fclose(fid);

fid = fopen('./fft8_input_hex_im.txt','w');
for i = 1:length(xi_hex)
    fprintf(fid, '%s\n', xi_hex{i});
end
fclose(fid);

Xr_hex_all = [ X1r_hex; X2r_hex; X3r_hex; X4r_hex ];
Xi_hex_all = [ X1i_hex; X2i_hex; X3i_hex; X4i_hex ];

fid = fopen('./fft8_output_hex_re.txt','w');
for i = 1:length(Xr_hex_all)
    fprintf(fid, '%s\n', Xr_hex_all{i});
end
fclose(fid);

fid = fopen('./fft8_output_hex_im.txt','w');
for i = 1:length(Xi_hex_all)
    fprintf(fid, '%s\n', Xi_hex_all{i});
end
fclose(fid);

% ================== VE SONG LIEN TUC + MAU ROI RAC ==================
Fs = 8;
Ts = 1/Fs;

t1 = 0:0.001:1;
t2 = 1:0.001:2;
t3 = 2:0.001:3;
t4 = 3:0.001:4;

x1c = A*cos(2*pi*f1*t1);
x2c = A*cos(2*pi*f2*t2);
x3c = A*cos(2*pi*f3*t3);
x4c = A*cos(2*pi*f4*t4);

t_cont = [t1 t2 t3 t4];
x_cont = [x1c x2c x3c x4c];

n = 0:31;
td = n*Ts;

figure;
plot(t_cont,x_cont,'LineWidth',1.5); hold on;
stem(td,x,'filled');
grid on;
xlabel('Time (s)');
ylabel('Amplitude');
title('Song sin lien tuc & cac diem roi rac');
legend('Analog-like signal','Sampled points');
hold off;

% ================== VE FFT 4 BLOCK ==================
figure; hold on; grid on;

stem(abs(X1),'filled');
stem(abs(X2),'filled');
stem(abs(X3),'filled');
stem(abs(X4),'filled');

title('Bien do FFT 8 diem cua 4 block');
xlabel('k');
ylabel('|X[k]|');

legend('Block 1: f = 1 cyc/8', ...
       'Block 2: f = 2 cyc/8', ...
       'Block 3: f = 3 cyc/8', ...
       'Block 4: f = 1.5 cyc/8');

hold off;

