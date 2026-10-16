# Grafik- und Leistungspaket · Stand 16.10.2026

Das erste Paket ist lokal umgesetzt. Es verbessert den bestehenden Renderer,
die Minimap und die Lesbarkeit im Kampf. Neue Figuren, Gebäude und Porträts
stehen als bearbeitbare Prototypen im Grafiklabor; sie ersetzen noch nicht
flächendeckend die vorhandene Spielgrafik. Die gemeldeten Online-Lags sind
damit noch nicht als behoben nachgewiesen. Es erfolgte kein Live-Gang.

## Bereits im Spiel angebunden

- Landschaftsobjekte behalten feste Plätze auf Atlasseiten. Ruhende Seiten
  werden nur bei Änderungen neu gerendert. Animierte Objekte haben eigene
  kleinere Seiten. Ein begrenzter Rückwegcache vermeidet Neuerstellungen.
- Sichtbare Objekte werden höchstens alle 250 ms gesammelt; eine Randzone
  lädt vor. Geländedekoration und Minimapfarben verwenden begrenzte Caches.
  Erkundungsnebel und bewegliche Kartenmarker bleiben aktuell.
- Die vorhandene Prüfung auf leere 3D-Ausgabe berücksichtigt alle aktiven
  Seiten. Bei fehlender Ausgabe bleibt der bestehende 2D-Rückfall erhalten.
- Angriffsvorbereitungen zeigen Flächen gemäß der vorhandenen Reichweite.
  Schaden, Zeiten und Trefferregeln bleiben gleich. Der Wolf behält seine
  vereinbarte Sprungpose ohne zusätzliche Zielmarkierung.
- Vier kompakte Effektatlanten und ein Quest-Symbol sind eingebunden.
- Persönlicher Blütenschmuck am Dorfstein reagiert auf bestehende
  Storyzustände. Keine neuen Speicherfelder, Belohnungen oder Collider.
- F3 zeigt zusätzlich P95/P99-Bildzeiten.

## Die zehn Grafikvorhaben

| Vorhaben | Konkreter Stand | Noch erforderlich |
|---|---|---|
| Waffen | Schwert, Stab, Bogen in je drei Stufen als GLB und transparente Itembilder | Handpositionen und Ausrüstung im Spiel prüfen |
| Skelettanimation | Goldener Krieger, acht Knochen, neun Animationen; Physik-Ragdoll im Labor | Stil, Bewegungen und alle Blickrichtungen ausarbeiten; Spielanbindung |
| Effekte | Feuer, Eis, Gift und Treffer als achtteilige Atlanten im Kampffeedback | Lesbarkeit in dichtem Koopkampf prüfen |
| NPC-Porträts | Mira, Fenna, Borin mit ComfyUI erzeugt und als Krita-Projekte gerahmt | Identität und Stil mit bestehender NPC-Grafik abstimmen; Dialogeinbau |
| Weltkarte | Inkscape-SVG aus tatsächlichen Gebiets-/Wegdaten und PNG | Beschriftung und Karteninteraktion ausarbeiten |
| Gebäudebaukasten | Mauern, Ecke, Ende, Tore, Schmiede, Taverne und Rathaus | Modulare Anschlüsse, vorhandene Kollisionen und Platzierung im Piloten prüfen |
| Gegnerlesbarkeit | Vorwarnflächen im bestehenden Kampf eingebaut | Manueller Drei-Klassen-/Koopdurchgang |
| Gegenstandssymbole | Sechs HUD-Symbole und neun Waffenbilder exportiert | Weitere Symbole gezielt in vorhandene UI einbauen |
| Storyvarianten | Drei Steinrosenmodelle im Labor; persönlicher Dorfschmuck im Spiel | Steinrosenvarianten nach visueller Abnahme anbinden |
| Reproduzierbare Pipeline | Blender-, SVG-, Krita-, ComfyUI-Quellen, Metadaten und Prüfwerkzeuge vorhanden | CI-Prüfung des konkreten Pakets; Vergleich auf weiteren Geräten |

Feste Gegenstände allein sparen keine Renderarbeit. Entscheidend sind die
ausbleibenden Aktualisierungen ruhender Atlasseiten und die Wiederverwendung
der Objekte. Große neue Gebäude müssen innerhalb derselben Leistungsgrenzen
bleiben. Die vorhandenen Weltkollisionen bleiben maßgeblich.

## Messung und Grenzen

Native lokale Prüfrouten: Godot 4.7.2, RTX 3060, 1152 × 648,
Zoom 1, ohne Netzwerk und Gegner-KI; 240 Bilder pro Route, die ersten 30
nicht gewertet. Bewegung: 60 Bilder stehen, 90 hin, 90 zurück.

