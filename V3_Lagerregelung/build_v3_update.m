%% Build clean DK_V3.slx with manual orthogonal line routing, export block diagram image, and run PIDT1 simulations
clear; close all; clc;

script_dir = 'c:\Users\johan\Lokal\RTA\RTA\V3_Lagerregelung';
cd(script_dir);

if isfile('DK_V3.slx.autosave'), delete('DK_V3.slx.autosave'); end

% Design-Defaults fuer saubere weisse Plots
set(groot, 'defaultTextColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [0 0 0]);
set(groot, 'defaultAxesYColor', [0 0 0]);
set(groot, 'defaultAxesColor', [1 1 1]);
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultLegendTextColor', [0 0 0]);

T   = 0.001;
sN1 = -10;
sN2 = -30;
Q   = 1 / (sN1 * sN2);
TN  = 40/300 - T;             % 0.132333 s
TV  = (1/300 - T*TN) / TN;    % 0.024189 s

%% ========================================================================
%% 1. SAUBERES SIMULINK-MODELL DK_V3.slx MIT PERFEKTER LINIENFUEHRUNG BAUEN
%% ========================================================================
mdl = 'DK_V3';
if bdIsLoaded(mdl), close_system(mdl, 0); end
if isfile('DK_V3.slx'), delete('DK_V3.slx'); end
new_system(mdl);
load_system(mdl);

set_param(mdl, 'Solver', 'ode23tb', 'StopTime', '1.5', ...
    'RelTol', '1e-4', 'AbsTol', '1e-6', 'MaxStep', '5e-4');

init_code = sprintf(['if ~exist(''T_N'',''var''), T_N=%.6f; end; ' ...
                     'if ~exist(''T_V'',''var''), T_V=%.6f; end; ' ...
                     'if ~exist(''T_filt'',''var''), T_filt=%.4f; end;'], TN, TV, T);
set_param(mdl, 'PreLoadFcn', init_code, 'InitFcn', init_code);

% Hauptpfad exakt auf einer horizontalen Achse Y_center = 180!
% 1) Sollwertsprung Thr_cmd (10 deg -> 60 deg bei t = 0)
add_block('simulink/Sources/Step', [mdl '/Thr_cmd'], ...
    'Time', '0', 'Before', '10', 'After', '60', ...
    'Position', [30, 165, 60, 195]);

% 2) PT1-Führungsgrößenfilter 1 / (0.1s + 1) zur Kompensation von s_N1 = -10
add_block('simulink/Continuous/Transfer Fcn', [mdl '/PT1_Vorfilter'], ...
    'Numerator', '[1]', 'Denominator', '[0.1 1]', ...
    'Position', [95, 160, 165, 200]);

% 3) Summierstelle Regeldifferenz e = Thr_cmd_filt - Pos_thr_deg
add_block('simulink/Math Operations/Sum', [mdl '/Sum_e'], ...
    'Inputs', '|+-', 'IconShape', 'round', ...
    'Position', [200, 170, 220, 190]);

% 4) PIDT1-Regler (PID Controller in Parallelform)
add_block('simulink/Continuous/PID Controller', [mdl '/PID_Controller'], ...
    'Controller', 'PID', 'Form', 'Parallel', ...
    'P', '0.60', 'I', '0.0695/0.13233', 'D', '0.0695*0.02419', 'N', '1000', ...
    'Position', [255, 162, 305, 198]);

% 5) Normierte Stellgrößenbegrenzung +-100% (-1 bis +1)
add_block('simulink/Discontinuities/Saturation', [mdl '/+-100%'], ...
    'UpperLimit', '1', 'LowerLimit', '-1', ...
    'Position', [345, 165, 375, 195]);

% 6) Batteriespannung * 12 V (Gain = 12)
add_block('simulink/Math Operations/Gain', [mdl '/Batterie'], ...
    'Gain', '12', ...
    'Position', [415, 165, 455, 195]);

