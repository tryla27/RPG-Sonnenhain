# Golem-Konzept: Endgegner des Himmelsgartens

Stand: 9.10.2026, Entwurf zur Abstimmung mit Angelo.

## Wunsch (Angelo, 9.10.2026, 23:24)

> Golem Endgegner für die letzte Map: ein riesiger magischer Steinhaufen-Golem,
> der Steinhagel in einem großen Umkreis verursacht (Vorbild: Golem aus Clash
> Royale). Dazu arbeiten wir ein Golem-Konzept aus.

## Einordnung

- **Letzte Map** ist der Himmelsgarten (Gebiet 12, empfohlen Stufe 40, Portal
  aus dem Sternenbruch). Dort gibt es bisher nur Himmelsfalter und
  Sternenwächterin, aber keinen Gebietsboss.
- Der Golem wird der **Gebiets-Endgegner** dort. Die drei Klassenbosse und die
  Arena der letzten Wache bleiben, wie sie sind.
- Die normalen Steingolems (Alte Ruinen), Kristallgolems und Lavagolems bleiben
  kleine Gegner. Der Endgegner muss sich davon klar abheben: Größe, Leuchten,
  eigene Bühne.

## Name (Vorschlag)

**Himmelsfels, der Sternkoloss**. Kurz im Spiel: „Sternkoloss“.
Alternativen: „Der Steinerne Himmel“, „Urgolem Basalthorn“.

## Aussehen

- **Riesig:** etwa viermal so hoch wie der Held (rund 260 px). Er ist ein Haufen
  großer, grob behauener Felsbrocken, den Magie zusammenhält. Zwischen den Brocken
  sind sichtbare Lücken, in denen blaues Sternenlicht pulsiert.
- **Kern:** In der Brust liegt ein leuchtender Kristallkern als Schwachpunkt. Er
  wird in Phase 2 freigelegt.
- **Schwebende Steine:** Drei bis fünf kleine Brocken kreisen um Schultern und
  Kopf. Sie sind das Zeichen für den Steinhagel: Vor dem Hagel steigen sie auf.
- **Gang:** Er ist langsam und schwer. Jeder Schritt lässt den Bildschirm leicht
  wackeln und Staub aufsteigen. Wie beim Clash-Royale-Golem wirkt er
  unaufhaltsam, aber träge.
- **Stil:** derselbe 32-px-Pixelstil wie die Welt. Für die Größe wird er aus
  mehreren Teilen zusammengesetzt (Rumpf, Arme, Kopf, Kern, schwebende Steine),
  damit Arme und Steine einzeln animiert werden können. Später passt er gut zum
  D2-Figurensystem (3D-Körper in Pixel-Optik), ist aber nicht davon abhängig.

## Bühne

- Eine **schwebende Felsinsel** im Himmelsgarten, etwa 1400 × 1000 px, mit
  Sternenstaub am Rand. Mit dem neuen Wegstein-Stil (Höhenunterschied) wirkt sie
  wie ein Plateau, auf das man hinaufsteigt.
- Am Eingang steht eine Siegelplatte. Wer sie betritt, weckt den Golem. Er
  steht nicht einfach herum, damit niemand ihn versehentlich anlockt.
- Nach dem Sieg bleibt die Insel frei. Der Golem erwacht nach einer Wartezeit
  (Vorschlag: 15 Minuten, wie bei den Klassenbossen) wieder.

## Kampf

### Phase 1 (100–50 % Leben): der Steinhaufen

| Angriff | Was passiert | Ausweichen |
|---|---|---|
| **Stampfer** | Er hebt den Fuß und stampft. Ein Ring aus Staub läuft nach außen (Radius 220 px). | Rechtzeitig weggehen oder mit Ausweichrolle durch den Ring |
| **Felswurf** | Er reißt einen Brocken aus der Schulter und wirft ihn auf den Spieler. Der Schatten am Boden wächst, Einschlag nach 1,1 s. | Aus dem Schatten laufen |
| **Steinhagel** (Kernangriff) | Die schwebenden Steine steigen auf, er hebt beide Arme. In **großem Umkreis (900 px)** erscheinen 18–26 Einschlagschatten, dicht beim Golem und lockerer am Rand. Nach 1,4 s schlagen Steine ein, in drei kurzen Wellen. | Zwischen den Schatten durch. Die Lücken sind immer breit genug für den Helden |

Steinhagel kommt in Phase 1 etwa alle 14 s, Stampfer und Felswurf dazwischen.

### Phase 2 (unter 50 %): der freigelegte Kern

- Brocken brechen ab und bleiben als **Deckung** auf der Insel liegen. Hinter
  ihnen ist man vor dem Felswurf sicher. Der Steinhagel zerschlägt die Deckung
  mit der Zeit.
