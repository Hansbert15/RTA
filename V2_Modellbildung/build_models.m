%% build_models.m
% Erstellt die Simulink-Modelle programmatisch gemäß Blockschaltbild aus den Mitschriften:
% 1. EI7_V2.slx (Hauptmodell Drosselklappe nach Prof. Blockschaltbild)
% 2. testfrage_system.slx (Testaufgabe F(s) = 5 / (2*s^2 + 8))
% 3. Exportiert saubere Screenshots der Simulink-Modelle als PNG für die Ausarbeitung
% 4. Exportiert beide Modelle nach R2018b

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
if exist([model_name '.slx'], 'file')
    delete([model_name '.slx']);
end
new_system(model_name);
open_system(model_name);

% Konfiguration des Solvers
set_param(model_name, 'Solver', 'ode23tb', 'StopTime', num2str(t_sim), ...
                      'RelTol', '1e-5', 'AbsTol', '1e-6', 'MaxStep', '5e-4');

% 1. Eingangsspannung u (Sprung 0 -> 6 V)
add_block('simulink/Sources/Step', [model_name '/u'], ...
    'Time', 't_step', 'Before', '0', 'After', 'U_step_val', ...
    'Position', [40, 145, 70, 175]);

% 2. Summierstelle Spannung (u - u_EMK)
add_block('simulink/Math Operations/Sum', [model_name '/Sum_U'], ...
    'IconShape', 'round', 'Inputs', '-+|', ...
    'Position', [115, 150, 135, 170]);

% 3. Elektrisches Teilsystem: (1/R) / ((L/R)*s + 1)
add_block('simulink/Continuous/Transfer Fcn', [model_name '/Ankerkreis'], ...
    'Numerator', '[0.4]', 'Denominator', '[0.0007 1]', ...
    'Position', [170, 136, 275, 184]);

% 4. Motorkonstante k_Mot (c * Phi_E)
add_block('simulink/Math Operations/Gain', [model_name '/k_Mot'], ...
    'Gain', 'k_Mot', ...
    'Position', [310, 142, 360, 178]);

% 5. Summierstelle Drehmoment (M_A - M_R - M_F)
add_block('simulink/Math Operations/Sum', [model_name '/Sum_M'], ...
    'IconShape', 'round', 'Inputs', '|--+', ...
    'Inputs', '|+--', ...
    'Position', [405, 145, 430, 175]);

% 6. Welle / Trägheitsmoment k_Welle = 1/J
add_block('simulink/Math Operations/Gain', [model_name '/k_Welle (1//J)'], ...
    'Gain', '1/J_ges', ...
    'Position', [475, 142, 535, 178]);

% 7. Integrator 1: omega_dot -> omega
add_block('simulink/Continuous/Integrator', [model_name '/1//s (omega)'], ...
    'InitialCondition', '0', ...
    'Position', [580, 145, 610, 175]);

% 8. Integrator 2: omega -> phi_Mot (Start bei Notlaufposition phi_0_rad / K_Gr)
add_block('simulink/Continuous/Integrator', [model_name '/1//s (phi_Mot)'], ...
    'InitialCondition', 'phi_0_rad / K_Gr', ...
    'Position', [675, 145, 705, 175]);

% 9. Faktor Getriebe k_Gr
add_block('simulink/Math Operations/Gain', [model_name '/k_Gr'], ...
    'Gain', 'K_Gr', ...
    'Position', [755, 142, 805, 178]);

% 10. Umrechnung rad -> deg (k_deg = 180/pi)
add_block('simulink/Math Operations/Gain', [model_name '/k_deg'], ...
    'Gain', '180/pi', ...
    'Position', [850, 142, 905, 178]);

% 11. Ausgangs-Scope phi_DK / deg
add_block('simulink/Sinks/Scope', [model_name '/phi_DK [deg]'], ...
    'Position', [965, 144, 995, 176]);

% 12. Rückführung Oben: EMK (k_EMK)
add_block('simulink/Math Operations/Gain', [model_name '/k_EMK'], ...
    'Gain', 'k_EMK', ...
    'Position', [310, 45, 365, 85], 'Orientation', 'left');

