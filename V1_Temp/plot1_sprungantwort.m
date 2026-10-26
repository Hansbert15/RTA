%% Plot 1: Sprungantwort des ungeregelten Systems mit Auswertung
% Laborversuch PRTA V1 - OTH Regensburg
% Autoren: Johannes Wutz, Oliver Grundmann, Eduardo Llama
% Gruppe: 5 | Datum: 26.10.2026

clear; close all; clc;

% Erzwinge sauberes helles Design (auch wenn MATLAB im Dark Mode läuft)
set(groot, 'defaultTextColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [0 0 0]);
set(groot, 'defaultAxesYColor', [0 0 0]);
set(groot, 'defaultLegendTextColor', [0 0 0]);

%% 1. Messdaten (Messprotokoll PRTA_V1)
% Phase 1: Aufheizen bei U = 20 V
t_aufheizen = [0, 2, 4, 6, 8, 10, 20, 30, 60, 90, 120, 150, 180, 210, ...
               240, 270, 300, 330, 360, 390, 420, 450, 480, 510, 540, 570, 600];
T_aufheizen = [21.9, 22.3, 24.3, 26.5, 28.2, 29.4, 32.6, 34.5, 37.3, 38.4, 38.9, 39.5, 39.9, 40.2, ...
               40.4, 40.8, 40.9, 41.0, 41.1, 41.3, 41.4, 41.5, 41.6, 41.6, 41.7, 41.7, 41.9];

% Phase 2: Störungssprung auf U = 18 V (Start bei t = 600 s)
t_stoer_rel = [0, 2, 4, 6, 8, 10, 20, 30, 60, 90, 120, 150, 180];
t_stoer = 600 + t_stoer_rel;
T_stoer = [41.9, 41.8, 41.7, 41.3, 41.0, 40.8, 40.1, 39.8, 39.1, 38.9, 38.9, 38.8, 38.8];

% Gesamtdaten zusammenführen
t_ges = [t_aufheizen, t_stoer(2:end)];
T_ges = [T_aufheizen, T_stoer(2:end)];

%% 2. Kennwerte
T_UV = 21.9;               % Umgebungstemperatur [°C]
T_end = 41.9;              % Endtemperatur nach 10 min [°C]
delta_T_ges = T_end - T_UV;% Gesamter Temperatursprung = 20.0 K

T_63 = T_UV + 0.632 * delta_T_ges; % 34.54 °C
t_63 = 30;                         % Gemessen: bei t = 30 s ist T = 34.5 °C
T_stoer_end = 38.8;        % Endtemperatur bei 18 V [°C]

%% 3. Grafik erstellen (Weißes wissenschaftliches Design)
fig = figure('Name', 'Sprungantwort PRTA V1', 'Units', 'pixels', ...
             'Position', [100, 100, 1050, 560], 'Color', 'w');

ax = axes('Parent', fig);
hold(ax, 'on');

% Shading für den Störungsbereich
h_patch = patch([600 780 780 600], [20 20 46 46], [0.93 0.93 0.95], ...
                'EdgeColor', 'none', 'FaceAlpha', 0.85);

% Horizontale Referenzlinien
h_end = yline(T_end, '--', 'Color', [0.85, 0.15, 0.15], 'LineWidth', 1.5);
h_uv  = yline(T_UV, ':', 'Color', [0.35, 0.35, 0.35], 'LineWidth', 1.3);
h_stoer = yline(T_stoer_end, '-.', 'Color', [0.75, 0.35, 0.1], 'LineWidth', 1.4);

% 63.2% Konstruktionslinien
plot([0, t_63], [T_63, T_63], 'Color', [0.1, 0.6, 0.25], 'LineStyle', ':', 'LineWidth', 1.3);
plot([t_63, t_63], [20, T_63], 'Color', [0.1, 0.6, 0.25], 'LineStyle', ':', 'LineWidth', 1.3);
h_63 = plot(t_63, T_63, 's', 'MarkerSize', 8.5, 'MarkerFaceColor', [0.1, 0.6, 0.25], ...
            'MarkerEdgeColor', 'k');

% Wendetangente zur Demonstration von Verzugszeit Tu / Ausgleichszeit Tg
t_tan = 0:50;
T_tan = 21.9 + 0.85 * (t_tan - 1.2);
idx_tan = T_tan <= 41.9 & T_tan >= 21.9;
h_tan = plot(t_tan(idx_tan), T_tan(idx_tan), 'Color', [0.85, 0.55, 0.0], 'LineWidth', 1.4, ...
             'LineStyle', '--');

% Messkurve
h_mess = plot(t_ges, T_ges, '-o', 'Color', [0.0, 0.30, 0.65], 'LineWidth', 1.8, ...
              'MarkerSize', 4.5, 'MarkerFaceColor', [0.0, 0.45, 0.85], ...
              'MarkerEdgeColor', [0.0, 0.20, 0.45]);

% Störungssprung Trennlinie
h_xline = xline(600, '-', 'Color', [0.5, 0.1, 0.1], 'LineWidth', 1.6);

% Textannotationen
text(120, 42.6, 'T_{\infty} = 41,9 °C', 'FontSize', 10.5, 'FontWeight', 'bold', 'Color', [0.75, 0.1, 0.1]);
text(42, 34.1, '63,2 %-Wert: \tau \approx 30 s (34,5 °C)', 'FontSize', 9.5, 'FontWeight', 'bold', 'Color', [0.1, 0.5, 0.2]);
text(615, 33.5, {'{\bf Störsprung (-10 % Spannung)}', '\Delta T = 3,1 K  \rightarrow  F_{rel} = 15,5 %'}, ...
     'FontSize', 9.5, 'Color', [0.5, 0.1, 0.1], 'BackgroundColor', 'w', 'Margin', 3);

% Formatierung Achsen & Titel
xlabel('Zeit t [s]', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
ylabel('Temperatur T [°C]', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
title('Sprungantwort des ungeregelten Systems mit Störungssprung (Kapitel 4.2.1)', ...
      'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');

xlim([0, 785]);
ylim([20, 45]);
grid on;
set(ax, 'Box', 'on', 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
        'GridColor', [0.82, 0.82, 0.82], 'GridAlpha', 0.8, 'FontSize', 10);

legend([h_mess, h_end, h_stoer, h_uv, h_63, h_tan, h_xline, h_patch], ...
       {'Messkurve Temperatur', 'Endwert T_{\infty} = 41,9 °C', ...
        'Endwert nach Störung T_{18V} = 38,8 °C', 'Umgebungstemperatur T_{UV} = 21,9 °C', ...
        '63,2 %-Punkt (\tau \approx 30 s)', 'Wendetangente (S-Kurve / Totzeit)', ...
        'Störungsaufschaltung (U = 20 V \rightarrow 18 V)', 'Störbereich (18 V)'}, ...
       'Location', 'southeast', 'FontSize', 8.8, 'Box', 'on', 'Color', [1 1 1 0.95], 'TextColor', 'k');

%% 4. Exportieren mit weißem Hintergrund
output_file = 'sprungantwort_auswertung.png';
exportgraphics(fig, output_file, 'Resolution', 300, 'BackgroundColor', 'white');
fprintf('Grafik erfolgreich exportiert: %s\n', output_file);
