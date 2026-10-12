# Einstieg – Reparaturpaket und Prüfstand

Geprüft am 12. Oktober 2026 mit Godot 4.7.2 unter Windows.
Basis: `2683c10`, mit dem GitHub-Hauptstand per Fetch abgeglichen.

## Reparaturen

- Kartenaufdeckung sammelt kleine Bewegungsschritte bis zum nächsten Aufdeckpunkt. Der bestätigte dunkle Start bleibt erhalten.
- Laden respektiert echte Boss-/Gebietssperren statt empfohlener Gebietslevel. Legale Standorte und Wegsteine bleiben erhalten; gesperrte Ziele führen sicher ins Dorf.
- Der Dorf-Wegstein mit Index 0 bleibt auch beim zweiten Laden erhalten. Die alte Untergrenze 1 verwandelte ihn in einen Außenstein.
- Tafel und Bank vor der Ratshalle stehen 33 Pixel näher an der Fassade und lassen den Weg zum Osttor frei.
- Vorhandene Geschosskollisionen erhalten Holzklänge; Materialwiedergabe liegt in `components/projectile_impacts.gd`. Keine zusätzlichen Kollisionsflächen.

## Nachweise

- Vollständige lokale Auswahl gemäß `tools/run_all_tests.sh`, über den vorhandenen Windows-Runner `build/run_godot_checks.py`: **134 bestanden, 0 fehlgeschlagen**, einschließlich des zusätzlichen Questtests. Tests mit getrennten APPDATA-/TEMP-Verzeichnissen; keine echten Spielstände verwendet.
- Inhaltsprüfung `tools/check_content.py` und Browser-Brücke `tools/check_browser_bridge.cjs`: bestanden.
- `check_start_area_journey.gd`: echte Charakteranlage, Dorfweg, Osttor-Aktion, Blütenwiesen/Pilzwald, Rückweg, 1.781 Bewegungsschritte; Position, Questwerte, Nebel und Torzustand nach Dateispeicherung. Alle 18 Identitäten werden am Start geprüft, nicht auf der gesamten Route.
- Zusatzfälle über Dateispeicherung: Dorfstein, tatsächlich versiegeltes Gebiet, zweimaliges Laden, Fusionsrang 3 und anschließender frischer Charakter ohne fremde Fusion.
- `check_start_quest_lifecycle.gd`: erste zwei Mira-Aufträge in allen drei Klassen über Haustür, NPC-Interaktion und reguläre Klassenangriffe. 286 Angriffe; Teilfortschritt, Abgabebereitschaft und Abschluss über Dateiladen geprüft. Passende Klassenwaffe, genau eine Gold-/Gegenstandsbelohnung, keine doppelte Auszahlung beim nächsten Gespräch. Gegner stehen für diese Trefferprüfung still; die KI-/Balancebewertung bleibt separat.
- Bestehende Charakterwechsel-, Fusions-, Speicherreparatur- und Netzwerkprüfungen bestehen. Ein Live-Relog mit einem betroffenen Konto wurde dadurch nicht nachgestellt.
- Webexport erstellt (Exit 0). Godot meldet in dieser Umgebung Zertifikatsspeicher-/Editor-Einstellungswarnungen; die lokalen Tests ersetzen keine Prüfung der TLS-Verbindung zum Live-Server.
- Aktuelle native Spielbilder unten visuell geprüft; 3D-Außenobjekte liefern im nativen Renderer sichtbare Pixel. Keine Bewertung der Spielbalance durch die gestellten Bilder.

Die Webvorlage unterstützt keine Startpfad-Überschreibung über `--script` oder Szenenargument. Deshalb erzeugt `tools/export_start_area_web.py` eine getrennte Projektkopie mit eigener Startszene. Rohmedien verwenden nach Möglichkeit Hardlinks, um Platz zu sparen; Quelltexte und Importmetadaten sind eigene Kopien. Der zuerst wegen Speichermangel abgebrochene Prüfexport wurde nach Bereinigung der neu angelegten Kopie erfolgreich wiederholt.

Im verbundenen Codex-Browser rendert die Blütenwiesen-Prüfszene sichtbar Figur, Gegner und Außenobjekte; Diagnose: `active_3d=true`, 72 Objekte, 6.295 sichtbare 3D-Pixel. Das ist ein lokaler Browser-Nachweis für diese Szene. Brave ist nicht als steuerbarer Browser verbunden. Brave-3D, tatsächliche Tiefensortierung in diesem Browser und ein echter Golem-Mehrspielerkampf bleiben Aufgabe 3 im Arbeitsplan. Der vorhandene 2D-Rückfall bleibt bestehen.

Die erste Questfolge ist zusätzlich als automatisierter Ablauf geprüft. Ein zusammenhängender manueller Durchgang mit bewegten Gegnern und Kampf-Balance steht noch aus. Die Wegstrecke verwendet reguläre Kollision und Toraktion; ihr isolierter Speicherfall setzt einen Questfortschritt gezielt. Der zusätzliche Questtest erwirbt ihn durch Klassenangriffe.

## Spielbilder

![Ratshalle mit freiem Hauptweg](ratshalle.png)
![Osttor](osttor.png)
![Blütenwiesen mit Gegnern](bluetenwiesen.png)
![Pilzwald mit Gegnern](pilzwald.png)
![Sonnenhain](sonnenhain.png)

Reproduktion der Bilder: `tools/capture_start_area.gd`. Netzwerk und Speichern sind in dieser Prüfszene deaktiviert.

## Veröffentlichung

Noch nicht live. [PR #134](https://github.com/tryla27/RPG-Sonnenhain/pull/134) ist angelegt. Die CI des ersten Uploads (`183216b`) war erfolgreich; zusätzliche Quest-/Web-Prüfwerkzeuge werden am erweiterten PR-Kopf erneut geprüft. Live-Schaltung erst mit Angelos Bestätigung für dieses konkrete Paket.
