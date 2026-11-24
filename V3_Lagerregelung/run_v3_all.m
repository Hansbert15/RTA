%% ========================================================================
%% PRAKTIKUM PRTA - VERSUCH V3: REGLERENTWURF DROSSELKLAPPE
%% Vollstaendiges Build-, Simulations- und Plot-Skript
%% ========================================================================
clear; close all; clc;

script_dir = fileparts(mfilename('fullpath'));
if isempty(script_dir)
    script_dir = pwd;
end
cd(script_dir);

% Design-Defaults fuer saubere weisse Plots
set(groot, 'defaultTextColor', [0 0 0]);
set(groot, 'defaultAxesXColor', [0 0 0]);
set(groot, 'defaultAxesYColor', [0 0 0]);
set(groot, 'defaultAxesColor', [1 1 1]);
set(groot, 'defaultFigureColor', [1 1 1]);
set(groot, 'defaultLegendTextColor', [0 0 0]);

%% ========================================================================
%% 1. LINEARE STRECKE & WURZELORTSKURVEN (P-REGLER & PIDT1-REGLER)
%% ========================================================================
z_1 = [0.4];
n_1 = [0.0006 1];
F1  = tf(z_1, n_1);
F2  = 0.03;
z_3 = [1];
n_3 = [8e-6 0];
F3  = tf(z_3, n_3);
F123 = F1 * F2 * F3;
F4  = 0.03;
F1234 = feedback(F123, F4);
z_5 = [0.05 * 180 / pi];
n_5 = [1 0];
F5  = tf(z_5, n_5);
F12345 = F1234 * F5;

% --- P-Regler WOK ---
Fo_P = 1 * F12345;
k_p_vec = [linspace(0, 0.1, 2000), linspace(0.1, 5, 1500), linspace(5, 100, 1000)];
[r_P, k_P_out] = rlocus(Fo_P, k_p_vec);

% Verzweigungspunkt (D = 1) suchen:
% Die beiden langsamen Pole starten bei 0 und -45.55
% Sortiere Wurzeln nach Realteil
poles_open = pole(Fo_P);
fprintf('Streckenpole F12345:\n');
disp(poles_open);

% Analytisch den Verzweigungspunkt zwischen 0 und -45.55 bestimmen:
% N(s) = 0.0006*8e-6*s^3 + 8e-6*s^2 + 0.4*0.03*0.03*s = 4.8e-9*s^3 + 8e-6*s^2 + 3.6e-4*s
% dN/ds = 1.44e-8*s^2 + 1.6e-5*s + 3.6e-4 = 0
p_deriv = [1.44e-8, 1.6e-5, 3.6e-4];
s_branch_roots = roots(p_deriv);
s_P_branch = max(s_branch_roots); % ca. -22.97 s^-1
Z_gain = 0.4 * 0.03 * 0.05 * (180/pi);
K_P_opt = - (4.8e-9 * s_P_branch^3 + 8e-6 * s_P_branch^2 + 3.6e-4 * s_P_branch) / Z_gain;
fprintf('P-Regler optimaler Verzweigungspunkt (D=1): s = %.3f s^-1, K_P,opt = %.5f V/deg\n', s_P_branch, K_P_opt);

