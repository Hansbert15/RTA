% Continental-Drosselklappe Typ xxx 2011
% Bestimmung der Uebertragungsfunktion

% Bitte ersetzen Sie "..." entsprechend. Siehe auch  "Einführung Matlab/Simulink" in "Moodle"


z_1 = [0.4]                  % Uebertragungsfunktion (TF) Anker (R, L) Spannung -> Strom
n_1 = [0.0006 1]
F1  = tf(z_1, n_1)

F2  = 0.03                   % TF (= Verstaerkung) Strom -> Moment

z_3 = [1]                    % TF Moment -> Beschleunigung -> Winkelgeschwindigkeit
n_3 = [8e-6 0]
F3  = tf(...)

F123 = F1*...              % Reihenschaltung der der drei TF

F4  = ...                   % TF (= Verstaerkung) EMK

F1234 = ...(F123, F4)   % Kreisstruktur (EMK im Rueckfuehrzweig)

z_5 = [...]   % Winkelgeschwindigkeit -> Motorposition -> Klappenposition in Grad
n_5 = [...]
F5  = ...

F12345 = ...            % Strecke, ohne Regler
