# Praktikum PRTA – Versuch V3: Reglerentwurf Drosselklappe
**Prof. Dr. Brüdigam | OTH Regensburg**
**Gruppe 2: Johannes Wutz, Oliver Grundmann, Eduardo Llama**
**Vollständige Vorbereitung, m-File-Herleitung (inkl. Mitschriften aus V2), Simulationsergebnisse, Versuchsauswertung und Testfragen**

---

## 0. Zusammenfassung der Mitschriften und Ergebnisse aus Versuch V2

In Versuch V2 (*Modellbildung Drosselklappe*) wurden die physikalischen Parameter und Nichtlinearitäten der Drosselklappe messtechnisch bestimmt (siehe `v2.docx`, `Mappe1.xlsx` sowie `EI7_V2.slx`):

1. **Geometrie / Hebelarm:**
   - Gemessener Hebelarm an der Drosselklappe: $r = 29{,}35\,\mathrm{mm} = 0{,}02935\,\mathrm{m}$
   - Notlaufposition (NLP): $\phi_0 = 7{,}5^\circ$ (im V2-Simulink-Modell $\phi_0 = 7^\circ$, im V3-Labor-Muster $\phi_0 = 5^\circ$)
   - Getriebeuntersetzung: $i = 20 \implies K_{\mathrm{Gr}} = \frac{1}{i} = 0{,}05$

2. **Feder- und Reibungsmessung über Federwaage (`v2.docx` & `Mappe1.xlsx`):**
   - **Gesamtkraft (Feder + Reibung in Öffnungsrichtung):**
     - Bei Notlaufposition ($\phi_0 = 7{,}5^\circ$): $F_{\mathrm{ges}} = 14{,}5\,\mathrm{N}$ (bzw. $15\,\mathrm{N} \implies M_{\mathrm{ges}} \approx 0{,}44\,\mathrm{N\,m}$)
     - Bei $\phi = 45^\circ$: $F_{\mathrm{ges}} = 15{,}0\,\mathrm{N}$ (bzw. $16\,\mathrm{N} \implies M_{\mathrm{ges}} \approx 0{,}46\,\mathrm{N\,m}$)
     - Bei $\phi = 90^\circ$: $F_{\mathrm{ges}} = 18{,}0\,\mathrm{N}$ ($\implies M_{\mathrm{ges}} \approx 0{,}53\,\mathrm{N\,m}$)
   - **Reine Federkraft $F_F$ und Federmoment $M_{F,\mathrm{DK}} = F_F \cdot r$ an der Klappenwelle:**
     - Bei NLP ($7{,}5^\circ$): $F_F = 4{,}5\,\mathrm{N} \implies M_{F0,\mathrm{DK}} = 4{,}5\,\mathrm{N} \cdot 29{,}35\,\mathrm{mm} = 132{,}08\,\mathrm{mN\,m} \approx 0{,}132\,\mathrm{N\,m}$
     - Bei $45^\circ$: $F_F = 6{,}0\,\mathrm{N} \implies M_{F,\mathrm{DK}}(45^\circ) = 6{,}0\,\mathrm{N} \cdot 29{,}35\,\mathrm{mm} = 176{,}10\,\mathrm{mN\,m} \approx 0{,}176\,\mathrm{N\,m}$
     - Bei $90^\circ$: $F_F = 8{,}0\,\mathrm{N} \implies M_{F,\mathrm{DK}}(90^\circ) = 8{,}0\,\mathrm{N} \cdot 29{,}35\,\mathrm{mm} = 234{,}80\,\mathrm{mN\,m} \approx 0{,}235\,\mathrm{N\,m}$
     - **Federsteifigkeit (Steigung $D$ bzw. $c_{F,\mathrm{DK}}$):**
       $$c_{F,\mathrm{DK}} = \frac{\Delta M_{F,\mathrm{DK}}}{\Delta \phi} \approx 1{,}24\,\frac{\mathrm{mN\,m}}{^\circ} = 0{,}00124\,\frac{\mathrm{N\,m}}{^\circ}$$
       *(Auf die Motorwelle umgerechnet mit $K_{\mathrm{Gr}} = 0{,}05$: $M_{F0,\mathrm{mot}} \approx 0{,}0066\dots 0{,}025\,\mathrm{N\,m}$)*
   - **Reibkraft $F_R = F_{\mathrm{ges}} - F_F$ und Reibmoment $M_{R,\mathrm{DK}}$:**
     - $F_R(7{,}5^\circ) = 10\,\mathrm{N}$, $F_R(45^\circ) = 9\,\mathrm{N}$, $F_R(90^\circ) = 10\,\mathrm{N} \implies \bar{F}_R = 9{,}67\,\mathrm{N}$
     - $\bar{M}_{R,\mathrm{DK}} = 9{,}67\,\mathrm{N} \cdot 29{,}34\,\mathrm{mm} = 283{,}62\,\mathrm{mN\,m} \approx 0{,}284\,\mathrm{N\,m}$
       *(Auf die Motorwelle reduziert mit $K_{\mathrm{Gr}} = 0{,}05$: $M_{R,\mathrm{mot}} = 0{,}05 \cdot 0{,}284\,\mathrm{N\,m} \approx 0{,}0142\,\mathrm{N\,m}$; vgl. V3-Laborwert $0{,}01\,\mathrm{N\,m}$)*

