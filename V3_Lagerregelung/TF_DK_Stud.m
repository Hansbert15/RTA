

clear; close all; clc;


%
% 1) Mechanische Messungen
%    - Hebelarm an der Klappe: r = 29,35 mm = 0,02935 m
%    - Notlaufposition (NLP):  phi_0 = 7,5 deg (im Modell: 7 deg)
%    - Gesamtkraft (Feder + Reibung) beim Oeffnen:
%        bei NLP (7,5 deg): F_ges = 14,5 N (bzw. 15 N -> 0,44 Nm)
%        bei 45 deg:        F_ges = 15,0 N (bzw. 16 N -> 0,46 Nm)
%        bei 90 deg:        F_ges = 18,0 N (-> 0,53 Nm)
%    - Reine Federkraft / Federmoment an der Klappenwelle:
%        bei NLP (7,5 deg): F_F = 4,5 N  -> M_F0,DK = 4,5 N * 29,35 mm = 132,08 mNm = 0,132 Nm
%        bei 45 deg:        F_F = 6,0 N  -> M_F(45) = 6,0 N * 29,35 mm = 176,10 mNm = 0,176 Nm
%        bei 90 deg:        F_F = 8,0 N  -> M_F(90) = 8,0 N * 29,35 mm = 234,80 mNm = 0,235 Nm
%        Federsteifigkeit (Steigung): D = c_F,DK = 1,24 mNm/deg = 0,00124 Nm/deg
%    - Reibkraft / Reibmoment an der Klappenwelle:
%        F_R = F_ges - F_F = 10 N (bei NLP), 9 N (bei 45 deg), 10 N (bei 90 deg)
%        Mittelwert F_R = 9,67 N -> M_R,DK = 9,67 N * 29,34 mm = 283,62 mNm = 0,284 Nm
%    - Motorkonstante aus Kraftmessung bei 45 deg (I = 0,44 A, Delta_F = 3 N):
%        M_DK = 3 N * 0,02935 m = 0,08805 Nm -> bezogen auf Klappe: k_m,DK = 0,20 Nm/A
%        (in Mappe1.xlsx ausserdem km = 0,3; im V2-Modell EI7_V2.slx am Motor:
%         k1_Motormoment = k2_EMK = 0,045 Nm/A, k3_Reibung = 0,002 Nm, k4_Feder = 0,0018 Nm/deg)
%    - Hinweis: Fuer die lineare Uebertragungsfunktion der Strecke (Aufgabe 1.3)
%      werden die Nichtlinearitaeten Feder und Reibung vernachlaessigt!
%
% 2) Elektrische & dynamische Streckenparameter:
%    - MODUS 1 ('V3_Vorlage'): Offizielle Zahlenwerte der Vorlage TF_DK_Stud.m
%      und des Labor-Simulinkmodells DK_V3.slx (aus Kap. 2.3 / 2.3.2):
%        R_A = 2,5 Ohm (1/R_A = 0,4 A/V), T_el = L_A/R_A = 0,0006 s (L_A = 1,5 mH)
%        k_Mot = k_EMK = 0,03 Nm/A (bzw. Vs/rad), J = 8e-6 kg*m^2
%        Getriebe K_Gr = 1/20 = 0,05, Umrechnung rad -> deg: 180/pi
%    - MODUS 2 ('V2_Modell'): Parameter aus unserem V2-Simulink-Modell EI7_V2.slx:
%        R_A = 10 Ohm (1/R_A = 0,1 A/V), T_el = L_A/R_A = 0,0005 s (L_A = 5 mH)
%        k_Mot = k_EMK = 0,045 Nm/A, J = 2,5e-5 kg*m^2, K_Gr = 1/20 = 0,05

PARAMETER_MODUS = 'V3_Vorlage'; % 'V3_Vorlage' (Standard fuer V3) oder 'V2_Modell'