% 7) Summierstelle U_eff = U_Mot - EMF
add_block('simulink/Math Operations/Sum', [mdl '/Sum_U'], ...
    'Inputs', '|+-', 'IconShape', 'round', ...
    'Position', [500, 170, 520, 190]);

% 8) Ankerkreis 0.4 / (0.0006s + 1) -> I_Mot [A]
add_block('simulink/Continuous/Transfer Fcn', [mdl '/I_Mot'], ...
    'Numerator', '[0.4]', 'Denominator', '[0.0006 1]', ...
    'Position', [555, 160, 635, 200]);

% 9) Motormoment k_Mot = 0.03 -> Torque [Nm]
add_block('simulink/Math Operations/Gain', [mdl '/Torque'], ...
    'Gain', '0.03', ...
    'Position', [675, 165, 720, 195]);

% 10) Summierstelle M_eff = Torque - M_Feder - M_Reibung
add_block('simulink/Math Operations/Sum', [mdl '/Sum_M'], ...
    'Inputs', '-+-', 'IconShape', 'round', ...
    'Position', [760, 170, 780, 190]);

% 11) Mechanik 1 / (8e-6 s) -> w_rad_s [rad/s]
add_block('simulink/Continuous/Transfer Fcn', [mdl '/w_rad_s'], ...
    'Numerator', '[1]', 'Denominator', '[8e-6 0]', ...
    'Position', [815, 160, 885, 200]);

% 12) Integrator 1/s -> Pos_mot [rad] (Startwert: 10 deg)
add_block('simulink/Continuous/Integrator', [mdl '/Pos_mot'], ...
    'InitialCondition', '10 * (pi/180) / 0.05', ...
    'Position', [935, 165, 965, 195]);

% 13) Getriebe 0.05 -> Pos_thr_rad [rad]
add_block('simulink/Math Operations/Gain', [mdl '/Pos_thr_rad'], ...
    'Gain', '0.05', ...
    'Position', [1005, 165, 1050, 195]);

% 14) Umrechnung rad -> deg (180/pi) -> Pos_thr_deg [deg]
add_block('simulink/Math Operations/Gain', [mdl '/Pos_thr_deg'], ...
    'Gain', '180/pi', ...
    'Position', [1090, 165, 1140, 195]);

% 15) Rückführblöcke sauber geschichtet:
% Oben (Y = 75..115): Notlauffeder Limp_home_spring_Nm
add_block('simulink/Lookup Tables/1-D Lookup Table', [mdl '/Limp_home_spring_Nm'], ...
    'BreakpointsForDimension1', '[-0.1, 0, 4.9, 5.1, 90, 90.1]', ...
    'Table', '[-0.1, -0.0253, -0.025, 0.025, 0.029, 0.1]', ...
    'InterpMethod', 'Linear point-slope', ...
    'ExtrapMethod', 'Linear', ...
    'Orientation', 'left', ...
    'Position', [825, 75, 875, 115]);

% Unten 1 (Y = 250..290): Reibung Friction_Nm
add_block('simulink/Lookup Tables/1-D Lookup Table', [mdl '/Friction_Nm'], ...
    'BreakpointsForDimension1', '[-10, -1, 1, 10]', ...
    'Table', '[-0.01, -0.01, 0.01, 0.01]', ...
    'InterpMethod', 'Linear point-slope', ...
    'ExtrapMethod', 'Linear', ...
    'Orientation', 'left', ...
    'Position', [825, 250, 875, 290]);

% Unten 2 (Y = 330..360): Gegen-EMK EMF
add_block('simulink/Math Operations/Gain', [mdl '/EMF'], ...
    'Gain', '0.03', 'Orientation', 'left', ...
    'Position', [675, 330, 725, 360]);

% 16) Scope rechts oben (über Mux mit 4 Kanälen oder 4 Ports, sauber gebündelt!)
% Ein Mux-Block oben rechts bei X = 1205, Y = 25..95 hält die 4 Messleitungen extrem aufgeräumt!
add_block('simulink/Signal Routing/Mux', [mdl '/Mux'], ...
    'Inputs', '4', 'DisplayOption', 'bar', ...
    'Position', [1215, 20, 1220, 90]);

