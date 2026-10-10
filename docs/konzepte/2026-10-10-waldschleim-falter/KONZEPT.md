# Waldschleim und Himmelsfalter – Konzept und Umsetzung (10.10.2026)

Angelo: „Sieh dir den Waldschleim an, er ist leider immer noch zu unsmooth bei
Bewegungen, er soll ikonisch werden als erster Mob … dann mache ebenfalls ein
Konzept für den Himmelsfalter.“ Das Konzept entstand in einem anderen Chat auf
Angelos Rechner (dort abgebrochen, nichts hochgeladen); hier übernommen und neu
umgesetzt.

## Waldschleim: ikonischer erster Mob

- Elastizität und Blatt als Markenzeichen.
- Hüpfer: zusammendrücken → strecken → kurzer Flug → breit landen → zweimal
  sanft nachfedern.
- Blatt schwingt verzögert hinterher; im Stand ruhiges Atmen, Blatt wiegt sich,
  gelegentlich zuckt es.
- Angriff, Treffer und Niederlage bleiben die gezeichneten Bilder; Kampfwerte
  unverändert.

**Umsetzung:** `tools/build_slime_parts.py` zerlegt das Ruhebild jeder Richtung
in Körper und Blatt (`art/sprites/mobs/woodland_v3/forest_slime/parts/`).
`components/forest_slime_motion.gd` verformt beides stufenlos (Hüpfbogen mit
weich interpolierten Schlüsselstellen, Blatt verzögert, Neigung im Flug,
Schatten wird beim Abheben kleiner). Vorher: acht harte Laufbilder.

## Himmelsfalter: schwebender Sternenträger

- Flauschiger dunkelvioletter Nachtfalter, große obere und kleinere untere
  Flügel, gefiederte Fühler.
- Lavendel, Perlmutt, wenige Goldakzente; sternförmige Augenzeichnung auf den
  oberen Flügeln.
- Echter Flügelschlag, untere Flügel verzögert; Schweben auch im Stand; Neigung
  beim Fliegen; eigener Rhythmus je Falter.
- Angriff: Flügel spreizen, Sternaugen hellen auf, Sternenstaub-Schuss.
- Niederlage: Flügel einklappen, absinken, helle Staubpunkte.

**Umsetzung:** `components/himmelsfalter_art.gd` (stufenlos gezeichnet, ersetzt
den bisherigen Block-Ersatz), Schuss `HimmelsfalterArt.draw_shot`.

## Vorschau

- `vorschau.gif` (bewegt, `tools/capture_slime_moth.gd` + `tools/make_gif.py`)
- `standbild.png`, `falter_im_spiel.png`

## Später

- Sternenfächer mit drei Geschossen als zusätzliche Fähigkeit des Falters.
- Prüfen, ob ein Teil des Ruckelns online aus Navigation oder Netzbewegung kommt.
