# Sonnenhain – verbindlicher Arbeitsplan

Stand: 12. Oktober 2026. Auftrag von Angelo: einen verfolgbaren Plan erstellen und Aufgaben nach Wichtigkeit einteilen. Grundlage: `NAECHSTE_ZIELE.md` und `konzepte/2026-10-11-naechste-schritte/KONZEPT.md`.

## Ausgangspunkt und Status

Letzter dokumentierter Live-Stand: 11.10.2026, Commit `3180af0` (Rezeptbuch, Golem-Musikstart, Netzwerkoptimierung). Dies ist kein erneuter Nachweis des laufenden Servers. Lokaler Arbeitsstand: `release-20261011`, mit noch nicht eingecheckten Einstiegskorrekturen und vielen erzeugten Import-/UID-Dateien. Vor Umsetzung den aktuellen Hauptstand und vorhandene Änderungen abgleichen; fremde Änderungen erhalten.

Status je Aufgabe: **offen → in Arbeit → geprüft → zur Veröffentlichung bereit → live bestätigt**. Konzepte und vorhandene Testdateien allein zählen nicht als geprüfte Umsetzung. Datum, Prüfergebnis, Bilder und gegebenenfalls PR-/Commit-Verweis beim Abschluss unten eintragen.

## Prioritäten und Reihenfolge

P0 = Spiel oder Fortschritt gefährdet; unterbricht andere Arbeit bei bestätigtem Fehler.
P1 = wichtig für einen verlässlichen Einstieg und zusammenhängenden Fortschritt.
P2 = Ausbau von Qualität und Bedienung nach den Kernreparaturen.
P3 = spätere Erweiterung oder Auslieferung nach den Spielupdates.

| Reihenfolge | Priorität | Aufgabe | Status | Fertig, wenn … |
|---|---|---|---|---|
| 1 | P0 | Vorhandene Einstiegskorrekturen prüfen: Aufdecken, Laden, Gebietssperren und Wegsteine; Charaktertrennung und Fusionserhalt nach Relog kontrollieren | lokal geprüft; PR/CI und betroffener Live-Relog ausstehend | Neue und alte Spielstände behalten Fortschritt, Fusionen und legale Reiseziele; Wechsel zwischen Charakteren vermischt nichts; bestätigte Fehler sind repariert |
| 2 | P1 | Einstieg Dorf → Blütenwiesen → Pilzwald abrunden: Ratshalle/Osttor, Hauszugänge, Quests, Sichtbarkeit, Trefferflächen, Übergänge und vorhandene Pfeilklänge | Weg-/Speicher-/Klangpaket lokal geprüft; vollständige Quest-/Kampffolge ausstehend | Hin-/Rückweg und erste Quests sind ohne blockierte Wege oder unsichtbare Figuren spielbar; Verhaltenstests und Spielbilder liegen vor |
| 3 | P1 | Darstellungs- und Golem-Probleme nachstellen: Brave-3D, Tiefensortierung, Golem-Kampf, Musikstart und Netzwerkstau | offen | Betroffene Browser-Szene und echter Mehrspielerkampf sind geprüft; Fehlerursache und Messgrenzen sind dokumentiert, vorhandene Probleme behoben oder präzise als Restpunkt benannt |
| 4 | P1 | Gemeinsame Level-/XP-Regel über 40 und 100, einschließlich Speichern, Server, Kampf, Skillpunkten und Testmodus | Konzept vorhanden | Level 40/41/99/100/101 und große XP-Werte funktionieren nach Relog und im Koop ohne Überlauf, Verlust oder unterschiedliche Grenzen |
| 5 | P1 | Händler an den Käuferfortschritt angleichen | Konzept vorhanden | Neue Angebote passen zum Käuferlevel; bestehende Preise/Identitäten bleiben stabil; Levelaufstieg, Charakterwechsel, Relog und Serverkauf sind geprüft |
| 6 | P2 | Alma auf „Kochen“ vereinfachen; Gebietsfreischaltungen mit Name und Bild anzeigen | Konzept vorhanden | Kochen und Rezeptbuch nutzen denselben Lernstand; Gebietshinweise erscheinen einmal pro Charakter und überschwemmen alte Spielstände nicht |
| 7 | P2 | Krieger als isolierten 3D-Prototyp bauen | Konzept vorhanden | Alle Grundaktionen, Kopf-/Körperrichtung, Ausrüstung und Ragdoll sind sichtbar; 1 und 20 Figuren im Browser getestet; Angelo kann den Look anhand einer Vorschau beurteilen |
| 8 | P2 | Übrige Monster gebietsweise erneuern | Konzept vorhanden | Je Gruppe acht Richtungen, passende Aktionen, Wegsuche und klare Angriffsankündigungen; zuerst Alte Ruinen, dann die weiteren Gruppen laut Konzept; fehlende frühe Gegner berücksichtigen |
| 9 | P2 | Bestätigten Krieger-Prototyp ins Spiel übernehmen; danach weitere Figuren, Trefferzonen, Ausrüstungsteile und Fenna | abhängig von 7 | Zuerst ein vollständiger Krieger mit alten Spielständen und Koop; danach schrittweiser Ausbau, ohne verlorene Gegenstände oder Identitäten |
| 10 | P2 | Fusionsvorschau und Fusionsstein verbessern | Konzept vorhanden | Vorschau entspricht dem tatsächlichen Kampf, verbraucht nichts; Erlernen, Fusion, Relog, Anwendung und Rückgabe bleiben korrekt |
| 11 | P3 | Instrumente und weitere Atmosphäre | später | Laute, Flöte, Trommel und Harfe zunächst ohne Kampfboni; Musikregeln und bestätigte Klangrichtung angewendet |
| 12 | P3 | Android-App auf den dann freigegebenen Spielstand bringen | ausdrücklich zurückgestellt | Spielupdates sind ausreichend abgeschlossen; Login, Touch-Steuerung, Rezeptbuch, Shop, Golem und Installationsupdate auf echtem Handy geprüft; eigene Veröffentlichungsfreigabe liegt vor |

