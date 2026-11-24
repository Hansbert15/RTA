%% simulate_and_verify.m
% Führt die Simulation beider Modelle aus und erzeugt die Diagramme:
% 1. plot_drosselklappe_simulation.png: Alle 3 Größen (Spannung, Winkel, Strom)
%    in exakt derselben Skalierung und Achsenaufteilung wie im Oszilloskop-Bild
%    der PDF "Messungen Conti Drosselklappe.pdf".
% 2. plot_testfrage_simulation.png: Sprungantwort für Testfrage F(s) = 5/(2s^2+8).

clear; clc; close all;

% Erzwinge sauberes helles Design (auch im MATLAB Dark Mode)
set(groot, 'defaultTextColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [0 0 0]);
set(groot, 'defaultAxesYColor', [0 0 0]);
set(groot, 'defaultAxesColor', [1 1 1]);
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultLegendTextColor', [0 0 0]);

%% 1. Parameter laden und Modelle aktualisieren
init_parameters;
build_models;

%% 2. Simulation 1: Öffnungsvorgang der Drosselklappe bei 6 V (-50 .. 450 ms)
sim_out_dk = sim('EI7_V2', 'StopTime', num2str(t_sim));

% Zeitachse so verschieben, dass der Spannungssprung wie im Oszi bei t = 0 ms liegt (-50 ms bis 450 ms)
t_ms   = (sim_out_dk.sim_phi_deg.Time - t_step) * 1000;
phi_dk = sim_out_dk.sim_phi_deg.Data;
i_mot  = sim_out_dk.sim_current.Data;
u_mot  = zeros(size(t_ms));
u_mot(t_ms >= 0) = U_step_val;

% Abbildung im identischen Layout wie das Oszilloskop-Bild aus der PDF:
% - Gemeinsame normierte Y-Skala (10 Teilstriche von 0 bis 10):
%   * Blau (Spannung u):    -1.0 V  bis  9.0 V  (1 V / Div)
%   * Grün (Winkel phi_DK):  0.0 °  bis 100.0 ° (10 ° / Div)
%   * Rot  (Strom I):       -0.5 A  bis  4.5 A  (0.5 A / Div)
fig1 = figure('Name', 'Simulierter Öffnungsvorgang mit 6 V ab Notlaufposition', ...
              'Units', 'pixels', 'Position', [100, 100, 960, 620], 'Color', 'w');

% Hauptachse mit Platz links für die zwei Skalen (Blau: V, Grün: °) und rechts (Rot: A)
ax_main = axes('Parent', fig1, 'Position', [0.14, 0.12, 0.78, 0.80]);
hold(ax_main, 'on');

% Normierung auf [0 .. 10] Divisions wie im PicoScope-Screenshot
y_u_div   = (u_mot  - (-1.0)) / 1.0;    % -1 V -> 0,  9 V -> 10
y_phi_div = (phi_dk -   0.0)  / 10.0;   %  0 ° -> 0, 100 ° -> 10
y_i_div   = (i_mot  - (-0.5)) / 0.5;    % -0.5 A -> 0, 4.5 A -> 10

col_u   = [0.00, 0.00, 0.90]; % Blau  (Spannung)
col_phi = [0.05, 0.52, 0.05]; % Grün  (Klappenwinkel)
col_i   = [0.90, 0.00, 0.00]; % Rot   (Motorstrom)

% Gestrichelte Gitterlinien wie im Oszilloskop
for y_g = 0:10
    yline(ax_main, y_g, ':', 'Color', [0.65, 0.80, 0.85], 'LineWidth', 0.8, 'HandleVisibility', 'off');
end
for x_g = -50:50:450
    xline(ax_main, x_g, ':', 'Color', [0.65, 0.80, 0.85], 'LineWidth', 0.8, 'HandleVisibility', 'off');
end
% Vertikale Triggerlinie bei t = 0,0 ms (blau wie im Oszi)
xline(ax_main, 0, '-', 'Color', [0.20, 0.20, 0.90], 'LineWidth', 1.0, 'HandleVisibility', 'off');

% Drei Messgrößen plotten
p_u   = plot(ax_main, t_ms, y_u_div,   '-', 'Color', col_u,   'LineWidth', 2.0, 'DisplayName', 'Eingangsspannung u(t) [V]');
p_phi = plot(ax_main, t_ms, y_phi_div, '-', 'Color', col_phi, 'LineWidth', 2.4, 'DisplayName', 'Klappenwinkel \phi_{DK}(t) [°]');
p_i   = plot(ax_main, t_ms, y_i_div,   '-', 'Color', col_i,   'LineWidth', 1.8, 'DisplayName', 'Motorstrom I(t) [A]');

xlim(ax_main, [-50, 450]);
ylim(ax_main, [0, 10]);

set(ax_main, 'XTick', -50:50:450, ...
             'XTickLabel', {'-50,0', '0,0', '50,0', '100,0', '150,0', '200,0', '250,0', '300,0', '350,0', '400,0', '450,0'}, ...
             'YTick', [], 'Box', 'on', 'Color', 'w', 'XColor', 'k', 'YColor', 'none', 'FontSize', 10);

xlabel(ax_main, 'Zeit t [ms]', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
title(ax_main, 'Simulierter Öffnungsvorgang mit 6 V ab Notlaufposition (7,5° \rightarrow 90°)', ...
      'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');

legend(ax_main, [p_u, p_phi, p_i], 'Location', 'southeast', 'FontSize', 9.5, 'Box', 'on', 'Color', 'w');

% Beschriftung der 3 Y-Achsen (links: Spannung [Blau] & Winkel [Grün], rechts: Strom [Rot])
u_vals   = [-1.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0];
phi_vals = [ 0.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0];
i_vals   = [-0.5, 0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5];

for k = 1:11
    yk = k - 1;
    % Blaue Spannungsskala (ganz links)
    if k ~= 10
        text(ax_main, -88, yk, strrep(sprintf('%.1f', u_vals(k)), '.', ','), ...
             'Color', col_u, 'FontSize', 9.5, 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    end
    % Grüne Winkelskala (daneben links)
    if k <= 10
        text(ax_main, -56, yk, strrep(sprintf('%.1f', phi_vals(k)), '.', ','), ...
             'Color', col_phi, 'FontSize', 9.5, 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
    end
    % Rote Stromskala (rechts)
    if k ~= 10
        text(ax_main, 456, yk, strrep(sprintf('%.1f', i_vals(k)), '.', ','), ...
             'Color', col_i, 'FontSize', 9.5, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
    end
end

% Einheiten-Kopfzeilen exakt wie im Oszilloskop oben an den Skalen
text(ax_main, -88, 9.55, {'V'; 'DC'}, 'Color', col_u,   'FontSize', 9.5, 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
text(ax_main, -56, 9.55, {'°'; 'DC'}, 'Color', col_phi, 'FontSize', 9.5, 'FontWeight', 'bold', 'HorizontalAlignment', 'right');
text(ax_main, 456, 9.55, {'A'; 'DC'}, 'Color', col_i,   'FontSize', 9.5, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');

exportgraphics(fig1, 'V2_Ausarbeitung/plot_drosselklappe_simulation.png', 'Resolution', 300, 'BackgroundColor', 'white');
exportgraphics(fig1, 'plot_drosselklappe_simulation.png', 'Resolution', 300, 'BackgroundColor', 'white');
disp('-> Plot gespeichert: V2_Ausarbeitung/plot_drosselklappe_simulation.png');


%% 3. Simulation 2: Testfragen-System F(s) = 5 / (2*s^2 + 8)
sim_out_tf = sim('testfrage_system', 'StopTime', '10');

t_tf = sim_out_tf.sim_test_y.Time;
u_tf = sim_out_tf.sim_test_u.Data;
y_tf = sim_out_tf.sim_test_y.Data;

fig2 = figure('Name', 'Testfrage: Sprungantwort F(s)', 'Units', 'pixels', ...
              'Position', [150, 150, 1050, 420], 'Color', 'w');

ax3 = axes('Parent', fig2);
hold(ax3, 'on');

yline(ax3, 3.125, ':', 'Color', [0.80, 0.15, 0.15], 'LineWidth', 1.6, 'DisplayName', 'Stationärer Mittelwert y_m = 3,125');
plot(ax3, t_tf, u_tf, '--', 'Color', [0.35, 0.35, 0.35], 'LineWidth', 1.8, 'DisplayName', 'Eingangssprung u(t) (0 \rightarrow 5)');
plot(ax3, t_tf, y_tf, '-',  'Color', [0.00, 0.38, 0.82], 'LineWidth', 2.4, 'DisplayName', 'Ausgangssignal y(t)');

xlabel(ax3, 'Zeit t [s]', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
ylabel(ax3, 'Signalamplitude', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
title(ax3, 'Sprungantwort der Übertragungsfunktion F(s) = 5 / (2s^2 + 8) bei Eingangssprung 0 \rightarrow 5', ...
      'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
xlim(ax3, [0, 10]);
ylim(ax3, [-0.3, 7.2]);
grid(ax3, 'on');
set(ax3, 'Box', 'on', 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
         'GridColor', [0.85 0.85 0.85], 'GridAlpha', 0.85, 'FontSize', 10);
legend(ax3, 'Location', 'northeast', 'FontSize', 9.5, 'Box', 'on', 'Color', 'w');

exportgraphics(fig2, 'V2_Ausarbeitung/plot_testfrage_simulation.png', 'Resolution', 300, 'BackgroundColor', 'white');
exportgraphics(fig2, 'plot_testfrage_simulation.png', 'Resolution', 300, 'BackgroundColor', 'white');
disp('-> Plot gespeichert: V2_Ausarbeitung/plot_testfrage_simulation.png');
