# Golem-Konzept: Endgegner des Himmelsgartens

Stand: 10.10.2026, 02:30. Angelos Vorgaben vom 10.10. sind eingearbeitet; sie
ersetzen den ersten Entwurf (Kern-Phase, Golemiten) dort, wo sie sich
widersprechen.

## Wünsche

**9.10.2026, 23:24:** Golem-Endgegner für die letzte Map. Ein riesiger
magischer Steinhaufen-Golem, der in einem großen Umkreis Steinhagel verursacht.
Vorbild ist der Golem aus Clash Royale.

**10.10.2026, 02:18 (Vorgaben):**
- **Musik:** Beim Erscheinen läuft Endboss-Musik im Stil Heavy Metal/Hardtekk.
- **Beschwörung:** Er wird mit 30 Steinbeeren, 1 Rotkuchen und 1 Blaukuchen
  beschworen.
- **Aussehen:**
  - steinig-schwarz mit lila Elixier-Rissen
  - 64 px groß, als 3D-Modell
  - beim Tod Ragdoll an Armen und Körper
- **Gefühl:** sehr massiv und langsam. Beim Vorwärtsschleppen macht er
  imposante, schwer brechende Geräusche.
- **Einschilden:** Er bleibt stehen, beugt sich zusammen und bekommt 8 s lang
  −99 % Schaden. Abklingzeit 30 s.
- **Steinhagel-Feld:** Direkt nach dem Einschilden erscheint ein rundes Feld mit
  20 m Durchmesser. Darin fallen große Steinbrocken von oben und machen
  Schaden. Im Feld hat der Golem +30 % Tempo, und Verlangsamung wirkt auf ihn
  50 % schwächer.
- **Brockenwurf:** Alle 10 s schabt er mit einem Arm im Boden und wirft einen
  Riesenbrocken geradeaus. Der Brocken reißt Mobs, Spieler und Bäume mit. Er
  fliegt 15 m, rollt dann etwas weiter und bleibt liegen.
- **Schrei:** Fällt er unter 40 % Leben, hält er kurz inne und schreit. Der
  Schrei trifft alles auf der Map und hat eine wellenförmige Animation.

