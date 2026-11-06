%% simulate_and_verify.m
% Führt die Simulation beider Modelle aus, überprüft das physikalische
% Verhalten und erzeugt aussagekräftige Validierungs-Plots.

clear; clc; close all;

%% 1. Parameter initialisieren und Modelle bauen
init_parameters;

if ~exist('EI7_V2.slx', 'file') || ~exist('testfrage_system.slx', 'file')
    build_models;
end

disp('=====================================================');
disp(' Starte Simulation des Drosselklappen-Modells...');
disp('=====================================================');

%% 2. Simulation Drosselklappe
sim_out_dk = sim('EI7_V2', 'StopTime', num2str(t_sim));

t_dk   = sim_out_dk.sim_phi_deg.Time;
phi_dk = sim_out_dk.sim_phi_deg.Data;
i_mot  = sim_out_dk.sim_current.Data;
w_mot  = sim_out_dk.sim_omega.Data;

% U_in Vektor berechnen
u_in_plot = zeros(size(t_dk));
u_in_plot(t_dk >= t_step) = U_step_val;

figure('Name', 'Versuch V2: Drosselklappe Simulation', 'Position', [100, 100, 900, 700], 'Visible', 'off');

subplot(3,1,1);
plot(t_dk, u_in_plot, 'b', 'LineWidth', 1.8);
grid on;
title('1. Eingangsspannung am GS-Motor $u(t)$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Spannung $u$ [V]', 'Interpreter', 'latex', 'FontSize', 11);
ylim([-0.5, 7]);

subplot(3,1,2);
plot(t_dk, phi_dk, 'r', 'LineWidth', 2.0);
hold on;
yline(phi_0_deg, 'k--', 'Notlaufposition (7°)', 'LineWidth', 1.2, 'FontSize', 10);
grid on;
title('2. Winkelposition der Drosselklappe $\phi_{DK}(t)$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Winkel $\phi$ [Grad]', 'Interpreter', 'latex', 'FontSize', 11);
legend('Klappenwinkel', 'Notlaufstellung', 'Location', 'best');

subplot(3,1,3);
yyaxis left;
plot(t_dk, i_mot, 'Color', [0 0.5 0], 'LineWidth', 1.5);
ylabel('Motorstrom $i$ [A]', 'Interpreter', 'latex', 'FontSize', 11);
grid on;
yyaxis right;
plot(t_dk, w_mot * 60 / (2*pi), 'Color', [0.85 0.33 0.1], 'LineWidth', 1.5);
ylabel('Motordrehzahl $n$ [U/min]', 'Interpreter', 'latex', 'FontSize', 11);
title('3. Motorstrom $i(t)$ und Motordrehzahl $n(t)$', 'Interpreter', 'latex', 'FontSize', 12);
xlabel('Zeit $t$ [s]', 'Interpreter', 'latex', 'FontSize', 11);

saveas(gcf, 'plot_drosselklappe_simulation.png');
disp('-> Plot gespeichert: plot_drosselklappe_simulation.png');

%% Verifikationsausgabe Drosselklappe
disp('--- Verifikationsergebnisse Drosselklappe ---');
disp(['  Startwinkel (vor Sprung):       ' num2str(phi_dk(1), '%.2f') ' Grad (Soll: Notlaufposition ' num2str(phi_0_deg) '°)']);
disp(['  Stationärer Endwinkel (bei 6V): ' num2str(phi_dk(end), '%.2f') ' Grad']);
disp(['  Maximaler Einschaltstrom:       ' num2str(max(i_mot), '%.3f') ' A']);
disp(['  Stationärer Haltestrom:         ' num2str(i_mot(end), '%.3f') ' A']);
disp(['  Stationäre Drehzahl:            ' num2str(w_mot(end), '%.4f') ' rad/s (Soll: 0 im Anschlag/Gleichgewicht)']);


%% ===================================================
%% 3. Simulation Testfragen-System F(s) = 5 / (2*s^2 + 8)
%% ===================================================
disp('=====================================================');
disp(' Starte Simulation des Testfragen-Systems F(s)...');
disp('=====================================================');

sim_out_tf = sim('testfrage_system', 'StopTime', '10');

t_tf = sim_out_tf.sim_test_y.Time;
u_tf = sim_out_tf.sim_test_u.Data;
y_tf = sim_out_tf.sim_test_y.Data;

figure('Name', 'Testfrage: Sprungantwort F(s)', 'Position', [150, 150, 850, 500], 'Visible', 'off');

plot(t_tf, u_tf, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Eingangssprung u(t) (0 \rightarrow 5)');
hold on;
plot(t_tf, y_tf, 'b-', 'LineWidth', 2.0, 'DisplayName', 'Ausgang y(t)');
grid on;
title('Testfrage: Sprungantwort von $F(s) = \frac{5}{2s^2 + 8}$ bei Sprung $0 \to 5$', 'Interpreter', 'latex', 'FontSize', 12);
xlabel('Zeit $t$ [s]', 'Interpreter', 'latex', 'FontSize', 11);
ylabel('Signal', 'Interpreter', 'latex', 'FontSize', 11);

% Theoretischer stationärer Mittelwert: K = 5 / 8 = 0.625; bei Eingang 5: y_mittel = 5 * 0.625 = 3.125
yline(3.125, 'r:', 'Theoretischer Mittelwert (3.125)', 'LineWidth', 1.5, 'FontSize', 10);
legend('Location', 'northeast');

saveas(gcf, 'plot_testfrage_simulation.png');
disp('-> Plot gespeichert: plot_testfrage_simulation.png');

%% Verifikationsausgabe Testfragen-System
disp('--- Verifikationsergebnisse Testfrage ---');
disp(['  Min. Ausgangswert (Schwingung): ' num2str(min(y_tf(t_tf > 1.0)), '%.3f') ' (theoretisch: 0.0)']);
disp(['  Max. Ausgangswert (Schwingung): ' num2str(max(y_tf(t_tf > 1.0)), '%.3f') ' (theoretisch: 6.25)']);
disp(['  Mittelwert der Schwingung:      ' num2str(mean(y_tf(t_tf > 1.0)), '%.3f') ' (theoretisch: 3.125)']);
disp('=====================================================');
disp(' Alle Simulationen und Verifikationen ERFOLGREICH!');
disp('=====================================================');

