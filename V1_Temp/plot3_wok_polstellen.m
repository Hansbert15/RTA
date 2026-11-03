%% Plot 3: Getrennte Pol-Nullstellen-Diagramme und Wurzelortskurven (PI vs. PID)
% Laborversuch RTA V1: Temperaturregelung - OTH Regensburg
% Autoren: Johannes Wutz, Oliver Grundmann, Eduardo Llama
% Gruppe: 5 | Datum: 26.10.2026
%
% Exakte Berechnung über MATLAB Control System Toolbox (tf, rlocus)
% Vereinfachtes dominantes PT1-Streckenmodell G_S(s) = K_S / (1 + T_S*s)

clear; close all; clc;

% Design-Einstellungen für sauberen weißen Export
set(groot, 'defaultTextColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [0 0 0]);
set(groot, 'defaultAxesYColor', [0 0 0]);
set(groot, 'defaultAxesColor', [1 1 1]);
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultLegendTextColor', [0 0 0]);

%% 1. Übertragungsfunktionen des offenen Kreises (MATLAB Control System Toolbox)
s = tf('s');

% Dominanter thermischer Streckenpol (PT1-Näherung: p_S = -1/T_S)
p_s = -0.40;
Gs  = 1 / (s - p_s);

% PI-Regler: F_R,PI(s) = K_P * (1 + 1/(T_N*s)) -> Pol bei 0, Nullstelle bei z_PI = -1/T_N
z_pi = -0.18;
G_pi = (s - z_pi) / s * Gs;

% PID-Regler: F_R,PID(s) = K_P * (1 + 1/(T_N*s) + T_V*s) -> Pol bei 0, zwei reelle Nullstellen
z_pid1 = -0.90;
z_pid2 = -1.50;
G_pid  = (s - z_pid1) * (s - z_pid2) / s * Gs;

% Fein aufgelöste Verstärkungsvektoren für exakt glatte Wurzelortskurven via rlocus
k_pi_vec  = [linspace(0, 2, 2000), linspace(2, 25, 1000)];
k_pid_vec = [linspace(0, 0.1, 1500), linspace(0.1, 12, 3000), linspace(12, 80, 1000)];

[r_pi, ~]  = rlocus(G_pi, k_pi_vec);
[r_pid, ~] = rlocus(G_pid, k_pid_vec);

% Analytische Verzweigungspunkte beim PID zur exakten Kontrolle
% d/ds [s(s - p_s) / ((s - z_pid1)(s - z_pid2))] = 0
% -> s_verz = -0.2442, s_einm = -1.1058, Kreismittelpunkt = -0.675, Radius R = 0.4308
sigma_M = -0.675;
R_kreis = sqrt(0.675^2 - 0.27);

%% 2. Grafik erstellen (2 getrennte Diagramme mit identischer Skalierung & 1:1 Aspekt)
fig = figure('Name', 'Wurzelortskurven PI vs PID (MATLAB rlocus)', ...
             'Units', 'pixels', 'Position', [100, 100, 1180, 470], 'Color', 'w');

tlo = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% Farbpalette
col_ps    = [0.85, 0.42, 0.08]; % Streckenpol (Orange)
col_pi    = [0.10, 0.60, 0.25]; % PI-WOK & Regler-P/N (Grün)
col_pid   = [0.00, 0.38, 0.82]; % PID-WOK & Regler-Nullstellen (Blau)
col_axis  = [0.55, 0.55, 0.55]; % Koordinatenachsen

% Hilfsfunktion für gestochen scharfe Richtungspfeile exakt auf der Kurve
draw_arrow = @(ax, x, y, dx, dy, sz, col) patch(ax, ...
    'XData', [x + 0.55*sz*dx, x - 0.45*sz*dx - 0.52*sz*dy, x - 0.45*sz*dx + 0.52*sz*dy], ...
    'YData', [y + 0.55*sz*dy, y - 0.45*sz*dy + 0.52*sz*dx, y - 0.45*sz*dy - 0.52*sz*dx], ...
    'FaceColor', col, 'EdgeColor', col, 'LineWidth', 0.5, 'HandleVisibility', 'off');

arrow_sz = 0.068;

% ==============================================================================
% SUBPLOT 1: PI-Regler
% ==============================================================================
ax1 = nexttile(tlo, 1);
hold(ax1, 'on');

xline(ax1, 0, 'Color', col_axis, 'LineWidth', 1.0, 'HandleVisibility', 'off');
yline(ax1, 0, 'Color', col_axis, 'LineWidth', 1.0, 'HandleVisibility', 'off');

% Beide WOK-Äste aus MATLAB rlocus plotten
h_wok_pi = plot(ax1, real(r_pi(1, :)), imag(r_pi(1, :)), '-', 'LineWidth', 2.6, 'Color', col_pi);
plot(ax1, real(r_pi(2, :)), imag(r_pi(2, :)), '-', 'LineWidth', 2.6, 'Color', col_pi, 'HandleVisibility', 'off');

% Richtungspfeile für steigendes K_P:
% Ast 1: 0 -> z_PI (-0.18) nach links
draw_arrow(ax1, -0.085, 0, -1, 0, arrow_sz, col_pi);
% Ast 2: p_S (-0.40) -> -Inf nach links
draw_arrow(ax1, -0.95, 0, -1, 0, arrow_sz, col_pi);

% Offene Pole (x) und Nullstellen (o)
h_pi_p0 = plot(ax1, 0, 0, 'x', 'MarkerSize', 11, 'LineWidth', 2.5, 'Color', col_pi);
h_pi_z  = plot(ax1, z_pi, 0, 'o', 'MarkerSize', 9.5, 'LineWidth', 2.3, 'Color', col_pi, 'MarkerFaceColor', 'w');
h_pi_ps = plot(ax1, p_s, 0, 'x', 'MarkerSize', 11, 'LineWidth', 2.5, 'Color', col_ps);

daspect(ax1, [1 1 1]);
xlim(ax1, [-1.75, 0.25]);
ylim(ax1, [-0.72, 0.72]);
grid(ax1, 'on');
set(ax1, 'Box', 'on', 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
         'GridColor', [0.85 0.85 0.85], 'GridAlpha', 0.85, 'FontSize', 10);

title(ax1, 'PI-Regler', 'FontSize', 12.5, 'FontWeight', 'bold', 'Color', 'k');
xlabel(ax1, 'Realteil \sigma [s^{-1}]', 'FontSize', 10.5, 'FontWeight', 'bold', 'Color', 'k');
ylabel(ax1, 'Imaginärteil j\omega [s^{-1}]', 'FontSize', 10.5, 'FontWeight', 'bold', 'Color', 'k');

legend(ax1, [h_wok_pi, h_pi_p0, h_pi_z, h_pi_ps], ...
       {'WOK (PI)', 'Reglerpol s = 0', 'Reglernullstelle z_{PI}', 'Streckenpol p_S'}, ...
       'Location', 'northwest', 'FontSize', 8.5, 'Box', 'on', 'Color', [1 1 1]);

% ==============================================================================
% SUBPLOT 2: PID-Regler
% ==============================================================================
ax2 = nexttile(tlo, 2);
hold(ax2, 'on');

xline(ax2, 0, 'Color', col_axis, 'LineWidth', 1.0, 'HandleVisibility', 'off');
yline(ax2, 0, 'Color', col_axis, 'LineWidth', 1.0, 'HandleVisibility', 'off');

% Beide WOK-Äste aus MATLAB rlocus plotten
h_wok_pid = plot(ax2, real(r_pid(1, :)), imag(r_pid(1, :)), '-', 'LineWidth', 2.6, 'Color', col_pid);
plot(ax2, real(r_pid(2, :)), imag(r_pid(2, :)), '-', 'LineWidth', 2.6, 'Color', col_pid, 'HandleVisibility', 'off');

% Richtungspfeile für steigendes K_P (exakt auf der berechneten WOK):
% 1. Vom Reglerpol 0 nach links zum Verzweigungspunkt (-0.244)
draw_arrow(ax2, -0.11, 0, -1, 0, arrow_sz, col_pid);
% 2. Vom Streckenpol p_S (-0.40) nach rechts zum Verzweigungspunkt (-0.244)
draw_arrow(ax2, -0.325, 0, 1, 0, arrow_sz, col_pid);
% 3. Oberer & unterer Kreisscheitel (sigma_M = -0.675, +-R_kreis = +-0.4308) nach links
draw_arrow(ax2, sigma_M,  R_kreis, -1, 0, arrow_sz, col_pid);
draw_arrow(ax2, sigma_M, -R_kreis, -1, 0, arrow_sz, col_pid);
% 4. Vom Einmündungspunkt (-1.106) nach rechts in z_PID1 (-0.90) & nach links in z_PID2 (-1.50)
draw_arrow(ax2, -1.01, 0,  1, 0, arrow_sz, col_pid);
draw_arrow(ax2, -1.29, 0, -1, 0, arrow_sz, col_pid);

% Offene Pole (x) und Nullstellen (o)
h_pid_p0 = plot(ax2, 0, 0, 'x', 'MarkerSize', 11, 'LineWidth', 2.5, 'Color', col_pi);
h_pid_ps = plot(ax2, p_s, 0, 'x', 'MarkerSize', 11, 'LineWidth', 2.5, 'Color', col_ps);
h_pid_z1 = plot(ax2, z_pid1, 0, 'o', 'MarkerSize', 9.5, 'LineWidth', 2.3, 'Color', col_pid, 'MarkerFaceColor', 'w');
plot(ax2, z_pid2, 0, 'o', 'MarkerSize', 9.5, 'LineWidth', 2.3, 'Color', col_pid, 'MarkerFaceColor', 'w', 'HandleVisibility', 'off');

daspect(ax2, [1 1 1]);
xlim(ax2, [-1.75, 0.25]);
ylim(ax2, [-0.72, 0.72]);
grid(ax2, 'on');
set(ax2, 'Box', 'on', 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
         'GridColor', [0.85 0.85 0.85], 'GridAlpha', 0.85, 'FontSize', 10);

title(ax2, 'PID-Regler', 'FontSize', 12.5, 'FontWeight', 'bold', 'Color', 'k');
xlabel(ax2, 'Realteil \sigma [s^{-1}]', 'FontSize', 10.5, 'FontWeight', 'bold', 'Color', 'k');
ylabel(ax2, 'Imaginärteil j\omega [s^{-1}]', 'FontSize', 10.5, 'FontWeight', 'bold', 'Color', 'k');

legend(ax2, [h_wok_pid, h_pid_p0, h_pid_z1, h_pid_ps], ...
       {'WOK (PID)', 'Reglerpol s = 0', 'Reglernullstellen z_{PID1,2}', 'Streckenpol p_S'}, ...
       'Location', 'northwest', 'FontSize', 8.5, 'Box', 'on', 'Color', [1 1 1]);

%% 3. Exportieren mit rein weißem Hintergrund und hoher Auflösung (300 DPI)
script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
    script_dir = pwd;
end
output_file = fullfile(script_dir, 'wok_analyse.png');
exportgraphics(fig, output_file, 'Resolution', 300, 'BackgroundColor', 'white');
fprintf('Grafik erfolgreich exportiert nach: %s\n', output_file);
