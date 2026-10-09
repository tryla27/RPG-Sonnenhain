# Sonnenhain – umgesetzte GBA-Dorfkarte

Lokaler Implementierungsstand vom 8. Oktober 2026 auf Basis von GitHub `c877d49`.
Arbeitszweig `codex/dorfkarte-gba-boden`. Keine Veröffentlichung vorgenommen.

## Ergebnis

Die gesamte Map 0 verwendet neue ImageGen-basierte PNG-Bodenmaterialien in
nativer 32px-Aufteilung, mit sechs Farben für Natur/Erde und acht für Stein.
Grundlage ist die vom Nutzer akzeptierte Bodenauswahl und Spawn-Vorschau v3.
Spielstände und Regionsübergänge sind unverändert. Die spätere Platzierungsänderung
für Wege und Dekoration ist unten dokumentiert.

Nach der Nutzerkorrektur: Der Arena-Rand verwendet dasselbe schiefergraue
Kopfsteinpflaster wie die Dorfwege, keine violetten Blockreihen. Bäume stehen auf
der gleichen Wiese; kleine transparente Kupferblattauflagen ersetzen die fremden
braunen Bodenflecken.

Nutzeränderung vom 8. Oktober: Gelbe Erd-/Sandflächen sind auf der gesamten
Dorfkarte durch Wiese mit sparsamen Blumen ersetzt, einschließlich der freien
Arenahoffläche. Pflaster, Spawnplatten, Türvorplätze und Arenaeingang bleiben
erhalten. Die Blumenauflagen verwenden die vorhandenen nativen Zeichnungen
aus dem Terrain-Overlayatlas, ohne neue Kollisionen. Gelbe Bodenfamilien werden
im neuen Map-0-Stil nicht mehr ausgewählt; bestehende Familien-IDs und logische
Materialdaten bleiben kompatibel.

Weitere Nutzeränderung vom 8. Oktober: Alle sieben Eingänge sind durch ein
zusammenhängendes Kopfsteinpflasternetz verbunden. Vorplätze und Arena-Zugang
verwenden das gleiche Muster. Durchgehende Fahr-/Laufwege sind 96 Pixel bzw.
drei volle Tiles breit, auch westlich und östlich der Arena; Achsen liegen dafür
auf Tilemitten statt auf Rasterkanten.

Die Arena ist bei gleicher Größe 128 Pixel nach links versetzt: Bildanker
(544,1440), Tür (1081,2420), Arven (1081,2460). Alle abhängigen Außenkollisionen
leiten sich weiterhin aus den Gebäudespezifikationen ab. So entsteht Platz für
den rechten Rundweg, ohne das Bauwerk zu verkleinern. Innenräume bleiben erhalten.

Die fünf normalen Bäume stehen an neu ausgewählten Grasstellen; Borins Runenbaum
steht bei (1120,480). Die Laternen stehen am Wegrand und projizieren ihr Licht
auf die nächste Pflasterstelle. Dreizehn echte Blumenbusch-Sprites und deutlich
mehr Blumenauflagen beleben besonders die linken und nordöstlichen Grasbereiche.
`components/village_paths.gd` ist die gemeinsame Quelle für das Wegenetz und
die Lichtausrichtung. Prüfungen kontrollieren zusätzlich die drei Tile breiten
Arenawege und zusammenhängende, physisch begehbare Pflasterrouten zu allen Türen.

Weitere Ausarbeitung: Borins Haus, Schmiede und Kapelle stehen auf zwei
16-Pixel-hohen Steinterrassen (16 und 32 Weltpixel Höhe). Zwei kompakte, jeweils
128 Pixel breite Treppenläufe verbinden Straße, Zwischenpodest und Tür.
Die Gebäudegrafiken bleiben am bisherigen Bildschirmanker; Weltbasis,
Tür-/Kollisionsanker und zugehörige NPC-Positionen berücksichtigen die 32 Pixel
Höhe. Figur, Waffe und Namensschild werden gemeinsam höhenversetzt; die selben
Höhenregeln gelten für andere Spieler. Seitliche Klippen können nicht normal
durchlaufen werden, die Treppenkorridore bleiben mit dem größten Figurenradius
begehbar. Die vorhandene Spielstand-Ladeprüfung versetzt unzulässige Positionen
weiterhin an einen sicheren Ort.

An drei Anschlüssen zum Spawn ist `spawn_crossing` als dreizehnte Bodenfamilie
eingebaut: ineinandergreifende Bänder aus Kopfsteinpflaster und den Spawnplatten.
Der native PNG-Atlas ist jetzt 512×416 Pixel groß (208 Plätze). Die Mischgrafik
wird aus den vorhandenen beiden Materialien zusammengesetzt und auf acht Farben
begrenzt. Die 128px-Quelle liegt als `mixed_crossing_128.png` bei.

Nahansichten: `05-raised-forge.png`, `06-raised-borin.png`,
`07-raised-church.png`, `08-mixed-stone-crossing.png`.