%% 1. UEBERTRAGUNGSFUNKTION DER STRECKE (OHNE FEDER & REIBUNG)
if strcmpi(PARAMETER_MODUS, 'V3_Vorlage')
    % --- Vorlage-Werte aus TF_DK_Stud.m / DK_V3.slx ---
    z_1 = [0.4];                 % Uebertragungsfunktion (TF) Anker (R, L) Spannung -> Strom (1/R = 0.4)
    n_1 = [0.0006 1];            % T_el = L/R = 0.0006 s
    F2  = 0.03;                  % TF (= Verstaerkung) Strom -> Moment (k_Mot [Nm/A])
    z_3 = [1];                   % TF Moment -> Beschleunigung -> Winkelgeschwindigkeit
    n_3 = [8e-6 0];              % J*s mit J = 8e-6 kg*m^2
    F4  = 0.03;                  % TF (= Verstaerkung) EMK (k_EMK = k_Mot [Vs/rad])
    K_Gr = 0.05;                 % Getriebeuebersetzung 1/i = 1/20 = 0.05
else
    % --- Werte aus eigenem V2-Simulink-Modell (EI7_V2.slx) ---
    z_1 = [0.1];                 % 1/R_A = 1/10 Ohm = 0.1 A/V
    n_1 = [0.0005 1];            % T_el = L_A/R_A = 5mH / 10Ohm = 0.0005 s
    F2  = 0.045;                 % k1_Motormoment = 0.045 Nm/A
    z_3 = [1];                   % 1
    n_3 = [2.5e-5 0];            % J*s mit J = 2.5e-5 kg*m^2
    F4  = 0.045;                 % k2_EMK = 0.045 Vs/rad
    K_Gr = 1/20;                 % Getriebe_1_durch_i = 0.05
end

% 1.1 Ankerkreis: U_eff(s) -> I_Mot(s)
F1  = tf(z_1, n_1)

% 1.2 Motormoment: I_Mot(s) -> M_Mot(s)
% F2 ist bereits oben als Verstaerkung definiert

% 1.3 Mechanik (Traegheit + Integration): M_eff(s) -> omega_Mot(s)
F3  = tf(z_3, n_3)

% 1.4 Reihenschaltung im Vorwaertszweig des Motors: U_eff(s) -> omega_Mot(s)
F123 = F1 * F2 * F3          % Reihenschaltung der drei TF

% 1.5 Gegen-EMK im Rueckfuehrzweig: omega_Mot(s) -> U_EMK(s)
% F4 ist bereits oben definiert (F4 = k_EMK)

% 1.6 Geschlossene innere Motorschleife: U_Mot(s) -> omega_Mot(s)
F1234 = feedback(F123, F4)   % Kreisstruktur (EMK im Rueckfuehrzweig, Gegenkopplung)

% 1.7 Integration auf Motorwinkel + Getriebe + Umrechnung rad -> Grad:
%     omega_Mot(s) -> phi_Mot(s) = 1/s * omega_Mot(s)
%     phi_DK_deg(s) = (1/s) * K_Gr * (180/pi) * omega_Mot(s)
z_5 = [K_Gr * 180 / pi];     % Winkelgeschwindigkeit -> Motorposition -> Klappenposition in Grad
n_5 = [1 0];                 % Integrator 1/s
F5  = tf(z_5, n_5)

% 1.8 Gesamtuebertragungsfunktion der linearen Strecke (ohne Regler):
%     U_Mot(s) -> phi_DK_deg(s)
F12345 = F1234 * F5          % Strecke, ohne Regler

fprintf('=== Polstellen der ungeregelten Strecke F12345 ===\n');
disp(pole(F12345));



% Ergaenzen der Strecke um einen P-Regler mit Verstaerkung K_P = 1:
F_R_P = 1;
Fo_P  = F_R_P * F12345;      % Offener Regelkreis mit P-Regler (K_P = 1)

% Optimale Reglerverstaerkung K_P fuer schnellstes aperiodisches Einschwingen
% (Verzweigungspunkt der dominanten Pole bei Daempfung D = 1):
[r_P, k_P_vec] = rlocus(Fo_P, linspace(0, 0.2, 5000));
idx_branch_P = find(abs(imag(r_P(2,:))) > 1e-4, 1, 'first') - 1;
if isempty(idx_branch_P) || idx_branch_P < 1
    idx_branch_P = 1;
end
K_P_opt  = k_P_vec(idx_branch_P);
s_P_opt  = real(r_P(2, idx_branch_P));

fprintf('=== P-Regler Auslegung (WOK) ===\n');
fprintf('Optimale P-Verstaerkung (D = 1, schnellstes Einschwingen ohne Ueberschwingen):\n');
fprintf('  K_P,opt = %.4f V/deg  (Doppelpol bei s = %.2f s^-1)\n\n', K_P_opt, s_P_opt);

