# Sonnenhain – nächste Qualitätsstufe

Stand: 16. Oktober 2026. Auftrag von Angelo: Projektstand erklären und den bestehenden Plan um Blender, ComfyUI, Inkscape und Krita ergänzen. Nach dem Umsetzungsauftrag sind die Werkzeuge eingerichtet und das erste lokale Paket steht zur Prüfung bereit: [Umsetzungsbericht mit zehn Vorhaben und Vorschaubildern](QUALITY_V1_UMSETZUNG.md).

## 1. Ausgangslage

Grundlage sind die lokalen Projektdateien, Git-Historie und bisherigen Prüfberichte. Der öffentliche Hauptstand und der laufende Server wurden für diese Bestandsaufnahme nicht erneut abgefragt.

| Bereich | Belegter Stand | Noch offen |
|---|---|---|
| Spielkern | Godot-Action-RPG mit drei Klassen, Quests, Ausrüstung, Fähigkeiten, Fusionen, Kochen, Bossen und Koop | Zusammenhängendes Spielerlebnis und bestehende Grenzfälle weiter prüfen |
| Letzte dokumentierte Veröffentlichung | 12.10., PR #134, Commit `79bf216`; Website-/Servergleichheit und öffentliche Speicher-/Mehrspielerprüfung damals bestätigt | Heutigen Haupt-/Live-Stand vor neuer Umsetzung abgleichen |
| Lokales Folgepaket | HEAD `57832b5`: Starttexte und Prüfung bewegter Einstiegsgegner; laut Bericht 135 erfolgreiche Projektprüfungen | Längerer manueller Browserdurchgang, PR/CI und Veröffentlichung des Folgepakets; historische Upload-Sperre im Arbeitsplan beachten |
| Grafik | Top-down-Pixelwelt; echte 3D-Landschaftskörper auf Außenkarten 1–12 über gemeinsamen Viewport; erste Waldgegner erneuert | Brave-Darstellung, Tiefensortierung und vollständige räumliche Spielerfiguren |
| Fortschritt | Normaler XP-Aufstieg hat keinen pauschalen Stopp bei 40 | Testmodus, Essenz, Kampf-/Netzwerkgrenzen und große XP-Werte sind noch uneinheitlich |
| Android | Steuerung im Quellstand vorhanden | Aktualisierte App bleibt nach weiteren Spielupdates und eigener Freigabe vorgesehen |

Die 135 Prüfungen sind ein vorhandener Nachweis vom 12.10., kein neuer Testlauf vom 16.10. Im Arbeitsordner liegen bereits lokale Änderungen einschließlich Import-/UID-Dateien und Planergänzungen; diese bei Folgearbeiten erhalten und gezielt zuordnen.

## 2. Zielbild

Aktualisierte Reihenfolge auf Angelos weiteren Auftrag vom 16.10.:
[Leistung und feste Architektur zuerst](GRAFIK_GAMEPLAY_PERFORMANCE_KONZEPT.md).
Vor breitem Figuren-/Landschaftsausbau einen messbar flüssigen Pilot mit
festen Mauermodulen bauen. Der dort vorgeschlagene Runtime-Cachepfad ist
ein gesondert zu prüfender Entwurf, noch keine übernommene Grafikänderung.

Sonnenhain soll in seiner bisherigen Spielperspektive wie aus einem Guss wirken: klar erkennbare Figuren, vollständige Animationen, lesbare Kampfankündigungen, passende Ausrüstung und eine verständliche Oberfläche. Der goldene Krieger und die erneuerten Waldgegner liefern die vorhandenen Referenzen. Eine neue Kameraführung oder ein pauschaler Umbau von Map 0 ist damit nicht beschlossen.

Der erste Qualitätsabschnitt verbindet Dorf → Blütenwiesen → Pilzwald mit einem isolierten Krieger-Prototyp. An diesem kleinen Umfang werden Aussehen, Bedienung und Produktionsablauf bewiesen, bevor weitere Figuren und Gebiete folgen.

## 3. Aufgaben der vier Programme