`01-gesamte-dorfkarte.png` und `02-spawn-und-dorfmitte.png` sind echte
Godot-Renderings der eingebauten TileMap mit den aktuellen Dorf-PNGs. Sie sind
keine neu generierten Konzeptbilder. Die sechs Chunk-Ansichten dokumentieren
die restlichen Kartenteile. `03-boden-ohne-objekte.png` zeigt den gesamten Boden.

## Technik und Leistung

- Familien-IDs und alle 4592 logischen Materialfelder bleiben erhalten.
- Zwölf Familien × sechzehn 32px-Unterfelder = 192 Atlasplätze. Die Unterfelder
  einer 128px-Textur werden räumlich zusammenhängend verwendet statt zufällig
  durcheinandergewürfelt. Import: verlustfrei, ohne Mipmaps; Filter Nearest.
- Acht Nachbarn, 47 gültige Blob-Konfigurationen, vollständige konkave/konvexe
  Ecken und globale Pixelkonturen für natürliche Sand-/Grasränder.
- Ruhige zusammenhängende Flächen statt zufällig eingestreuter Wald-/Steinplätze.
- Reale Spawnplattform berücksichtigt: (569,655), Größe 512×480; Gameplay-Spawn
  (825,915) bleibt erhalten.
- Übergänge werden beim Vorbereiten in deckende PNGs für die sechs bestehenden
  Kartenbereiche gebacken, statt 235 einzelne Paar-Atlanten zeichnen zu müssen.
  Kein Blur und keine halbtransparenten Bodenränder.
- Chunk-Texturen höchstens 896×896; keine große 2624px-GPU-Textur nötig.
- SHA-256 über Grundgrafik, Auflagen, geordnetes Kartenlayout und Algorithmusrevision
  verhindert die Verwendung veralteter vorgerenderter Bereiche. Bei Abweichung
  wird korrekt neu zusammengesetzt. Normale Starts verwenden die vorhandenen PNGs.
- Live-TileMap und der bestehende Cache-Painter verwenden dieselben Texturen.

Der alte Stil bleibt zum Vergleichen erreichbar, indem in Godot die Projekteinstellung
`sonnenhain/terrain/gba_enabled` auf `false` gesetzt wird. Standard ist `true`.
Es gibt keine zusätzliche Auswahl in der Spieloberfläche.

## Dateien

- Produktionsgrafiken: `art/terrain/gba_v1/ground_32.png`, `foliage_32.png`, `chunks/`.
- Zeichen-/Generierungsquellen: `art/terrain/gba_v1/source/`.
- Importaufbereitung: `tools/build_gba_ground.gd` (Nearest-Neighbor, Palettenreduktion,
  gegenüberliegende 128px-Ränder paaren, einzelne Blattpixel als Alpha-Auflage).
- Neu backen: `tools/bake_gba_map0.gd`, anschließend Godot-Import ausführen.
- Ansichten erzeugen: `tools/capture_gba_map0.gd`.
- Quellenbilder, Musterübersicht und QA-Ansichten sind vom Spielpaket ausgeschlossen.

## Bildgenerierung

Eingebaute ImageGen-Funktion mit der akzeptierten zwölfteiligen Bodenauswahl
als Referenz. Prompt: dieselben zwölf Bodenmaterialien im 4×3-Raster, deutliche
quadratische Pixel, klassische GBA-Draufsicht, warme Herbstpalette, begrenzte
Farbstufen, gegenüberliegende Kanten je Material passend, ohne Gebäude, Figuren,
Text, Glows oder weiche Verläufe. Die Ausgabe wurde anschließend technisch auf
exakte native Pixel, Paletten und gemeinsame Randpixel normalisiert. Sie wurde
nicht als ungeprüftes 32px-Sheet direkt eingebaut.

## Verifikation

- `check_gba_ground.gd`: 47 Masken, natürliche/Stein-Paletten, Alpha, Materialränder,
  gültige sechs gebackene Bereiche, korrigierte Arena-/Baumböden, physische Wege
  vom Spawn zu allen sieben Eingängen und beiden geöffneten Toren mit dem größten
  vorhandenen Figurenradius. Bewegungssegmente in 8px-Schritten geprüft.
- `check_gba_render_paths.gd`: vollständige 1780×2600-Ansicht per TileMap und
  direktem Cache-Painter pixelidentisch.
- Bestehende Kartenmaterial-, Übergangs-, Dorfkollisions- und Inhaltsprüfungen.
- Gesamte Karte, Spawn und Nordost-Ausschnitt visuell kontrolliert.
- Web-Release erfolgreich nach `build/gba-preview/game/` exportiert. Dieselbe
  neue Boden-/Wegeprüfung anschließend aus dem exportierten `index.pck` ausgeführt:
  alle Prüfungen bestehen auch ohne Zugriff auf die originalen Projektdateien.

Die Implementierung ist lokal reviewbar; sie wurde noch nicht live ausgerollt.

## Final publication adjustment
Borin and the forge remain at ground level without raised foundations or stairs. Only the church retains its two stone levels and stairs.
