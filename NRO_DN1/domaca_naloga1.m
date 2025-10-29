clc, clear all;

% naloga 1

podatki = importdata('naloga1_1.txt');
t = podatki.data;
format long g
t;

% naloga 2

fid = fopen('naloga1_2.txt', 'r');
line = fgetl(fid);
num_values = sscanf(line, 'stevilo_podatkov_P: %d');
P = zeros(num_values, 1);

for i = 1:num_values
    line = fgetl(fid);
    P(i) = str2double(line);
end

fclose(fid);
format long g;

P;

%graf
figure(1)
plot(t, P)
title('graf P(t)')
xlabel('t[s]')
ylabel('P[W]')
grid on

% naloga 3

n = length(P);
I = 0;

for i = 1:n-1
    delta_t = t(i + 1) - t(i);
    I = I + delta_t * (P(i) + P(i + 1)) / 2;
end

I_trapz = trapz(t, P);

fprintf('integral: %.16f\n', I)
fprintf('trapz: %.16f\n', I_trapz)