**10.10.2026, 02:29 (Antworten):**
- Die bisherigen Golem-Mobs heißen jetzt **Wächter** (Steinwächter,
  Kristallwächter, Lavawächter, PR #97). Der neue Endgegner ist der einzige
  Golem.
- **Rotkuchen und Blaukuchen** gibt es schon: Roter Sonnenkuchen und Blauer
  Mondkuchen von Alma heißen jetzt so (PR #97).
- **Brocken** bleiben liegen, bis der nächste Golem erscheint.
- **Größe:** wirklich sehr groß, **5× so groß wie ein Spieler** und dazu sehr
  breit.

**10.10.2026, 02:32 (Stil):** Angelo hat Bilder als Stilrichtung geschickt (ein
bekannter Spiel-Golem aus einem Handyspiel). Rahmen und Farben aus diesem
Konzept gelten weiter. Siehe „Stilrichtung“ unten.

## Einordnung

- Die letzte Map ist der Himmelsgarten (Gebiet 12, empfohlen ab Stufe 40). Dort
  gibt es bisher keinen Gebietsboss.
- Der Golem ist dort ein **beschworener** Endgegner. Er steht nicht dauerhaft
  in der Welt, sondern erscheint, wenn jemand die Opfergaben an einem Altar
  ablegt.
- Klassenbosse und die Arena der letzten Wache bleiben, wie sie sind.

## Maße

Ein Meter sind 32 px. Der Held ist etwa 64 px hoch.
- **Golem: 5× Spielergröße**, also etwa 320 px hoch. Sehr breit, etwa 380 px
  von Faust zu Faust, wie ein gebückter Felsberg. Treffer- und
  Kollisionsfläche dazu: Körper etwa 220 × 140 px am Boden.
- Steinhagel-Feld: 20 m Durchmesser = 640 px, also Radius 320 px.
- Brockenwurf: 15 m Flug = 480 px, danach rollt der Brocken etwa 3 m (≈ 96 px)
  aus.
- Figur: im 64-px-Raster gebaut (gröbere Pixel als die Welt), damit er trotz
  der Größe zum Pixelstil passt.

## Beschwörung

- Im Himmelsgarten steht ein **Golem-Altar** (Steinplatte mit lila Rissen).
- Wer am Altar E drückt und 30 Steinbeeren, 1 Rotkuchen und 1 Blaukuchen
  dabeihat, legt sie ab. Der Altar bricht auf, der Golem steigt heraus, und die
  Bossmusik startet.
- Alle Zutaten gibt es schon: Steinbeeren pflückt man in der Welt, Rotkuchen
  und Blaukuchen kocht Alma (früher Roter Sonnenkuchen und Blauer Mondkuchen).
- Es gibt nur einen Golem gleichzeitig pro Welt. Solange einer lebt, ist der
  Altar gesperrt.

## Stilrichtung (nach Angelos Bildern)

Ein **eigener** Golem, kein Nachbau der Vorlage. Übernommen wird nur die
allgemeine Wirkung:
- **Silhouette:** gebückt, massiger Rumpf, riesige Schultern und Fäuste, kurze
  stämmige Beine. Der Kopf sitzt tief zwischen den Schultern. Er wirkt breiter
  als hoch.
- **Formen:** große, kantig behauene Felsblöcke mit klaren Flächen statt rundem
  Geröll. Die Fäuste bestehen aus mehreren Blöcken.
- **Lesbarkeit:** wenige große Formen und deutliches Licht von oben, damit er
  auch klein im Bild sofort als Felskoloss erkennbar ist.

Bewusst **anders** als die Vorlage:
- Farben: steinig-schwarzer Basalt, lila Elixier-Risse
- Gesicht: zwei schmale, lila glühende Spalten in einer gesprungenen
  Basaltplatte, kein Gesichtsschild wie bei der Vorlage
- keine Kristallkrone auf dem Kopf; das Lila sitzt in den Rissen zwischen den
  Blöcken
- schwebende Brocken um die Schultern als eigenes Erkennungszeichen

## Aussehen und Animation

- **Körper:** steinig-schwarzer Felshaufen (Basalt). Durch die Fugen laufen
  **lila Elixier-Risse**, die pulsieren. Bei Treffern leuchten die Risse kurz
  auf.
- **3D-Modell in Pixel-Optik:** einfache 3D-Körper (Rumpf, Kopf, zwei Arme aus
  Gelenkteilen, Beine/Stumpf), in kleiner Auflösung gerendert und als
  Pixelbild in die 2D-Welt gesetzt. Das ist genau der Weg aus D2 (Prototyp
  3D-Figuren). Der Golem wird damit die **erste 3D-Figur** im Spiel.
- **Ragdoll beim Tod:** Arme und Körper werden zu Physik-Teilen und fallen in
  sich zusammen. Das passiert nur bei jedem Spieler im Bild, nicht auf dem
  Server.
- **Animationen:**
  - Schleppen (schwer, mit Bodenstaub)
  - Einschilden (zusammenbeugen, Risse dunkel, Steinhülle)
  - Schaben (Arm gräbt, Brocken bricht heraus)
  - Wurf
  - Schrei (Kopf zurück, Risse gleißend)
  - Tod

## Kampf

| Fähigkeit | Ablauf | Gegenspiel |
|---|---|---|
| **Schleppen** | Er geht sehr langsam auf das Ziel zu, jeder Schritt dröhnt. | Abstand halten |
| **Einschilden** | Er bleibt stehen und beugt sich zusammen: −99 % Schaden für 8 s, Abklingzeit 30 s. | Pause zum Heilen und Positionieren |
| **Steinhagel-Feld** | Direkt danach entsteht ein Feld mit 640 px Durchmesser um ihn. Darin fallen Brocken mit Schatten-Vorwarnung. Im Feld: Golem +30 % Tempo, Verlangsamung auf ihn halb so stark. | Raus aus dem Feld oder zwischen den Schatten durch |
| **Brockenwurf** | Alle 10 s. Er schabt sichtbar (Vorwarnung als Linie am Boden) und wirft geradeaus. Der Brocken fliegt 480 px, nimmt Spieler, Mobs und Bäume mit, rollt aus und bleibt als **Hindernis** liegen. | Seitlich ausweichen; liegende Brocken als Deckung nutzen |
| **Schrei** (einmal, unter 40 %) | Er hält inne und schreit. Eine Welle läuft über die ganze Map und trifft jeden Spieler im Himmelsgarten. | Nicht ausweichbar, nur aushalten (Heilung bereithalten) |

## Werte (Vorschlag, nach dem ersten Test anpassbar)

- **Leben:** 6000 bei einem Spieler, +70 % je weiterem Gruppenmitglied in der
  Nähe.
- **Tempo:** 40, im Feld 52. Er ist langsamer als jeder normale Gegner.
- **Schaden:**
  - Schritt: kein Schaden
  - Hagelbrocken: 45 je Treffer
  - Brockenwurf: 110 plus Mitreißen
  - Schrei: 25 % des maximalen Lebens plus 1 s Taumeln
- **Feld:** bleibt 12 s, also bis kurz nach dem Ende des Schilds. → Frage 3.
- **Liegender Brocken:** bleibt liegen, bis der nächste Golem erscheint (Angelo).
  Er ist ein festes Hindernis und wird auf dem Server gespeichert, damit er
  einen Neustart übersteht.
- **Bäume** werden nicht gelöscht, nur für 5 Minuten umgeworfen. → Frage 4.

## Klang und Musik

- **Bossmusik Heavy Metal/Hardtekk:** Ich baue sie wie die übrige Musik per
  Skript (`tools/build_music.py`): verzerrte Gitarren-Synths, Doublebass,
  Hardtekk-Kick ab etwa 170 BPM. Wenn du lieber einen eigenen oder gekauften
  Track nutzt, binde ich den ein. → Frage 5.
- **Schleppen:** tiefes Knirschen und Bersten von Stein, bei jedem Schritt
  leichtes Bildwackeln.
- **Einschilden:** dumpfes Zusammenschieben, danach gedämpfte Treffer
  („klonk“ statt Treffer).
- **Hagel:** Pfeifen, dann Einschläge mit Kies-Nachklang. Bei vielen Steinen
  greift der Limiter des Effekte-Busses.
- **Schaben und Wurf:** Kratzen im Boden, Abriss, Flug-Rumpeln, Ausrollen.
- **Schrei:** tiefer Felsenschrei mit Hall, dazu die Welle im Bild.
- Wie bei den Schritten gibt es vorher eine **Hörprobe** zum Auswählen.

## Was zusätzlich gebaut werden muss

1. **3D-Figurensystem (D2):** Die Grundlage für das 64-px-3D-Modell mit
   Ragdoll muss her:
   - kleiner 3D-Viewport
   - Pixel-Shader
   - Einbettung in die 2D-Welt mit richtiger Tiefe
   - Ragdoll (Physik-Knochen)

   Das ist der größte Brocken. Er nützt danach auch dem Krieger und den
   anderen Figuren.
2. **Altar und Opfergaben:** Altar im Himmelsgarten, Prüfung der Zutaten im
   Inventar, Beschwörung über den Server, damit es nur einen Golem gibt.
3. **Rotkuchen und Blaukuchen:** erledigt, nur umbenannt (PR #97).
4. **Bossmusik:** neuer Track, Umschalten beim Erscheinen, Ende beim Tod.
5. **Server-Kampflogik:** Zustände (Schleppen, Schild, Feld, Schaben/Wurf,
   Schrei, Tod), Abklingzeiten, Treffer, Tempo-Bonus im Feld, alles
   übertragen an die Spieler.
6. **Mitreißen:** Spieler und Mobs werden entlang der Flugbahn geschoben. Der
   Server braucht dafür einen kurzen „Stoß“-Zustand pro Spieler.
7. **Umwerfbare Bäume:** Bäume sind bisher feste Deko. Gebraucht werden eine
   Liste umgeworfener Bäume auf dem Server, die im Bild zu sehen ist, und ein
   Neuzeichnen der Boden-Kacheln.
8. **Liegende Brocken als Hindernis:** Kollision für Spieler, Mobs und
   Geschosse, gemeinsam auf dem Server. Sie bleiben liegen, bis der nächste
   Golem erscheint, und müssen deshalb dauerhaft auf dem Server gespeichert
   werden.
9. **Map-weiter Schrei:** trifft alle Spieler im Himmelsgarten. Die
   Wellenanimation läuft bei allen im Bild.
10. **Ragdoll nur im Bild:** Der Server meldet nur „tot“, jeder Spieler sieht
    den Zusammenbruch selbst.
11. **Beute und Sieg-Markierung im Spielstand** (siehe Frage 6).
12. **Tests und Vorschaubilder:**
    - Tests: Schild-Zeitfenster, Feldradius und Tempo-Bonus, Wurfweite und
      Liegenbleiben, Schrei-Schwelle, nur ein Golem.
    - Bilder: Golem stehend, eingeschildet mit Feld, beim Wurf und beim
      Schrei.

## Umfang und Reihenfolge

Groß (XL), weil das 3D-Figurensystem dazugehört. Vorschlag:
1. **3D-Prototyp:** Golem als 3D-Figur, stehend, schleppend, Ragdoll-Tod.
   Danach kommen Bilder zur Abnahme. Das ist zugleich der D2-Prototyp.
2. **Beschwörung:** Altar, Opfergaben, Bossmusik (mit Hörprobe).
3. **Kampf Teil 1:** Schleppen, Schild, Steinhagel-Feld.
4. **Kampf Teil 2:** Brockenwurf mit Mitreißen, umwerfbare Bäume, liegende
   Brocken, Schrei.
5. **Feinschliff:** Klänge, Werte, Beute.

## Fragen an dich

Beantwortet: Größe (5×, sehr breit), Kuchen (umbenannt), Brocken (liegen bis
zum nächsten Golem). Noch offen:

3. **Feld:** Wie lange soll das Steinhagel-Feld bleiben? Vorschlag 12 s.
4. **Bäume:** Sollen umgeworfene Bäume nach einiger Zeit wieder stehen
   (Vorschlag 5 Minuten) oder dauerhaft weg sein?
5. **Musik:** Soll ich den Hardtekk-Track selbst bauen, oder hast du einen?
6. **Beute:** Was gibt er? Zur Auswahl: eigene Halskette, LV-40-Rüstungsteil
   (passt zum neuen Rüstungskonzept), Material.
7. **Name:** „Himmelsfels, der Sternkoloss“, oder einen eigenen?
8. **Golemiten:** Der erste Entwurf hatte zwei kleine Golemiten beim Tod. Weg
   damit, weil jetzt der Ragdoll-Tod das Finale ist?
