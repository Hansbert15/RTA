%% init_parameters.m
% Initialisierungsskript für Versuch V2: Modellbildung Drosselklappe
% Praktikum RTA / PRTA - Prof. Dr. Brüdigam

clear; clc;

disp('=====================================================');
disp(' Initialisiere Parameter für Versuch V2 Drosselklappe');
disp('=====================================================');

%% 1. Elektrische Parameter des permanenterregten GS-Motors
R_A     = 10.0;             % [Ohm]  Ankerwiderstand (typischer Wert ca. 8-12 Ohm)
L_A     = 5.0e-3;           % [H]    Ankerinduktivität (ca. 2 - 10 mH)
T_el    = L_A / R_A;        % [s]    Elektrische Zeitkonstante (~ 0.5 ms << T_mech)

%% 2. Elektromechanische Kopplung
% Im SI-Einheitensystem gilt theoretisch: k_Mot [Nm/A] = k_EMK [Vs/rad]
k_Mot   = 0.045;            % [Nm/A]   Drehmomentkonstante c * Phi_E
k_EMK   = 0.045;            % [Vs/rad] Generatorische EMK-Konstante

%% 3. Mechanische Parameter (auf Motorwelle bezogen)
J_ges   = 2.5e-5;           % [kg*m^2] Gesamtmassenträgheitsmoment (Anker + Getriebe + Klappe)
d_visk  = 8.0e-5;           % [Nm*s/rad] Viskoser Reibwert (geschwindigkeitslinear)
M_coul  = 0.003;            % [Nm]     Coulomb-Gleitreibung / Losbrechmoment an der Motorwelle

%% 4. Getriebe
% Untersetzungsverhältnis Motor zu Drosselklappe (Motor dreht schneller als Klappe)
i_Getr  = 20.0;             % Untersetzungsverhältnis i
K_Gr    = 1.0 / i_Getr;     % Faktor Getriebe = 1/i (omega_DK = K_Gr * omega_Mot)
K_deg   = 180.0 / pi;       % Umrechnung rad -> deg

%% 5. Federmodell (Notlauffeder / Rückstellfeder)
% Notlaufposition: bei unbestromtem Motor stellt Feder die Klappe auf phi_0
phi_0_deg   = 7.0;          % [deg] Notlauf-Öffnungswinkel
phi_0_rad   = phi_0_deg * pi / 180.0; % [rad]

% Federsteifigkeit (bezogen auf Motorwelle)
% M_F_mot = c_F_mot * (phi_mot - phi_0_mot)
c_F_deg     = 0.0015;       % [Nm/deg] Federrate an der Motorwelle
c_F_rad     = c_F_deg * (180.0 / pi); % [Nm/rad]

% Momentensprung an der Notlaufstellung (Nichtlinearität der vorgespannten Feder)
M_F0_mot    = 0.005;        % [Nm] Grundvorspannungsmoment an Notlaufposition

%% 6. Simulations- und Eingangsparameter
U_step_val  = 6.0;          % [V] Sprungspannung (max. 6 V wegen Zahnbruchgefahr!)
t_step      = 0.5;          % [s] Sprungzeitpunkt
t_sim       = 10.0;         % [s] Gesamtsimulationszeit

disp('Parameter erfolgreich im MATLAB-Workspace definiert!');
disp(['  Ankerwiderstand R:           ' num2str(R_A) ' Ohm']);
disp(['  Drehmomentkonstante k_Mot:   ' num2str(k_Mot) ' Nm/A']);
disp(['  EMK-Konstante k_EMK:         ' num2str(k_EMK) ' Vs/rad']);
disp(['  Getriebeuntersetzung i:      ' num2str(i_Getr)]);
disp(['  Notlaufwinkel phi_0:         ' num2str(phi_0_deg) ' deg']);