- Der **Kern** leuchtet offen. Treffer von vorn auf den Kern machen **+50 %
  Schaden**. Das belohnt gutes Zielen; zusammen mit C2 (Angriffe in
  Kopfrichtung) und D3 (Trefferzonen) passt das später noch besser.
- Steinhagel kommt jetzt alle 9 s und hat eine vierte Welle.
- **Neu: Sternenfall.** Ein großer Stein fällt genau in die Mitte der Insel
  (Radius 300 px, langer Vorlauf von 2,5 s). Wer dort steht, nimmt schweren
  Schaden.

### Tod (wie in Clash Royale)

- Der Golem **zerfällt** mit einer Todeswelle. Der Ring ist vorher angezeigt,
  nach 1,5 s folgt mittlerer Schaden in 260 px.
- Aus dem Haufen stehen **zwei Golemiten** auf: halb so groß, schneller, mit je
  12 % seines Lebens. Jeder Golemit wirft kleinen Steinhagel (8 Schatten,
  400 px) und zerfällt beim Tod mit einer kleinen Todeswelle.
- Erst wenn beide Golemiten besiegt sind, gilt der Kampf als gewonnen.

## Werte (Vorschlag)

- **Leben:** 6000 bei einem Spieler, für jedes weitere Gruppenmitglied in der
  Nähe +70 %. Zum Vergleich: Der Jagdmeister hat 2350.
- **Schaden:**
  - Stampfer 70
  - Felswurf 85
  - Hagelstein 45 je Treffer (es treffen selten mehr als zwei)
  - Sternenfall 160
  - Todeswelle 90
- **Geschwindigkeit:** 48. Er ist langsamer als jeder normale Gegner.
- **Erfahrung:** 1500, dazu 300 je Golemit.
- **Beute:**
  - Ein garantiertes Endgegner-Teil, siehe Frage 3.
  - Viel Gold und eine Sternkoloss-Essenz für Runen oder Fusionen.

## Klang

- Tiefes Grollen im Leerlauf und bei jedem Schritt. Beim Erwachen ein
  bergartiges Knirschen.
- **Steinhagel:** ein aufsteigendes Pfeifen beim Aufsteigen der Steine, dann
  einzelne dumpfe Einschläge mit Kies-Nachklang. Bei vielen Steinen gleichzeitig
  greift der Limiter des Effekte-Busses, damit es nicht übersteuert.
- **Kern:** ein heller, gläserner Ton bei Treffern.
- Alles wird wie die übrigen Klänge per Skript erzeugt (`tools/build_sfx.py`).
  Vor dem Einbau bekommst du eine Hörprobe zum Auswählen, wie bei der
  Schrittprobe.

## Technik

- `components/golem_boss.gd`: Zustände und Angriffe als Daten, also Phasen,
  Abklingzeiten und Muster des Hagels. Zustandslose Regeln, damit Server und
  Spiel dasselbe rechnen.
- `components/golem_design.gd`: Zeichnen aus Teilen (Rumpf, Arme, Kopf, Kern,
  schwebende Steine) mit Animation.
- Die Einschläge laufen über die vorhandenen Gegner-Geschosse mit
  Vorwarnschatten. Der Server entscheidet die Treffer, wie bei den übrigen
  Bossen.
- **Tests:**
  - Der Hagel lässt immer einen Weg frei.
  - Phasenwechsel bei 50 %.
  - Golemiten erscheinen beim Tod.
  - Gruppen-Skalierung.
  - Eine Spielstand-Markierung für den Sieg.
- **Vorschaubilder:** Golem im Stand, beim Hagel mit Schatten und in Phase 2.

## Umfang

Groß (L): Design und Zeichnung, Kampflogik mit Server, Klänge, Bühne, Tests.
Vorschlag in drei Schritten, jeder mit Bildern zur Abnahme:

1. Aussehen und Bühne (nur Bilder, kein Kampf)
2. Kampf Phase 1 mit Steinhagel
3. Phase 2, Tod mit Golemiten, Beute und Klänge

## Fragen an dich

1. **Name:** „Himmelsfels, der Sternkoloss“, oder ein anderer?
2. **Erwachen:** Mit Siegelplatte (Vorschlag) oder steht er offen auf der Map
   und greift an, wer zu nahe kommt?
3. **Beute:** Was soll er geben? Zur Auswahl:
   - eine eigene Halskette, zum Beispiel „Golemherz“ mit Steinhaut für 3 s nach
     schwerem Treffer
   - ein Rüstungsteil, das später zu D4 (Rüstung pro Körperteil) passt
   - ein Fusionsstein-Material
4. **Golemiten beim Tod:** So wie in Clash Royale (zwei kleine, die
   nachkommen), oder soll der Kampf mit dem großen Golem enden?
5. **Gehört er zum Endspiel?** Soll man ihn besiegen müssen, bevor die Arena
   der letzten Wache öffnet (dann vier Siegel statt drei), oder bleibt er ein
   freiwilliger Endgegner?
