# Sonnenhain: acht Innenräume und Dorfobjekte

Umsetzung nach Freigabe vom 6. Oktober 2026. Der vorhandene 2D-Stil, Bewohner, Händler, Quests, Spielstände und Zugangsschutz bleiben erhalten.

## Neue Produktionsgrafiken

`art/village/interiors/`: Taverne, Ratshalle, Arena-Eingangshalle, Schmiede, Fenna-Atelier, Pips Werkstatt, Kapelle, Borins Skillhaus. Mira und Liora teilen die Ratshalle. Die sieben Vorschauen wurden mit Imagegen von fest eingezeichneten Personen befreit; Pip erhielt einen achten Entwurf. Spielfiguren werden separat animiert.

`art/village/objects/`: Dorfeiche, Ahorn, Tanne, Borins Runenbaum, Brunnen, Spawnpunkt und drei Büsche (oliv, Herbst, Blüten). Die Büsche wurden ohne die Farbschleier der ursprünglichen Vorschauen neu erstellt. Insgesamt 17 Produktions-PNGs.

## Größe, Platzierung und Kollisionen

Eine 64 Pixel große Figur entspricht 2 Metern. Gewöhnliche Räume sind 896 × 512 Weltpixel groß, die Arena-Halle 1344 × 768. Die Pflanzen, Türen und Möbel wurden in den gerenderten Spielansichten neben dieser Figur geprüft. Der Spawn ist vollständig sichtbar und hat freie Treppen und Laufwege; Säulen, Kristallsockel und Plattformwände besitzen separate Hitboxen.

Bild und Raumkollision verwenden dieselbe Umrechnung von Quellpixeln zu Weltpixeln. Wände, Schränke, Werkbänke, Tische, Stühle und Bänke blockieren den tatsächlichen Körperradius, auch bei schnellen Bewegungen. Teppiche und Heilfeld bleiben begehbar. Baumkronen und Dorfobjekte überschneiden keine Hausgrafiken oder die Spawnplattform. Baumstämme und Laternenfüße blockieren; die zuletzt gewünschte Begehbarkeit der Büsche bleibt erhalten.

Pips Werkstatt ist durch Borins Seitentür erreichbar. Ihr Ausgang führt zu Borin zurück, danach ins Dorf an die ursprüngliche Eintrittsposition. Elaras Heilfeld stimmt mit der Grafik überein; das nördliche Tor der Arena-Halle öffnet den vorhandenen Arena-Einstieg.

## Geänderte Systeme

- `main.gd`: Bewohnerpositionen, Raumwechsel, Interaktionshinweise, Dorfobjekte und Hitboxen.
- `components/village_interiors_32.gd`: acht datenbasierte Räume, Möbel, Bild- und Kollisionsumrechnung.
- `components/arena_interior.gd`: gemeinsame Arena-Hallendarstellung.
- `components/start_scenery_32.gd`: neue Pflanzen und Brunnen; transparente Pixelränder werden beim Laden bereinigt.
- `components/spawn_platform_32.gd`, `spawn_stone_body.gd`: Spawnbild, Tiefensortierung, Höhen und acht solide Bereiche.
- `components/village_layout.gd`, `village_fixtures.gd`, `map0_ground_plan_32.gd`: verteilte Dorfobjekte, verschobene Grundstücke und freie Wege.
- `components/food_system.gd`: Erntepositionen folgen den neuen Büschen.
- `components/patch_notes.gd`: sichtbare Versionshinweise.
- Prüfungen in `tools/check_content.py`, `check_map0_legacy_building_assets.gd`, `check_village_collisions.gd`, `check_spawn_platform.gd`, `check_spawn_network.gd`, `tests/gameplay/check_map0_scenery_cleanup.gd` und neu `check_village_room_assets.gd`; Bildprüfung über `tools/capture_village_upgrade.gd`.

## Spell-Fusionen und frühere Aufgaben

Die vorhandenen 528 eindeutigen Zweierfusionen bleiben im datenbasierten Fusionskatalog. A+B und B+A besitzen dieselbe kanonische Kennung. Voraussetzungen, fehlende Spells und Verfügbarkeit werden weiterhin durch die bestehenden Charakterdaten bestimmt. Vollständige Liste: [spell-fusionen.csv](spell-fusionen.csv). Umhangrichtungen, zehn Roboter-Kopfschmücke, zehn Fenna-Brustabzeichen und Borins wirksame Runentokens sind unverändert erhalten und werden durch die Regressionstests geprüft.

## Prüfung

65 lokale Godot-Prüfungen plus zwei Speichertests mit einem isolierten lokalen Server. Zusätzlich Contentprüfung und gerenderte Dorf- und Raumansichten. Geprüft werden alle neun Bewohner-IDs und acht Grafiken, Eingänge, Möbelhitboxen, schnelle Bewegungen, erreichbare Bewohner, Pip-Raumwechsel, Heilung, Arena-Zugang, Spawn und Multiplayer.

Keine neuen Platzhalter. Die ursprünglichen Vorschauen unter `docs/previews/` bleiben zur Dokumentation erhalten; das Spiel lädt ausschließlich die Produktionsgrafiken.
