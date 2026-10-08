# Sonnenhain – 3D-Waldschleim als späterer Test

Status: Gespeichertes Konzept für die Zukunft. Noch keine 3D-Umstellung im Spiel.

## Nutzerentscheidung

Die Monster- und Charakterdarstellung soll möglicherweise auf echtes 3D
umgestellt werden. Zuerst wird ausschließlich der Waldschleim als Prototyp
untersucht. Die übrigen 26 Monsterentwürfe bleiben archiviert.

## Waldschleim-Identität

Unser erster, schwächster und einfältigster Gegner bleibt ein süßer grüner
Glibberschleim: niedrige runde Kuppel, breite weiche Basis, wenige Glibberlappen,
freundliche Glanzaugen, kleines Lächeln und dezente Wangen. Keine Blätter,
Blüten, Waffen oder Ausrüstung.

Visuelle Referenz: [süßer Waldschleim](waldschleim-v2/waldschleim-v3-suess.png).
Ursprüngliche Sammlung: [27 Monsterentwürfe](monster-design-v1/README.md).

## Erster 3D-Prototyp

- Einfaches echtes 3D-Modell der Glibberform; PNG als Form- und Farbvorlage.
- Klare Grünflächen und zurückhaltender Glanz. Realistische Glasoptik nur
  untersuchen, wenn sie auf der Pixelkarte lesbar und im Browser bezahlbar bleibt.
- Orthografische Kamera, deren Blickwinkel zur vorhandenen RPG-Karte passt.
- Animation durch Körperverformung: ruhiges Wackeln, Zusammendrücken, Strecken,
  Hüpfen, breite Landung, Körperstoß, Trefferreaktion und Zusammensacken.
- Zunächst separat in einem 3D-Viewport rendern und an der bestehenden
  Waldschleimposition in die 2D-Welt einfügen. Blickrichtung aus der Spielbewegung.
- Bewegung, Trefferkörper, Kampfwerte und erster einfacher Angriff bleiben
  beim vorhandenen Spielsystem. Darstellung und Kampfentscheidung getrennt halten.

## Prüfpunkte vor einer weiteren Umstellung

- Größe neben dem 64-Weltpixel-Charakter und klare Lesbarkeit auf Gras/Pflaster.
- Richtige Überdeckung hinter Bäumen, Häusern und anderen Weltobjekten.
- Licht und Schatten passen zur bestehenden Karte; keine störenden Halos.
- Übereinstimmung von Animation, Fußposition und Trefferzeit.
- Leistung und Ladezeit im Browser, auch bei mehreren sichtbaren Schleimen.
- Koop: gleiche Position, Blickrichtung und Angriffszustände für alle Spieler.
- Sichtbarer Vergleich mit dem bestehenden 2D-Schleim; rückschaltbarer Test.

## Spätere Möglichkeiten

1. 3D-Figuren auf der 2D-Karte: weitere Monster, Charaktere und NPCs samt
   sichtbarer Ausrüstung und Animationen. Die Umgebung kann Pixelart bleiben.
2. Komplettes 3D-Sonnenhain: zusätzlich Gelände, Häuser, Innenräume, Möbel,
   Vegetation, Dorfobjekte, Arena und Dungeonobjekte modellieren.

Welche Richtung folgt, wird erst nach dem Waldschleim-Test entschieden.
Quest-, Inventar- und Wertelogik benötigt dafür keine komplette Neuentwicklung.

## Veröffentlichungsumfang jetzt

Die 3D-Arbeit und neuen Monsterentwürfe sind ausschließlich Dokumentation.
Veröffentlicht werden die fertiggestellten Arkanhalsketten und die Korrekturen
für feste Menüs sowie vollständige Nebel-/Atmosphärenabdeckung beim Zoomen.