figure('Name', 'Wurzelortskurve P-Regler', 'Color', 'w');
rlocus(Fo_P);
grid on;
title('Wurzelortskurve des offenen Regelkreises mit P-Regler (Fo\_P)');


%% 3. AUFGABE 2.3.2: PIDT1-REGLER (PARAMETER: K, T, TN, TV)
% Beschreibung des Simulink PIDT1-Reglers laut Anleitung Kap. 2.3.2:
%   F_R(s) = P + I*(1/s) + D*s / ((1/N)*s + 1)
%          = K * ( 1 + 1/(T_N*s) + (T_V*s)/(T*s + 1) )
%          = K * ( (T*T_N + T_N*T_V)*s^2 + (T + T_N)*s + 1 ) / ( T*T_N*s^2 + T_N*s )
%
% Vorgaben aus Anleitung Kap. 2.3.2:
T   = 0.001;                 % Zeitkonstante D-Glied: T = 1.0 ms (Filterkoeffizient N = 1/T = 1000)
sN1 = -10;                   % Gewaehlte Reglernullstelle 1
sN2 = -30;                   % Gewaehlte Reglernullstelle 2
K   = 1;                     % Normierte Verstaerkung fuer WOK-Darstellung

% Koeffizientenvergleich mit Zaehlerpolynom:
%   (T*T_N + T_N*T_V)*s^2 + (T + T_N)*s + 1 = Q * (s - sN1)*(s - sN2)
%                                           = Q * (s^2 + 40*s + 300)
Q  = 1 / (sN1 * sN2);        % Q = 1/300
TN = (- (sN1 + sN2)) * Q - T;% T + TN = 40/300  => TN = 40/300 - 0.001 = 0.13233 s
TV = (Q - T * TN) / TN;      % T*TN + TN*TV = 1/300 => TV = 0.02419 s

fprintf('=== PIDT1-Reglerparameter (Kap. 2.3.2) ===\n');
fprintf('  T   = %.5f s  (Filterkoeffizient N = 1/T = %.0f)\n', T, 1/T);
fprintf('  Q   = %.6f\n', Q);
fprintf('  T_N = %.5f s\n', TN);
fprintf('  T_V = %.5f s\n', TV);

% Uebertragungsfunktion des PIDT1-Reglers (mit K = 1):
z_R = [ (T*TN + TN*TV), (T + TN), 1 ];
n_R = [ (T*TN), TN, 0 ];
F_R_PIDT1 = K * tf(z_R, n_R)

% Offener Regelkreis mit PIDT1-Regler:
Fo = F_R_PIDT1 * F12345

% Geeignete Reglerverstaerkung K aus der WOK (Daempfung D = 1 bei s ≈ -16.4 s^-1):
K_PIDT1_opt = 0.0695;        % Aus WOK Kap. 2.3.2: Gain = 0.0695, Pole = -16.4, Damping = 1

% Umrechnung auf Simulink PID-Block Parameter (Parallele Form: P, I, D, N):
P_sim = K_PIDT1_opt;
I_sim = K_PIDT1_opt / TN;
D_sim = K_PIDT1_opt * TV;
N_sim = 1 / T;

fprintf('\nGeeignete Reglerverstaerkung aus WOK (D = 1, Pole bei s = -16.4 s^-1):\n');
fprintf('  K_opt = %.4f\n', K_PIDT1_opt);
fprintf('Umrechnung fuer Simulink PID-Controller Block (Parallelform):\n');
fprintf('  P = K       = %.5f\n', P_sim);
fprintf('  I = K / T_N = %.5f\n', I_sim);
fprintf('  D = K * T_V = %.6f\n', D_sim);
fprintf('  N = 1 / T   = %.1f\n', N_sim);

figure('Name', 'Wurzelortskurve PIDT1-Regler (Gesamt)', 'Color', 'w');
rlocus(Fo);
grid on;
title('Wurzelortskurve des offenen Regelkreises mit PIDT1-Regler (Fo)');

figure('Name', 'Wurzelortskurve PIDT1-Regler (Zoom auf dominante Pole)', 'Color', 'w');
rlocus(Fo);
grid on;
xlim([-35 0]);
ylim([-12 12]);
title('Wurzelortskurve PIDT1-Regler (Ausschnitt nahe Ursprung)');
