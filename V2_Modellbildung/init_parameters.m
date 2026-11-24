%% init_parameters.m
% Initialisierungsskript für Versuch V2: Modellbildung Drosselklappe
% Praktikum RTA / PRTA - Prof. Dr. Brüdigam
% Gruppe 5: Johannes Wutz, Oliver Grundmann, Eduardo Llama

clear; clc;

disp('=====================================================');
disp(' Initialisiere Parameter für Versuch V2 Drosselklappe');
disp('=====================================================');

%% 1. Elektrische Parameter des permanenterregten GS-Motors
R_A     = 2.5;              % [Ohm]  Ankerwiderstand (im Stillstand an verschied. Winkeln gemessen)
T_el    = 0.625e-3;         % [s]    Elektrische Zeitkonstante (aus Oszi-Sprungantwort: 0.625 ms, bzw. ~0.7 ms)
L_A     = R_A * T_el;       % [H]    Ankerinduktivität L = R * tau = 1.56 mH (bzw. 1.75 mH bei 0.7 ms)

%% 2. Elektromechanische Kopplung (Mitschriften / Messungen)
k_Mot   = 0.027;            % [Nm/A]   Motormomentkonstante c * Phi_E (aus Kraft-/Strommessung: 0.027 Nm/A)
k_EMK   = 0.030;            % [Vs/rad] Generatorische EMK-Konstante (aus Oszi-Aufnahmen: ~0.030 Vs/rad)

%% 3. Mechanische Parameter (auf Motorwelle bezogen)
J_ges   = 7.2e-6;           % [kg*m^2] Massenträgheitsmoment des Rotors (7.2e-6 kg*m^2)
M_R     = 0.008;            % [Nm]     Gleitreibmoment bezogen auf Motorwelle (0.008 Nm = 8 mNm)

%% 4. Getriebe & Winkelumrechnung
i_Getr  = 20.0;             % Untersetzungsverhältnis i = 20
K_Gr    = 1.0 / i_Getr;     % Faktor Getriebe K_Gr = 0.05
K_deg   = 180.0 / pi;       % Umrechnung rad -> deg (57.2958 deg/rad)

%% 5. Federmodell (Notlauffeder / Rückstellfeder bezogen auf Motorwelle)
phi_0_deg = 7.5;            % [deg] Notlaufposition (NLP = 7.5°)
phi_0_rad = phi_0_deg * pi / 180.0; % [rad]

% Eckwerte der Federkennlinie bezogen auf die Motorwelle (aus Mitschriften: 0.015 Nm bei NLP, 0.022 Nm bei 90°)
M_F_NLP   = 0.015;          % [Nm] Federvorspannmoment an der Notlaufposition (7.5°)
M_F_90    = 0.022;          % [Nm] Federmoment am oberen Anschlag (90°)
c_F_deg   = (M_F_90 - M_F_NLP) / (90.0 - phi_0_deg); % [Nm/deg] Steigung an Motorwelle

% Lookup-Table für Federkennlinie inkl. steifer Anschläge bei 0° und 90°
% (Verhindert Weiterdrehen über 90° hinaus und modelliert den Momentensprung bei NLP = 7.5°)
feder_phi_lut = [-0.5,   0.0,    7.4,    7.5,    7.6,    90.0,   90.1,  91.0];
feder_M_lut   = [-0.20, -0.022, -0.015,  0.000,  0.015,  0.022,  0.15,  0.50];

% Lookup-Table für Coulomb-Reibung (0.008 Nm entgegen der Drehrichtung)
reib_w_lut    = [-1000, -0.5,  0.0,  0.5,  1000];
reib_M_lut    = [-M_R,  -M_R,  0.0,  M_R,  M_R];

%% 6. Simulations- und Eingangsparameter
U_step_val = 6.0;           % [V] Sprungspannung (0 -> 6 V)
t_step     = 0.05;          % [s] Sprung nach 50 ms Vorlauf (entspricht t = 0 ms im Oszilloskop-Plot -50..450 ms)
t_sim      = 0.50;          % [s] Gesamtsimulationsdauer 500 ms (-50 ms bis +450 ms)

disp('Parameter erfolgreich im MATLAB-Workspace definiert!');
