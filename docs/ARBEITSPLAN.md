# Sonnenhain – verbindlicher Arbeitsplan

Umsetzung 16.10.: [Prüfbares erstes Grafik-/Leistungspaket](QUALITY_V1_UMSETZUNG.md)
mit Werkzeugen, Messwerten, zehn Grafikvorhaben und Vorschaubildern. Die
Renderer-/Minimapoptimierung ist lokal eingebaut, neue Modelle stehen im
Grafiklabor. Der Live-Koopvergleich und die gebietsweise Übernahme bleiben offen.

Stand: 16. Oktober 2026. Auftrag von Angelo: einen verfolgbaren Plan erstellen und Aufgaben nach Wichtigkeit einteilen. Grundlage: `NAECHSTE_ZIELE.md` und `konzepte/2026-10-11-naechste-schritte/KONZEPT.md`.

Ergänzung vom 16.10.: [Plan für die nächste Qualitätsstufe](NEXT_LEVEL_PLAN.md)
mit Bestandsaufnahme und Produktionsablauf für **Blender, ComfyUI, Inkscape
und Krita**. Die P0-/P1-Reihenfolge bleibt bestehen; Werkzeugbasis und
Stilblatt können vorbereitend entstehen. Danach folgt der Krieger als
vollständige Qualitätsvorlage vor dem breiten Ausbau. Aktuelle Live-Version
und frühere Prüfergebnisse wurden bei dieser Planergänzung nicht neu geprüft.

Werkzeugzentrale (17.10.): Regeln in `AGENTS.md`, Konzept und Plan unter
[docs/werkzeugzentrale](werkzeugzentrale/UMSETZUNGSPLAN.md). Paket 0/1
(Projektaufnahme, begrenzte Aufträge, Abbruch) umgesetzt, Windows-Nachprüfung
und Pakete 2–7 offen: [Prüfstand](werkzeugzentrale/PRUEFSTAND.md).

## Ausgangspunkt und Status

Eigenes Gestaltungskonzept vom 16.10. auf Angelos Auftrag:
[„Ein Dorf, das mit deinem Abenteuer wächst“](VERBESSERUNGSKONZEPT.md).
Es konkretisiert den Qualitätsausbau durch einen besseren Einstieg,
lesbare Begegnungen, freiwillige Entdeckungen und persönliche
Heimkehrreaktionen. Erstes Inhaltspaket: „Heimkehr nach Sonnenhain“;
Krieger-Grafikvorschau getrennt. Die P0-/P1-Aufgaben behalten Vorrang.
Neue Mechaniken und Zielwerte sind Entwürfe, noch keine Umsetzung.

Bestätigter Live-Stand: 12.10.2026, Commit `79bf21682ed6ba2f43c18e27a5785e7df9b9f7c2`, Einstiegspaket aus PR #134. Website und Spielserver liefern denselben Stand; öffentliche Verbindungs-, Mehrspieler- und Speicherprüfungen waren erfolgreich. Details: `konzepte/2026-10-11-startbereich/RELEASE_2026-10-12.md`. Lokaler Arbeitsstand: `release-20261011`, auf den Merge-Commit vorgerückt. Erzeugte Import-/UID-Dateien und lokale Fortschrittsdokumentation bleiben außerhalb des veröffentlichten Pakets. Vor weiterer Umsetzung den Hauptstand abgleichen; fremde Änderungen erhalten.

Status je Aufgabe: **offen → in Arbeit → geprüft → zur Veröffentlichung bereit → live bestätigt**. Konzepte und vorhandene Testdateien allein zählen nicht als geprüfte Umsetzung. Datum, Prüfergebnis, Bilder und gegebenenfalls PR-/Commit-Verweis beim Abschluss unten eintragen.

## Prioritäten und Reihenfolge

**Neue Schwerpunktsetzung 16.10. auf Angelos Auftrag:**
[Flüssige Welt, feste Architektur, Grafik und Gameplay](GRAFIK_GAMEPLAY_PERFORMANCE_KONZEPT.md).
Lag-Messung und ein Pilot mit festen Mauern, stabiler Ressourcenbelegung
und getrenntem statischem/dynamischem Rendering rücken vor den breiten
Grafikausbau. Danach Architekturset und kleine Gameplay-Verbesserung mit
Blender, Krita, Inkscape und ComfyUI. Der Runtime-Cachepfad wird zunächst
gegen persistente echte 3D-Instanzen geprüft; noch keine Technikübernahme.
P0 bleibt vorrangig, Fortschritt und Speichern werden nicht fallen gelassen.