3. **Motorkonstante und elektrische Parameter (aus `ausarbeitung_v2.pdf` & `init_parameters.m`):**
   - Aus Halteversuch bei $45^\circ$ (`v2.docx`): $I = 0{,}44\,\mathrm{A}$ bei $F = 3\,\mathrm{N} \implies k_{m,\mathrm{DK}} = 0{,}20\,\mathrm{N\,m/A}$ (bzw. $0{,}3\,\mathrm{N\,m/A}$ in `Mappe1.xlsx`).
   - Im finalen V2-Simulink-Modell (`EI7_V2.slx` / `ausarbeitung_v2.pdf`):
     $R_A = 2{,}5\,\Omega$ ($1/R_A = 0{,}4\,\mathrm{A/V}$), $T_{\mathrm{el}} = \frac{L_A}{R_A} = 0{,}625\,\mathrm{ms}$ ($L_A = 1{,}56\,\mathrm{mH}$, im Simulink-Block $0{,}7\,\mathrm{ms}$), $k_{\mathrm{Mot}} = 0{,}027\,\mathrm{N\,m/A}$, $k_{\mathrm{EMK}} = 0{,}030\,\mathrm{V\,s/rad}$, $J \approx J_{\mathrm{Rotor}} = 7{,}2 \cdot 10^{-6}\,\mathrm{kg\,m^2}$, $K_{\mathrm{Gr}} = \frac{1}{20} = 0{,}05$, $M_{R,\mathrm{Mot}} = 0{,}008\,\mathrm{N\,m}$, $M_{F,\mathrm{Mot}} = 0{,}015\dots 0{,}022\,\mathrm{N\,m}$ ($\phi_{\mathrm{NLP}} = 7{,}5^\circ$).
   - In der V3-Musterdatei (`TF_DK_Stud.m` / `DK_V3.slx`):
     $R_A = 2{,}5\,\Omega$ ($1/R_A = 0{,}4\,\mathrm{A/V}$), $T_{\mathrm{el}} = \frac{L_A}{R_A} = 0{,}0006\,\mathrm{s}$ ($L_A = 1{,}5\,\mathrm{mH}$), $k_{\mathrm{Mot}} = k_{\mathrm{EMK}} = 0{,}03\,\mathrm{N\,m/A}$, $J = 8 \cdot 10^{-6}\,\mathrm{kg\,m^2}$, $K_{\mathrm{Gr}} = 0{,}05$.

