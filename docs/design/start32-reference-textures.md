# Sonnenhain – Starttexturen v28.3

Spiel: http://localhost:8787/start32-game/index.html

Umgebung von Map0, 1780×2600 Welteinheiten, 32×32-Pixel-Bodenraster. Figuren und Fähigkeiten verwenden ihre vorhandenen Animationssysteme.

## Grafiken

- src/dev/art/start32/objects-faithful.png: Wohnhaus, Elaras Laden, Taverne, Eiche, Brunnen, Spawnkristall.
- src/dev/art/start32/props-faithful.png: Warenwagen, Blumenbusch, Fässer, Laterne, Anschlagtafel, Tor.
- src/dev/art/start32/materials-faithful.png: Gras, Blumenwiese, Erdweg, unregelmäßiges Pflaster, Mauerstein, Waldboden.
- terrain_32.png und start_tileset_32.tres im selben Ordner: natives Godot-TileSet mit exakten 32px-Zellen. Materialien in zusammenhängenden 4×4-Patches, Wegkanten mit Alpha.

Transparente Objekte werden einzeln aus ihren Atlanten gezeichnet und nach Bodenkontakt sortiert. Kein Gesamtbild einer Map wird als Hintergrund eingesetzt. Gebäude behalten ihre Grundfläche; mehrstöckige Dachgrafiken stehen 32px über die frühere Oberkante. Cachegrenzen wurden erweitert. Die Tavernentür liegt entsprechend der sichtbaren Grafik bei Hausposition+(126,157).

## Bildgenerierung

Built-in imagegen, Referenzen: freigegebene Galerieblätter 01 und 02. Kein CLI-Fallback. Die Originale unter .codex/generated_images bleiben erhalten; alle eingesetzten Atlanten wurden in dieses Projekt kopiert.

Promptvorgaben für Objekte: Produktions-Spriteatlas; detailreiche Fachwerk-, Terrakotta-, Laub-, Stein- und Kristallgestaltung wie die Referenz; einzelne orthografische RPG-Objekte; reale Alpha-Transparenz; keine ganze Map, Schrift oder Figuren. Wohnhaus, Trankladen, Taverne, Eiche, Brunnen und Spawnkristall sowie Warenwagen, Blumenbusch, Fässer, Laterne, Anschlagtafel und Tor. Separater Hintergrundextraktionsschritt für den Objektatlas.

Promptvorgaben für Materialien: getrennte nahtlos wiederholbare Gras-, Blumen-, Weg-, Pflaster-, Mauer- und Waldbodenflächen im gleichen Pixelstil und in der Referenzpalette. Größenanpassung und Tile-Aufbereitung deterministisch durch tools/build_start_tiles_32.gd.

## Validierung

Map-Logik: 0 Fehler. Ausrüstung/Sterben bestanden. Native32px: 4592 Weltzellen, transparente Sprite-Ecken und Tavernenzugang geprüft. Hausverdeckung hinter/vor dem Gebäude korrekt. Cachevergleich: 0 abweichende Pixel. Lokale CPU-Zeichenzeit im Test: Median 0,689ms mit Cache, 3,142ms ohne; keine FPS-Zusage für andere Geräte. Browser-Sichtprüfung: neue Grafiken geladen, keine Konsolenfehler.
