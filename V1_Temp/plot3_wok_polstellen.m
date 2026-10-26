%% Plot 3: Getrennte Pol-Nullstellen-Diagramme und Wurzelortskurven (PI vs. PID)
% Laborversuch RTA V1: Temperaturregelung - OTH Regensburg
% Autoren: Johannes Wutz, Oliver Grundmann, Eduardo Llama
% Gruppe: 5 | Datum: 26.10.2026
%
% Berechnung erfolgt vollständig über native MATLAB Control System Toolbox (tf, rlocus)

clear; close all; clc;

% Design-Einstellungen für sauberen weißen Export
set(groot, 'defaultTextColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [0 0 0]);
set(groot, 'defaultAxesYColor', [0 0 0]);
set(groot, 'defaultAxesColor', [1 1 1]);
set(groot, 'defaultFigureColor', [1 1 1]);

%% 1. Definition der Übertragungsfunktionen mit MATLAB Control System Toolbox
s = tf('s');

% Streckenmodell mit dominanten thermischen Polen (Rohr & Sensor)
p_s1 = -0.35;
p_s2 = -0.85;
Gs = 1 / ((s - p_s1) * (s - p_s2));

% PI-Regler: Pol im Ursprung und Nullstelle (Kompensation / Nachstellzeit)
z_pi = -0.20;
G_pi = (s - z_pi) / s * Gs;

% PID-Regler: Pol im Ursprung und zwei Nullstellen (Vorhalt + Nachstellung)
z_pid1 = -0.50;
z_pid2 = -1.10;
G_pid = (s - z_pid1) * (s - z_pid2) / s * Gs;

% Exakte Berechnung der Wurzelortskurven mit MATLABs rlocus
[r_pi, k_pi]   = rlocus(G_pi);
[r_pid, k_pid] = rlocus(G_pid);

%% 2. Grafik erstellen (2 getrennte Diagramme nebeneinander)
fig = figure('Name', 'Wurzelortskurven PI vs PID (MATLAB rlocus)', ...
             'Units', 'pixels', 'Position', [100, 100, 1100, 480], 'Color', 'w');

% ==============================================================================
% SUBPLOT 1: PI
% ==============================================================================
ax1 = subplot(1, 2, 1);
hold(ax1, 'on');

% Koordinatenachsen
xline(ax1, 0, 'Color', [0.55 0.55 0.55], 'LineWidth', 1.0);
yline(ax1, 0, 'Color', [0.55 0.55 0.55], 'LineWidth', 1.0);

% Farben definieren
col_orange = [0.85, 0.45, 0.10];
col_green  = [0.10, 0.65, 0.25];
col_blue   = [0.00, 0.35, 0.85];

% WOK-Äste für PI:
% Row 1: Start bei 0 -> Ende bei Nullstelle (-0.20) [Grün]
plot(ax1, real(r_pi(1, :)), imag(r_pi(1, :)), '-', 'LineWidth', 2.4, 'Color', col_green);

% Row 2 & 3: Start bei Streckenpolen (-0.35, -0.85) -> Verzweigung -> +-j*Inf [Orange]
plot(ax1, real(r_pi(2, :)), imag(r_pi(2, :)), '-', 'LineWidth', 2.4, 'Color', col_orange);
plot(ax1, real(r_pi(3, :)), imag(r_pi(3, :)), '-', 'LineWidth', 2.4, 'Color', col_orange);

% Richtungspfeile entlang der WOK (Verlauf für steigende Verstärkung K)
% 1. Reelle Achse: 0 -> -0.2 (links)
quiver(ax1, -0.07, 0, -0.05, 0, 0, 'Color', col_green, 'LineWidth', 1.8, 'MaxHeadSize', 3.5);
% 2. Reelle Achse: p_s1 (-0.35) -> Verzweigungspunkt (-0.58) (links)
quiver(ax1, -0.43, 0, -0.05, 0, 0, 'Color', col_orange, 'LineWidth', 1.8, 'MaxHeadSize', 3.5);
% 3. Reelle Achse: p_s2 (-0.85) -> Verzweigungspunkt (-0.58) (rechts)
quiver(ax1, -0.75, 0, 0.05, 0, 0, 'Color', col_orange, 'LineWidth', 1.8, 'MaxHeadSize', 3.5);
% 4. Verzweigungsast nach oben (+j*inf)
quiver(ax1, -0.528, 0.55, 0.005, 0.12, 0, 'Color', col_orange, 'LineWidth', 1.9, 'MaxHeadSize', 2.5);
% 5. Verzweigungsast nach unten (-j*inf)
quiver(ax1, -0.528, -0.55, 0.005, -0.12, 0, 'Color', col_orange, 'LineWidth', 1.9, 'MaxHeadSize', 2.5);

% Pole (x) und Nullstellen (o)
plot(ax1, 0, 0, 'x', 'MarkerSize', 12, 'LineWidth', 2.6, 'Color', col_green);
plot(ax1, z_pi, 0, 'o', 'MarkerSize', 10, 'LineWidth', 2.2, 'Color', col_green);
plot(ax1, p_s1, 0, 'x', 'MarkerSize', 12, 'LineWidth', 2.4, 'Color', col_orange);
plot(ax1, p_s2, 0, 'x', 'MarkerSize', 12, 'LineWidth', 2.4, 'Color', col_orange);

% Achsenbeschriftung und Titel (EXAKT NUR "PI")
title(ax1, 'PI', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');
xlabel(ax1, 'Reeller Anteil \sigma [s^{-1}]', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
ylabel(ax1, 'Imaginärer Anteil j\omega [s^{-1}]', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
xlim(ax1, [-1.25, 0.25]);
ylim(ax1, [-1.50, 1.50]);
grid(ax1, 'on');
set(ax1, 'Box', 'on', 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
         'GridColor', [0.85 0.85 0.85], 'GridAlpha', 0.8, 'FontSize', 10);

% ==============================================================================
% SUBPLOT 2: PID
% ==============================================================================
ax2 = subplot(1, 2, 2);
hold(ax2, 'on');

% Koordinatenachsen
xline(ax2, 0, 'Color', [0.55 0.55 0.55], 'LineWidth', 1.0);
yline(ax2, 0, 'Color', [0.55 0.55 0.55], 'LineWidth', 1.0);

% WOK-Äste für PID (alle Kurven direkt aus MATLAB rlocus)
plot(ax2, real(r_pid(1, :)), imag(r_pid(1, :)), '-', 'LineWidth', 2.4, 'Color', col_blue);
plot(ax2, real(r_pid(2, :)), imag(r_pid(2, :)), '-', 'LineWidth', 2.4, 'Color', col_blue);
plot(ax2, real(r_pid(3, :)), imag(r_pid(3, :)), '-', 'LineWidth', 2.4, 'Color', col_blue);

% Richtungspfeile entlang der WOK für PID
% 1. Vom Ursprung nach links zum Verzweigungspunkt
quiver(ax2, -0.06, 0, -0.05, 0, 0, 'Color', col_blue, 'LineWidth', 1.8, 'MaxHeadSize', 3.5);
% 2. Vom Streckenpol p_s1 nach rechts zum Verzweigungspunkt
quiver(ax2, -0.27, 0, 0.05, 0, 0, 'Color', col_blue, 'LineWidth', 1.8, 'MaxHeadSize', 3.5);
% 3. Oberer Bogen (wandert nach links)
quiver(ax2, -1.05, 0.605, -0.12, 0, 0, 'Color', col_blue, 'LineWidth', 1.9, 'MaxHeadSize', 2.5);
% 4. Unterer Bogen (wandert nach links)
quiver(ax2, -1.05, -0.605, -0.12, 0, 0, 'Color', col_blue, 'LineWidth', 1.9, 'MaxHeadSize', 2.5);
% 5. Vom Einmündungspunkt (-1.65) nach rechts in die Nullstelle (-1.10)
quiver(ax2, -1.45, 0, 0.08, 0, 0, 'Color', col_blue, 'LineWidth', 1.8, 'MaxHeadSize', 3.5);
% 6. Vom Einmündungspunkt (-1.65) nach links Richtung -Unendlich
quiver(ax2, -2.10, 0, -0.15, 0, 0, 'Color', col_blue, 'LineWidth', 1.8, 'MaxHeadSize', 3.5);
% 7. Vom Pol p_s2 (-0.85) nach rechts in die Nullstelle (-0.50)
quiver(ax2, -0.70, 0, 0.06, 0, 0, 'Color', col_blue, 'LineWidth', 1.8, 'MaxHeadSize', 3.5);

% Pole (x) und Nullstellen (o)
plot(ax2, 0, 0, 'x', 'MarkerSize', 12, 'LineWidth', 2.6, 'Color', col_green);
plot(ax2, p_s1, 0, 'x', 'MarkerSize', 12, 'LineWidth', 2.4, 'Color', col_orange);
plot(ax2, p_s2, 0, 'x', 'MarkerSize', 12, 'LineWidth', 2.4, 'Color', col_orange);
plot(ax2, z_pid1, 0, 'o', 'MarkerSize', 10, 'LineWidth', 2.2, 'Color', col_blue);
plot(ax2, z_pid2, 0, 'o', 'MarkerSize', 10, 'LineWidth', 2.2, 'Color', col_blue);

% Achsenbeschriftung und Titel (EXAKT NUR "PID")
title(ax2, 'PID', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');
xlabel(ax2, 'Reeller Anteil \sigma [s^{-1}]', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
ylabel(ax2, 'Imaginärer Anteil j\omega [s^{-1}]', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
xlim(ax2, [-3.0, 0.25]);
ylim(ax2, [-1.00, 1.00]);
grid(ax2, 'on');
set(ax2, 'Box', 'on', 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
         'GridColor', [0.85 0.85 0.85], 'GridAlpha', 0.8, 'FontSize', 10);

%% 3. Exportieren mit rein weißem Hintergrund und hoher Auflösung (300 DPI)
output_file = 'wok_analyse.png';
exportgraphics(fig, output_file, 'Resolution', 300, 'BackgroundColor', 'white');
fprintf('Grafik erfolgreich exportiert: %s\n', output_file);