| Route | P95 vorher | P95 nachher | P99 vorher | P99 nachher |
|---|---:|---:|---:|---:|
| Wiese | 31,081 ms | 16,725 ms | 61,599 ms | 46,427 ms |
| Mauertor | 27,116 ms | 16,710 ms | 60,413 ms | 48,003 ms |

Damit sank die P95-Bildzeit dieser beiden lokalen Routen um etwa 46 bzw.
38 Prozent. Der HUD-Zeichenabschnitt lag zuletzt bei rund 2 statt 13 ms.
Es gibt weiterhin einzelne langsame Bilder und hohe Kosten beim ersten
Modellaufbau. Die kurze Messung unter laufender Entwicklungsumgebung ist
keine Garantie für stabile 60 FPS, Browser, Smartphone oder Live-Koop.
Die Pilzwald-Nachmessung ist noch offen; dafür wird kein Gewinn behauptet.

Das isolierte Labor mit 20 animierten Kriegern ergab über 120 Bilder
P95 16,698 ms. Auch das ist kein Lastnachweis für das gesamte Spiel.
Rohprotokolle liegen lokal unter `build/`; die Labor-Messdatei ist unter
[design/quality-v1/warriors_20.json](design/quality-v1/warriors_20.json) abgelegt.

## Werkzeuge und Reparatur

Blender 5.2.2 LTS, Inkscape 1.4.4 als portable Extraktion, Krita 5.3.4.1
und ComfyUI Desktop mit separater lokaler CUDA-Umgebung sind eingerichtet.
Die Programme und großen Modellgewichte liegen auf E:; sie gehören nicht
in den Spielserver oder das Git-Repository.

Krita scheiterte zunächst beim Ressourcenabgleich. Vor dem Neuaufbau des
abgeleiteten SQLite-Caches wurden Ressourcen und Konfiguration vollständig
gesichert. Anschließend wurden drei Material- und drei Porträtprojekte
tatsächlich als KRA gespeichert und als PNG exportiert. Pinsel und
Originalressourcen wurden erhalten. Sicherung lokal auf E: unter
`Sonnenhain-Tools/Krita-profile-backup-20261016`.

Start im Projektordner: `START-GRAFIKLABOR.ps1` und `START-COMFYUI.ps1`.
`tools/art_pipeline/build.ps1` erzeugt Karten-/SVG-/Material-/Blenderausgaben
und prüft den Import. KI-Entwürfe werden gesondert mit
`generate_comfy_concepts.py` erstellt; Workflow, Seed, Modellhash und Versionen
stehen unter `art/source/comfyui`. Die Quelldateien unter `art/source` sind
durch `.gdignore` vom Spieleimport ausgeschlossen.

## Prüfstand und nächste Arbeit

Die vollständige lokale Suite meldete zuletzt 140 bestandene Prüfungen,
ohne Fehler. Eine zustandsverändernde UI-Prüfung läuft einmal isoliert,
damit parallele App-Prüfungen ihre gemeinsame Touch-Konfiguration nicht ändern.
Zwei zusätzliche WebSocket-Speicherprüfungen gegen einen lokalen Testserver
bestanden. Vorhandene Ressourcenfreigabe-/Enginewarnungen bleiben in den Logs;
Erfolg bedeutet Rückgabecode 0 ohne `SCRIPT ERROR`, entsprechend der CI.
Der normale Webexport ist erfolgreich. Die isolierte interaktive
Browservorschau startet und lässt das Intro überspringen. Blütenwiesen und
Pilzwald zeigen im verbundenen Chromium-Browser aktive 3D-Ausgabe
(`active_3d=true`, 72 bzw. 106 Objekte, 1371 bzw. 1235 geprüfte Bildpunkte).
Die isolierte Prüfhülle meldet eine fehlende optionale `SonnenhainBrowser`-
Schnittstelle; Start und Landschaft funktionieren dennoch. Brave ist offen.

1. Brave und schwächere Geräte gesondert testen; die Chromium-Sichtprüfung
   ersetzt keinen Browser-Leistungsvergleich.
2. Konkreten Branch über PR und CI prüfen; serverseitige Laufzeiten und
   echte Zwei-Spieler-Bewegung im gemeldeten Lag-Fall vergleichen.
3. Vorhandene Prototypen am kleinen Wiesen-/Dorfpiloten visuell prüfen und
   gebietsweise anbinden. Keine pauschale Umstellung aller Maps.
4. Vor jedem Live-Gang Angelos ausdrückliche Freigabe gemäß `AGENTS.md`
   einholen; Android bleibt eine eigene Auslieferung.

## Vorschaubilder

![3D-Landschaft im Chromium-Browser](design/quality-v1/browser-wiese.jpg)

![Krieger im isolierten Grafiklabor](design/quality-v1/warrior_gold.png)

![Gebäudebaukasten: Schmiede](design/quality-v1/building_smithy.png)

![Angebundene Zeichenmodule: Heimkehr, Warnflächen und Effekte](design/quality-v1/gameplay.png)
