%% build_models.m
% Erstellt die Simulink-Modelle programmatisch gemäß Aufgabenstellung:
% 1. EI7_V2.slx (Hauptmodell Drosselklappe)
% 2. testfrage_system.slx (Testaufgabe F(s) = 5 / (2*s^2 + 8))
% 3. Export beider Modelle nach R2018b

clear; clc;
init_parameters;

disp('=====================================================');
disp(' Erstelle Simulink-Modelle programmatisch...');
disp('=====================================================');

%% ===================================================
%% MODELL 1: Drosselklappe (EI7_V2)
%% ===================================================
model_name = 'EI7_V2';
if bdIsLoaded(model_name)
    close_system(model_name, 0);
end
new_system(model_name);
open_system(model_name);

% Konfiguration des Solvers (robuster kontinuierlicher Solver für mechatronische Systeme)
set_param(model_name, 'Solver', 'ode45', 'StopTime', num2str(t_sim), ...
                      'RelTol', '1e-5', 'AbsTol', '1e-6', 'MaxStep', '1e-3');

% Blöcke hinzufügen
% 1. Eingangsspannung (Sprung 0 -> 6V)
add_block('simulink/Sources/Step', [model_name '/U_in'], ...
    'Time', num2str(t_step), 'Before', '0', 'After', num2str(U_step_val), ...
    'Position', [40, 100, 80, 130]);

% 2. Summierstelle Spannung (u - u_EMK)
add_block('simulink/Math Operations/Sum', [model_name '/Sum_U'], ...
    'IconShape', 'rectangular', 'Inputs', '+-', ...
    'Position', [120, 100, 145, 135]);

% 3. Elektrischer Zweig (PT1-Glied: (1/R) / ((L/R)*s + 1))
add_block('simulink/Continuous/Transfer Fcn', [model_name '/PT1_Elektrik'], ...
    'Numerator', '[1/R_A]', 'Denominator', '[L_A/R_A 1]', ...
    'Position', [180, 92, 280, 148]);

% 4. Motormoment (k_Mot)
add_block('simulink/Math Operations/Gain', [model_name '/k_Mot'], ...
    'Gain', 'k_Mot', ...
    'Position', [320, 102, 370, 138]);

% 5. Summierstelle Drehmoment: M_eff = M_el - M_R - M_F
add_block('simulink/Math Operations/Sum', [model_name '/Sum_M'], ...
    'IconShape', 'rectangular', 'Inputs', '+--', ...
    'Position', [410, 95, 435, 145]);

% 6. Massenträgheit (1/J)
add_block('simulink/Math Operations/Gain', [model_name '/Gain_1_over_J'], ...
    'Gain', '1/J_ges', ...
    'Position', [465, 105, 515, 135]);

% 7. Integrator 1: omega_dot -> omega
add_block('simulink/Continuous/Integrator', [model_name '/Int_omega'], ...
    'InitialCondition', '0', ...
    'Position', [545, 105, 575, 135]);

% 8. Integrator 2: omega -> phi_mot
% Startwinkel des Motors entspricht der Notlaufposition
add_block('simulink/Continuous/Integrator', [model_name '/Int_phi_mot'], ...
    'InitialCondition', 'phi_0_rad * i_Getr', ...
    'Position', [625, 105, 655, 135]);

% 9. Getriebefaktor K_Gr = 1/i
add_block('simulink/Math Operations/Gain', [model_name '/K_Gr'], ...
    'Gain', 'K_Gr', ...
    'Position', [695, 105, 745, 135]);

% 10. Umrechnung in Grad (K_deg = 180/pi)
add_block('simulink/Math Operations/Gain', [model_name '/K_deg'], ...
    'Gain', 'K_deg', ...
    'Position', [780, 105, 830, 135]);

% 11. EMK-Rückführung (k_EMK)
add_block('simulink/Math Operations/Gain', [model_name '/k_EMK'], ...
    'Gain', 'k_EMK', ...
    'Position', [340, 25, 390, 55], 'Orientation', 'left');

% 12. Reibungsblock (viskose Dämpfung + Coulomb-Reibung via tanh)
% M_R = d_visk * omega + M_coul * tanh(50 * omega)
add_block('simulink/User-Defined Functions/Fcn', [model_name '/Fcn_Reibung'], ...
    'Expr', 'd_visk*u(1) + M_coul*tanh(50*u(1))', ...
    'Position', [460, 200, 560, 230], 'Orientation', 'left');

% 13. Federmodell (Notlauffeder mit Momentensprung)
% Eingang: phi_DK_deg
% M_F_mot = c_F_deg*(u(1)-phi_0_deg) + M_F0_mot*tanh(20*(u(1)-phi_0_deg))
add_block('simulink/User-Defined Functions/Fcn', [model_name '/Fcn_Feder'], ...
    'Expr', 'c_F_deg*(u(1)-phi_0_deg) + M_F0_mot*tanh(20*(u(1)-phi_0_deg))', ...
    'Position', [580, 260, 750, 290], 'Orientation', 'left');

% 14. Scopes und ToWorkspace zur Ergebniserfassung
add_block('simulink/Sinks/Scope', [model_name '/Scope_Klappe'], ...
    'Position', [890, 104, 920, 136]);

add_block('simulink/Sinks/To Workspace', [model_name '/ToWS_phi'], ...
    'VariableName', 'sim_phi_deg', 'SaveFormat', 'Timeseries', ...
    'Position', [890, 160, 950, 180]);

add_block('simulink/Sinks/To Workspace', [model_name '/ToWS_i'], ...
    'VariableName', 'sim_current', 'SaveFormat', 'Timeseries', ...
    'Position', [330, 160, 390, 180]);