| Programm | Konkrete Aufgabe in Sonnenhain | Bearbeitbare Quelle | Übergabe an Godot |
|---|---|---|---|
| **Blender** | Räumlichen Krieger modellieren, Skelett und Animationen bauen; Waffenhalter, Rüstung und später Landschaftsmodule/Gegner | `.blend`, Texturen und Exportprofil | `.glb` mit Modell, Skelett und benannten Animationen; Einbindung in vorhandene Perspektive zunächst im Prototyp |
| **ComfyUI** | Stilvarianten, Materialstudien, Porträtideen und Referenzblätter aus festgelegten Vorlagen erarbeiten | Workflow-JSON, Modell-/Versionsangaben, Seed, Eingaben und Parameter | Ausgewählte Entwürfe zur Bearbeitung in Krita; nur geprüfte fertige Bilder werden Spielassets |
| **Inkscape** | Zusammenhängende Formen für Fähigkeitsicons, Gegenstandsrahmen, Gebietssymbole, Questzeichen und Bedienelemente entwickeln | SVG mit Raster, Farben und einheitlicher Strichstärke | PNG in festgelegten Spielgrößen; SVG bleibt die skalierbare Arbeitsquelle |
| **Krita** | Pixelmaterialien malen, Entwürfe vereinheitlichen, Porträts und Effekte ausarbeiten, Spritefehler und Animationsübergänge korrigieren | `.kra` mit Ebenen und Palette | PNG-Texturen bzw. transparente PNG-Einzelbilder; Spriteatlas über bestehenden oder ergänzten Buildschritt |

Nicht jedes Asset muss alle Programme durchlaufen. Ein UI-Symbol kann direkt aus Inkscape kommen, ein Modell direkt aus Blender mit Krita-Textur. ComfyUI unterstützt die Entwurfsphase; Figurengeometrie, acht konsistente Ansichten und Animationen erhalten ihre verbindliche Form im Modell bzw. in der manuellen Bearbeitung.

## 4. Gemeinsamer Produktionsablauf

1. **Stilblatt festlegen:** vorhandenen goldenen Krieger, Waldmonster und ein Spielbild bei normalem Zoom als Referenzen sammeln. Palette, Proportionen, Materialwirkung, Licht, Konturen und Zielgrößen festhalten. Pixelmaterialien in der tatsächlichen Spielgröße beurteilen.
2. **Entwürfe begrenzen:** in ComfyUI wenige vergleichbare Varianten für denselben Auftrag erzeugen. Referenzen und Parameter sichern; eine Richtung auswählen und in Krita präzisieren. Keine unkontrollierte Massenproduktion verschiedener Stile.
3. **Produktionsquelle erstellen:** Körper und Bewegung in Blender; Pixeltexturen und gemalte Details in Krita; Symbole und Rahmen in Inkscape. Quellen behalten, Exporte reproduzierbar erzeugen.
4. **Isoliert in Godot einbauen:** bestehende Module und Darstellung anbinden. Zuerst Form, Fußpunkt, Größenverhältnis, Ausrüstung und Animation prüfen, dann Kampfkontakt, Schatten und Tiefensortierung.
5. **Im Spiel vergleichen:** Vorher-/Nachher-Bilder mit gleichem Ort, Zoom und Beleuchtung. Browser, Speicher-/Koopfolgen und gemessene Leistung prüfen. Erst einen vollständigen Piloten abnehmen, danach verwandte Assets ableiten.

## 5. Reihenfolge mit greifbaren Ergebnissen