% 13. Rückführung Mitte: Reibung M_R (Lookup Table)
add_block('simulink/Lookup Tables/1-D Lookup Table', [model_name '/Reibung M_R'], ...
    'Table', 'reib_M_lut', 'BreakpointsForDimension1', 'reib_w_lut', ...
    'Position', [480, 235, 535, 275], 'Orientation', 'left');

% 14. Rückführung Unten: Feder M_F (Lookup Table inkl. NLP & Anschlag)
add_block('simulink/Lookup Tables/1-D Lookup Table', [model_name '/Feder M_F'], ...
    'Table', 'feder_M_lut', 'BreakpointsForDimension1', 'feder_phi_lut', ...
    'Position', [610, 320, 675, 360], 'Orientation', 'left');

% Signallinien verbinden und beschriften
h1 = add_line(model_name, 'u/1', 'Sum_U/2', 'autorouting', 'on');
set_param(h1, 'Name', 'u');

add_line(model_name, 'Sum_U/1', 'Ankerkreis/1', 'autorouting', 'on');

h2 = add_line(model_name, 'Ankerkreis/1', 'k_Mot/1', 'autorouting', 'on');
set_param(h2, 'Name', 'I');

h3 = add_line(model_name, 'k_Mot/1', 'Sum_M/1', 'autorouting', 'on');
set_param(h3, 'Name', 'M_A');

add_line(model_name, 'Sum_M/1', 'k_Welle (1//J)/1', 'autorouting', 'on');

h4 = add_line(model_name, 'k_Welle (1//J)/1', '1//s (omega)/1', 'autorouting', 'on');
set_param(h4, 'Name', 'd_omega/dt');

h5 = add_line(model_name, '1//s (omega)/1', '1//s (phi_Mot)/1', 'autorouting', 'on');
set_param(h5, 'Name', 'omega');

h6 = add_line(model_name, '1//s (phi_Mot)/1', 'k_Gr/1', 'autorouting', 'on');
set_param(h6, 'Name', 'phi_Mot');

h7 = add_line(model_name, 'k_Gr/1', 'k_deg/1', 'autorouting', 'on');
set_param(h7, 'Name', 'phi_DK [rad]');

h8 = add_line(model_name, 'k_deg/1', 'phi_DK [deg]/1', 'autorouting', 'on');
set_param(h8, 'Name', 'phi_DK [deg]');

% Rückführungen
add_line(model_name, '1//s (omega)/1', 'k_EMK/1', 'autorouting', 'on');
h_emk = add_line(model_name, 'k_EMK/1', 'Sum_U/1', 'autorouting', 'on');
set_param(h_emk, 'Name', 'u_EMK');

add_line(model_name, '1//s (omega)/1', 'Reibung M_R/1', 'autorouting', 'on');
h_mr = add_line(model_name, 'Reibung M_R/1', 'Sum_M/2', 'autorouting', 'on');
set_param(h_mr, 'Name', 'M_R');

add_line(model_name, 'k_deg/1', 'Feder M_F/1', 'autorouting', 'on');
h_mf = add_line(model_name, 'Feder M_F/1', 'Sum_M/3', 'autorouting', 'on');
set_param(h_mf, 'Name', 'M_F');

save_system(model_name);

% Screenshot des sauberen Simulink-Modells exportieren (bevor ToWorkspace-Blöcke ergänzt werden)
print(['-s' model_name], '-dpng', '-r300', 'V2_Ausarbeitung/simulink_modell_drosselklappe.png');
disp('-> Simulink-Modellbild exportiert: V2_Ausarbeitung/simulink_modell_drosselklappe.png');

% ToWorkspace-Blöcke für die Auswertung hinzufügen
add_block('simulink/Sinks/To Workspace', [model_name '/ToWS_phi'], ...
    'VariableName', 'sim_phi_deg', 'SaveFormat', 'Timeseries', ...
    'Position', [960, 210, 1020, 230]);