% Plot 1: WOK P-Regler (Gesamt + Zoom)
fig1 = figure('Position', [100, 100, 1150, 460], 'Color', 'w');
tlo1 = tiledlayout(fig1, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

ax1a = nexttile(tlo1, 1);
hold(ax1a, 'on'); grid(ax1a, 'on'); box(ax1a, 'on');
xline(ax1a, 0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
yline(ax1a, 0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
colors_wok = [0.00 0.38 0.82; 0.85 0.33 0.10; 0.10 0.60 0.25];
for b = 1:size(r_P, 1)
    plot(ax1a, real(r_P(b,:)), imag(r_P(b,:)), 'LineWidth', 2.2, 'Color', colors_wok(b,:));
end
plot(ax1a, real(poles_open), imag(poles_open), 'kx', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Streckenpole (K_P=0)');
xlabel(ax1a, 'Realteil \sigma [s^{-1}]', 'FontWeight', 'bold');
ylabel(ax1a, 'Imaginaerteil j\omega [s^{-1}]', 'FontWeight', 'bold');
title(ax1a, 'WOK mit P-Regler (Gesamtansicht)', 'FontWeight', 'bold');
xlim(ax1a, [-2000 200]); ylim(ax1a, [-1200 1200]);

ax1b = nexttile(tlo1, 2);
hold(ax1b, 'on'); grid(ax1b, 'on'); box(ax1b, 'on');
xline(ax1b, 0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
yline(ax1b, 0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
for b = 1:size(r_P, 1)
    plot(ax1b, real(r_P(b,:)), imag(r_P(b,:)), 'LineWidth', 2.2, 'Color', colors_wok(b,:), 'HandleVisibility', 'off');
end
h_p0 = plot(ax1b, real(poles_open), imag(poles_open), 'kx', 'MarkerSize', 10, 'LineWidth', 2);
h_popt = plot(ax1b, s_P_branch, 0, 'ro', 'MarkerSize', 9, 'MarkerFaceColor', 'r');
text(ax1b, s_P_branch - 1, 12, sprintf('K_{P,opt} = %.4f\ns_{1,2} = %.1f s^{-1} (D=1)', K_P_opt, s_P_branch), ...
    'FontSize', 9.5, 'FontWeight', 'bold', 'Color', [0.8 0 0], 'BackgroundColor', 'w', 'EdgeColor', [0.8 0 0]);
xlabel(ax1b, 'Realteil \sigma [s^{-1}]', 'FontWeight', 'bold');
ylabel(ax1b, 'Imaginaerteil j\omega [s^{-1}]', 'FontWeight', 'bold');
title(ax1b, 'WOK mit P-Regler (Dominanter Bereich)', 'FontWeight', 'bold');
xlim(ax1b, [-60 5]); ylim(ax1b, [-50 50]);
lgd = legend(ax1b, [h_p0, h_popt], {'Offene Pole (0; -46,3)', 'Optimum D=1 (K_P = 0,1195)'}, 'Location', 'northwest');
set(lgd, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', [0.3 0.3 0.3]);

exportgraphics(fig1, fullfile(script_dir, 'plot_v3_wok_p_regler.png'), 'Resolution', 300, 'BackgroundColor', 'white');

% --- PIDT1-Regler WOK ---
T   = 0.001;
sN1 = -10;
sN2 = -30;
Q   = 1 / (sN1 * sN2);
TN  = 40/300 - T;
TV  = (1/300 - T*TN) / TN;

z_R = [(T*TN + TN*TV), (T + TN), 1];
n_R = [(T*TN), TN, 0];
F_R_PIDT1 = tf(z_R, n_R);
Fo_PID = F_R_PIDT1 * F12345;

k_pid_vec = [linspace(0, 0.02, 1000), linspace(0.02, 0.2, 3000), linspace(0.2, 5, 1000), linspace(5, 250, 1000)];
[r_PID, k_PID_out] = rlocus(Fo_PID, k_pid_vec);
poles_pid_open = pole(Fo_PID);
zeros_pid_open = zero(Fo_PID);

K_PID_opt = 0.0695;
r_PID_opt = rlocus(Fo_PID, K_PID_opt);
% Dominanter Doppelpol bei K = 0.0695:
dom_poles_opt = r_PID_opt(abs(real(r_PID_opt) + 16.4) < 5);

fig2 = figure('Position', [100, 100, 1150, 460], 'Color', 'w');
tlo2 = tiledlayout(fig2, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

ax2a = nexttile(tlo2, 1);
hold(ax2a, 'on'); grid(ax2a, 'on'); box(ax2a, 'on');
xline(ax2a, 0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
yline(ax2a, 0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
cols_pid = lines(size(r_PID, 1));
for b = 1:size(r_PID, 1)
    plot(ax2a, real(r_PID(b,:)), imag(r_PID(b,:)), 'LineWidth', 2.0, 'Color', cols_pid(b,:));
end
plot(ax2a, real(poles_pid_open), imag(poles_pid_open), 'kx', 'MarkerSize', 9, 'LineWidth', 1.8);
plot(ax2a, real(zeros_pid_open), imag(zeros_pid_open), 'bo', 'MarkerSize', 8, 'LineWidth', 1.8);
xlabel(ax2a, 'Realteil \sigma [s^{-1}]', 'FontWeight', 'bold');
ylabel(ax2a, 'Imaginaerteil j\omega [s^{-1}]', 'FontWeight', 'bold');
title(ax2a, 'WOK mit PIDT1-Regler (Gesamtansicht)', 'FontWeight', 'bold');
xlim(ax2a, [-3500 500]); ylim(ax2a, [-2500 2500]);

ax2b = nexttile(tlo2, 2);
hold(ax2b, 'on'); grid(ax2b, 'on'); box(ax2b, 'on');
xline(ax2b, 0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
yline(ax2b, 0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
for b = 1:size(r_PID, 1)
    plot(ax2b, real(r_PID(b,:)), imag(r_PID(b,:)), 'LineWidth', 2.2, 'Color', cols_pid(b,:), 'HandleVisibility', 'off');
end
h_pp = plot(ax2b, real(poles_pid_open), imag(poles_pid_open), 'kx', 'MarkerSize', 10, 'LineWidth', 2);
h_zz = plot(ax2b, real(zeros_pid_open), imag(zeros_pid_open), 'bo', 'MarkerSize', 9, 'LineWidth', 2, 'MarkerFaceColor', 'w');
h_kopt = plot(ax2b, -16.4, 0, 'rs', 'MarkerSize', 9, 'MarkerFaceColor', 'r');
text(ax2b, -26, 6.2, sprintf('Gain K = 0,0695\nPol: s = -16,4 s^{-1}\nDaempfung D = 1 (0%% Overshoot)'), ...
    'FontSize', 9, 'FontWeight', 'bold', 'Color', [0.8 0 0], 'BackgroundColor', 'w', 'EdgeColor', [0.8 0 0]);
xlabel(ax2b, 'Realteil \sigma [s^{-1}]', 'FontWeight', 'bold');
ylabel(ax2b, 'Imaginaerteil j\omega [s^{-1}]', 'FontWeight', 'bold');
title(ax2b, 'WOK mit PIDT1-Regler (Dominanter Bereich)', 'FontWeight', 'bold');
xlim(ax2b, [-35 2]); ylim(ax2b, [-12 12]);
lgd = legend(ax2b, [h_pp, h_zz, h_kopt], {'Offene Pole (0, 0, -45.6)', 'Reglernullstellen (-10, -30)', 'Auslegungspunkt K = 0,0695'}, 'Location', 'southwest');
set(lgd, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', [0.3 0.3 0.3]);

exportgraphics(fig2, fullfile(script_dir, 'plot_v3_wok_pidt1_regler.png'), 'Resolution', 300, 'BackgroundColor', 'white');


%% ========================================================================
%% 2. SIMULINK-MODELLE FUER V2 (R2024a) UND V3 (DK_V3.slx) ERSTELLEN
%% ========================================================================
% 2.1 Konvertiere das V2-Modell EI7_V2.slx nach R2024a fuer V3 (Kap. 1.3 Hinweis!)
v2_model_path = fullfile(script_dir, '..', 'V2_Modellbildung', 'EI7_V2.slx');
if isfile(v2_model_path)
    load_system(v2_model_path);
    Simulink.exportToVersion('EI7_V2', fullfile(script_dir, 'EI7_V2_R2024a.slx'), 'R2024a');
    close_system('EI7_V2', 0);
    fprintf('EI7_V2_R2024a.slx erfolgreich im Ordner V3_Lagerregelung gespeichert!\n');
end

% 2.2 Erstelle das nichtlineare Regelkreis-Modell DK_V3.slx exakt nach Abb. Kap. 2.3
mdl_v3 = 'DK_V3';
if bdIsLoaded(mdl_v3)
    close_system(mdl_v3, 0);
end
new_system(mdl_v3);
load_system(mdl_v3);

set_param(mdl_v3, 'Solver', 'ode23tb', 'StopTime', '2.0', ...
    'RelTol', '1e-4', 'AbsTol', '1e-6', 'MaxStep', '1e-3');

% Sollwertsprung Thr_cmd: Sprung von 10 deg auf 60 deg bei t = 0.0 s
add_block('simulink/Sources/Step', [mdl_v3 '/Thr_cmd'], ...
    'Time', '0', 'Before', '10', 'After', '60', ...
    'Position', [30, 145, 60, 175]);

% Regeldifferenz e = Thr_cmd - Pos_thr
add_block('simulink/Math Operations/Sum', [mdl_v3 '/Sum_e'], ...
    'Inputs', '|+-', 'IconShape', 'round', ...
    'Position', [105, 150, 125, 170]);

% PID Controller Block (Parallele Form P + I/s + D*N/(1+N/s))
add_block('simulink/Continuous/PID Controller', [mdl_v3 '/PID_Controller'], ...
    'Controller', 'PID', 'Form', 'Parallel', ...
    'P', 'P_reg', 'I', 'I_reg', 'D', 'D_reg', 'N', 'N_reg', ...
    'Position', [160, 142, 210, 178]);

% Stellgroessenbegrenzung Saturation U_mot (-12 V ... +12 V)
add_block('simulink/Discontinuities/Saturation', [mdl_v3 '/Sat_Umot'], ...
    'UpperLimit', '12', 'LowerLimit', '-12', ...
    'Position', [245, 145, 275, 175]);

% Summierstelle U_eff = U_mot - EMF
add_block('simulink/Math Operations/Sum', [mdl_v3 '/Sum_U'], ...
    'Inputs', '|+-', 'IconShape', 'round', ...
    'Position', [315, 150, 335, 170]);

% Ankerkreis 0.4 / (0.0006s + 1) -> I_Mot [A]
add_block('simulink/Continuous/Transfer Fcn', [mdl_v3 '/I_Mot'], ...
    'Numerator', '[0.4]', 'Denominator', '[0.0006 1]', ...
    'Position', [365, 140, 445, 180]);

% Motormoment k_Mot = 0.03 -> Torque [Nm]
add_block('simulink/Math Operations/Gain', [mdl_v3 '/Torque'], ...
    'Gain', '0.03', ...
    'Position', [480, 145, 525, 175]);

% Summierstelle M_eff = Torque - M_Feder - M_Reibung
add_block('simulink/Math Operations/Sum', [mdl_v3 '/Sum_M'], ...
    'Inputs', '-+-', 'IconShape', 'round', ...
    'Position', [560, 150, 580, 170]);

% Mechanik 1 / (8e-6 s) -> w in [rad/s]
add_block('simulink/Continuous/Transfer Fcn', [mdl_v3 '/w_rad_s'], ...
    'Numerator', '[1]', 'Denominator', '[8e-6 0]', ...
    'Position', [610, 140, 680, 180]);

% Integrator 1/s -> Pos_mot [rad] (Startwert: 10 deg -> 10 * pi/180 / 0.05 rad)
add_block('simulink/Continuous/Integrator', [mdl_v3 '/Pos_mot'], ...
    'InitialCondition', '10 * (pi/180) / 0.05', ...
    'Position', [715, 145, 745, 175]);

% Getriebe 0.05 -> Pos_thr [rad]
add_block('simulink/Math Operations/Gain', [mdl_v3 '/Pos_thr_rad'], ...
    'Gain', '0.05', ...
    'Position', [780, 145, 825, 175]);

% rad -> deg (180/pi) -> Pos_thr [deg]
add_block('simulink/Math Operations/Gain', [mdl_v3 '/Pos_thr_deg'], ...
    'Gain', '180/pi', ...
    'Position', [860, 145, 910, 175]);

% Gegen-EMK: EMF [V] = 0.03 * w
add_block('simulink/Math Operations/Gain', [mdl_v3 '/EMF'], ...
    'Gain', '0.03', 'Orientation', 'left', ...
    'Position', [480, 290, 530, 320]);

% Reibung (1-D Lookup Table exakt wie in Abb. Kap. 2.3):
% Vector of input values: [-10, -1, 1, 10], Table data: [-0.01, -0.01, 0.01, 0.01]
add_block('simulink/Lookup Tables/1-D Lookup Table', [mdl_v3 '/Friction_Nm'], ...
    'BreakpointsForDimension1', '[-10, -1, 1, 10]', ...
    'Table', '[-0.01, -0.01, 0.01, 0.01]', ...
    'InterpMethod', 'Linear point-slope', ...
    'ExtrapMethod', 'Linear', ...
    'Orientation', 'left', ...
    'Position', [615, 225, 665, 265]);

% Notlauffeder (1-D Lookup Table exakt wie in Abb. Kap. 2.3):
% Vector of input values: [-0.1, 0, 4.9, 5.1, 90, 90.1]
% Table data: [-0.1, -0.0253, -0.025, 0.025, 0.029, 0.1]
add_block('simulink/Lookup Tables/1-D Lookup Table', [mdl_v3 '/Limp_home_spring_Nm'], ...
    'BreakpointsForDimension1', '[-0.1, 0, 4.9, 5.1, 90, 90.1]', ...
    'Table', '[-0.1, -0.0253, -0.025, 0.025, 0.029, 0.1]', ...
    'InterpMethod', 'Linear point-slope', ...
    'ExtrapMethod', 'Linear', ...
    'Orientation', 'left', ...
    'Position', [615, 70, 665, 110]);

% Scope
add_block('simulink/Sinks/Scope', [mdl_v3 '/Scope_DK'], ...
    'Position', [960, 144, 990, 176]);

% Verbindungen
add_line(mdl_v3, 'Thr_cmd/1', 'Sum_e/1');
add_line(mdl_v3, 'Sum_e/1', 'PID_Controller/1');
add_line(mdl_v3, 'PID_Controller/1', 'Sat_Umot/1');
add_line(mdl_v3, 'Sat_Umot/1', 'Sum_U/1');
add_line(mdl_v3, 'Sum_U/1', 'I_Mot/1');
add_line(mdl_v3, 'I_Mot/1', 'Torque/1');
add_line(mdl_v3, 'Torque/1', 'Sum_M/2');
add_line(mdl_v3, 'Sum_M/1', 'w_rad_s/1');
add_line(mdl_v3, 'w_rad_s/1', 'Pos_mot/1');
add_line(mdl_v3, 'Pos_mot/1', 'Pos_thr_rad/1');
add_line(mdl_v3, 'Pos_thr_rad/1', 'Pos_thr_deg/1');
add_line(mdl_v3, 'Pos_thr_deg/1', 'Scope_DK/1');

% Rueckfuehrungen
add_line(mdl_v3, 'Limp_home_spring_Nm/1', 'Sum_M/1');
add_line(mdl_v3, 'Pos_thr_deg/1', 'Limp_home_spring_Nm/1');
add_line(mdl_v3, 'Friction_Nm/1', 'Sum_M/3');
add_line(mdl_v3, 'w_rad_s/1', 'Friction_Nm/1');
add_line(mdl_v3, 'w_rad_s/1', 'EMF/1');
add_line(mdl_v3, 'EMF/1', 'Sum_U/2');
add_line(mdl_v3, 'Pos_thr_deg/1', 'Sum_e/2');

% Signal-Logging per To Workspace fuer Auswertung
add_block('simulink/Sinks/To Workspace', [mdl_v3 '/ToWS_pos'], ...
    'VariableName', 'sim_pos', 'SaveFormat', 'Array', 'Position', [955, 200, 1005, 220]);
add_block('simulink/Sinks/To Workspace', [mdl_v3 '/ToWS_cmd'], ...
    'VariableName', 'sim_cmd', 'SaveFormat', 'Array', 'Position', [105, 95, 155, 115]);
add_block('simulink/Sinks/To Workspace', [mdl_v3 '/ToWS_umot'], ...
    'VariableName', 'sim_umot', 'SaveFormat', 'Array', 'Position', [290, 95, 340, 115]);
add_line(mdl_v3, 'Pos_thr_deg/1', 'ToWS_pos/1');
add_line(mdl_v3, 'Thr_cmd/1', 'ToWS_cmd/1');
add_line(mdl_v3, 'Sat_Umot/1', 'ToWS_umot/1');

% Standardwerte im Base Workspace setzen (PIDT1 mit K = 0.0695)
P_reg = 0.0695;
I_reg = 0.0695 / TN;
D_reg = 0.0695 * TV;
N_reg = 1 / T;

save_system(mdl_v3, fullfile(script_dir, 'DK_V3.slx'));
Simulink.exportToVersion(mdl_v3, fullfile(script_dir, 'DK_V3_R2024a.slx'), 'R2024a');
fprintf('DK_V3.slx und DK_V3_R2024a.slx erfolgreich erstellt!\n');


%% ========================================================================
%% 3. SIMULATION DER REGLER AM NICHTLINEAREN MODELL (10 deg -> 60 deg)
%% ========================================================================
% 3.1 P-Regler für verschiedene Verstärkungen K_P
KP_list = [K_P_opt, 0.1, 0.25, 0.5, 2.0];
sim_P_results = cell(length(KP_list), 1);

for i = 1:length(KP_list)
    P_reg = KP_list(i);
    I_reg = 0;
    D_reg = 0;
    N_reg = 1000;
    simOut = sim(mdl_v3, 'StopTime', '1.5');
    sim_P_results{i}.t = simOut.tout;
    sim_P_results{i}.pos = simOut.sim_pos;
    sim_P_results{i}.cmd = simOut.sim_cmd;
    sim_P_results{i}.umot = simOut.sim_umot;
    sim_P_results{i}.KP = KP_list(i);
    fprintf('P-Regler K_P = %.4f: Endwert phi_end = %.2f deg (Bleibende Abweichung e_inf = %.2f deg), Max = %.2f deg\n', ...
        KP_list(i), simOut.sim_pos(end), 60 - simOut.sim_pos(end), max(simOut.sim_pos));
end

% Plot 3: P-Regler Sprungantworten (10° -> 60°)
fig3 = figure('Position', [100, 100, 1150, 440], 'Color', 'w');
tlo3 = tiledlayout(fig3, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

ax3a = nexttile(tlo3, 1);
hold(ax3a, 'on'); grid(ax3a, 'on'); box(ax3a, 'on');
plot(ax3a, sim_P_results{1}.t, sim_P_results{1}.cmd, 'k--', 'LineWidth', 1.6, 'DisplayName', 'Sollwert (10° \rightarrow 60°)');
cols_p = [0.85 0.33 0.10; 0.93 0.69 0.13; 0.10 0.60 0.25; 0.00 0.38 0.82; 0.49 0.18 0.56];
for i = 1:length(KP_list)
    lbl = sprintf('K_P = %.4f (\\phi_{\\infty} = %.1f°)', KP_list(i), sim_P_results{i}.pos(end));
    if i == 1
        lbl = sprintf('K_{P,WOK} = %.4f (\\phi_{\\infty} = %.1f°)', KP_list(i), sim_P_results{i}.pos(end));
    end
    plot(ax3a, sim_P_results{i}.t, sim_P_results{i}.pos, 'LineWidth', 2.0, 'Color', cols_p(i,:), 'DisplayName', lbl);
end
xlabel(ax3a, 'Zeit t [s]', 'FontWeight', 'bold');
ylabel(ax3a, 'Klappenwinkel \phi_{DK} [°]', 'FontWeight', 'bold');
title(ax3a, 'Sprungantwort 10° \rightarrow 60° mit P-Regler (Klappenposition)', 'FontWeight', 'bold');
xlim(ax3a, [0 1.2]); ylim(ax3a, [5 70]);
lgd = legend(ax3a, 'Location', 'southeast', 'FontSize', 8.5);
set(lgd, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', [0.3 0.3 0.3]);

ax3b = nexttile(tlo3, 2);
hold(ax3b, 'on'); grid(ax3b, 'on'); box(ax3b, 'on');
for i = 1:length(KP_list)
    plot(ax3b, sim_P_results{i}.t, sim_P_results{i}.umot, 'LineWidth', 1.8, 'Color', cols_p(i,:), ...
        'DisplayName', sprintf('K_P = %.4f', KP_list(i)));
end
yline(ax3b, 2.25, 'r:', 'LineWidth', 1.4, 'DisplayName', 'Min. Spannung gegen Feder+Reibung (\approx 2,3 V)');
xlabel(ax3b, 'Zeit t [s]', 'FontWeight', 'bold');
ylabel(ax3b, 'Motorspannung U_{Mot} [V]', 'FontWeight', 'bold');
title(ax3b, 'Stellgroesse U_{Mot} beim P-Regler', 'FontWeight', 'bold');
xlim(ax3b, [0 1.2]); ylim(ax3b, [-4 13]);
lgd = legend(ax3b, 'Location', 'northeast', 'FontSize', 8.5);
set(lgd, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', [0.3 0.3 0.3]);

exportgraphics(fig3, fullfile(script_dir, 'plot_v3_sim_p_regler.png'), 'Resolution', 300, 'BackgroundColor', 'white');


% 3.2 PIDT1-Regler Simulation (WOK-Wert K = 0.0695, höhere Verstärkungen sowie mit PT1-Führungsgrößenfilter 1/(0.1s+1) zur Kompensation von s_N1 = -10 + Anti-Windup)
K_PID_list = [0.0695, 0.25, 0.50];
sim_PID_results = cell(length(K_PID_list), 1);

for i = 1:length(K_PID_list)
    K_curr = K_PID_list(i);
    P_reg = K_curr;
    I_reg = K_curr / TN;
    D_reg = K_curr * TV;
    N_reg = 1 / T;
    set_param([mdl_v3 '/PID_Controller'], 'LimitOutput', 'off', 'AntiWindupMode', 'none');
    simOut = sim(mdl_v3, 'StopTime', '1.5');
    sim_PID_results{i}.t = simOut.tout;
    sim_PID_results{i}.pos = simOut.sim_pos;
    sim_PID_results{i}.cmd = simOut.sim_cmd;
    sim_PID_results{i}.umot = simOut.sim_umot;
    sim_PID_results{i}.K = K_curr;
    fprintf('PIDT1-Regler (ohne Vorfilter/AW) K = %.4f: Endwert phi_end = %.2f deg, Max = %.2f deg\n', ...
        K_curr, simOut.sim_pos(end), max(simOut.sim_pos));
end

% Fuege PT1-Fuehrungsgroessenfilter F_F(s) = 1 / (0.1*s + 1) nach Thr_cmd ein (kompensiert Nullstelle s_N1 = -10!)
% Damit das Filter bei 10 deg startet, nutzen wir ein Zustandsraum- / Integrator-PT1 oder verschieben 10 + 50/(0.1s+1):
% Noch einfacher in Simulink: State-Space Block für PT1 mit A = -10, B = 10, C = 1, D = 0 und InitialCondition x0 = 10!
delete_line(mdl_v3, 'Thr_cmd/1', 'Sum_e/1');
add_block('simulink/Continuous/State-Space', [mdl_v3 '/PT1_Vorfilter_sN1_10'], ...
    'A', '-10', 'B', '10', 'C', '1', 'D', '0', 'X0', '10', ...
    'Position', [68, 144, 95, 176]);
add_line(mdl_v3, 'Thr_cmd/1', 'PT1_Vorfilter_sN1_10/1');
add_line(mdl_v3, 'PT1_Vorfilter_sN1_10/1', 'Sum_e/1');

% 1) Simulation mit PT1-Fuehrungsgroessenfilter (1/(0.1s+1)) bei K = 0.0695 und K = 0.50 (ohne Anti-Windup)
K_curr = 0.0695;
P_reg = K_curr; I_reg = K_curr / TN; D_reg = K_curr * TV; N_reg = 1 / T;
simOut_VF_00695 = sim(mdl_v3, 'StopTime', '1.5');
fprintf('PIDT1 + PT1-Vorfilter (1/(0.1s+1)) bei K = 0.0695: Endwert = %.2f deg, Max = %.2f deg\n', ...
    simOut_VF_00695.sim_pos(end), max(simOut_VF_00695.sim_pos));

% 2) Simulation mit PT1-Fuehrungsgroessenfilter (1/(0.1s+1)) UND Anti-Windup (clamping) bei K = 0.50:
set_param([mdl_v3 '/PID_Controller'], 'LimitOutput', 'on', 'UpperSaturationLimit', '12', 'LowerSaturationLimit', '-12', 'AntiWindupMode', 'clamping');
K_curr = 0.50;
P_reg = K_curr; I_reg = K_curr / TN; D_reg = K_curr * TV; N_reg = 1 / T;
simOut_AW = sim(mdl_v3, 'StopTime', '1.5');
fprintf('PIDT1 + PT1-Vorfilter (1/(0.1s+1)) + Anti-Windup bei K = 0.50: Endwert = %.2f deg, Max = %.2f deg\n', ...
    simOut_AW.sim_pos(end), max(simOut_AW.sim_pos));

% Plot 4: PIDT1-Regler Sprungantworten (10° -> 60°) inkl. PT1-Führungsgrößenfilter & Anti-Windup
fig4 = figure('Position', [100, 100, 1150, 440], 'Color', 'w');
tlo4 = tiledlayout(fig4, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

ax4a = nexttile(tlo4, 1);
hold(ax4a, 'on'); grid(ax4a, 'on'); box(ax4a, 'on');
plot(ax4a, sim_PID_results{1}.t, sim_PID_results{1}.cmd, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Sollwert (10° \rightarrow 60°)');
cols_pid_sim = [0.85 0.33 0.10; 0.93 0.69 0.13; 0.00 0.38 0.82];
for i = 1:length(K_PID_list)
    lbl = sprintf('K = %.4f (\\phi_{max} = %.1f°)', K_PID_list(i), max(sim_PID_results{i}.pos));
    if i == 1
        lbl = sprintf('K_{WOK} = %.4f (\\phi_{max} = %.1f°)', K_PID_list(i), max(sim_PID_results{i}.pos));
    end
    plot(ax4a, sim_PID_results{i}.t, sim_PID_results{i}.pos, 'LineWidth', 1.9, 'Color', cols_pid_sim(i,:), 'DisplayName', lbl);
end
plot(ax4a, simOut_VF_00695.tout, simOut_VF_00695.sim_pos, '-.', 'LineWidth', 2.1, 'Color', [0.49 0.18 0.56], ...
    'DisplayName', sprintf('K = 0,0695 + PT_1-Vorfilter (\\phi_{max} = %.1f°)', max(simOut_VF_00695.sim_pos)));
plot(ax4a, simOut_AW.tout, simOut_AW.sim_pos, '-', 'LineWidth', 2.4, 'Color', [0.10 0.60 0.25], ...
    'DisplayName', sprintf('K = 0,50 + PT_1-Vorfilter + AW (\\phi_{max} = %.1f°)', max(simOut_AW.sim_pos)));
xlabel(ax4a, 'Zeit t [s]', 'FontWeight', 'bold');
ylabel(ax4a, 'Klappenwinkel \phi_{DK} [°]', 'FontWeight', 'bold');
title(ax4a, 'Sprungantwort 10° \rightarrow 60° mit PIDT1-Regler & PT_1-Vorfilter', 'FontWeight', 'bold');
xlim(ax4a, [0 1.5]); ylim(ax4a, [5 76]);
lgd = legend(ax4a, 'Location', 'southeast', 'FontSize', 7.8);
set(lgd, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', [0.3 0.3 0.3]);

ax4b = nexttile(tlo4, 2);
hold(ax4b, 'on'); grid(ax4b, 'on'); box(ax4b, 'on');
for i = 1:length(K_PID_list)
    plot(ax4b, sim_PID_results{i}.t, sim_PID_results{i}.umot, 'LineWidth', 1.7, 'Color', cols_pid_sim(i,:), ...
        'DisplayName', sprintf('K = %.4f', K_PID_list(i)));
end
plot(ax4b, simOut_VF_00695.tout, simOut_VF_00695.sim_umot, '-.', 'LineWidth', 2.0, 'Color', [0.49 0.18 0.56], ...
    'DisplayName', 'K = 0,0695 + PT_1-Vorfilter');
plot(ax4b, simOut_AW.tout, simOut_AW.sim_umot, '-', 'LineWidth', 2.3, 'Color', [0.10 0.60 0.25], ...
    'DisplayName', 'K = 0,50 + PT_1-Vorfilter + AW');
xlabel(ax4b, 'Zeit t [s]', 'FontWeight', 'bold');
ylabel(ax4b, 'Motorspannung U_{Mot} [V]', 'FontWeight', 'bold');
title(ax4b, 'Stellgroesse U_{Mot} beim PIDT1-Regler', 'FontWeight', 'bold');
xlim(ax4b, [0 1.5]); ylim(ax4b, [-6 13]);
lgd = legend(ax4b, 'Location', 'northeast', 'FontSize', 7.8);
set(lgd, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', [0.3 0.3 0.3]);

exportgraphics(fig4, fullfile(script_dir, 'plot_v3_sim_pidt1_regler.png'), 'Resolution', 300, 'BackgroundColor', 'white');


%% ========================================================================
%% 4. TESTFRAGEN-PLOTS (KAPITEL 4)
%% ========================================================================
% 4.1 Testfrage 2 & 3: WOK fuer s_P1 = s_P2 = 0; s_P3 = -3; s_N1 = -1
s = tf('s');
Fo_test = (s + 1) / (s^2 * (s + 3));
% Alternativ über zpk: Fo_test = zpk([-1], [0 0 -3], 1);

fig5 = figure('Position', [100, 100, 620, 460], 'Color', 'w');
ax5 = axes(fig5);
hold(ax5, 'on'); grid(ax5, 'on'); box(ax5, 'on');
xline(ax5, 0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');
yline(ax5, 0, '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');

k_test = [linspace(0, 1, 1000), linspace(1, 20, 2000), linspace(20, 100, 1000)];
r_test = rlocus(Fo_test, k_test);
cols_t = [0.00 0.38 0.82; 0.85 0.33 0.10; 0.10 0.60 0.25];
for b = 1:size(r_test, 1)
    plot(ax5, real(r_test(b,:)), imag(r_test(b,:)), 'LineWidth', 2.4, 'Color', cols_t(b,:));
end
% Asymptotenschnittpunkt: sigma_A = (0 + 0 - 3 - (-1)) / (3 - 1) = -2 / 2 = -1
xline(ax5, -1, ':', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);
h_tp = plot(ax5, [0, 0, -3], [0, 0, 0], 'kx', 'MarkerSize', 11, 'LineWidth', 2.2);
h_tz = plot(ax5, -1, 0, 'bo', 'MarkerSize', 10, 'LineWidth', 2.2, 'MarkerFaceColor', 'w');
text(ax5, 0.1, 0.35, 's_{P1,2} = 0 (Doppelpol)', 'FontWeight', 'bold', 'FontSize', 9.5);
text(ax5, -3.4, 0.35, 's_{P3} = -3', 'FontWeight', 'bold', 'FontSize', 9.5);
text(ax5, -0.9, -0.35, 's_{N1} = -1 (\sigma_A = -1)', 'FontWeight', 'bold', 'FontSize', 9.5, 'Color', [0 0.38 0.82]);
xlabel(ax5, 'Realteil \sigma [s^{-1}]', 'FontWeight', 'bold');
ylabel(ax5, 'Imaginaerteil j\omega [s^{-1}]', 'FontWeight', 'bold');
title(ax5, 'Testfrage: WOK fuer s_{P1,2} = 0, s_{P3} = -3, s_{N1} = -1', 'FontWeight', 'bold');
xlim(ax5, [-4 1]); ylim(ax5, [-3.5 3.5]);
lgd = legend(ax5, [h_tp, h_tz], {'Pole (0, 0, -3)', 'Nullstelle (-1)'}, 'Location', 'northwest');
set(lgd, 'Color', 'w', 'TextColor', 'k', 'EdgeColor', [0.3 0.3 0.3]);

exportgraphics(fig5, fullfile(script_dir, 'plot_v3_testfrage_wok.png'), 'Resolution', 300, 'BackgroundColor', 'white');


% 4.2 Testfrage 6: Pole/Nullstellen und Sprungantwort von PT1-, PD- und PDT1-Glied
fig6 = figure('Position', [100, 100, 1180, 560], 'Color', 'w');
tlo6 = tiledlayout(fig6, 2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

% --- Reihe 1: Pol-/Nullstellen-Diagramme ---
% 1) PT1: F(s) = K / (T1*s + 1), Pol bei s_P = -1/T1 = -2
ax6_1 = nexttile(tlo6, 1);
hold(ax6_1, 'on'); grid(ax6_1, 'on'); box(ax6_1, 'on');
xline(ax6_1, 0, 'k-'); yline(ax6_1, 0, 'k-');
plot(ax6_1, -2, 0, 'rx', 'MarkerSize', 12, 'LineWidth', 2.5);
text(ax6_1, -2.3, 0.25, 's_P = -1/T_1', 'FontWeight', 'bold', 'Color', 'r');
title(ax6_1, 'PT_1-Glied: Pol-/Nullstellenplan', 'FontWeight', 'bold');
xlabel(ax6_1, 'Realteil \sigma'); ylabel(ax6_1, 'Imaginaerteil j\omega');
xlim(ax6_1, [-4 1]); ylim(ax6_1, [-1 1]);

% 2) PD: F(s) = K * (T_V*s + 1), Nullstelle bei s_N = -1/T_V = -1
ax6_2 = nexttile(tlo6, 2);
hold(ax6_2, 'on'); grid(ax6_2, 'on'); box(ax6_2, 'on');
xline(ax6_2, 0, 'k-'); yline(ax6_2, 0, 'k-');
plot(ax6_2, -1, 0, 'bo', 'MarkerSize', 11, 'LineWidth', 2.5, 'MarkerFaceColor', 'w');
text(ax6_2, -1.4, 0.25, 's_N = -1/T_V', 'FontWeight', 'bold', 'Color', 'b');
title(ax6_2, 'Ideales PD-Glied: Pol-/Nullstellenplan', 'FontWeight', 'bold');
xlabel(ax6_2, 'Realteil \sigma'); ylabel(ax6_2, 'Imaginaerteil j\omega');
xlim(ax6_2, [-4 1]); ylim(ax6_2, [-1 1]);

% 3) PDT1: F(s) = K * (T_V*s + 1) / (T_1*s + 1), s_N = -1/T_V = -1, s_P = -1/T_1 = -5 (T_V > T_1)
ax6_3 = nexttile(tlo6, 3);
hold(ax6_3, 'on'); grid(ax6_3, 'on'); box(ax6_3, 'on');
xline(ax6_3, 0, 'k-'); yline(ax6_3, 0, 'k-');
plot(ax6_3, -1, 0, 'bo', 'MarkerSize', 11, 'LineWidth', 2.5, 'MarkerFaceColor', 'w');
plot(ax6_3, -5, 0, 'rx', 'MarkerSize', 12, 'LineWidth', 2.5);
text(ax6_3, -1.5, 0.25, 's_N = -1/T_V', 'FontWeight', 'bold', 'Color', 'b');
text(ax6_3, -5.6, 0.25, 's_P = -1/T_1', 'FontWeight', 'bold', 'Color', 'r');
title(ax6_3, 'Reales PDT_1-Glied (T_V > T_1): P/N-Plan', 'FontWeight', 'bold');
xlabel(ax6_3, 'Realteil \sigma'); ylabel(ax6_3, 'Imaginaerteil j\omega');
xlim(ax6_3, [-6.5 1]); ylim(ax6_3, [-1 1]);

% --- Reihe 2: Sprungantworten h(t) ---
t_vec = linspace(0, 2.5, 500);
% 1) PT1: h(t) = K * (1 - exp(-t/T1)) mit K=1, T1=0.5
ax6_4 = nexttile(tlo6, 4);
hold(ax6_4, 'on'); grid(ax6_4, 'on'); box(ax6_4, 'on');
h_pt1 = 1 * (1 - exp(-t_vec / 0.5));
plot(ax6_4, [-0.3 0 t_vec], [0 0 h_pt1], 'LineWidth', 2.2, 'Color', [0.00 0.38 0.82]);
plot(ax6_4, [0 0.5], [0 1], 'r--', 'LineWidth', 1.2);
yline(ax6_4, 1, 'k:', 'K');
xline(ax6_4, 0.5, 'k:', 'T_1');
title(ax6_4, 'PT_1-Glied: Sprungantwort h(t)', 'FontWeight', 'bold');
xlabel(ax6_4, 'Zeit t [s]'); ylabel(ax6_4, 'h(t)');
xlim(ax6_4, [-0.3 2.5]); ylim(ax6_4, [-0.1 1.3]);

% 2) PD: h(t) = K * (1 + T_V * delta(t))
ax6_5 = nexttile(tlo6, 5);
hold(ax6_5, 'on'); grid(ax6_5, 'on'); box(ax6_5, 'on');
plot(ax6_5, [-0.3 0 0 2.5], [0 0 1 1], 'LineWidth', 2.2, 'Color', [0.00 0.38 0.82]);
% Dirac-Stoß Pfeil bei t = 0
quiver(ax6_5, 0, 0, 0, 2.8, 0, 'r', 'LineWidth', 2.5, 'MaxHeadSize', 0.4);
text(ax6_5, 0.12, 2.3, 'Dirac-Impuls K\cdot T_V\cdot \delta(t) \rightarrow \infty', 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 9);
yline(ax6_5, 1, 'k:', 'K');
title(ax6_5, 'Ideales PD-Glied: Sprungantwort h(t)', 'FontWeight', 'bold');
xlabel(ax6_5, 'Zeit t [s]'); ylabel(ax6_5, 'h(t)');
xlim(ax6_5, [-0.3 2.5]); ylim(ax6_5, [-0.2 3.2]);

% 3) PDT1: h(t) = K * (1 + (T_V/T_1 - 1)*exp(-t/T_1)) mit K=1, T_V=1.0, T_1=0.25 -> Start bei K*T_V/T_1 = 4
ax6_6 = nexttile(tlo6, 6);
hold(ax6_6, 'on'); grid(ax6_6, 'on'); box(ax6_6, 'on');
h_pdt1 = 1 * (1 + (1.0/0.25 - 1) * exp(-t_vec / 0.25));
plot(ax6_6, [-0.3 0 0 t_vec], [0 0 h_pdt1(1) h_pdt1], 'LineWidth', 2.2, 'Color', [0.00 0.38 0.82]);
yline(ax6_6, 1, 'k:', 'K = 1');
yline(ax6_6, 4, 'r:', 'K \cdot T_V / T_1');
xline(ax6_6, 0.25, 'k:', 'T_1');
title(ax6_6, 'Reales PDT_1-Glied: Sprungantwort h(t)', 'FontWeight', 'bold');
xlabel(ax6_6, 'Zeit t [s]'); ylabel(ax6_6, 'h(t)');
xlim(ax6_6, [-0.3 2.5]); ylim(ax6_6, [-0.2 4.5]);

exportgraphics(fig6, fullfile(script_dir, 'plot_v3_testfrage_glieder.png'), 'Resolution', 300, 'BackgroundColor', 'white');

close_system(mdl_v3, 0);
fprintf('=== ALLE PLOTS UND MODELLE FUER V3 ERFOLGREICH GENERIERT! ===\n');