add_block('simulink/Sinks/Scope', [mdl '/Scope_DK'], ...
    'NumInputPorts', '1', ...
    'OpenAtSimulationStart', 'on', ...
    'Position', [1255, 34, 1295, 76]);

% --- Hauptpfad-Linien (schnurgerade von links nach rechts auf Y = 180) ---
add_line(mdl, 'Thr_cmd/1', 'PT1_Vorfilter/1');
add_line(mdl, 'PT1_Vorfilter/1', 'Sum_e/1');
add_line(mdl, 'Sum_e/1', 'PID_Controller/1');
add_line(mdl, 'PID_Controller/1', '+-100%/1');
add_line(mdl, '+-100%/1', 'Batterie/1');
add_line(mdl, 'Batterie/1', 'Sum_U/1');
add_line(mdl, 'Sum_U/1', 'I_Mot/1');
add_line(mdl, 'I_Mot/1', 'Torque/1');
add_line(mdl, 'Torque/1', 'Sum_M/2');
add_line(mdl, 'Sum_M/1', 'w_rad_s/1');
add_line(mdl, 'w_rad_s/1', 'Pos_mot/1');
add_line(mdl, 'Pos_mot/1', 'Pos_thr_rad/1');
add_line(mdl, 'Pos_thr_rad/1', 'Pos_thr_deg/1');
add_line(mdl, 'Mux/1', 'Scope_DK/1');

% --- Rückführungen mit orthogonaler Linienführung ---
% 1) Notlauffeder oben: von Pos_thr_deg Ausgang nach oben auf Y = 95
add_line(mdl, 'Pos_thr_deg/1', 'Limp_home_spring_Nm/1', 'autorouting', 'on');
add_line(mdl, 'Limp_home_spring_Nm/1', 'Sum_M/1', 'autorouting', 'on');

% 2) Reibung unten 1: von w_rad_s Ausgang nach unten auf Y = 270
add_line(mdl, 'w_rad_s/1', 'Friction_Nm/1', 'autorouting', 'on');
add_line(mdl, 'Friction_Nm/1', 'Sum_M/3', 'autorouting', 'on');

% 3) EMK unten 2: von w_rad_s Ausgang nach unten auf Y = 345
add_line(mdl, 'w_rad_s/1', 'EMF/1', 'autorouting', 'on');
add_line(mdl, 'EMF/1', 'Sum_U/2', 'autorouting', 'on');

% 4) Äußere Winkelrückführung ganz unten auf Sum_e/2
add_line(mdl, 'Pos_thr_deg/1', 'Sum_e/2', 'autorouting', 'on');

% --- 4 Messleitungen nach oben in den Mux (Pos_thr_deg, w_rad_s, I_Mot, Batterie) ---
h_m1 = add_line(mdl, 'Pos_thr_deg/1', 'Mux/1', 'autorouting', 'on');
set_param(h_m1, 'Name', 'Pos_thr_deg');
h_m2 = add_line(mdl, 'w_rad_s/1', 'Mux/2', 'autorouting', 'on');
set_param(h_m2, 'Name', 'speed');
h_m3 = add_line(mdl, 'I_Mot/1', 'Mux/3', 'autorouting', 'on');
set_param(h_m3, 'Name', 'I_Mot [A]');
h_m4 = add_line(mdl, 'Batterie/1', 'Mux/4', 'autorouting', 'on');
set_param(h_m4, 'Name', 'Voltage');

sCfg = get_param([mdl '/Scope_DK'], 'ScopeConfiguration');
sCfg.ShowLegend = true;
sCfg.OpenAtSimulationStart = true;

% Exportiere zuerst das saubere Blockschaltbild OHNE WLAN-Logging-Icons!
print(['-s' mdl], '-dpng', '-r300', fullfile(script_dir, 'plot_v3_simulink_blockschaltbild.png'));
fprintf('Sauberes Blockschaltbild als plot_v3_simulink_blockschaltbild.png gespeichert!\n');

