%% Plot 1: Sprungantwort des ungeregelten Systems mit Auswertung
% Laborversuch V1: Temperaturregelung
% Fach: Regelungstechnik Anwendungen
% Autoren: Johannes Wutz, Oliver Grundmann, Eduardo Llama
% Gruppe: 5 | Datum: 26.10.2026

clear; close all; clc;

% Erzwinge sauberes helles Design (auch im MATLAB Dark Mode)
set(groot, 'defaultTextColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [0 0 0]);
set(groot, 'defaultAxesYColor', [0 0 0]);
set(groot, 'defaultLegendTextColor', [0 0 0]);

%% 1. Messdaten (Messprotokoll V1)
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

% 63.2% Wert
T_63 = T_UV + 0.632 * delta_T_ges; % 34.54 °C
t_63 = 30;                         % Gemessen: bei t = 30 s ist T = 34.5 °C
T_stoer_end = 38.8;        % Endtemperatur bei 18 V [°C]

%% 3. Grafik erstellen (Großformat)
fig = figure('Name', 'Sprungantwort V1', 'Units', 'pixels', ...
             'Position', [100, 100, 1200, 650], 'Color', 'w');

ax = axes('Parent', fig);
hold(ax, 'on');

% Shading für den Störungsbereich (ab t = 600 s)
patch([600 785 785 600], [20 20 45 45], [0.95 0.94 0.95], ...
      'EdgeColor', 'none', 'FaceAlpha', 0.85);

% Horizontale Referenzlinien für Endwerte
yline(T_end, '--', 'Color', [0.75, 0.75, 0.75], 'LineWidth', 1.2);
yline(T_UV, ':', 'Color', [0.75, 0.75, 0.75], 'LineWidth', 1.2);
yline(T_stoer_end, '-.', 'Color', [0.85, 0.85, 0.85], 'LineWidth', 1.2);

%% 63.2% Konstruktion in EINER FARBE (Lila/Magenta)
col_63 = [0.65, 0.15, 0.65];
plot([0, t_63], [T_63, T_63], 'LineStyle', '--', 'Color', col_63, 'LineWidth', 1.6);
plot([t_63, t_63], [20, T_63], 'LineStyle', '--', 'Color', col_63, 'LineWidth', 1.6);
plot(t_63, T_63, 's', 'MarkerSize', 8, 'MarkerFaceColor', col_63, 'MarkerEdgeColor', col_63);

%% Tangente in EINER FARBE (Grün)
% Gelegt zwischen 2. und 3. Messpunkt: t=2s / 22.3°C und t=4s / 24.3°C
% Steigung m = 1.0 K/s, Schnitt mit T_end (41.9) bei t = 21.6 s
col_tan = [0.12, 0.62, 0.22];
t_tan = 1.6:0.5:22;
T_tan = 22.3 + 1.0 * (t_tan - 2);
plot(t_tan, T_tan, '--', 'Color', col_tan, 'LineWidth', 2.2);
plot([21.6, 21.6], [20, 41.9], ':', 'Color', col_tan, 'LineWidth', 1.5);
plot([2, 4], [22.3, 24.3], 'o', 'MarkerSize', 6, 'MarkerFaceColor', col_tan, 'MarkerEdgeColor', col_tan);
plot(21.6, 41.9, 'o', 'MarkerSize', 8, 'MarkerFaceColor', col_tan, 'MarkerEdgeColor', col_tan);

%% Messkurve (Blau)
plot(t_ges, T_ges, '-o', 'Color', [0.0, 0.30, 0.65], 'LineWidth', 2.0, ...
     'MarkerSize', 4.5, 'MarkerFaceColor', [0.0, 0.45, 0.85], ...
     'MarkerEdgeColor', [0.0, 0.20, 0.45]);

%% Störungssprung (Rote Linie bei t = 600 s)
xline(600, '-', 'Color', [0.85, 0.15, 0.15], 'LineWidth', 2.0);

%% Das EINZIGE Textfeld im gesamten Diagramm (beim roten Strich: "Störung")
text(608, 43.5, 'Störung', 'FontSize', 12, 'FontWeight', 'bold', ...
     'Color', [0.85, 0.15, 0.15], 'BackgroundColor', 'w', ...
     'EdgeColor', [0.85, 0.15, 0.15], 'Margin', 4);

%% Achsenskalierung mit T_End und T_Raum links in der Y-Skalierung
y_ticks = [20, 21.9, 25, 30, 34.54, 38.8, 41.9, 45];
y_labels = {'20', 'T_{Raum} = 21,9', '25', '30', '34,5 (63,2 %)', '38,8', 'T_{End} = 41,9', '45'};

set(ax, 'YTick', y_ticks, 'YTickLabel', y_labels);
xlabel('Zeit t [s]', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
ylabel('Temperatur T [°C]', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
title('Sprungantwort des ungeregelten Systems mit Störungssprung (Kapitel 4.2.1)', ...
      'FontSize', 13, 'FontWeight', 'bold', 'Color', 'k');

xlim([0, 785]);
ylim([20, 45]);
grid on;
set(ax, 'Box', 'on', 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
        'GridColor', [0.82, 0.82, 0.82], 'GridAlpha', 0.8, 'FontSize', 10.5);

%% 4. Exportieren mit weißem Hintergrund
output_file = 'sprungantwort_auswertung.png';
exportgraphics(fig, output_file, 'Resolution', 300, 'BackgroundColor', 'white');
fprintf('Grafik erfolgreich exportiert: %s\n', output_file);
