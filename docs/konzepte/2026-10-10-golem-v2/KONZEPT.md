# Dunkler Golem v2 und Spawn-Brummen – Konzept (10.10.2026)

Angelos Liste von 15:52 Uhr, Antworten von 16:55 Uhr (unten). Teil 1 (Kampf,
Technik, Leistung) ist gebaut, Bild `kampf.png`; Teil 2 (Optik) und das
Brummen folgen.

## 1. Spawn-Brummen neu

Nur ein Brummen, das mal tiefer, mal einen Ton höher liegt, sonst nichts.

- Ein tiefer, weicher Grundton (etwa 55 Hz mit zwei leisen Obertönen), kein
  Rauschen, kein Klirren.
- Er wechselt in unregelmäßigen Abständen (4–9 s) sanft zwischen Grundton und
  einem Ganzton höher (etwa 62 Hz) und zurück.
- Als nahtlose Schleife (ca. 40 s), leiser mit Abstand zum Spawn-Stein wie
  vorher, drinnen still.
- Vorab zwei Varianten zum Anhören in der Klangprobe (weicher / etwas
  brummiger), dann einbauen.

## 2. Ruckeln seit dem Golem – Gründe

Gemessen (Testlauf mit Golem, 24 Brocken, 60 umgeworfenen Bäumen):

| Teil | Kosten |
|---|---|
| Golem-Logik pro Bild (Laufen, Feld, Würfe, Wellen) | ≈ 0,04 ms |
| Weltpaket-Anteil des Golems | ≈ 2,8 KB pro Paket, ca. 10 Pakete/s (≈ 28 KB/s pro Spieler) |
| Paket übernehmen | ≈ 0,02 ms |
| Kollision mit Brocken (pro Prüfung) | ≈ 0,06 ms |

Der Golem selbst kostet also kaum Rechenzeit. Wahrscheinliche Ursachen:

1. **3D-Landschaft (#105), am selben Mittag live gegangen.** Rendert ständig ein
   zusätzliches 3D-Bild mit 70–150 Objekten und baut es beim Laufen alle
   0,25 s neu auf. Auf schwächeren Grafikkarten oder im Browser der größte
   Brocken. Bei Angelo fällt sie mit #108 auf 2D zurück.
2. **Skriptfehler neben Kräutern** in jedem Bild (im Browser teuer, weil jede
   Meldung in die Konsole geht). Behoben in #113.
3. **Golem-Daten in jedem Weltpaket**, auch weit weg vom Himmelsgarten.
   Lösung: Golem-Teil nur senden, wenn sich etwas geändert hat oder der
   Spieler im Himmelsgarten ist.
4. **Neuzeichnen der Landschaft**, sobald Bäume umfallen oder nachwachsen
   (ganzer Kartencache wird verworfen). Lösung: nur die betroffenen Kacheln
   neu zeichnen.

Zum Nachweis bei Angelo: eine kleine FPS-/Bildzeit-Anzeige (F3) einbauen.

## 3. Brocken verschwinden nach dem Kampf, 15 min Pause

- Nach Sieg (oder wenn der Golem verschwindet) zerbröseln alle geworfenen
  Brocken innerhalb von 3 s mit kleinem Staub-Effekt.
- Danach ist der Altar **15 Minuten** gesperrt (für alle auf dem Server). Am
  Altar steht „Der Golem erwacht wieder in 12:34“, das Kartensymbol wird grau.
- Die Sperre wird auf dem Server gespeichert (überlebt Neustarts).
- Umgeworfene Bäume wachsen wie bisher nach 10 Minuten nach.

## 4. Optik: feiner, 128 px, größere Beine

- Neuer Golem als **echtes Pixel-Sprite mit 128×128 px** je Bild statt aus
  großen Blöcken gezeichnet. Im Spiel 2,5-fach skaliert (≈ 320 px, weiter 5×
  Spielergröße), dadurch viel feinere Kanten, Steinstruktur, Risse und Licht.
- Ansichten: vorn, Seite, hinten; Zustände: Stehen, Gehen (4 Bilder), Schild,
  Schaben, Stampfen, Schrei, Aufstehen.
- **Beine deutlich größer und stämmiger** (etwa ein Drittel der Höhe).
- Erzeugt von einem eigenen Werkzeug (`tools/build_golem_art.py`), erst ein
  Vorschaublatt zur Freigabe, dann Einbau.

## 5. Größerer Felsregen, weiterer Wurf

- Steinhagel-Feld: Durchmesser **+22 %** (Radius 320 → 390 px).
- Brockenwurf: Reichweite **+22 %** (Flug 480 → 586 px, Rollen 96 → 117 px).
- Warnstreifen und Felsregen-Klang passen sich an.

## 6. Steine sehen aus wie Steine

- Jeder Brocken bekommt eine eigene, unregelmäßige Form: 9–12 Ecken mit
  unterschiedlicher Länge, drei Helligkeitsflächen (Licht, Seite, Schatten),
  2–3 Dellen (dunkle Mulden mit hellem Rand), feine Risse.
- Fliegende Brocken drehen sich, liegende behalten ihre Form (Saat pro Brocken).
- Hagelsteine kleiner, gleiche Machart.

## 7. Kopftreffer zählen am meisten

- Der Golem bekommt Trefferzonen nach seinem Bild: **Kopf ×1,6**, Rumpf ×1,0,
  Beine ×0,75.
- Pfeile und Zaubergeschosse treffen die Zone, durch die sie fliegen (das hohe
  Bild zählt, nicht nur die Füße). Nahkampf zählt als Rumpf.
- Kopftreffer zeigen „KOPF!“ an der Schadenszahl; beim Zerfall platzt der Kopf
  am stärksten auseinander.

## 8. Stärker und gefährlicher

- Leben **+20 %**: großer Golem 8640 (Stufe 40 ≈ 48.400), Hälften 4320
  (≈ 24.200), +70 % je weiterem Spieler.
- Alle Angriffe und Zauber **+35 % Schaden**.
- **Brocken und Stampfer (Auto-Attacke) machen Prozent-Schaden der maximalen
  Lebenspunkte, Rüstung hilft nicht**. Vorschlag:
  - Stampfer: 45 % der maximalen HP (Hälften 22 %)
  - Brocken: 55 % der maximalen HP (Hälften 27 %)
  - Hagelstein: 8 % der maximalen HP
  - Schrei: 34 % der maximalen HP (vorher 25 %)
- Ausweichen bleibt der Schutz: Ring beim Stampfer, Warnstreifen beim Wurf.

## 9. Klügeres Laufen, Verfolgung über die ganze Map

- Weg um Hindernisse mit der vorhandenen Wegsuche (`mob_navigation.gd`),
  angepasst an den großen Körper (Rasterzellen 64 px, Körperradius 90 px),
  neuer Weg jede Sekunde.
- Hängt er 2 s fest, weicht er seitlich aus und sucht einen neuen Weg; als
  letzte Möglichkeit zerschlägt er kleine Hindernisse (Bäume, Steine) auf dem
  Weg.
- Er verfolgt Spieler im ganzen Himmelsgarten, nicht nur am Altar.

## 10. Beute: legendäre Rüstung für jeden, als tragbares 3D-Teil

- Jeder Beteiligte bekommt **eine legendäre Rüstung** (siehe Frage unten).
- Neue Inventarbilder für alle legendären Rüstungen: aus 3D-Modellen gerendert
  (wie die neue 3D-Landschaft), 64×64 px, mit Licht und Tiefe.
- Golem-Rüstung als eigenes Modell: Basaltplatten, lila Risse, schwebende
  Schultersteine. Am Charakter überarbeitetes Aussehen im gleichen Stil.

## Offene Fragen an Angelo

1. Beute: Soll jeder Spieler eine **zufällige** der 7 legendären Rüstungen
   bekommen (Golem-Rüstung nur selten, z. B. 15 %), oder **immer die
   Golem-Rüstung**?
2. Prozent-Schaden: Passen 45 % (Stampfer) und 55 % (Brocken)? Sollen auch die
   Hagelsteine Prozent-Schaden machen?
3. Verfolgung: Nur im Himmelsgarten, oder auch durch die Tore in andere Gebiete
   (dann müsste er durch die Tore passen)?
4. 15-Minuten-Sperre: Gilt sie auch im Testmodus, oder darf man dort sofort
   wieder beschwören?

## Antworten (16:55) und Umsetzung Teil 1

1. Beute: **immer die Golem-Rüstung** für jeden Beteiligten.
2. Prozent-Schaden: **ja**, Stampfer 45 %, Brocken 55 %, Hagel 8 %, Schrei 34 %.
3. Verfolgung: **nur im Himmelsgarten**.
4. 15-Minuten-Pause: **nicht im Testmodus**.
5. Neu: Der Golem darf Server und andere Mobs nicht ausbremsen.

Leistung, gemessen im Netztest (3 Spieler, ganzer Kampf):

| Teil | Kosten |
|---|---|
| Golem-Logik pro Bild (Schnitt) | ≈ 0,11 ms |
| Längstes Bild (Wegsuche) | ≈ 2,5–2,9 ms |
| Wegsuche, Ziel unerreichbar (Budget 600 Zellen) | ≈ 10 ms, höchstens alle 3 s |
| Weltpaket außerhalb des Himmelsgartens | < 120 Zeichen statt ≈ 2,8 KB |

Schutzmaßnahmen: Wegsuche nur bei versperrter Sichtlinie (Prüfung alle 0,25 s),
Raster wird nach der Beschwörung verteilt gefüllt (40 Zellen pro Bild),
Wegdaten gehen nicht ins Weltpaket, Brocken höchstens 24, Falter höchstens 10,
umgeworfene Bäume zeichnen nur ihre Kacheln neu. Der Server schreibt jede
Minute `GOLEM_PERF` ins Log (Schnitt und Spitze).