| Schritt | Priorität / Abhängigkeit | Konkretes Ergebnis | Abschlusskriterium |
|---|---|---|---|
| A – Einstieg abschließen | P0 bei bestätigtem Fortschrittsverlust, sonst P1 | Durchgang mit neuem und bestehendem Charakter; Dorf, erste Quests, Wald, Rückreise und Relog | Keine Blockade, verlorene Fusion oder vermischter Charakterfortschritt; längerer echter Browserkampf dokumentiert |
| B – Browser und Golem | P1; vor breiter 3D-Übernahme | Reproduzierbare Brave-Prüfszene und echter Koop-Golemkampf | Figuren/Landschaft sichtbar, Verdeckung korrekt; Musikstart, Framezeiten und Netzwerkstau mit Messbedingungen dokumentiert |
| C – Fortschritt und Handel | P1; bestehende Vorprüfung nutzen | Gemeinsame Regeln für Level/XP, Speichern, Kampf, Essenz, Testmodus und Händler | 40/41/99/100/101 sowie große XP-Werte nach Relog und im Koop korrekt; bestehende Angebote behalten Identität und Preis |
| D – Werkzeugbasis und Stilblatt | P2; vorbereitend neben A–C möglich | Installationen/Versionen und GPU-/VRAM-Eignung erfasst; ein kleiner Export je relevantem Werkzeug; abgestimmtes Stilblatt | Eine GLB-Animation und PNG-Textur laufen in Godot; ein Icon wird korrekt importiert; ComfyUI-Workflow ist samt Voraussetzungen wiederholbar |
| E – Krieger als Qualitätsvorlage | P2; nach D, Übernahme erst nach B | Modell, Textur, Skelett, Waffe und alle Grundaktionen in eigener Vorschau | Angelo kann Bilder/Animation beurteilen; 1 und 20 Figuren bei 70 % und 100 % Zoom im Browser gemessen |
| F – Ersten Krieger integrieren | P2; nach geprüfter Vorschau E | Spielbarer Krieger mit bestehender Identität, Ausrüstung und Kampfsteuerung | Alte Speicherstände und Koop funktionieren; Aktionen, sichtbare Waffe und tatsächliche Treffer stimmen überein |
| G – Monster, UI und Komfort ausbauen | P2; Vorlage aus E/F nutzen | Zuerst Alte Ruinen, dann weitere Gebiete; kleine konsistente Icongruppe, Alma/Kochen und Gebietshinweise | Pro Gegnergruppe vollständige Aktionen/acht Richtungen; lesbare Oberfläche, funktionierende Eingaben und gespeicherte Hinweise |
| H – Übrige Figuren und Fenna | P2; nach F | Magier/Bogenschütze, weitere Identitäten, Farben und Umhänge; Körperteil-Ausrüstung als eigenes Paket | Vorhandene Items behalten Werte/Identitäten; Fenna-Vorschau stimmt mit der Spielfigur überein |
| I – Weitere Inhalte und Android | P3; nach Spielupdates | Fusionsausbau, spätere Atmosphäre und anschließend separat geprüfte App | Ziele des Arbeitsplans erfüllt; App auf echtem Gerät geprüft und gesondert zur Auslieferung freigegeben |

A–C bleiben vor dem großen Grafikumbau priorisiert. D erlaubt, den neuen Produktionsablauf früh vorzubereiten. Keine feste Wochenfrist: Umfang und Leistung des Krieger-Prototyps entscheiden über den Ausbau.

### Krieger-Pilot im Detail

- Verbindliche Vorlage: vorhandener goldener menschlicher Krieger; zunächst eine Identität und eine Waffe.
- Aktionen: Stehen, Gehen, Sprinten, Schlag, Fähigkeit, Sprung, Ausweichen, Treffer und Niederlage. Kopf folgt Maus/Stick innerhalb der vorgesehenen Grenzen, Körper der Bewegung.
- Acht Richtungen beurteilen; bei einem räumlichen Modell entstehen diese aus derselben Geometrie. Animationstempo und Ereignisse für Treffer werden gemeinsam mit der Kampfsteuerung geprüft.
- Ragdoll bleibt Darstellung auf dem Client. Trefferzonen und Rüstung pro Körperteil erhalten später eigene Regeln und Migrationen.
- Bestehende 2D-Darstellung bleibt als Rückfall verfügbar, bis der neue Pfad im betroffenen Browser funktioniert.
- Vorschau enthält Lauf-/Angriffsvergleich, Ausrüstung, Verdeckung durch Landschaft und dieselbe Szene mit 1 bzw. 20 Figuren.

### Erstes kleines Assetpaket

Für die erste Stilprüfung genügen der Krieger-Pilot, eine zusammengehörige Materialpalette und sechs Icons: Angriff, Fähigkeit, Quest, Wegstein, Kochen und Fusion. Sie zeigen die Wirkung der Werkzeuge, ohne die ganze Oberfläche gleichzeitig umzubauen. Bestehende Karte 0 dient als Vergleichsszene; ihre Neugestaltung ist kein Bestandteil dieses Pakets.

## 6. Ablage und technische Vereinbarungen

Vorgeschlagene Struktur innerhalb des bestehenden Repos; erst mit tatsächlichen Dateien anlegen:

```text
art/source/blender/       Modelle, Skelette, Szenen
art/source/krita/         Texturen, Porträts, Effektquellen
art/source/inkscape/      Icons, Rahmen, Symbole
art/source/comfyui/       Workflows, Referenz-/Modellangaben
art/models/              geprüfte GLB-Exporte
art/textures/            geprüfte PNG-Texturen
art/ui/                  geprüfte UI-Exporte
docs/design/next-level/  Stilblatt, Assetliste, Vorschauen, Messberichte
```

Vorhandene Assetpfade weiterverwenden, wenn sie bereits passen. Große Modellgewichte und Caches gehören nicht ins Spielpaket; bearbeitbare Quellen beim Export ausschließen und große Binärquellen nach der vorhandenen Speicher-/Buildstrategie verwalten.

Jeder fertige Asseteintrag hält ID, Quelle, Version, Exportgröße, Fußpunkt bzw. Ursprung, Maßstab, Animationsnamen, Dauer und Verwendungsort fest. Bei KI-Entwürfen zusätzlich Workflow, Modelle, Versionen/Hash, Seed, Eingaben und Nutzungsbedingungen erfassen. Ein Seed allein garantiert keine identischen Ergebnisse auf anderer Hardware oder mit anderen Versionen. Keine Modellwahl vor Prüfung der tatsächlich verfügbaren Hardware und Nutzungsbedingungen.

Blender-Ausgabe zuerst per `.glb` testen, damit der Spielimport von exportierten Dateien ausgeht. Materialwirkung und Animationen nach dem Import in Godot prüfen. Ragdoll-/Kampfkonfiguration wird in Godot angebunden; ein Modell-Export allein liefert kein fertiges Spielverhalten. Pixeltexturen und PNG-Icons erhalten passende Filterung und werden auf Kanten, Transparenz und Lesbarkeit geprüft.

## 7. Abnahme und nächster konkreter Schritt

Ein Paket ist fertig, wenn die bearbeitbare Quelle vorliegt, der Export wiederholbar ist, die tatsächliche Spielgröße überzeugt und die betroffenen Abläufe geprüft sind. Bei der Leistung zunächst dieselbe Szene vor und nach Einbau messen: Hardware, Browser, Auflösung, Zoom, Figurenzahl, Framezeiten, Ladezeit und Speicherbedarf festhalten. Ziel bleibt die vorhandene 60-FPS-Ausrichtung; Grenzwerte für zusätzliche Assets anhand dieser Basis festlegen.

**Unmittelbar als Nächstes:** aktuellen Haupt-/Arbeitsstand abgleichen, den offenen Einstiegsdurchgang abschließen und Brave/Golem reproduzierbar prüfen. Als erste Vorbereitung des Grafikpakets vorhandene Krieger-/Monsterreferenzen und Werkzeugvoraussetzungen erfassen; daraus Stilblatt und einen kleinen Importtest erstellen. Danach Fortschrittsregeln umsetzen und den Krieger-Prototyp ausarbeiten.

Neue Spiellogik kommt in `components/`; sichtbare Änderungen erhalten Spielbilder. Veröffentlichung weiterhin nur mit der für das konkrete Paket erforderlichen Freigabe nach `AGENTS.md`; Android getrennt. Dieser Plan installiert keine Programme und ändert noch keine Balance oder Speicherstände.

## Technische Quellen

- [Blender: glTF-2.0-Export, Materialien und Animationen](https://docs.blender.org/manual/en/latest/addons/import_export/scene_gltf2.html)
- [ComfyUI: Workflow-Metadaten](https://github.com/Comfy-Org/docs/blob/main/development/api-development/workflow-metadata.mdx) – Workflow-JSON zusätzlich separat sichern; Metadaten können fehlen oder beim Bearbeiten verloren gehen.
- [Inkscape: SVG speichern und PNG exportieren](https://wiki.inkscape.org/wiki/Save_as_vs_export)
- [Krita: Animation als Bildfolge ausgeben](https://docs.krita.org/en/reference_manual/render_animation.html)

Projektgrundlagen: [nächste Schritte](konzepte/2026-10-11-naechste-schritte/KONZEPT.md), [Fortschrittsvorprüfung](konzepte/2026-10-12-fortschritt/VORPRUEFUNG.md), [Einstiegsfolgepaket](konzepte/2026-10-12-einstieg/README.md) und [bestehende 3D-Landschaft](design/obstacles-live-3d/README.md).
