# Sonnenhain – Gameplay Redesign v28

Branch: `feature/gameplay-redesign-v28`

## Ziel
Sonnenhain wird so modularisiert, dass Bewegung, Klassen/Rassen, Kartenlesbarkeit, Minimap und Atmosphäre separat verändert werden können.

## 1. Bewegung & Animation
- 8 Richtungen für alle Spielercharaktere: N, NE, E, SE, S, SW, W, NW
- Zustände: Idle, Walk, Roll, Attack
- Rollanimation neu aufbauen
- gleiche Richtungslogik für alle Charaktere
- Animationen werden über Daten/Profile gesteuert

## 2. Rassen
### Mensch
- Standardgeschwindigkeit
- ausgewogene Werte

### Ork
- langsamer
- robuster
- mehr Lebenspunkte
- etwas mehr physischer Schaden

### Roboter
- stabil
- leicht höhere Resistenz
- mittlere Geschwindigkeit

## 3. Klassen
### Krieger
- normale Geschwindigkeit
- darf rollen
- hohe Nahkampfstärke

### Magier
- darf NICHT rollen
- höherer Magieschaden
- geringere Mobilität

### Bogenschütze
- schneller
- darf rollen
- bessere Rollgeschwindigkeit

## 4. Map-Lesbarkeit
Nicht passierbare Bereiche müssen optisch sofort erkennbar sein.
- blockierende Büsche deutlich dichter/dunkler
- Mauern/Felsen klarer von Dekoration trennen
- Kollisionsbereiche dürfen nicht wie begehbare Dekoration wirken
- spätere Tile-Kategorien: PASSABLE, SOFT_BLOCK, HARD_BLOCK, WATER, WALL

## 5. Minimap 2.0
- genauere Weltgrenzen
- Spielerposition und Blickrichtung
- Wegsteine, Quests, Portale, Dungeons
- unterschiedliche Marker-Prioritäten
- bessere Kontraste und Gebietsnamen

## 6. Licht, Schatten & Atmosphäre
- weichere Schatten
- abgestufte Schattierung
- Nebel mit Dichte und Farbton
- Dämmerung mit weicher Farbinterpolation
- getrennte Profile für Tag, Abend, Nacht und Spezialregionen

## Geplante Integrationsreihenfolge
1. 8-Richtungs-Bewegungslogik
2. Rassen-/Klassenprofile
3. Rollregeln
4. Character-Sprite-Layout
5. Map-Lesbarkeit
6. Minimap 2.0
7. Schatten / Nebel / Dämmerung
8. Multiplayer-Sync der neuen Zustände
