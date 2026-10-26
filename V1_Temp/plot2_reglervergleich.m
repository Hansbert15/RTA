%% Plot 2: Vergleichsanalyse der Regelungsarten (Manuell, P, PI, PID, Ungeregelt)
% Laborversuch PRTA V1 - OTH Regensburg
% Autoren: Johannes Wutz, Oliver Grundmann, Eduardo Llama
% Gruppe: 5 | Datum: 26.10.2026

clear; close all; clc;

% Erzwinge sauberes helles Design
set(groot, 'defaultTextColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [0 0 0]);
set(groot, 'defaultAxesYColor', [0 0 0]);
set(groot, 'defaultLegendTextColor', [0 0 0]);

%% 1. Daten aus Messprotokoll und Auswertung
kategorien_zeit = {'Manuelle Regelung', 'P-Regler', 'PI-Regler', 'PID-Regler'};
zeiten = [65, 25, 20, 22]; % Einschwingzeit in Sekunden ins +-0.2K Band

kategorien_stoer = {'Ungeregelt (Steuerung)', 'P-Regler', 'PI-Regler', 'PID-Regler'};
fehler_stoer_rel = [15.5, 3.9, 0.0, 0.0]; % Relativer stationärer Fehler bei -10% Spannung [%]

%% 2. Grafik erstellen
fig = figure('Name', 'Reglervergleich RTA V1', 'Units', 'pixels', ...
             'Position', [100, 100, 1100, 480], 'Color', 'w');

% --- Subplot 1: Einschwingzeiten ---
ax1 = subplot(1, 2, 1);
hold(ax1, 'on');
farben_zeit = [0.75, 0.25, 0.25;  % Manuell (rot)
               0.20, 0.50, 0.75;  % P (blau)
               0.15, 0.65, 0.35;  % PI (grün - Optimum!)
               0.90, 0.60, 0.15]; % PID (orange)

b1 = bar(1:4, zeiten, 0.55, 'FaceColor', 'flat');
b1.CData = farben_zeit;

% Werte über den Balken anzeigen (in Schwarz)
for i = 1:length(zeiten)
    text(i, zeiten(i) + 2.4, sprintf('%d s', zeiten(i)), ...
         'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
end

% Keine störende Text-Annotation im Balken

set(ax1, 'XTick', 1:4, 'XTickLabel', kategorien_zeit, 'XTickLabelRotation', 15);
ylabel('Einschwingzeit t_{ein} [s] (\pm0,2 °C Band)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
title('A: Einschwingzeit nach Sollwertsprung (35 \rightarrow 45 °C)', 'FontSize', 11.5, 'FontWeight', 'bold', 'Color', 'k');
ylim([0, 78]);
grid on;
set(ax1, 'Box', 'on', 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
         'GridColor', [0.85 0.85 0.85], 'GridAlpha', 0.8, 'FontSize', 10);

% --- Subplot 2: Stationäre Regelabweichung bei Störung (-10% Spannung) ---
ax2 = subplot(1, 2, 2);
hold(ax2, 'on');
farben_stoer = [0.80, 0.20, 0.20;  % Ungeregelt
                0.20, 0.50, 0.75;  % P
                0.15, 0.65, 0.35;  % PI
                0.90, 0.60, 0.15]; % PID

b2 = bar(1:4, fehler_stoer_rel, 0.55, 'FaceColor', 'flat');
b2.CData = farben_stoer;

for i = 1:length(fehler_stoer_rel)
    if fehler_stoer_rel(i) > 0
        text(i, fehler_stoer_rel(i) + 0.6, sprintf('%.1f %%', fehler_stoer_rel(i)), ...
             'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
    else
        text(i, 0.9, '0,0 %', ...
             'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold', 'Color', [0.1 0.55 0.25]);
    end
end

set(ax2, 'XTick', 1:4, 'XTickLabel', kategorien_stoer, 'XTickLabelRotation', 15);
ylabel('Relativer stationärer Fehler F_{rel} [%]', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
title('B: Stationärer Fehler bei 10 % Spannungsstörung', 'FontSize', 11.5, 'FontWeight', 'bold', 'Color', 'k');
ylim([0, 18.5]);
grid on;
set(ax2, 'Box', 'on', 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
         'GridColor', [0.85 0.85 0.85], 'GridAlpha', 0.8, 'FontSize', 10);

%% 3. Exportieren mit weißem Hintergrund
output_file = 'reglervergleich.png';
exportgraphics(fig, output_file, 'Resolution', 300, 'BackgroundColor', 'white');
fprintf('Grafik erfolgreich exportiert: %s\n', output_file);
