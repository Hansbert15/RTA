%% Plot 3: Polstellen- und Wurzelortskurven-Analyse (Mitschrift Seite 3)
% Laborversuch PRTA V1 - OTH Regensburg
% Autoren: Johannes Wutz, Oliver Grundmann, Eduardo Llama
% Gruppe: 5 | Datum: 26.10.2026

clear; close all; clc;

% Erzwinge sauberes helles Design
set(groot, 'defaultTextColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [0 0 0]);
set(groot, 'defaultAxesYColor', [0 0 0]);
set(groot, 'defaultLegendTextColor', [0 0 0]);

%% 1. Grafik erstellen
fig = figure('Name', 'WOK Polstellen PRTA V1', 'Units', 'pixels', ...
             'Position', [100, 100, 950, 540], 'Color', 'w');

ax = axes('Parent', fig);
hold(ax, 'on');

% Koordinatenachsen
xline(0, '-', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.2);
yline(0, '-', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.2);

% Achsenbeschriftung
plot(0.2, 0, 'k>', 'MarkerFaceColor', 'k', 'MarkerSize', 6);
plot(0, 1.35, 'k^', 'MarkerFaceColor', 'k', 'MarkerSize', 6);
text(0.18, -0.12, '\bf Re\{s\}', 'FontSize', 11, 'Color', 'k');
text(0.03, 1.35, '\bf Im\{s\}', 'FontSize', 11, 'Color', 'k');

% Streckenpole
p_strecke1 = -0.35;
p_strecke2 = -0.85;

h_p1 = plot(p_strecke1, 0, 'x', 'MarkerSize', 11, 'LineWidth', 2.2, 'Color', [0.85, 0.45, 0.1]);
h_p2 = plot(p_strecke2, 0, 'x', 'MarkerSize', 11, 'LineWidth', 2.2, 'Color', [0.85, 0.45, 0.1]);

% --- P-Regler (Orange) ---
h_P = plot([-0.35, -0.6], [0, 0], '-', 'LineWidth', 2.6, 'Color', [0.9, 0.5, 0.1]);
plot([-0.85, -0.6], [0, 0], '-', 'LineWidth', 2.6, 'Color', [0.9, 0.5, 0.1]);

% --- PI-Regler (Grün) ---
p_I = 0.0;
n_PI = -0.22;

h_pI = plot(p_I, 0, 'x', 'MarkerSize', 12, 'LineWidth', 2.5, 'Color', [0.1, 0.65, 0.3]);
h_nPI = plot(n_PI, 0, 'o', 'MarkerSize', 10, 'LineWidth', 2.2, 'Color', [0.1, 0.65, 0.3]);
h_PI = plot([0, n_PI], [0, 0], '-', 'LineWidth', 2.2, 'Color', [0.1, 0.65, 0.3]);

% --- PID-Regler (Blau) ---
theta = linspace(0, 2*pi, 200);
r_circle = 0.42;
x_center = -0.70;
x_circle = x_center + r_circle * cos(theta);
y_circle = 0.95 * r_circle * sin(theta);
h_PID = plot(x_circle, y_circle, '-', 'LineWidth', 2.2, 'Color', [0.0, 0.35, 0.85]);

n_PID1 = -0.70;
n_PID2 = -1.15;
h_nPID1 = plot(n_PID1, 0, 'o', 'MarkerSize', 10, 'LineWidth', 2.2, 'Color', [0.0, 0.35, 0.85]);
plot(n_PID2, 0, 'o', 'MarkerSize', 10, 'LineWidth', 2.2, 'Color', [0.0, 0.35, 0.85]);

% Pfeile für Wanderungsrichtung
quiver(-0.70, 0.40, -0.05, 0, 0, 'Color', [0.0, 0.35, 0.85], 'LineWidth', 2, 'MaxHeadSize', 3);
quiver(-0.70, -0.40, 0.05, 0, 0, 'Color', [0.0, 0.35, 0.85], 'LineWidth', 2, 'MaxHeadSize', 3);

% Textannotationen zur Interpretation
text(-0.25, 0.65, {'{\bf PI-Regler:} Pol bei s=0 eliminiert', 'stationäre Regelabweichung'}, ...
     'FontSize', 9.5, 'Color', [0.1, 0.55, 0.25], 'BackgroundColor', [1 1 1 0.9], 'Margin', 2);
text(-1.38, 0.70, {'{\bf PID-Regler:} D-Anteil zieht Pole nach', 'links (schneller, aber Schwingung', 'bei Z/N-Parametrierung)'}, ...
     'FontSize', 9.5, 'Color', [0.0, 0.30, 0.75], 'BackgroundColor', [1 1 1 0.9], 'Margin', 2);
text(-0.55, -0.65, {'{\bf P-Regler:} Reelle Polbewegung', '\rightarrow bleibende Regelabweichung'}, ...
     'FontSize', 9.5, 'Color', [0.85, 0.45, 0.1], 'BackgroundColor', [1 1 1 0.9], 'Margin', 2);

% Formatierung
xlabel('Reeller Anteil \sigma [s^{-1}]', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
ylabel('Imaginärer Anteil j\omega [s^{-1}]', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
title('Pol-Nullstellen- und Wurzelortskurven-Synthese (gemäß Vorlesung & Mitschrift)', ...
      'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');

xlim([-1.45, 0.25]);
ylim([-1.1, 1.45]);
grid on;
set(ax, 'Box', 'on', 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
        'GridColor', [0.85 0.85 0.85], 'GridAlpha', 0.8, 'FontSize', 10);

legend([h_p1, h_P, h_pI, h_nPI, h_PID, h_nPID1], ...
       {'Streckenpole (\tau \approx 30 s, Verzug)', ...
        'P-Regler: Wurzelort entlang Re-Achse', ...
        'PI-Regler: Integratorpol s = 0', ...
        'PI-Regler: Nullstelle z = -1/T_N', ...
        'PID-Regler: WOK-Ast durch D-Vorhalt', ...
        'PID-Regler: Nullstellen z_1, z_2 (T_V)'}, ...
       'Location', 'southwest', 'FontSize', 8.8, 'Box', 'on', 'Color', [1 1 1 0.95], 'TextColor', 'k');

%% 2. Exportieren mit weißem Hintergrund
output_file = 'wok_analyse.png';
exportgraphics(fig, output_file, 'Resolution', 300, 'BackgroundColor', 'white');
fprintf('Grafik erfolgreich exportiert: %s\n', output_file);