> [!TIP]
> In [TF_DK_Stud.m](file:///c:/Users/johan/Lokal/RTA/RTA/V3_Lagerregelung/TF_DK_Stud.m) sind **beide Parametersätze** vollständig dokumentiert und über den Schalter `PARAMETER_MODUS` (`'V3_Vorlage'` vs. `'V2_Modell'`) direkt umschaltbar. Standardmäßig ist `'V3_Vorlage'` aktiv, damit die Ergebnisse exakt zu den Musterdateien des Labor-PCs in V3 passen.

---

## 1. Vorbereitung zu Hause (Kapitel 1.3)

### 1.1 Anforderungen an die Drosselklappenlageregelung

Für das elektronische Gaspedal (E-Gas) eines Ottomotors gelten im Fahrzeugeinsatz hohe dynamische und stationäre Anforderungen:

| Kriterium | Erwartete Anforderung | Physikalisch-technische Begründung |
| :--- | :--- | :--- |
| **Genauigkeit** | **Sehr hohe stationäre Genauigkeit** (bleibende Regelabweichung $e_\infty \to 0^\circ$, Toleranz typ. $< 0{,}1^\circ \dots 0{,}5^\circ$). | Bereits kleinste Winkelabweichungen verändern – insbesondere im Leerlauf und Teillastbereich – den Luftmassenstrom erheblich, was zu Drehzahlschwankungen, unruhigem Motorlauf oder erhöhten Emissionen führt. |
| **Überschwingen** | **Minimales bzw. kein Überschwingen** (idealerweise aperiodisches Einschwingen mit Dämpfung $D \ge 1$, maximal $< 1\dots 2\,\%$). | 1. **Mechanischer Schutz:** Nahe der Endanschläge ($0^\circ$ und $90^\circ$) würde ein Überschwingen zum harten Anschlagen der Klappe führen (Gefahr von Getriebeschäden/Zahnbruch).<br>2. **Fahrkomfort:** Ein Überschwingen der Klappe erzeugt einen ungewollten Drehmomentstoß des Verbrennungsmotors (Ruckeln).<br>3. **Nichtlinearität:** Bei Richtungswechsel im Überschwingen greift sofort die Haft-/Coulombreibung und führt zu Grenzzyklen (Stick-Slip). |
| **Geschwindigkeit** | **Sehr hohe Stellgeschwindigkeit** (Anstiegs-/Ausregelzeit $t_{\mathrm{ein}} \approx 50\,\mathrm{ms} \dots 150\,\mathrm{ms}$ für große Sprünge). | Der Fahrer erwartet beim Betätigen des Gaspedals ein verzögerungsfreies Ansprechen des Motors. Zudem nutzen moderne Motorsteuerungen die Drosselklappe für schnelle Leerlauf- und Momenteneingriffe (z.B. ESP/ASR, Schaltvorgänge). |

---

### 1.2 Herleitung des MATLAB m-Files `TF_DK_Stud.m` (Lineare Streckenübertragungsfunktion)

Unter Vernachlässigung der Nichtlinearitäten (Notlauffeder $M_F = 0$ und Reibung $M_R = 0$) besteht die Strecke aus fünf Teilübertragungsfunktionen:

1. **Ankerkreis (`F1` – Spannung $U_{\mathrm{eff}} \to$ Motorstrom $I_{\mathrm{Mot}}$):**
   $$F_1(s) = \frac{I_{\mathrm{Mot}}(s)}{U_{\mathrm{eff}}(s)} = \frac{1/R_A}{T_{\mathrm{el}}\,s + 1} = \frac{0{,}4}{0{,}0006\,s + 1}$$
   ```matlab
   z_1 = [0.4];
   n_1 = [0.0006 1];
   F1  = tf(z_1, n_1);
   ```

2. **Motormoment (`F2` – Strom $I_{\mathrm{Mot}} \to$ Drehmoment $M_{\mathrm{Mot}}$):**
   $$F_2(s) = k_{\mathrm{Mot}} = 0{,}03\,\frac{\mathrm{N\,m}}{\mathrm{A}}$$
   ```matlab
   F2  = 0.03;
   ```

3. **Mechanik (`F3` – Drehmoment $M_{\mathrm{eff}} \to$ Winkelbeschleunigung $\dot{\omega} \to$ Winkelgeschwindigkeit $\omega_{\mathrm{Mot}}$):**
   $$F_3(s) = \frac{\Omega_{\mathrm{Mot}}(s)}{M_{\mathrm{eff}}(s)} = \frac{1}{J \cdot s} = \frac{1}{8 \cdot 10^{-6}\,s}$$
   ```matlab
   z_3 = [1];
   n_3 = [8e-6 0];
   F3  = tf(z_3, n_3);
   ```

4. **Reihenschaltung im Vorwärtszweig (`F123`):**
   $$F_{123}(s) = F_1(s) \cdot F_2(s) \cdot F_3(s) = \frac{0{,}012}{4{,}8 \cdot 10^{-9}\,s^2 + 8 \cdot 10^{-6}\,s}$$
   ```matlab
   F123 = F1 * F2 * F3;
   ```

5. **Gegen-EMK im Rückführzweig (`F4`) und geschlossene Motorschleife (`F1234`):**
   Mit $F_4 = k_{\mathrm{EMK}} = 0{,}03\,\mathrm{V\,s/rad}$ ergibt sich über den `feedback`-Befehl:
   $$F_{1234}(s) = \frac{F_{123}(s)}{1 + F_{123}(s) \cdot F_4} = \frac{0{,}012}{4{,}8 \cdot 10^{-9}\,s^2 + 8 \cdot 10^{-6}\,s + 0{,}00036}$$
   ```matlab
   F4    = 0.03;
   F1234 = feedback(F123, F4);
   ```

6. **Winkelintegration, Getriebe und Umrechnung in Grad (`F5` – $\omega_{\mathrm{Mot}} \to \phi_{\mathrm{DK}}\,[^\circ]$):**
   $$\Phi_{\mathrm{DK,deg}}(s) = \frac{1}{s} \cdot K_{\mathrm{Gr}} \cdot \frac{180^\circ}{\pi} \cdot \Omega_{\mathrm{Mot}}(s) \implies F_5(s) = \frac{0{,}05 \cdot \frac{180}{\pi}}{s} = \frac{2{,}8648}{s}$$
   ```matlab
   z_5 = [0.05 * 180 / pi];
   n_5 = [1 0];
   F5  = tf(z_5, n_5);
   ```

7. **Gesamtübertragungsfunktion der linearen Strecke ohne Regler (`F12345`):**
   $$F_{12345}(s) = F_{1234}(s) \cdot F_5(s) = \frac{0{,}03438}{4{,}8 \cdot 10^{-9}\,s^3 + 8 \cdot 10^{-6}\,s^2 + 0{,}00036\,s}$$
   ```matlab
   F12345 = F1234 * F5;
   ```
   **Polstellen der ungeregelten Strecke ($IT_2$-Verhalten):**
   - $s_{P1} = 0\,\mathrm{s^{-1}}$ (freier Integrator: Übergang von Drehzahl auf Winkelposition)
   - $s_{P2} = -46{,}29\,\mathrm{s^{-1}}$ (dominanter elektromechanischer Motorpol, $\tau_{\mathrm{mech}} \approx 21{,}6\,\mathrm{ms}$)
   - $s_{P3} = -1620{,}38\,\mathrm{s^{-1}}$ (schneller elektrischer Ankerpol, $\tau_{\mathrm{el}} \approx 0{,}62\,\mathrm{ms}$)

---

## 2. Versuchsdurchführung & Reglerauslegung (Kapitel 2.3)

### 2.1 Regelkreis mit P-Regler (Kapitel 2.3 & 2.3.1)

#### Wurzelortskurve und optimale Reglerverstärkung $K_{P,\mathrm{opt}}$
Ergänzt man die Strecke um einen P-Regler mit $K_P = 1$ ($F_{o,P}(s) = 1 \cdot F_{12345}(s)$) und zeichnet die Wurzelortskurve mit `rlocus(Fo_P)`, so laufen die beiden dominanten reellen Pole $s_{P1} = 0$ und $s_{P2} = -46{,}29\,\mathrm{s^{-1}}$ mit wachsendem $K_P$ aufeinander zu.

![WOK P-Regler](file:///c:/Users/johan/Lokal/RTA/RTA/V3_Lagerregelung/plot_v3_wok_p_regler.png)

- **Optimaler Punkt (schnellstes Einschwingen ohne Überschwingen, $D = 1$):**
  Am Verzweigungspunkt $s_{1,2} = -22{,}98\,\mathrm{s^{-1}}$ treffen sich die beiden reellen Pole, bevor sie als konjugiert-komplexes Polpaar in die komplexe Ebene abbiegen.
- **Zugehörige optimale Reglerverstärkung aus der WOK:**
  $$K_{P,\mathrm{opt}} = \mathbf{0{,}1195\,\frac{\mathrm{V}}{^\circ}} \quad (\text{Doppelpol bei } s_{1,2} = -22{,}98\,\mathrm{s^{-1}}, \text{ Dämpfung } D = 1)$$

---

#### Verhalten in der nichtlinearen Simulink-Simulation (Sprung $10^\circ \to 60^\circ$)

Simuliert man das reale, nichtlineare Simulink-Modell [DK_V3.slx](file:///c:/Users/johan/Lokal/RTA/RTA/V3_Lagerregelung/DK_V3.slx) (mit Notlauffeder und Reibung) für einen Sollwertsprung von $10^\circ$ auf $60^\circ$, zeigt sich folgendes Verhalten:

![Simulation P-Regler](file:///c:/Users/johan/Lokal/RTA/RTA/V3_Lagerregelung/plot_v3_sim_p_regler.png)

1. **Welche Probleme erkennen Sie?**
   - **Massive bleibende Regelabweichung ($e_\infty \neq 0$):** Mit der aus der linearen WOK ermittelten Verstärkung $K_{P,\mathrm{opt}} = 0{,}1195\,\mathrm{V/^\circ}$ bleibt die Klappe bereits bei $\phi_\infty = \mathbf{36{,}96^\circ}$ stehen! Es verbleibt ein stationärer Fehler von $e_\infty = 60^\circ - 36{,}96^\circ = \mathbf{23{,}04^\circ}$.
   - **Zielkonflikt bei Erhöhung von $K_P$:** Erhöht man $K_P$ (z.B. auf $K_P = 0{,}5$ oder $K_P = 2{,}0$), sinkt zwar die bleibende Regelabweichung ($\phi_\infty = 55{,}6^\circ$ bzw. $58{,}85^\circ$), aber die Pole wandern ins Komplexe ($D < 1$) und die Klappe beginnt deutlich überzuschwingen ($\phi_{\mathrm{max}} = 64{,}3^\circ$ bei $K_P = 2{,}0$).

2. **Was sind die Ursachen?**
   - Obwohl die lineare Strecke einen Integrator enthält (Winkel = Integral der Drehzahl), greifen **vor** diesem Integrator an der Momentensummierstelle zwei massive stationäre Störmomente an:
     1. **Vorgespannte Notlauffeder ($M_F$):** Zieht die Klappe permanent mit $M_F \approx 0{,}025 \dots 0{,}029\,\mathrm{N\,m}$ (am Motor) Richtung Notlaufposition ($5^\circ$) zurück. Um allein dieses Federmoment bei $60^\circ$ ($M_F \approx 0{,}0276\,\mathrm{N\,m}$) im Stillstand ($\omega = 0$) zu halten, benötigt der Motor einen Dauerstrom von $I_{\mathrm{halt}} = \frac{M_F}{k_{\mathrm{Mot}}} = \frac{0{,}0276}{0{,}03} = 0{,}92\,\mathrm{A}$ und damit eine Dauerspannung von $U_{\mathrm{halt}} = R_A \cdot I_{\mathrm{halt}} = 2{,}5\,\Omega \cdot 0{,}92\,\mathrm{A} \approx \mathbf{2{,}30\,\mathrm{V}}$.
     2. **Haft-/Coulomb-Reibung ($M_R = \pm 0{,}01\,\mathrm{N\,m}$):** Sobald die Bewegung abgebremst wird und die Motorspannung unter die Summe aus Feder- und Reibmoment fällt ($|M_{\mathrm{el}} - M_F| \le M_R$), bleibt die Klappe in einer **Totzone (Haftreibungsband)** stecken.
   - Da ein P-Regler die Stellspannung nur gemäß $U_{\mathrm{Mot}} = K_P \cdot e$ erzeugt, **muss** im stationären Zustand zwingend eine Regelabweichung $e_\infty = \frac{M_F(\phi_\infty) \pm M_R}{K_P \cdot k_{\mathrm{Mot}} / R_A} > 0$ übrig bleiben!

3. **Wie können Sie das Verhalten verbessern? Welche Verstärkung / welche anderen Regler kommen in Frage?**
   - **Beim reinen P-Regler:** Keine Verstärkung $K_P$ kann gleichzeitig $e_\infty = 0$ und Überschwingfreiheit garantieren. Ein Kompromiss liegt bei ca. $K_P \approx 0{,}4 \dots 0{,}5\,\mathrm{V/^\circ}$ (schneller Anstieg ohne Überschwingen über $60^\circ$, jedoch immer noch $\approx 4{,}4^\circ$ bleibende Abweichung).
   - **Andere Regler:**
     - **I-Anteil erforderlich (PI- oder PID / $\text{PIDT}_1$-Regler):** Ein Integrator im Regler integriert die Regelabweichung so lange auf, bis die nötige Haltespannung für die Notlauffeder ($U_{\mathrm{halt}} \approx 2{,}3\,\mathrm{V}$) bei $e_\infty = 0$ bereitgestellt wird.
     - **D-Anteil erforderlich ($\text{PIDT}_1$-Regler):** Da Strecke + I-Regler zwei Pole im Ursprung ($s_{P1,2} = 0$) besitzen, wäre ein reiner PI-Regler sehr langsam oder schwingungsanfällig. Ein **$\text{PIDT}_1$-Regler** steuert zwei frei platzierbare Nullstellen bei, die die Wurzelortskurve weit in die stabile linke Halbebene ziehen.
     - **Zusätzlich (Strukturverbesserung):** **Störgrößenaufschaltung / Vorsteuerung der bekannten Federkennlinie** ($U_{\mathrm{Vor}}(\phi_{\mathrm{soll}}) = \frac{R_A}{k_{\mathrm{Mot}}} \cdot M_F(\phi_{\mathrm{soll}}) \approx 2{,}3\,\mathrm{V}$).

---

### 2.2 $\text{PIDT}_1$-Regler (Kapitel 2.3.2)

#### Parameterberechnung ($K, T, T_N, T_V$) aus vorgegebenen Nullstellen

Die Übertragungsfunktion des Simulink-$\text{PIDT}_1$-Reglers lautet:
$$F_R(s) = P + I \frac{1}{s} + \frac{D\,s}{(1/N)\,s + 1} = K \left( 1 + \frac{1}{T_N\,s} + \frac{T_V\,s}{T\,s + 1} \right) = K \cdot \frac{(T\,T_N + T_N\,T_V)\,s^2 + (T + T_N)\,s + 1}{T\,T_N\,s^2 + T_N\,s}$$

**Vorgaben laut Anleitung Kap. 2.3.2:**
- Filterzeitkonstante des D-Anteils: $T = 0{,}001\,\mathrm{s} = 1{,}0\,\mathrm{ms}$ ($\implies N = \frac{1}{T} = 1000\,\mathrm{s^{-1}}$)
- Gewünschte Reglernullstellen: $s_{N1} = -10\,\mathrm{s^{-1}}$ und $s_{N2} = -30\,\mathrm{s^{-1}}$

**Koeffizientenvergleich des Zählerpolynoms:**
$$(T\,T_N + T_N\,T_V)\,s^2 + (T + T_N)\,s + 1 \stackrel{!}{=} Q \cdot (s - s_{N1})(s - s_{N2}) = Q \cdot (s + 10)(s + 30) = Q \cdot (s^2 + 40\,s + 300)$$

1. **Absolutglied ($s^0$):**
   $$300 \cdot Q = 1 \implies Q = \frac{1}{300} \approx 0{,}003333\,\mathrm{s^2}$$
2. **Lineares Glied ($s^1$):**
   $$T + T_N = 40 \cdot Q = \frac{40}{300} = 0{,}13333\,\mathrm{s} \implies T_N = \frac{40}{300} - 0{,}001 = \mathbf{0{,}13233\,\mathrm{s}}$$
3. **Quadratisches Glied ($s^2$):**
   $$T\,T_N + T_N\,T_V = Q = \frac{1}{300} \implies T_V = \frac{\frac{1}{300} - T \cdot T_N}{T_N} = \frac{0{,}003333 - 0{,}001 \cdot 0{,}13233}{0{,}13233} = \mathbf{0{,}02419\,\mathrm{s}}$$

---

#### Wurzelortskurve und Verstärkung $K$ des $\text{PIDT}_1$-Reglers

![WOK PIDT1-Regler](file:///c:/Users/johan/Lokal/RTA/RTA/V3_Lagerregelung/plot_v3_wok_pidt1_regler.png)

- Der Doppelpol im Ursprung ($s_{P1,2} = 0$, aus Strecke + I-Anteil) spaltet sich sofort in ein konjugiert-komplexes Polpaar auf, das von den beiden Reglernullstellen ($s_{N1} = -10$, $s_{N2} = -30$) angezogen wird und zwischen ihnen bei $s \approx -16{,}4\,\mathrm{s^{-1}}$ wieder auf die negative reelle Achse einmündet.
- **Auslegungspunkt für aperiodisches Einschwingen ($D = 1$, $0\,\%$ Overshoot im linearen Modell):**
  $$K_{\mathrm{WOK}} = \mathbf{0{,}0695} \quad (\text{reeller Doppelpol bei } s = -16{,}4\,\mathrm{s^{-1}})$$
- **Umrechnung für den Simulink-PID-Block (Parallelform $P, I, D, N$):**
  - $P = K = \mathbf{0{,}0695}$
  - $I = \frac{K}{T_N} = \frac{0{,}0695}{0{,}13233} = \mathbf{0{,}5252\,\mathrm{s^{-1}}}$
  - $D = K \cdot T_V = 0{,}0695 \cdot 0{,}02419 = \mathbf{0{,}001681\,\mathrm{s}}$
  - $N = \frac{1}{T} = \mathbf{1000\,\mathrm{s^{-1}}}$

---

#### Simulation des $\text{PIDT}_1$-geregelten Systems & kritische Bewertung

![Simulation PIDT1-Regler](file:///c:/Users/johan/Lokal/RTA/RTA/V3_Lagerregelung/plot_v3_sim_pidt1_regler.png)

**Erfüllt das Ergebnis mit $K = 0{,}0695$ Ihre Erwartungen? Warum (nicht)?**
- **Nein, das Ergebnis mit $K = 0{,}0695$ ist im nichtlinearen System nicht optimal:**
  1. **Starkes Überschwingen ($\phi_{\mathrm{max}} \approx 73{,}0^\circ$ statt $60^\circ$, d.h. $+26\,\%$ Überschwingen) trotz Auslegung auf $D = 1$:**
     - **Ursache 1 (D-Stoß & Stellgrößensättigung / Windup):** Beim Sprung von $10^\circ$ auf $60^\circ$ erzeugt der D-Anteil ($N = 1000$) einen riesigen Spannungsimpuls, der jedoch durch die Saturation bei $+12\,\mathrm{V}$ abgeschnitten wird. Der reale D-Bremsimpuls bzw. die lineare Dynamik greift während der Sättigung nicht wie in der linearen WOK berechnet, während der Integrator bereits voll auflädt (**Integrator-Windup**).
     - **Ursache 2 (Zwei langsame Reglernullstellen bei $-10$ und $-30$):** Im geschlossenen Kreis liegen die Nullstellen nahe bei den dominanten Polen ($-16{,}4\,\mathrm{s^{-1}}$), was in der Sprungantwort zu einem starken Überschwingen führt, das anschließend nur sehr langsam über den Kriechpol nahe $s_{N1} = -10\,\mathrm{s^{-1}}$ abklingt.
  2. **Langsames "Kriechen" zurück auf den Sollwert (Haftreibung + kleiner I-Gain):**
     - Nach dem Überschwingen auf $\approx 73^\circ$ (oder bei größeren Verstärkungen auf $\approx 70^\circ$) kehrt die Klappe nur extrem langsam Richtung $60^\circ$ zurück (bei $K = 0{,}0695$ nach $1{,}5\,\mathrm{s}$ erst bei $56{,}6^\circ$).
     - **Ursache:** In der Nähe des Sollwerts ist die Regeldifferenz $e$ klein. Da die Haft-/Gleitreibung ($\pm 0{,}01\,\mathrm{N\,m}$) und die Federkraft überwunden werden müssen, bleibt die Klappe kurzzeitig stehen, bis der relativ schwache I-Anteil ($I = K/T_N = 0{,}525\,\mathrm{s^{-1}}$) mühsam genug Spannung aufintegriert hat, um das Losbrechmoment in Gegenrichtung zu überwinden.

---

## 3. Versuchsauswertung & Verbesserungsvorschläge (Kapitel 3)

### 3.1 Vergleich der beiden realisierten Regler (P vs. $\text{PIDT}_1$)

| Eigenschaft | P-Regler ($K_P = 0{,}1195 \dots 0{,}5$) | $\text{PIDT}_1$-Regler ($K = 0{,}0695 \dots 0{,}5$) |
| :--- | :--- | :--- |
| **Stationäre Genauigkeit ($e_\infty$)** | **Mangelhaft:** Große bleibende Regelabweichung ($e_\infty = 23{,}0^\circ$ bei $K_P = 0{,}1195$; $e_\infty = 4{,}4^\circ$ bei $K_P = 0{,}5$) infolge Notlauffeder und Reibung. | **Sehr gut ($e_\infty \to 0^\circ$):** Der I-Anteil kompensiert das statische Federrückstellmoment stationär vollständig (bei $K \ge 0{,}25$ wird $60{,}0^\circ$ erreicht). |
| **Überschwingen** | Bei $K_P \le 0{,}5$ **kein Überschwingen** (bleibt unter $60^\circ$). Erst bei sehr hohem $K_P \ge 1{,}0$ tritt Überschwingen auf. | **Deutliches Überschwingen** ($\approx 66^\circ \dots 73^\circ$), verursacht durch Reglernullstellen, Stellgrößenbegrenzung ($\pm 12\,\mathrm{V}$) und Integrator-Windup. |
| **Geschwindigkeit** | Schneller Erst-Anstieg, erreicht den Sollwert $60^\circ$ jedoch nie vollständig. | Sehr schneller Anstieg ($< 50\,\mathrm{ms}$ bis $60^\circ$), aber verzögertes Einschwingen auf den Endwert durch Windup und Reibungs-Kriechen. |

---

### 3.2 Konkrete Verbesserungsvorschläge für ein optimales Verhalten

1. **$\text{PT}_1$-Führungsgrößenfilter (Vorfilter) zur Kompensation der Nullstelle $s_{N1} = -10\,\mathrm{s^{-1}}$ (vor Anti-Windup!):**
   - Die langsame Reglernullstelle $s_{N1} = -10\,\mathrm{s^{-1}}$ liegt näher am Ursprung als das dominante Polpaar ($s = -16{,}4\,\mathrm{s^{-1}}$) und verursacht in der Führungsübertragungsfunktion zusammen mit dem D-Stoß beim Sollwertsprung ein starkes Überschwingen.
   - Schaltet man direkt nach dem Sollwertsprung ein **$\text{PT}_1$-Führungsgrößenfilter** mit der Zeitkonstante $T_F = \frac{1}{|s_{N1}|} = \frac{1}{10\,\mathrm{s^{-1}}} = \mathbf{0{,}1\,\mathrm{s}}$ ein:
     $$F_F(s) = \frac{1}{T_F\,s + 1} = \frac{1}{0{,}1\,s + 1}$$
     so kürzt der Pol $s_P = -10\,\mathrm{s^{-1}}$ des Vorfilters genau die Reglernullstelle $s_{N1} = -10\,\mathrm{s^{-1}}$ in der Führungsübertragungsfunktion weg und glättet gleichzeitig den Sollwertsprung, sodass der extreme $+12\,\mathrm{V}$-D-Stoß entfällt.
2. **Anti-Windup-Maßnahme im PID-Regler (Clamping / Back-Calculation):**
   - Da die Motorspannung auf $\pm 12\,\mathrm{V}$ begrenzt ist, wird im Simulink-PID-Block die interne Ausgangsbegrenzung (`Limit output: [-12, 12]`) samt **Anti-Windup (`Clamping`)** aktiviert. Dadurch stoppt der Integrator während einer eventuellen $12\,\mathrm{V}$-Sättigungsphase. In Kombination mit dem $\text{PT}_1$-Führungsgrößenfilter und $K = 0{,}50$ schwingt die Klappe nahezu überschwingfrei und sehr schnell auf exakt $60{,}0^\circ$ ein (siehe grüne Kurve in der Simulation).
3. **Störgrößenaufschaltung / Vorsteuerung der Notlauffeder:**
   - Da die Federkennlinie $M_F(\phi)$ und der Vorspannungssprung $\pm 0{,}025\,\mathrm{N\,m}$ bei $\phi_0 = 5^\circ$ (bzw. $7{,}5^\circ$ aus V2) exakt bekannt sind, kann die benötigte Haltespannung direkt als **Vorsteuerung** zum Reglerausgang addiert werden:
     $$U_{\mathrm{Vor}}(\phi_{\mathrm{soll}}) = \frac{R_A}{k_{\mathrm{Mot}}} \cdot M_F(\phi_{\mathrm{soll}}) \approx \frac{2{,}5\,\Omega}{0{,}03\,\mathrm{N\,m/A}} \cdot 0{,}027\,\mathrm{N\,m} \approx 2{,}25\,\mathrm{V} \quad (\text{für } \phi_{\mathrm{soll}} > \phi_0)$$
   - **Effekt:** Der I-Anteil wird fast vollständig entlastet und muss nur noch kleine Modellfehler und die Reibung ausregeln.

---

### 3.3 Gewonnene Erkenntnisse (1 bis 3 Sätze)

> **Erkenntnisse:**
> Ein rein auf Basis der linearisierten Strecke (Wurzelortskurve) ausgelegter Regler führt an einer stark nichtlinearen Strecke mit vorgespannter Notlauffeder, Haftreibung und Stellgrößenbegrenzung ($\pm 12\,\mathrm{V}$) zu erheblichen Abweichungen vom theoretischen Idealverhalten (große bleibende Regelabweichung beim P-Regler bzw. Überschwingen und langsames Kriechen beim $\text{PIDT}_1$-Regler). Während erst der I-Anteil des $\text{PIDT}_1$-Reglers das permanente Rückstellmoment der Notlauffeder stationär kompensieren kann, erfordert eine schnelle und überschwingfreie Lageregelung in der Praxis zwingend nichtlineare Erweiterungen wie **Anti-Windup**, eine **Vorsteuerung der Federkennlinie** sowie die Vermeidung des D-Sprungstoßes.

---

## 4. Vollständige Beantwortung der Testfragen (Kapitel 4)

### 4.1 Anforderungen an die Drosselklappenlageregelung (Kap. 1.3)
- **Genauigkeit:** Stationär exakt ($e_\infty = 0^\circ$, Toleranz $< 0{,}2^\circ$), um den Luftmassenstrom und die Motordrehzahl präzise zu treffen.
- **Überschwingen:** Minimal bzw. überschwingfrei ($D \ge 1$), um ein Anschlagen an den mechanischen Endanschlägen ($0^\circ / 90^\circ$), Drehmomentruckeln und Haftreibungs-Grenzzyklen zu verhindern.
- **Geschwindigkeit:** Sehr schnell ($t_{\mathrm{ein}} \approx 50 \dots 150\,\mathrm{ms}$), für spontanes Ansprechverhalten des Fahrzeugs auf Gaspedalbewegungen.

---

### 4.2 Skizzieren der Wurzelortskurve für $s_{P1} = s_{P2} = 0;\; s_{P3} = -3;\; s_{N1} = -1$

![Testfrage WOK](file:///c:/Users/johan/Lokal/RTA/RTA/V3_Lagerregelung/plot_v3_testfrage_wok.png)

**Analytische Konstruktionsregeln für die Handskizze:**
1. **Pole ($\times$) und Nullstellen ($\circ$):** Doppelpol im Ursprung $s_{P1,2} = 0$, einfacher Pol bei $s_{P3} = -3$, einfache Nullstelle bei $s_{N1} = -1$.
2. **Äste auf der reellen Achse** (überall dort, wo rechts davon eine *ungerade* Gesamtanzahl an reellen Polen + Nullstellen liegt):
   - Zwischen $0$ und $-1$: Rechts liegen 2 Pole ($s_{P1,2}=0$, gerade) $\implies$ **kein** WOK-Ast auf $[-1, 0]$.
   - Zwischen $-1$ und $-3$: Rechts liegen 2 Pole und 1 Nullstelle (Summe $= 3$, ungerade) $\implies$ **WOK-Ast auf $[-3, -1]$** (der Pol $s_{P3} = -3$ wandert direkt nach rechts in die Nullstelle $s_{N1} = -1$).
   - Links von $-3$: Rechts liegen 3 Pole und 1 Nullstelle (Summe $= 4$, gerade) $\implies$ **kein** WOK-Ast für $\sigma < -3$.
3. **Asymptoten für $s \to \infty$:**
   - Überschuss $n - m = 3 - 1 = 2$ Asymptoten.
   - Asymptotenwinkel: $\phi_{A1,2} = \frac{\pm 180^\circ}{3 - 1} = \pm 90^\circ$ (vertikal nach oben und unten).
   - Asymptotenschnittpunkt (Schwerpunkt auf der reellen Achse):
     $$\sigma_A = \frac{\sum s_{Pi} - \sum s_{Nj}}{n - m} = \frac{(0 + 0 - 3) - (-1)}{3 - 1} = \frac{-2}{2} = \mathbf{-1}$$
4. **Verlauf:** Die beiden Pole im Ursprung ($s_{P1,2} = 0$) verzweigen sofort unter $\pm 90^\circ$ in die linke Halbebene und nähern sich asymptotisch der vertikalen Geraden $\sigma_A = -1$ nach $\pm j\infty$ an.

---

### 4.3 MATLAB-Befehle zum Zeichnen dieser Wurzelortskurve

**Variante 1 (über Zähler-/Nennerpolynome mit `tf`):**
```matlab
% Zähler: (s + 1) -> [1 1]
% Nenner: s^2 * (s + 3) = s^3 + 3*s^2 -> [1 3 0 0]
Fo = tf([1 1], [1 3 0 0]);
rlocus(Fo);
grid on;
```

**Variante 2 (direkt über Pol-/Nullstellen-Vektoren mit `zpk`):**
```matlab
Fo = zpk([-1], [0 0 -3], 1);
rlocus(Fo);
grid on;
```

---

### 4.4 Welche Bedeutung haben Pol- und Nullstellen?

- **Polstellen ($s_{Pi}$, Nullstellen des Nennerpolynoms $N(s) = 0$):**
  - Bestimmen die **Stabilität** und die **natürlichen Eigenbewegungen (Eigenmoden $e^{s_{Pi} t}$)** des Systems.
  - **Realteil $\sigma_i = \operatorname{Re}\{s_{Pi}\}$:** Bestimmt das Abklingverhalten bzw. die Stabilität:
    - $\sigma_i < 0$: exponentiell abklingend (**asymptotisch stabil**; je weiter links, desto kleiner die Zeitkonstante $\tau_i = 1/|\sigma_i|$ und desto schneller das System).
    - $\sigma_i = 0$: konstante Integration oder Dauerschwingung (**grenzstabil**).
    - $\sigma_i > 0$: exponentiell aufklingend (**instabil**).
  - **Imaginärteil $\omega_i = \operatorname{Im}\{s_{Pi}\}$:** Bestimmt die Schwingungsfähigkeit. Konjugiert-komplexe Polpaare ($\sigma_i \pm j\omega_i$ mit $\omega_i \neq 0$) erzeugen harmonische Schwingungen mit der Kreisfrequenz $\omega_i$.
- **Nullstellen ($s_{Nj}$, Nullstellen des Zählerpolynoms $Z(s) = 0$):**
  - Verändern **nicht** die Stabilität des Einzelglieds, bestimmen aber über die Gewichtung (Residuen) der Eigenmoden, **wie stark** die einzelnen Pole im Ausgangssignal angeregt werden (differenzierender Vorhalt, Phasenvorhalt, Überschwingverhalten).
  - **In der Wurzelortskurve (geschlossener Regelkreis):** Die Nullstellen des offenen Kreises wirken als **Attraktoren (Endpunkte)**, zu denen $m$ Äste der geschlossenen Regelkreispole für $K \to \infty$ hinwandern. Durch geschicktes Platzieren von Reglernullstellen lässt sich die WOK in die stabile linke Halbebene ziehen.

---

### 4.5 Was versteht man unter „Pol-/Nullstellenkompensation“?

Unter **Pol-/Nullstellenkompensation** versteht man das gezielte Platzieren einer Reglernullstelle $s_{N,\mathrm{Regler}}$ exakt auf (oder nahe bei) einem langsamen, stabilen Streckenpol $s_{P,\mathrm{Strecke}}$ (z.B. Wahl der Nachstellzeit $T_N = T_1$ beim PI-Regler, sodass sich $(1 + s T_N)$ im Zähler des Reglers und $(1 + s T_1)$ im Nenner der Strecke im offenen Kreis $F_o(s) = F_R(s) \cdot F_S(s)$ rechnerisch herauskürzen).

- **Vorteil:** Der langsame, verzögernde Streckenpol wird kompensiert, die Systemordnung reduziert sich und der Regelkreis kann deutlich schneller ausgelegt werden.
- **Grenzen / Vorsicht:**
  1. Instabile Pole ($\operatorname{Re}\{s_P\} \ge 0$) dürfen **niemals** durch Nullstellen kompensiert werden, da die Kompensation wegen unvermeidbarer Bauteiltoleranzen nie exakt ist und die instabile Eigenbewegung intern erhalten bleibt (interne Instabilität).
  2. Bei Störungen, die zwischen Regler und Strecke angreifen, wird der kompensierte Streckenpol in der Störübertragungsfunktion wieder sichtbar (langsames Ausregeln von Störungen).

---

### 4.6 Pole, Nullstellen und Sprungantwort von $\text{PT}_1$-, $\text{PD}$- und $\text{PDT}_1$-Glied

![Testfrage Übertragungsglieder](file:///c:/Users/johan/Lokal/RTA/RTA/V3_Lagerregelung/plot_v3_testfrage_glieder.png)

| Übertragungsglied | Übertragungsfunktion $F(s)$ | Pole ($\times$) & Nullstellen ($\circ$) | Sprungantwort $h(t)$ (für $t \ge 0$) |
| :--- | :--- | :--- | :--- |
| **$\text{PT}_1$-Glied** | $F(s) = \frac{K}{T_1\,s + 1}$ | **1 reeller Pol:** $s_P = -\frac{1}{T_1} < 0$<br>**Keine Nullstelle** | $h(t) = K \cdot \left(1 - e^{-t/T_1}\right)$<br>Startet bei $h(0) = 0$ mit Anfangssteigung $K/T_1$, erreicht bei $t = T_1$ genau $63{,}2\,\%$ und nähert sich asymptotisch dem Endwert $K$. |
| **Ideales $\text{PD}$-Glied** | $F(s) = K \cdot (T_V\,s + 1)$ | **Keine Pole**<br>**1 reelle Nullstelle:** $s_N = -\frac{1}{T_V} < 0$ | $h(t) = K \cdot \left(1 + T_V \cdot \delta(t)\right)$<br>Unendlich hoher **Dirac-Stoß** $K T_V \delta(t)$ bei $t = 0$ (D-Anteil), danach konstant auf dem P-Endwert $h(t>0) = K$. *(Physikalisch nicht exakt realisierbar).* |
| **Reales $\text{PDT}_1$-Glied** ($T_V > T_1$) | $F(s) = K \cdot \frac{T_V\,s + 1}{T_1\,s + 1}$ | **1 reelle Nullstelle:** $s_N = -\frac{1}{T_V}$<br>**1 reeller Pol:** $s_P = -\frac{1}{T_1}$<br>(für $T_V > T_1$ liegt $s_P$ weiter links als $s_N$) | $h(t) = K \cdot \left(1 + \left(\frac{T_V}{T_1} - 1\right) e^{-t/T_1}\right)$<br>Springt bei $t = 0$ sofort auf den Überhöhungswert $h(0^+) = K \cdot \frac{T_V}{T_1}$ und klingt mit der Zeitkonstante $T_1$ exponentiell auf den stationären Endwert $h(\infty) = K$ ab. |

---

### 4.7 Bestimmung von $T_N$ und $T_V$ eines $\text{PIDT}_1$-Reglers aus vorgegebenen Nullstellen (Kap. 2.3.2)

1. **Ausgangspunkt (Übertragungsfunktion des $\text{PIDT}_1$-Reglers auf gemeinsamem Hauptnenner):**
   $$F_R(s) = K \left( 1 + \frac{1}{T_N\,s} + \frac{T_V\,s}{T\,s + 1} \right) = K \cdot \frac{(T\,T_N + T_N\,T_V)\,s^2 + (T + T_N)\,s + 1}{T\,T_N\,s^2 + T_N\,s}$$
   Die Filterzeitkonstante $T$ des realen D-Anteils wird vorab fest gewählt (sehr klein, z.B. $T = 0{,}001\,\mathrm{s}$).
2. **Soll-Zählerpolynom aus den beiden gewünschten Nullstellen $s_{N1}$ und $s_{N2}$ aufstellen:**
   Da die Nullstellen des Reglers die Wurzeln des Zählerpolynoms sind, muss der Zähler ein Vielfaches $Q$ von $(s - s_{N1})(s - s_{N2})$ sein:
   $$(T\,T_N + T_N\,T_V)\,s^2 + (T + T_N)\,s + 1 \stackrel{!}{=} Q \cdot (s - s_{N1})(s - s_{N2}) = Q \cdot \left(s^2 - (s_{N1} + s_{N2})\,s + s_{N1}\,s_{N2}\right)$$
3. **Schrittweise Auflösung durch Koeffizientenvergleich ($s^0$, $s^1$, $s^2$):**
   - **Normierungsfaktor $Q$ aus dem Absolutglied ($s^0$):**
     $$Q \cdot s_{N1}\,s_{N2} = 1 \implies Q = \frac{1}{s_{N1} \cdot s_{N2}}$$
   - **Nachstellzeit $T_N$ aus dem linearen Term ($s^1$):**
     $$T + T_N = -Q \cdot (s_{N1} + s_{N2}) \implies T_N = -\frac{s_{N1} + s_{N2}}{s_{N1} \cdot s_{N2}} - T$$
   - **Vorhaltezeit $T_V$ aus dem quadratischen Term ($s^2$):**
     $$T\,T_N + T_N\,T_V = Q \implies T_V = \frac{Q - T \cdot T_N}{T_N} = \frac{1}{s_{N1} \cdot s_{N2} \cdot T_N} - T$$
   *(Für $s_{N1} = -10$, $s_{N2} = -30$ und $T = 0{,}001\,\mathrm{s}$ folgt damit direkt: $Q = \frac{1}{300}$, $T_N = \frac{40}{300} - 0{,}001 = 0{,}13233\,\mathrm{s}$ und $T_V = \frac{1/300 - 0{,}001 \cdot 0{,}13233}{0{,}13233} = 0{,}02419\,\mathrm{s}$.)*
