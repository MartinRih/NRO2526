clear all; close all; clc;

fn_nodes = "vozlisca_temperature_dn2_28.txt";
fid = fopen(fn_nodes, "r");

% 1.
fgetl(fid);

% 2.
line = fgetl(fid);
Nx = sscanf(line, "st. koordinat v x-smeri: %d");

% 3.
line = fgetl(fid);
Ny = sscanf(line, "st. koordinat v y-smeri: %d");

% 4.
line = fgetl(fid);
N = sscanf(line, "st. vseh vozlišč: %d");

data = textscan(fid, "%f %f %f", "Delimiter", ",");
fclose(fid);

x = data{1};
y = data{2};
T = data{3};

fprintf("Nx = %d , Ny = %d\n", Nx, Ny);
fprintf("Prebranih vozlišč: %d\n", length(x));

fn_cells = "celice_dn2_28.txt";
fid = fopen(fn_cells, "r");

% 1.
fgetl(fid);

% 2.
line = fgetl(fid);
Nc = sscanf(line, "st. celic: %d");

C = textscan(fid, "%f %f %f %f", "Delimiter", ",");
fclose(fid);

celice = [C{1}, C{2}, C{3}, C{4}];

fprintf("Prebranih celic: %d\n", Nc);

Tx = 0.403;
Ty = 0.503;

tic;
F1 = scatteredInterpolant(x, y, T, "linear", "none");
T1 = F1(Tx, Ty);
cas1 = toc;

fprintf("Metoda 1 (scatteredInterpolant): T = %.6f °C, t = %.6f s\n", T1, cas1);

xu = unique(x);
yu = unique(y);

Tmat = reshape(T, Nx, Ny)';

tic;
F2 = griddedInterpolant({yu, xu}, Tmat, "linear");
T2 = F2(Ty, Tx);
cas2 = toc;

fprintf("Metoda 2 (griddedInterpolant): T = %.6f °C, t = %.6f s\n", T2, cas2);

tic;

dx = xu(2) - xu(1);
dy = yu(2) - yu(1);

ix = floor((Tx - xu(1)) / dx) + 1;
iy = floor((Ty - yu(1)) / dy) + 1;

ix = max(1, min(ix, Nx-1));
iy = max(1, min(iy, Ny-1));

T11 = Tmat(iy,   ix);
T21 = Tmat(iy,   ix+1);
T12 = Tmat(iy+1, ix);
T22 = Tmat(iy+1, ix+1);

x1 = xu(ix);   x2 = xu(ix+1);
y1 = yu(iy);   y2 = yu(iy+1);

K1 = (x2 - Tx)/(x2 - x1) * T11 + (Tx - x1)/(x2 - x1) * T21;
K2 = (x2 - Tx)/(x2 - x1) * T12 + (Tx - x1)/(x2 - x1) * T22;

T3 = (y2 - Ty)/(y2 - y1) * K1 + (Ty - y1)/(y2 - y1) * K2;

cas3 = toc;

fprintf("Metoda 3 (bilinearna): T = %.6f °C, t = %.10f s\n", T3, cas3);

[Tmax, idx] = max(T);
fprintf("\nNajvečja temperatura = %.6f °C na koordinatah (%.6f , %.6f)\n", ...
        Tmax, x(idx), y(idx));