**Neue Meldung 16.10.: Lags im Online-Spiel seit Einführung der
3D-Landschaftsmodelle auf den Maps.** Als übergreifenden P1-Fehler vor
weiterem breitem 3D-Ausbau untersuchen; bei unspielbaren Kämpfen/Abbrüchen
oder Fortschrittsverlust P0. Erweitert Aufgabe 3 über Brave und Golem hinaus.
[Fehlereintrag und Messplan](SERVER_LAGS_3D.md). Ursache noch offen;
Client-Framezeiten, Serverlast und Netzwerkverzögerung gemeinsam prüfen.

P0 = Spiel oder Fortschritt gefährdet; unterbricht andere Arbeit bei bestätigtem Fehler.
P1 = wichtig für einen verlässlichen Einstieg und zusammenhängenden Fortschritt.
P2 = Ausbau von Qualität und Bedienung nach den Kernreparaturen.
P3 = spätere Erweiterung oder Auslieferung nach den Spielupdates.

| Reihenfolge | Priorität | Aufgabe | Status | Fertig, wenn … |
|---|---|---|---|---|
| 1 | P0 | Vorhandene Einstiegskorrekturen prüfen: Aufdecken, Laden, Gebietssperren und Wegsteine; Charaktertrennung und Fusionserhalt nach Relog kontrollieren | Reparaturpaket live bestätigt; betroffener Konto-/Fusionsfall weiterhin nicht live nachgestellt | Neue und alte Spielstände behalten Fortschritt, Fusionen und legale Reiseziele; Wechsel zwischen Charakteren vermischt nichts; bestätigte Fehler sind repariert |
| 2 | P1 | Einstieg Dorf → Blütenwiesen → Pilzwald abrunden: Ratshalle/Osttor, Hauszugänge, Quests, Sichtbarkeit, Trefferflächen, Übergänge und vorhandene Pfeilklänge | Erstes Paket live; Starttexte lokal korrigiert; bewegte Einzelgegner in drei Klassen geprüft; manueller längerer Kampf offen | Hin-/Rückweg und erste Quests sind ohne blockierte Wege oder unsichtbare Figuren spielbar; Verhaltenstests und Spielbilder liegen vor |
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

**Aktuell:** Startmeldung und Prolog nennen das Rathaus korrekt; 135 lokale Tests einschließlich bewegter Schleim-/Käfer-Einzelkämpfe in allen drei Klassen bestehen. Folgepaket und interaktive Prüfszene werden zur Überprüfung vorbereitet. Der längere manuelle Browser-Durchgang wurde wegen Werkzeugunterbrechung nicht abgeschlossen und bleibt offen. Bericht: `konzepte/2026-10-12-einstieg/README.md`. Brave-/Golem-Nachweise bleiben ebenfalls offen. Danach folgt das Fortschrittspaket; seine Vorprüfung liegt in `konzepte/2026-10-12-fortschritt/VORPRUEFUNG.md`. PR #134 bleibt der bestätigte Live-Stand `79bf216`.

Folgepaket lokal committet als `57832b5` auf `fix/start-intro-combat-20261012`.
Die automatische Freigabeprüfung hat den Branch-Push abgelehnt, weil sie
eine konkrete Freigabe für den öffentlichen Upload dieses Folgepakets
verlangt. Kein Upload, PR, Merge oder Live-Gang dieses Folgepakets erfolgt.