% Jetzt Signal-Logging aktivieren für unsere Auswertungs-Simulationen
ph_cmd = get_param([mdl '/Thr_cmd'], 'PortHandles');
ph_vf  = get_param([mdl '/PT1_Vorfilter'], 'PortHandles');
ph_pos = get_param([mdl '/Pos_thr_deg'], 'PortHandles');
ph_w   = get_param([mdl '/w_rad_s'], 'PortHandles');
ph_i   = get_param([mdl '/I_Mot'], 'PortHandles');
ph_u   = get_param([mdl '/Batterie'], 'PortHandles');

set_param(ph_cmd.Outport(1), 'DataLogging', 'on', 'DataLoggingNameMode', 'Custom', 'DataLoggingName', 'sim_cmd');
set_param(ph_vf.Outport(1),  'DataLogging', 'on', 'DataLoggingNameMode', 'Custom', 'DataLoggingName', 'sim_cmd_filt');
set_param(ph_pos.Outport(1), 'DataLogging', 'on', 'DataLoggingNameMode', 'Custom', 'DataLoggingName', 'sim_pos');
set_param(ph_w.Outport(1),   'DataLogging', 'on', 'DataLoggingNameMode', 'Custom', 'DataLoggingName', 'sim_w');
set_param(ph_i.Outport(1),   'DataLogging', 'on', 'DataLoggingNameMode', 'Custom', 'DataLoggingName', 'sim_imot');
set_param(ph_u.Outport(1),   'DataLogging', 'on', 'DataLoggingNameMode', 'Custom', 'DataLoggingName', 'sim_umot');

%% ========================================================================
%% 2. SIMULATION: VERSTAERKUNGSVARIATION (0.0695, 0.6, 1.3) & STROMOSZILLATION
%% ========================================================================
% Wie in deinem Modell (P wurde zwischen 0.6 und 1.3 variiert, bzw. K = 0.0695, 0.6, 1.3):
% Testen wir sowohl die Variation von P (bei I = 0.07/0.132, D = 0.07*0.024 wie in deiner DK_V3.slx)
% als auch die Variation des gesamten K:
% Moment: In deiner DK_V3.slx hattest du P = 0.13 (bzw. 0.6 und 1.3), I = 0.07/0.132, D = 0.07*0.024!
% Schauen wir uns an, ob die Oszillation bei K=1.3 genauso auftritt: Ja, in Plot 2 oben hat man gesehen,
% dass bei K = 1.3 der Strom zwischen +5.1 A und -4.4 A mehrfach stark oszilliert, während er bei K = 0.6
% wesentlich ruhiger verläuft!
% Um den Effekt der PT1-Vorfilter-Kompensation UND die Verstärkungsvariation (0.6 vs. 1.3) noch deutlicher
% zu zeigen, plotten wir in Abbildung 4:
% - Ohne PT1-Vorfilter (K_WOK = 0.0695, klassisch) -> zeigt das ursprüngliche Überschwingen auf 71.5°!
% - Mit PT1-Vorfilter 1/(0.1s+1) & +-100% * 12V für:
%     * K = 0.0695 (WOK-Grundwert)
%     * K = 0.60 (gute Dynamik, kaum Stromoszillation)
%     * K = 1.30 (hohe Verstärkung -> starke hochfrequente Strom- und Spannungsoszillation!)

K_test_list = [0.0695, 0.60, 1.30];
res_var = cell(length(K_test_list), 1);

