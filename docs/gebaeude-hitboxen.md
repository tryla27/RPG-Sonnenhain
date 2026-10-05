# Gebäude und Hitboxen – 5. Oktober 2026

## Änderungen

- Neue transparente Außenansichten: `art/village/atelier.png`, `skillhaus.png`, `ratshalle.png` (eingebaut, je 448 × 448 Weltpixel).
- Borins Haus steht im Nordosten bei (1248, 64), die Ratshalle bei (1088, 960). Gemeinsame Eingänge für Borin/Pip und Mira/Liora bleiben erhalten.
- Bäume wurden aus Gebäudebereichen entfernt und in freie Dorfbereiche versetzt. Auch die vollständige Baumkrone hat Abstand zum gesamten Gebäude-Sprite.
- Gebäudekollisionen umfassen jetzt die Grundfläche statt nur eines schmalen Fassadenstreifens. Dachüberstände bleiben entsprechend der vorhandenen Perspektive übergehbar.
- Innenräume besitzen individuelle Möbelkollisionen: Theken, Tische, Stühle, Schränke, Esse, Amboss, Lager, Podeste, beide Kirchenbankreihen sowie Arenabänke und Fackelständer.
- `VillageInteriors32.furniture(id)` liefert die modularen Kollisionsflächen pro Raum. `blocked` berücksichtigt den Körperradius der gewählten Figur; die bestehende Bewegung prüft den Weg weiterhin in Schritten von höchstens 12 Pixeln.
- Teppiche, gemalte Runen und Elaras Heilungsfeld bleiben begehbar. Torvald wurde neben seine Esse gestellt, damit er nicht innerhalb ihrer Hitbox steht.

## Prüfung

57 lokale Godot-Prüfungen erfolgreich, einschließlich der fünf lokalen Netzwerkprüfungen. Die zwei zunächst fehlgeschlagenen Geschossprüfungen verwenden jetzt die tatsächliche Fassade statt der alten Hausgröße und wurden erfolgreich erneut ausgeführt.

`tools/check_village_collisions.gd` prüft alle Gebäude-/Baum-Bildgrenzen, Möbel und Körperradius in neun Raum-IDs, Bewegung gegen Möbel sowie Wege vom Eingang zu jedem NPC. `check_village_fusion_upgrade.gd` prüft weiterhin die tatsächliche Erreichbarkeit sämtlicher Haustüren und des Südausgangs vom Spawn. Dorf und Außenansichten wurden zusätzlich mit dem echten Renderer betrachtet.

Die sieben zuvor gezeigten Innenraum-Neuentwürfe liegen weiterhin als Vorschauen in `docs/previews/interiors-2026-10-05/`; die neuen Hitboxen passen zu den derzeit tatsächlich gezeichneten Innenräumen. Diese Vorschaugrafiken enthalten Referenzfiguren und werden deshalb nicht ungeprüft als begehbare Raumtexturen verwendet.

## Bilderzeugung

Die drei Außenansichten wurden mit dem eingebauten Imagegen-Werkzeug erstellt. Gemeinsamer Prompt: eigenständiges transparentes Sonnenhain-Gebäude-Sprite, einfache 2D-Pokémon/GBA-Pixelgrafik, frontale orthografische Perspektive mit sichtbarem steilem rotem Ziegeldach, cremefarbener Putz, braunes Fachwerk, grauer Steinsockel und warme goldene Fenster; quadratisches Bild, mittige Eingangstür am unteren Rand, zwei Geschosse, passend zur 2 m großen Spielfigur; ohne Charaktere, Bäume, Gras, Schrift oder UI.

Motivzusätze: Fenna – Schneiderzeichen mit Schere und Garn, zwei Stoffschaufenster; Borin – Buchschild, dezentes blaues Runenfenster und kleiner Schornstein; Mira/Liora – Blattwappen über einer mittigen Doppeltür und ausgewogene Fenster.
