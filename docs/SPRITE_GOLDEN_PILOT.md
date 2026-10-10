# Golden-Sprite-Pilot: Menschlicher Krieger + Waldschleim

Stand: 2026-10-04

## Ziel

Die prozeduralen Figurenrenderer werden schrittweise durch produktionsfähige Sprites ersetzt. Der erste Pilot umfasst genau zwei Referenzen:

- Menschlicher Krieger als Golden Character
- Waldschleim (Enemy Type 0) als Golden Mob

Der bestehende prozedurale Renderer bleibt während des Piloten als Fallback erhalten.

## Gemeinsamer Richtungsstandard

Der vorhandene Runtime-Index aus `Hero.direction_index(look)` ist maßgeblich:

| Index | Richtung |
|---:|---|
| 0 | S |
| 1 | SW |
| 2 | W |
| 3 | NW |
| 4 | N |
| 5 | NE |
| 6 | E |
| 7 | SE |

Alle Sheets ordnen ihre Richtungen exakt in dieser Reihenfolge an.

## Golden Character: menschlicher Krieger

Identität:

- kräftige, klar lesbare Krieger-Silhouette
- Silber / Nachtblau / Sonnengold
- Schwert und Sonnenschild
- braunes Haar
- klassische Sonnenhain-Fantasy statt moderner Sci-Fi-Anmutung

Technik:

- Frame: 96 × 96 px
- Fußanker: y = 79 px (≈ 82 %)
- echte 8 Richtungen, keine gespiegelten Ersatzansichten
- transparenter Hintergrund
- harte Pixelkante; keine halbtransparenten Schatten außerhalb des Körpers

Geplante Animationsreihen:

- idle
- walk
- run
- attack_1 (Schwert)
- attack_2 (Schildhieb)
- ability
- hit
- death
- dodge

Ausrüstung wird später in getrennte Layer überführt. Der Golden Pilot darf zunächst als zusammengesetzte Basisfigur integriert werden, um Stil, Lesbarkeit, Fußanker und Kameramaßstab zu validieren.

## Golden Mob: Waldschleim

Identität:

- kräftiges Waldgrün mit hellen limettengrünen Lichtkanten
- asymmetrischer Blattspross als Richtungsanker
- kompakte, gewichtige Form statt Maskottchen-Look
- Gesicht nur auf Vorder- und Seitenansichten; Rückansichten bleiben wirklich gesichtslos

Technik:

- Produktionsframe: 128 × 128 px
- Fußanker: y = 105 px (≈ 82 %)
- echte 8 Richtungen
- transparenter Hintergrund
- Squash-and-Stretch über Spriteframes, nicht über Runtime-Geometrie

Geplante Animationsreihen:

- idle
- move
- attack
- hit
- death

## Vorgesehene Assetpfade

```
art/sprites/characters/golden_human_warrior/
  idle_8dir.png
  walk_8dir.png
  run_8dir.png
  attack_1_8dir.png
  attack_2_8dir.png
  ability_8dir.png
  hit_8dir.png
  death_8dir.png
  dodge_8dir.png

art/sprites/mobs/golden_forest_slime/
  idle_8dir.png
  move_8dir.png
  attack_8dir.png
  hit_8dir.png
  death_8dir.png
```

## Runtime-Integration

### Spieler

`components/rpg_hero.gd` bleibt vorerst der Fallback. Der Spritepfad soll nur für `role == 0 && race == 0` aktiviert werden, bis der Golden Character im echten Spiel abgenommen ist.

Die Runtime muss weiterhin berücksichtigen:

- `look` → 8-Richtungs-Index
- walk/run state
- roll/dodge
- death
- hurt flash
- Ausrüstung/Fallback, solange einzelne Layer fehlen

### Waldschleim

`components/monster_design_32.gd` enthält bereits den dedizierten `paint_waldschleim`-Pfad für `t == 0`. Dieser ist die direkte Fallbackstelle, sobald das Sprite-Sheet vorhanden ist.

## Abnahmekriterien im Spiel

1. Figur rutscht beim Richtungswechsel nicht am Boden.
2. Fußpunkt bleibt in allen acht Richtungen identisch.
3. S/N/E/W und Diagonalen sind ohne Namensschild sofort unterscheidbar.
4. Krieger bleibt bei normalem Zoom klar als Sonnenhain-Krieger lesbar.
5. Waldschleim bleibt in Bewegung eindeutig erkennbar und wirkt nicht wie ein generischer Blob.
6. Keine sichtbaren Hintergrundrechtecke oder Alpha-Säume.
7. Keine Änderung an Kollisionsradius, Kampfwerten oder Loot.
8. Multiplayer und Character-Preview verwenden denselben Richtungsindex.
9. Der prozedurale Renderer kann per Fallback weiterlaufen, bis alle benötigten Animationsreihen vorhanden sind.

## Pilot-Artefakte

Für die visuelle Stilabnahme wurden am 2026-10-04 bereits eine Golden-Character/Golden-Mob-Konzepttafel sowie je ein extrahiertes 8-Richtungs-Idle-Testsheet erzeugt. Diese dienen zunächst als Stil- und Maßstabsreferenz; die finalen Produktionssheets sollen als saubere transparente Einzelassets in die oben genannten Pfade übernommen werden.

## Aktueller Produktionsstand (2026-10-05)

Bereits live:

- menschlicher Krieger: authored 8-Richtungs-Idle-Sprite
- menschlicher Krieger: 8-Richtungs-Sprunganimation mit 8 Frames je Richtung
- Waldschleim: authored 8-Richtungs-Idle-Sprite
- gemeinsamer Golden-Sprite-Runtime-Loader mit prozeduralem Fallback

Noch offen aus dem ursprünglichen Pixelart-Plan:

- Krieger: walk, run, attack_1, attack_2, ability, hit, death, dodge als authored Sprites
- Waldschleim: move, attack, hit, death als authored Sprites
- anschließend Ausrüstung in getrennte Sprite-Layer überführen, sobald die Basisanimationen vollständig abgenommen sind

Wichtig: Diese offenen Reihen werden nicht durch alte Branches blind zurückgemerged. Neue Sprite-Arbeit muss auf dem aktuellen `main` aufsetzen, damit Atelier-, Umhang-, Skill-, Save- und Multiplayer-Fixes erhalten bleiben.

## Stand 2026-10-10: goldener Ritter vollständig

Angelo: Der Krieger soll vollständig der neue Ritter sein, die Vorlagen liegen
im Repo. Vorlage sind die Sprungbilder (`jump/jump-<richtung>-8f-v1.png`);
deren erstes Bild zeigt den Ritter stehend in allen 8 Richtungen.

- `tools/build_golden_warrior.py` erzeugt daraus `knight_8dir.png`:
  Stehen (Atmen), Gehen, Laufen, Angriff, Treffer; Beine werden an der Hüfte
  getrennt und abwechselnd gehoben bzw. geschwungen.
- Rolle und Sturz entstehen im Spiel durch Drehen des Standbilds.
- Gilt für alle menschlichen Krieger (beide Geschlechter); Orks und Roboter
  behalten den gezeichneten Körper. Rüstungen ändern das Aussehen des Ritters
  noch nicht (eigene Ebenen folgen).
- Das alte 24-px-Standbild (`idle_8dir.png`) wird nicht mehr benutzt.
- Vorschau: `docs/konzepte/2026-10-10-bugliste/ritter.png`,
  `ritter_blatt.png`, `krieger.png`.