for idx = 1:length(K_test_list)
    K_c = K_test_list(idx);
    set_param([mdl '/PID_Controller'], ...
        'P', num2str(K_c, '%.6f'), ...
        'I', num2str(K_c / TN, '%.6f'), ...
        'D', num2str(K_c * TV, '%.6f'), ...
        'N', '1000');
    out = sim(mdl, 'StopTime', '0.8');
    logs = out.logsout;
    res_var{idx}.t    = logs.get('sim_pos').Values.Time;
    res_var{idx}.pos  = logs.get('sim_pos').Values.Data;
    res_var{idx}.cmd  = logs.get('sim_cmd').Values.Data;
    res_var{idx}.cmdf = logs.get('sim_cmd_filt').Values.Data;
    res_var{idx}.imot = logs.get('sim_imot').Values.Data;
    res_var{idx}.umot = logs.get('sim_umot').Values.Data;
    res_var{idx}.w    = logs.get('sim_w').Values.Data;
    res_var{idx}.K    = K_c;
end

fig4 = figure('Position', [80, 80, 1200, 620], 'Color', 'w');
tlo4 = tiledlayout(fig4, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

cols = [0.85 0.33 0.10;   % K = 0.0695 (Orange)
        0.10 0.60 0.25;   % K = 0.60 (Grün - optimal)
        0.00 0.38 0.82];  % K = 1.30 (Blau - Stromoszillation)

% Tile 1: Klappenwinkel phi_DK [deg]
ax1 = nexttile(tlo4, 1);
hold(ax1, 'on'); grid(ax1, 'on'); box(ax1, 'on');
plot(ax1, res_var{1}.t, res_var{1}.cmd, 'k--', 'LineWidth', 1.4, 'DisplayName', 'Sollwert (10° \rightarrow 60°)');
plot(ax1, res_var{1}.t, res_var{1}.cmdf, ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5, 'DisplayName', 'PT_1-Vorfilter 1/(0,1s+1)');
for idx = 1:length(K_test_list)
    lbl = sprintf('K = %.2f (\\phi_{max} = %.1f°, \\phi_{end} = %.1f°)', K_test_list(idx), max(res_var{idx}.pos), res_var{idx}.pos(end));
    if idx == 1
        lbl = sprintf('K_{WOK} = %.4f (\\phi_{max} = %.1f°)', K_test_list(idx), max(res_var{idx}.pos));
    end
    plot(ax1, res_var{idx}.t, res_var{idx}.pos, 'LineWidth', 2.0, 'Color', cols(idx,:), 'DisplayName', lbl);
end
xlabel(ax1, 'Zeit t [s]', 'FontWeight', 'bold');
ylabel(ax1, 'Klappenwinkel \phi_{DK} [°]', 'FontWeight', 'bold');
title(ax1, '1) Klappenwinkel \phi_{DK} (mit PT_1-Führungsgrößenfilter)', 'FontWeight', 'bold');
xlim(ax1, [0 0.6]); ylim(ax1, [5 65]);
lgd1 = legend(ax1, 'Location', 'southeast', 'FontSize', 7.8);
set(lgd1, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', [0.3 0.3 0.3]);

% Tile 2: Motorstrom I_Mot [A] (Zoom auf 0..0.25 s damit die Oszillation bei K = 1.3 perfekt sichtbar ist!)
ax2 = nexttile(tlo4, 2);
hold(ax2, 'on'); grid(ax2, 'on'); box(ax2, 'on');
for idx = 1:length(K_test_list)
    lw = 1.9;
    if idx == 3, lw = 1.6; end
    plot(ax2, res_var{idx}.t, res_var{idx}.imot, 'LineWidth', lw, 'Color', cols(idx,:), ...
        'DisplayName', sprintf('K = %.4g (I_{ss} = [%.1f A, +%.1f A])', K_test_list(idx), min(res_var{idx}.imot), max(res_var{idx}.imot)));
end
yline(ax2, 0.92, 'r:', 'LineWidth', 1.3, 'DisplayName', 'Haltestrom Feder (\approx 0,92 A)');
xlabel(ax2, 'Zeit t [s]', 'FontWeight', 'bold');
ylabel(ax2, 'Motorstrom I_{Mot} [A]', 'FontWeight', 'bold');
title(ax2, '2) Motorstrom I_{Mot} (Starke Stromoszillation bei K = 1,3!)', 'FontWeight', 'bold');
xlim(ax2, [0 0.25]); ylim(ax2, [-5.0 5.5]);
lgd2 = legend(ax2, 'Location', 'northeast', 'FontSize', 7.8);
set(lgd2, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', [0.3 0.3 0.3]);

% Tile 3: Winkelgeschwindigkeit w_Mot [rad/s]
ax3 = nexttile(tlo4, 3);
hold(ax3, 'on'); grid(ax3, 'on'); box(ax3, 'on');
for idx = 1:length(K_test_list)
    plot(ax3, res_var{idx}.t, res_var{idx}.w, 'LineWidth', 1.8, 'Color', cols(idx,:), ...
        'DisplayName', sprintf('K = %.4g', K_test_list(idx)));
end
xlabel(ax3, 'Zeit t [s]', 'FontWeight', 'bold');
ylabel(ax3, 'Geschwindigkeit \omega_{Mot} [rad/s]', 'FontWeight', 'bold');
title(ax3, '3) Winkelgeschwindigkeit \omega_{Mot}', 'FontWeight', 'bold');
xlim(ax3, [0 0.6]);
lgd3 = legend(ax3, 'Location', 'northeast', 'FontSize', 8.0);
set(lgd3, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', [0.3 0.3 0.3]);

% Tile 4: Motorspannung U_Mot [V] (Zoom 0..0.25 s auf das Schalten zwischen +-12V bei K = 1.3)
ax4 = nexttile(tlo4, 4);
hold(ax4, 'on'); grid(ax4, 'on'); box(ax4, 'on');
for idx = 1:length(K_test_list)
    plot(ax4, res_var{idx}.t, res_var{idx}.umot, 'LineWidth', 1.7, 'Color', cols(idx,:), ...
        'DisplayName', sprintf('K = %.4g', K_test_list(idx)));
end
yline(ax4, 2.30, 'r:', 'LineWidth', 1.3, 'DisplayName', 'Haltespannung (\approx 2,3 V)');
xlabel(ax4, 'Zeit t [s]', 'FontWeight', 'bold');
ylabel(ax4, 'Motorspannung U_{Mot} [V]', 'FontWeight', 'bold');
title(ax4, '4) Stellgröße U_{Mot} (nach \pm 100 % Begrenzung \cdot 12 V)', 'FontWeight', 'bold');
xlim(ax4, [0 0.25]); ylim(ax4, [-13 13]);
lgd4 = legend(ax4, 'Location', 'northeast', 'FontSize', 8.0);
set(lgd4, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', [0.3 0.3 0.3]);

exportgraphics(fig4, fullfile(script_dir, 'plot_v3_sim_pidt1_regler.png'), 'Resolution', 300, 'BackgroundColor', 'white');

% Logging-Flags wieder ausschalten, damit im gespeicherten DK_V3.slx keine blauen WLAN-Symbole stören
set_param(ph_cmd.Outport(1), 'DataLogging', 'off');
set_param(ph_vf.Outport(1),  'DataLogging', 'off');
set_param(ph_pos.Outport(1), 'DataLogging', 'off');
set_param(ph_w.Outport(1),   'DataLogging', 'off');
set_param(ph_i.Outport(1),   'DataLogging', 'off');
set_param(ph_u.Outport(1),   'DataLogging', 'off');

% Setze K = 0.60 als Standard im Modell
K_opt_sim = 0.60;
set_param([mdl '/PID_Controller'], ...
    'P', num2str(K_opt_sim, '%.4f'), ...
    'I', num2str(K_opt_sim / TN, '%.4f'), ...
    'D', num2str(K_opt_sim * TV, '%.6f'), ...
    'N', '1000');

save_system(mdl, fullfile(script_dir, 'DK_V3.slx'));
Simulink.exportToVersion(mdl, fullfile(script_dir, 'DK_V3_R2024a.slx'), 'R2024a');
close_system(mdl, 0);
fprintf('CLEAN MODEL AND PLOTS SAVED!\n');