add_block('simulink/Sinks/To Workspace', [model_name '/ToWS_i'], ...
    'VariableName', 'sim_current', 'SaveFormat', 'Timeseries', ...
    'Position', [295, 210, 355, 230]);
add_block('simulink/Sinks/To Workspace', [model_name '/ToWS_omega'], ...
    'VariableName', 'sim_omega', 'SaveFormat', 'Timeseries', ...
    'Position', [655, 75, 715, 95]);

add_line(model_name, 'k_deg/1', 'ToWS_phi/1', 'autorouting', 'on');
add_line(model_name, 'Ankerkreis/1', 'ToWS_i/1', 'autorouting', 'on');
add_line(model_name, '1//s (omega)/1', 'ToWS_omega/1', 'autorouting', 'on');

save_system(model_name);


%% ===================================================
%% MODELL 2: Testfragen-System F(s) = 5 / (2*s^2 + 8)
%% ===================================================
model_test = 'testfrage_system';
if bdIsLoaded(model_test)
    close_system(model_test, 0);
end
if exist([model_test '.slx'], 'file')
    delete([model_test '.slx']);
end
new_system(model_test);
open_system(model_test);

set_param(model_test, 'Solver', 'ode45', 'StopTime', '10', ...
                      'RelTol', '1e-6', 'AbsTol', '1e-7', 'MaxStep', '1e-3');

add_block('simulink/Sources/Step', [model_test '/Sprung (0 -> 5)'], ...
    'Time', '1', 'Before', '0', 'After', '5', ...
    'Position', [60, 100, 95, 130]);

add_block('simulink/Continuous/Transfer Fcn', [model_test '/F(s)'], ...
    'Numerator', '[5]', 'Denominator', '[2 0 8]', ...
    'Position', [165, 92, 265, 138]);

add_block('simulink/Signal Routing/Mux', [model_test '/Mux'], ...
    'Inputs', '2', ...
    'Position', [330, 85, 335, 135]);

add_block('simulink/Sinks/Scope', [model_test '/Scope'], ...
    'Position', [385, 94, 415, 126]);

add_line(model_test, 'Sprung (0 -> 5)/1', 'F(s)/1', 'autorouting', 'on');
add_line(model_test, 'Sprung (0 -> 5)/1', 'Mux/1', 'autorouting', 'on');
add_line(model_test, 'F(s)/1', 'Mux/2', 'autorouting', 'on');
add_line(model_test, 'Mux/1', 'Scope/1', 'autorouting', 'on');

save_system(model_test);
print(['-s' model_test], '-dpng', '-r300', 'V2_Ausarbeitung/simulink_testfrage.png');
disp('-> Simulink-Testfragenbild exportiert: V2_Ausarbeitung/simulink_testfrage.png');

add_block('simulink/Sinks/To Workspace', [model_test '/ToWS_u'], ...
    'VariableName', 'sim_test_u', 'SaveFormat', 'Timeseries', ...
    'Position', [320, 35, 380, 55]);
add_block('simulink/Sinks/To Workspace', [model_test '/ToWS_y'], ...
    'VariableName', 'sim_test_y', 'SaveFormat', 'Timeseries', ...
    'Position', [320, 165, 380, 185]);
add_line(model_test, 'Sprung (0 -> 5)/1', 'ToWS_u/1', 'autorouting', 'on');
add_line(model_test, 'F(s)/1', 'ToWS_y/1', 'autorouting', 'on');

save_system(model_test);

%% Export nach R2018b
try
    Simulink.exportToVersion('EI7_V2', 'EI7_V2_R2018b.slx', 'R2018b');
    Simulink.exportToVersion('testfrage_system', 'testfrage_system_R2018b.slx', 'R2018b');
catch ME
    warning('Export R2018b Warnung: %s', ME.message);
end

close_system('EI7_V2', 0);
close_system('testfrage_system', 0);
disp('=====================================================');
disp(' Modellbau und Bildexport abgeschlossen!');
disp('=====================================================');