Upload am 12.10.2026 von Angelo nach konkreter Rückfrage mit „ok weiter“
freigegeben. Branch `fix/start-area-validation-20261011` hochgeladen;
[PR #134](https://github.com/tryla27/RPG-Sonnenhain/pull/134) angelegt.
Die CI ist erfolgreich. Die frühere Upload-Sperre ist
mit dieser ausdrücklichen Freigabe aufgehoben.

Der Merge-Versuch wurde durch die automatische Freigabeprüfung abgelehnt,
weil sie die konkrete Upload-/PR-Freigabe nicht als ausdrückliche
Merge-Freigabe wertete. Angelo hat anschließend ausdrücklich das konkrete
Paket für Merge und Website-/Server-Live-Gang freigegeben; der Merge ist
erfolgt. Android bleibt zurückgestellt.

## Fortschrittsprotokoll

| Datum | Aufgabe | Ergebnis / Nachweis | Nächster Schritt |
|---|---|---|---|
| 17.10.2026 | 3 / Lag-Fehler | Server: Wegsuche begrenzt (längstes Serverbild 306 → 42–71 ms, Mitspieler-Lücken > 150 ms 3 → 0, auch mit vier Spielern). RTX 3060 nativ: P99 50–52 → 17–21 ms. Brave/Edge: Wiesen-P95 125 → 27–30 ms, kein Brave-Sonderfehler. PR #136, nicht live | Live-Freigabe, danach Live-Protokolle prüfen |
| 12.10.2026 | Planung | Prioritäten und Abschlusskriterien aus bestehendem Konzept und lokalem Änderungsstand erstellt; keine erneuten Spieltests oder Liveprüfungen | Aufgabe 1 beginnen |
| 12.10.2026 | 1 / Teil von 2 | GitHub-Hauptstand abgeglichen; Dorfstein-Ladefehler repariert; 133 lokale Projektprüfungen bestanden, Inhalts-/Browser-Brückenprüfung bestanden; fünf native Spielbilder erstellt. Details: `konzepte/2026-10-11-startbereich/README.md` | PR/CI; Quest-/Kampf-/Browserprüfung fortsetzen |
| 12.10.2026 | Übergabe | Implementierung lokal als `c28afb7` committet; öffentliche Upload-Freigabe durch automatische Prüfung verlangt | Angelo um Freigabe für Branch-Upload und PR bitten |
| 12.10.2026 | PR / weitere Einstiegsprüfung | Upload freigegeben, PR #134 angelegt; zusätzlicher Verhaltenstest für erste zwei Mira-Aufträge in allen drei Klassen besteht (286 reguläre Angriffe, Teilfortschritt/Abgabe/Belohnung nach Dateiladen) | Erweiterte vollständige Testsuite und CI abschließen |
| 12.10.2026 | Weitere Nachweise | 134 lokale Prüfungen grün; erste CI auf `183216b` erfolgreich. Getrennte Web-Prüfszene zeigt Blütenwiesen und Pilzwald mit aktiver 3D-Landschaft im verbundenen Codex-Browser. Brave und manueller Kampf bleiben offen; veralteter Starttext „Mira am Dorfplatz“ als weiterer Einstiegspunkt gefunden | Ergänzungen in PR #134 prüfen; danach Starttexte und manuellen Einstieg fortsetzen |
| 12.10.2026 | Veröffentlichung vorbereiten | Erweiterte CI auf `1cf5348` erfolgreich: Tests, Web-/Serverexports, Serverstart. Merge automatisch wegen fehlender konkreter Merge-Freigabe abgelehnt. Arbeitsstand noch nicht live | Freigabe für Merge und Website-/Server-Live-Gang einholen |
| 12.10.2026 | Veröffentlichung gestartet | Merge und Live-Gang freigegeben; PR #134 als `79bf216` mit `[deploy]` zusammengeführt; Website- und Server-Workflow gestartet | Erfolgreiche Auslieferung, Versionsgleichheit und öffentliche Mehrspielerprüfung bestätigen |
| 12.10.2026 | Live bestätigt | Website- und Server-Deploy erfolgreich, Versionsgleichheit für `79bf216` bestätigt. Öffentliche TLS/WSS-, Zwei-Spieler- und Speicher-/Reconnect-Prüfungen bestanden. Bericht: `konzepte/2026-10-11-startbereich/RELEASE_2026-10-12.md` | Starttexte und manuellen Einstieg fortsetzen |
| 12.10.2026 | Einstieg-Folgepaket | Starttexte korrigiert, HUD-Meldung ungekürzt sichtbar; 135 Tests grün, sechs KI-Einzelkämpfe bestehen. Interaktive Prüfszene vorbereitet; manueller Browser-Durchgang wegen Werkzeugunterbrechung offen | Folgepaket über PR/CI prüfen; manuellen Durchgang fortsetzen |
| 12.10.2026 | Folgepaket-Übergabe | Commit `57832b5` lokal fertig; öffentlicher Upload durch automatische Prüfung wegen fehlender konkreter Payload-Freigabe abgelehnt | Freigabe für dieses Folgepaket einholen |