Die Reihenfolge innerhalb derselben Priorität berücksichtigt Abhängigkeiten und den bisherigen Konzeptplan. Bestätigte Speicherverluste, Abstürze oder unspielbare Kämpfe werden jederzeit zu P0. Reine Schönheitskorrekturen verdrängen keine offenen P0-/P1-Aufgaben.

## Arbeitspakete

1. **Einstieg und Stabilität:** Aufgaben 1–3. Erst vorhandene lokale Reparaturen bewerten und vervollständigen. Browser- oder Liveprüfungen ohne Zugriff als ausstehend kennzeichnen; lokale Tests ersetzen diese nicht.
2. **Fortschritt und Handel:** Aufgaben 4–5. XP-Auslegung aus dem Konzept ausdrücklich in den Änderungsnotizen nennen: nach dem Aufstieg auf 100 vervierfacht sich der Bedarf je weiterem Aufstieg. Darstellung großer Werte zuerst festlegen. Kleine Schritte mit gemeinsamem Speicher-/Netzwerktest.
3. **Komfort:** Aufgabe 6, danach die isolierte Fusionsvorschau aus Aufgabe 10, wenn sie ohne den großen Figurenumbau umsetzbar ist.
4. **Grafik:** Aufgabe 7 als eigene Vorschau; danach 8 und 9 in überschaubaren Gruppen. Die Übernahme des 3D-Figurensystems hängt von der Beurteilung des Prototyps ab. Größere Umbauten vor Beginn ankündigen.
5. **Weitere Inhalte und App:** Rest von 10, dann 11; Aufgabe 12 bleibt nach den weiteren Spielupdates. Kein automatischer App-Termin.

## Vorgehen bei jeder Aufgabe

- Vor Beginn aktuellen Code, offene Änderungen und vorhandene Prüfungen abgleichen. Nur tatsächliche Lücken umsetzen.
- Eine Aufgabe beziehungsweise einen eng zusammenhängenden Teil bearbeiten; neuen Code nach `AGENTS.md` in passende Module legen.
- Verhalten und relevante Speicher-/Koopfolgen prüfen. Sichtbare Änderungen mit Spielbildern belegen. Für Code-Commits vollständige Projektprüfungen gemäß `AGENTS.md`, anschließend PR und grüne CI.
- Entwicklernotizen und spielrelevante Patch Notes aktualisieren; generierte Importdateien nicht nebenbei übernehmen.
- Abschluss hier und in `NAECHSTE_ZIELE.md` dokumentieren. Geprüft, veröffentlicht und live bestätigt getrennt halten.
- Vor jeder Live-Schaltung Angelos Bestätigung zum konkret geprüften Paket einholen, wie in `AGENTS.md` festgelegt. Android erhält eine eigene Freigabe.

Keine vollständige Modularisierung nebenbei; sie bleibt pausiert. Keine automatischen Hintergrundläufe eingerichtet. Dieser Plan wird bei weiterer Arbeit im Chat fortgeschrieben.

## Nächster Arbeitsschritt

**Aktuell:** geprüftes Einstiegspaket in PR/CI überführen. Danach die vollständige Quest-/Kampffolge aus Aufgabe 2 und die Browser-/Golem-Nachweise aus Aufgabe 3 schließen. Fehler mit betroffenen Live-Konten nur bei tatsächlich reproduziertem Befund als erledigt markieren.

## Fortschrittsprotokoll

| Datum | Aufgabe | Ergebnis / Nachweis | Nächster Schritt |
|---|---|---|---|
| 12.10.2026 | Planung | Prioritäten und Abschlusskriterien aus bestehendem Konzept und lokalem Änderungsstand erstellt; keine erneuten Spieltests oder Liveprüfungen | Aufgabe 1 beginnen |
| 12.10.2026 | 1 / Teil von 2 | GitHub-Hauptstand abgeglichen; Dorfstein-Ladefehler repariert; 133 lokale Projektprüfungen bestanden, Inhalts-/Browser-Brückenprüfung bestanden; fünf native Spielbilder erstellt. Details: `konzepte/2026-10-11-startbereich/README.md` | PR/CI; Quest-/Kampf-/Browserprüfung fortsetzen |
