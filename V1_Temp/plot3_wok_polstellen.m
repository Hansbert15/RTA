%% Plot 3: Getrennte Pol-Nullstellen-Diagramme (PI vs. PID)
% Laborversuch RTA V1: Temperaturregelung - OTH Regensburg
% Autoren: Johannes Wutz, Oliver Grundmann, Eduardo Llama
% Gruppe: 5 | Datum: 26.10.2026

clear; close all; clc;

% Erzwinge sauberes helles Design
set(groot, 'defaultTextColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [0 0 0]);
set(groot, 'defaultAxesYColor', [0 0 0]);

%% Grafik erstellen (2 getrennte PN-Diagramme nebeneinander)
fig = figure('Name', 'PN-Diagramme PI vs PID', 'Units', 'pixels', ...
             'Position', [100, 100, 1100, 480], 'Color', 'w');

% Streckenpole (Rohr & Sensor)
p_s1 = -0.35;
p_s2 = -0.85;

% ==============================================================================
% SUBPLOT 1: PI
% ==============================================================================
ax1 = subplot(1, 2, 1);
hold(ax1, 'on');

% Koordinatenachsen
xline(0, '-', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.2);
yline(0, '-', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.2);
plot(0.25, 0, 'k>', 'MarkerFaceColor', 'k', 'MarkerSize', 5.5);
plot(0, 1.45, 'k^', 'MarkerFaceColor', 'k', 'MarkerSize', 5.5);
text(0.18, -0.14, '\bf Re\{s\}', 'FontSize', 10.5, 'Color', 'k');
text(0.02, 1.38, '\bf Im\{s\}', 'FontSize', 10.5, 'Color', 'k');

% Streckenpole (Orange)
plot(p_s1, 0, 'x', 'MarkerSize', 12, 'LineWidth', 2.4, 'Color', [0.85, 0.45, 0.1]);
plot(p_s2, 0, 'x', 'MarkerSize', 12, 'LineWidth', 2.4, 'Color', [0.85, 0.45, 0.1]);

% PI-Regler: Pol im Ursprung und Nullstelle (Grün)
p_I = 0.0;
n_PI = -0.22;
plot(p_I, 0, 'x', 'MarkerSize', 13, 'LineWidth', 2.6, 'Color', [0.1, 0.65, 0.25]);
plot(n_PI, 0, 'o', 'MarkerSize', 10, 'LineWidth', 2.2, 'Color', [0.1, 0.65, 0.25]);

% Mathematisch exakte WOK für PI berechnen
% D(s) = s * (1 + s/0.35) * (1 + s/0.85), N(s) = 1 + s/0.22
k_vec_pi = [linspace(0, 0.5, 300), linspace(0.5, 8, 500)];
roots_pi = zeros(length(k_vec_pi), 3);
for i = 1:length(k_vec_pi)
    k = k_vec_pi(i);
    % s^3 + (0.35+0.85)*s^2 + 0.35*0.85*s + k*(s + 0.22) * (0.35*0.85/0.22)
    poly_d = [1, (0.35+0.85), 0.35*0.85, 0];
    scale = (0.35*0.85)/0.22;
    poly_n = [0, 0, scale*k, scale*k*0.22];
    roots_pi(i, :) = roots(poly_d + poly_n);
end

% Sortiere und zeichne WOK-Kurven
plot([0, n_PI], [0, 0], '-', 'LineWidth', 2.8, 'Color', [0.1, 0.65, 0.25]);
plot([p_s1, p_s2], [0, 0], '-', 'LineWidth', 2.8, 'Color', [0.85, 0.45, 0.1]);

% Komplexe Äste (gehen nach oben und unten ins Unendliche)
complex_mask = abs(imag(roots_pi)) > 0.01;
r_comp = roots_pi(complex_mask);
r_upper = r_comp(imag(r_comp) > 0);
r_lower = r_comp(imag(r_comp) < 0);
[~, idx_u] = sort(imag(r_upper));
[~, idx_l] = sort(abs(imag(r_lower)));
plot(real(r_upper(idx_u)), imag(r_upper(idx_u)), '-', 'LineWidth', 2.5, 'Color', [0.85, 0.45, 0.1]);
plot(real(r_lower(idx_l)), imag(r_lower(idx_l)), '-', 'LineWidth', 2.5, 'Color', [0.85, 0.45, 0.1]);

% Pfeile für WOK-Richtung bei PI
% 1. Reelle Achse von 0 nach n_PI (links)
quiver(-0.08, 0, -0.06, 0, 0, 'Color', [0.1, 0.65, 0.25], 'LineWidth', 2, 'MaxHeadSize', 3.5);
% 2. Reelle Achse von p_s1 nach links zum Verzweigungspunkt
quiver(-0.42, 0, -0.06, 0, 0, 'Color', [0.85, 0.45, 0.1], 'LineWidth', 2, 'MaxHeadSize', 3.5);
% 3. Reelle Achse von p_s2 nach rechts zum Verzweigungspunkt
quiver(-0.76, 0, 0.06, 0, 0, 'Color', [0.85, 0.45, 0.1], 'LineWidth', 2, 'MaxHeadSize', 3.5);
% 4. Verzweigung nach oben (+j*inf)
quiver(-0.52, 0.55, 0.01, 0.15, 0, 'Color', [0.85, 0.45, 0.1], 'LineWidth', 2.2, 'MaxHeadSize', 3.5);
% 5. Verzweigung nach unten (-j*inf)
quiver(-0.52, -0.55, 0.01, -0.15, 0, 'Color', [0.85, 0.45, 0.1], 'LineWidth', 2.2, 'MaxHeadSize', 3.5);

% Beschriftung Achsen & Titel (EXAKT NUR "PI")
xlabel('Reeller Anteil \sigma [s^{-1}]', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
ylabel('Imaginärer Anteil j\omega [s^{-1}]', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
title('PI', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');
xlim([-1.25, 0.25]);
ylim([-1.45, 1.55]);
grid on;
set(ax1, 'Box', 'on', 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
         'GridColor', [0.85 0.85 0.85], 'GridAlpha', 0.8, 'FontSize', 10);

% ==============================================================================
% SUBPLOT 2: PID
% ==============================================================================
ax2 = subplot(1, 2, 2);
hold(ax2, 'on');

% Koordinatenachsen
xline(0, '-', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.2);
yline(0, '-', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.2);
plot(0.25, 0, 'k>', 'MarkerFaceColor', 'k', 'MarkerSize', 5.5);
plot(0, 1.45, 'k^', 'MarkerFaceColor', 'k', 'MarkerSize', 5.5);
text(0.18, -0.14, '\bf Re\{s\}', 'FontSize', 10.5, 'Color', 'k');
text(0.02, 1.38, '\bf Im\{s\}', 'FontSize', 10.5, 'Color', 'k');

% PID-Nullstellen (Blau)
n_PID1 = -0.50;
n_PID2 = -1.10;
plot(n_PID1, 0, 'o', 'MarkerSize', 10, 'LineWidth', 2.2, 'Color', [0.0, 0.35, 0.85]);
plot(n_PID2, 0, 'o', 'MarkerSize', 10, 'LineWidth', 2.2, 'Color', [0.0, 0.35, 0.85]);

% Streckenpole (Orange) & Integrator (Grün)
plot(p_s1, 0, 'x', 'MarkerSize', 12, 'LineWidth', 2.4, 'Color', [0.85, 0.45, 0.1]);
plot(p_s2, 0, 'x', 'MarkerSize', 12, 'LineWidth', 2.4, 'Color', [0.85, 0.45, 0.1]);
plot(0, 0, 'x', 'MarkerSize', 13, 'LineWidth', 2.6, 'Color', [0.1, 0.65, 0.25]);

% Mathematisch exakte WOK für PID berechnen
k_vec_pid = [linspace(0, 0.3, 200), linspace(0.3, 2, 300), linspace(2, 20, 500)];
roots_pid = zeros(length(k_vec_pid), 3);
for i = 1:length(k_vec_pid)
    k = k_vec_pid(i);
    % D(s) = s * (s+0.35) * (s+0.85) = s^3 + 1.2 s^2 + 0.2975 s
    poly_d = [1, 1.2, 0.2975, 0];
    % N(s) = (s+0.5)*(s+1.1) = s^2 + 1.6 s + 0.55
    poly_n = [0, k, 1.6*k, 0.55*k];
    roots_pid(i, :) = roots(poly_d + poly_n);
end

% Äste auf der reellen Achse
s_break1 = -0.165; % Verzweigungspunkt
s_break2 = -1.65;  % Einmündungspunkt

plot([0, s_break1], [0, 0], '-', 'LineWidth', 2.8, 'Color', [0.0, 0.35, 0.85]);
plot([p_s1, s_break1], [0, 0], '-', 'LineWidth', 2.8, 'Color', [0.0, 0.35, 0.85]);
plot([p_s2, n_PID1], [0, 0], '-', 'LineWidth', 2.8, 'Color', [0.0, 0.35, 0.85]);
plot([-2.6, s_break2], [0, 0], '-', 'LineWidth', 2.8, 'Color', [0.0, 0.35, 0.85]);
plot([s_break2, n_PID2], [0, 0], '-', 'LineWidth', 2.8, 'Color', [0.0, 0.35, 0.85]);

% Komplexe Schleife (aus dem Verzweigungspunkt über die Nullstellen zurück auf die reelle Achse)
complex_mask_pid = abs(imag(roots_pid)) > 0.001;
r_comp_pid = roots_pid(complex_mask_pid);
r_u_pid = r_comp_pid(imag(r_comp_pid) > 0);
r_l_pid = r_comp_pid(imag(r_comp_pid) < 0);
[~, idx_up] = sort(real(r_u_pid), 'descend');
[~, idx_lp] = sort(real(r_l_pid), 'descend');

% Nahtloser Anschluss an die reellen Verzweigungspunkte
x_upper = [s_break1; real(r_u_pid(idx_up)); s_break2];
y_upper = [0; imag(r_u_pid(idx_up)); 0];
x_lower = [s_break1; real(r_l_pid(idx_lp)); s_break2];
y_lower = [0; imag(r_l_pid(idx_lp)); 0];

plot(x_upper, y_upper, '-', 'LineWidth', 2.5, 'Color', [0.0, 0.35, 0.85]);
plot(x_lower, y_lower, '-', 'LineWidth', 2.5, 'Color', [0.0, 0.35, 0.85]);

% Pfeile für PID-WOK:
% 1. Vom Ursprung nach links zum Verzweigungspunkt
quiver(-0.06, 0, -0.06, 0, 0, 'Color', [0.0, 0.35, 0.85], 'LineWidth', 2, 'MaxHeadSize', 3.5);
% 2. Vom Pol p_s1 nach rechts zum Verzweigungspunkt
quiver(-0.28, 0, 0.06, 0, 0, 'Color', [0.0, 0.35, 0.85], 'LineWidth', 2, 'MaxHeadSize', 3.5);
% 3. Oberer Bogen (wandert im Bogen nach links)
quiver(-0.90, 0.61, -0.16, 0, 0, 'Color', [0.0, 0.35, 0.85], 'LineWidth', 2.2, 'MaxHeadSize', 3.5);
% 4. Unterer Bogen (wandert im Bogen nach links)
quiver(-0.90, -0.61, -0.16, 0, 0, 'Color', [0.0, 0.35, 0.85], 'LineWidth', 2.2, 'MaxHeadSize', 3.5);
% 5. Vom Einmündungspunkt nach rechts in die Nullstelle n_PID2
quiver(-1.50, 0, 0.12, 0, 0, 'Color', [0.0, 0.35, 0.85], 'LineWidth', 2.2, 'MaxHeadSize', 3.5);
% 6. Vom Einmündungspunkt nach links nach -unendlich
quiver(-1.95, 0, -0.15, 0, 0, 'Color', [0.0, 0.35, 0.85], 'LineWidth', 2.2, 'MaxHeadSize', 3.5);
% 7. Von p_s2 nach rechts in die Nullstelle n_PID1
quiver(-0.73, 0, 0.09, 0, 0, 'Color', [0.0, 0.35, 0.85], 'LineWidth', 2.2, 'MaxHeadSize', 3.5);

% Beschriftung Achsen & Titel (EXAKT NUR "PID")
xlabel('Reeller Anteil \sigma [s^{-1}]', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
ylabel('Imaginärer Anteil j\omega [s^{-1}]', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
title('PID', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');
xlim([-2.7, 0.25]);
ylim([-1.45, 1.55]);
grid on;
set(ax2, 'Box', 'on', 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
         'GridColor', [0.85 0.85 0.85], 'GridAlpha', 0.8, 'FontSize', 10);

%% Exportieren mit weißem Hintergrund
output_file = 'wok_analyse.png';
exportgraphics(fig, output_file, 'Resolution', 300, 'BackgroundColor', 'white');
fprintf('Grafik erfolgreich exportiert: %s\n', output_file);
