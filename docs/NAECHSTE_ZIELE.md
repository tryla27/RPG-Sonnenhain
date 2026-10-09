# Sonnenhain – nächste Ziele

Stand: 9. Oktober 2026. Arkanhalsketten und die ersten vier erneuerten
Waldmonster sind veröffentlicht. Aktueller Schwerpunkt: Startbereich abrunden
und weitere Spielinhalte.
Die zuletzt bestätigten Nutzerentscheidungen haben Vorrang vor älteren Konzepten.

## Entscheidungen

- 9.10.2026: Live-Schaltungen (`[deploy]`) nur nach einmaliger Rückfrage und
  ausdrücklicher Bestätigung durch Angelo, jedes Mal. Sonst freie Hand.
- 9.10.2026: Neuer Code kommt in Module unter `components/`, nicht in
  `main.gd` (Regeln in `AGENTS.md`).
- 9.10.2026: Modularisierung nach vier Modulen (Inhalte, Netzwerk, Weltgeometrie,
  Gegenstände) pausiert. Weitere Teile nur herauslösen, wenn ohnehin dort
  gearbeitet wird. Schwerpunkt jetzt: Spielinhalte und Startbereich.
- 9.10.2026: Klangrichtung für alle Sounds: 16-Bit, märchenhaft
  (`docs/sound/KONZEPT.md`).

## 1. Startbereich abrunden

Dorf → Blütenwiesen → erstes Waldstück einmal komplett durchspielen und alles
glätten, was dort hakt: Trefferflächen, Balance, Sounds und Übergänge. Die
ersten Spielminuten entscheiden, ob jemand weiterspielt.

## 2. Sounds

Neues Soundkonzept: `docs/sound/KONZEPT.md`. Erst Paket 1 (Kampfgefühl im
Startbereich), danach Oberfläche, Fähigkeiten, Atmosphäre und übrige Gegner.
Klangrichtung: 16-Bit, märchenhaft. Sounds entstehen überwiegend per Skript.

## 3. Schrittweise Modularisierung von `main.gd`

Pausiert (siehe Entscheidungen). Bereits ausgelagert: `game_content.gd`,
`network_codec.gd`, `world_geometry.gd`, `item_rules.gd`.
Vorgehen beim Herauslösen: `AGENTS.md`, Abschnitt 4.

Referenz: `docs/architecture/main-modularization.md`.

## Weitere bereits dokumentierte Ziele

Die folgenden Vorhaben sind aus vorhandenen Konzepten übernommen. Einige Teile
sind bereits umgesetzt; vor Arbeitsbeginn den aktuellen Live-Stand prüfen.

### Vollständige Pixelart-Spriteumstellung

**Für später: 3D-Waldschleim-Test** gemäß [gespeichertem Konzept](WALDSCHLEIM_3D_KONZEPT.md). Die Monsterumstellung wird jetzt nicht veröffentlicht.

**Waldmonster:** Waldschleim, Käfer, Pilz und Moosrolf sind erneuert und live
(siehe unten). Die [Designsammlung für alle 27 Monster](monster-design-v1/README.md)
bleibt die Vorlage für die übrigen 23 Monster, die Gebiet für Gebiet nach dem
gleichen Muster folgen. [Waldschleim-Entwurf v2](waldschleim-v2/README.md).

- Hochwertige Bitmap-Sprites für 18 Spieleridentitäten (3 Klassen × 3 Völker ×
  2 Erscheinungen), 27 Mobtypen und anschließend wichtige NPCs.
- Acht echte Blickrichtungen, konsistente Identität und vollständige Animationen.
- Golden-Pilot für menschlichen Krieger und Waldschleim ist vorhanden; Ausbau
  der Animationen und Übertragung auf die übrigen Figuren bleiben Folgearbeit.
- Ausrüstung und kosmetische Teile in passende sichtbare Layer überführen.

Referenzen: `docs/SPRITE_GOLDEN_PILOT.md` und die Übergabe
`WEITERARBEIT_SPRITES.md` in der übergeordneten lokalen Projektwurzel.

### Fenna: umfassende Gestaltung und Vorschau

- Gemeinsame Farbauswahl aus Gegenstands- und Tilefarben mit Materialbereichen.
- Farben getrennt pro Gegenstand speichern; alle Klassen und Völker unterstützen.
- Vorschau für Blickrichtungen, Stehen, Laufen, Sprinten und vorhandene Sprünge.
- Passende Umhangbewegung und vollständige Maus-/Tastaturbedienung.

Referenz: `design-entwurf/fenna/FENNA_KONZEPT.md` in der übergeordneten
lokalen Projektwurzel. Umhang- und Farbteile sind teilweise bereits vorhanden.

## Bereits erledigt und live

- Arkanhalsketten (Commit `c721f7a`): sechs klassenübergreifende Halsketten,
  eigener Ausrüstungsplatz, Bossdrops, Umwandlung alter Kerne, Koop-Sync.
  Regeln und Prüfungen: `docs/arcane-necklaces/README.md`.
- Erste vier Waldmonster erneuert: Waldschleim, Käfer, Pilz und Moosrolf mit
  Sprites in acht Richtungen, vollständigen Posenzyklen, Drüsenschüssen,
  Giftstaub, Wolfssprung, dauerhafter Verfolgung mit Hindernis-Routing und
  Pilz-Giftzischen. Vorschauen: `docs/mob-erneuerung/`.

- Dorfplatz und Bodenflächen im vereinbarten Pixelstil; Sand durch Gras ersetzt.
- Verbundene Kopfsteinpflasterwege und passende Hauseingänge; breitere Arenawege.
- Baum- und Laternenplatzierung sowie zusätzliche Blumen und Blumenbüsche.
- Zwei Steinebenen und Treppen nur an der Kirche; keine erhöhten Sockel an
  Borins Haus oder der Schmiede.
- Natürliche Übergänge zwischen Kopfsteinpflaster und Spawnplatten ohne Karomuster.