add_block('simulink/Sinks/To Workspace', [model_name '/ToWS_omega'], ...
    'VariableName', 'sim_omega', 'SaveFormat', 'Timeseries', ...
    'Position', [620, 50, 680, 70]);

% Signallinien verbinden
add_line(model_name, 'U_in/1', 'Sum_U/1');
add_line(model_name, 'Sum_U/1', 'PT1_Elektrik/1');
add_line(model_name, 'PT1_Elektrik/1', 'k_Mot/1');
add_line(model_name, 'PT1_Elektrik/1', 'ToWS_i/1');
add_line(model_name, 'k_Mot/1', 'Sum_M/1');

add_line(model_name, 'Sum_M/1', 'Gain_1_over_J/1');
add_line(model_name, 'Gain_1_over_J/1', 'Int_omega/1');
add_line(model_name, 'Int_omega/1', 'Int_phi_mot/1');

% Abzweige von omega
add_line(model_name, 'Int_omega/1', 'k_EMK/1');
add_line(model_name, 'k_EMK/1', 'Sum_U/2');

add_line(model_name, 'Int_omega/1', 'Fcn_Reibung/1');
add_line(model_name, 'Fcn_Reibung/1', 'Sum_M/2');

add_line(model_name, 'Int_omega/1', 'ToWS_omega/1');

% Vom Motorwinkel zur Klappe
add_line(model_name, 'Int_phi_mot/1', 'K_Gr/1');
add_line(model_name, 'K_Gr/1', 'K_deg/1');

% Von Klappenwinkel in Grad zum Scope, Workspace und Federrückführung
add_line(model_name, 'K_deg/1', 'Scope_Klappe/1');
add_line(model_name, 'K_deg/1', 'ToWS_phi/1');
add_line(model_name, 'K_deg/1', 'Fcn_Feder/1');
add_line(model_name, 'Fcn_Feder/1', 'Sum_M/3');

save_system(model_name);
disp('Modell EI7_V2.slx erfolgreich erstellt und gespeichert!');


%% ===================================================
%% MODELL 2: Testfragen-System F(s) = 5 / (2*s^2 + 8)
%% ===================================================
model_test = 'testfrage_system';
if bdIsLoaded(model_test)
    close_system(model_test, 0);
end
new_system(model_test);
open_system(model_test);

set_param(model_test, 'Solver', 'ode45', 'StopTime', '10', ...
                      'RelTol', '1e-5', 'AbsTol', '1e-6', 'MaxStep', '1e-3');

% 1. Step-Block: Sprungförmiges Eingangssignal 0 -> 5
add_block('simulink/Sources/Step', [model_test '/Step_0_to_5'], ...
    'Time', '1', 'Before', '0', 'After', '5', ...
    'Position', [60, 100, 100, 130]);

% 2. Transfer Fcn: F(s) = 5 / (2*s^2 + 8)
add_block('simulink/Continuous/Transfer Fcn', [model_test '/Transfer_Fcn'], ...
    'Numerator', '[5]', 'Denominator', '[2 0 8]', ...
    'Position', [160, 92, 260, 138]);

% 3. Mux-Block, um Eingang und Ausgang im Scope gemeinsam darzustellen
add_block('simulink/Signal Routing/Mux', [model_test '/Mux'], ...
    'Inputs', '2', ...
    'Position', [320, 95, 325, 145]);

% 4. Scope
add_block('simulink/Sinks/Scope', [model_test '/Scope'], ...
    'Position', [370, 104, 400, 136]);

% 5. To Workspace zur Verifikation & Plotting
add_block('simulink/Sinks/To Workspace', [model_test '/ToWS_u'], ...
    'VariableName', 'sim_test_u', 'SaveFormat', 'Timeseries', ...
    'Position', [320, 40, 380, 60]);

add_block('simulink/Sinks/To Workspace', [model_test '/ToWS_y'], ...
    'VariableName', 'sim_test_y', 'SaveFormat', 'Timeseries', ...
    'Position', [320, 180, 380, 200]);

% Verbindungen
add_line(model_test, 'Step_0_to_5/1', 'Transfer_Fcn/1');
add_line(model_test, 'Step_0_to_5/1', 'Mux/1');
add_line(model_test, 'Step_0_to_5/1', 'ToWS_u/1');

add_line(model_test, 'Transfer_Fcn/1', 'Mux/2');
add_line(model_test, 'Transfer_Fcn/1', 'ToWS_y/1');

add_line(model_test, 'Mux/1', 'Scope/1');

save_system(model_test);
disp('Modell testfrage_system.slx erfolgreich erstellt und gespeichert!');


%% ===================================================
%% EXPORT NACH R2018b
%% ===================================================
disp('Exportiere Modelle in Version R2018b...');
try
    Simulink.exportToVersion('EI7_V2', 'EI7_V2_R2018b.slx', 'R2018b');
    disp(' -> EI7_V2_R2018b.slx erfolgreich erstellt!');
catch ME
    warning('Fehler beim Export von EI7_V2: %s', ME.message);
end

try
    Simulink.exportToVersion('testfrage_system', 'testfrage_system_R2018b.slx', 'R2018b');
    disp(' -> testfrage_system_R2018b.slx erfolgreich erstellt!');
catch ME
    warning('Fehler beim Export von testfrage_system: %s', ME.message);
end

close_system('EI7_V2', 0);
close_system('testfrage_system', 0);

disp('=====================================================');
disp(' Modellbau abgeschlossen!');
disp('=====================================================');

