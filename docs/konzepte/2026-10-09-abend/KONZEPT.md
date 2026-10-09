# Konzept: Wünsche vom 9.10.2026 (Abend), neu sortiert

Stand: 9.10.2026, 22 Uhr. Ergänzt das Konzept vom Morgen
(`docs/konzepte/2026-10-09/KONZEPT.md`, Pakete 1–3 sind live) um Angelos
neue Wünsche. Sortiert nach: erst Fehler und Stabilität, dann schnelle
Komfortpunkte, dann Spielgefühl, dann die großen Grafik-Umbauten.

Größen: **S** bis 2 h, **M** halber Tag, **L** 1–3 Tage, **XL** eine Woche und mehr.

---

## A. Fehler und Stabilität (zuerst)

### A1. Charakterwechsel vermischt Kartenfortschritt und mehr (M)

**Befund (im Code nachgesehen).** Alles ist pro Charakter gespeichert,
lokal und auf dem Server richtig getrennt. Durcheinander kommt es beim
**Wechseln ohne Neustart**:

1. **Fortschritt wird zusammengemischt (Hauptursache).**
   - Beim Öffnen eines anderen Charakters bleibt der alte Spielzustand im
     Speicher (`open_account_character` setzt nur die neue ID).
   - Kommt die Antwort vom Server, hält `apply_save_data` das für ein
     Wiederverbinden desselben Charakters. Es mischt Quests, Borin-Quests,
     Ereignisse, Bosse und Rettung des **alten** Charakters in den neuen.
   - Der nächste Speicherstand lädt das hoch. Der Server erlaubt nur
     Fortschritt nach oben und kann das danach nie mehr zurücknehmen.
2. **Kartennebel wird nie gelöscht.** Weder ein neuer Charakter noch das
   Laden setzt den Nebel zurück. Fehlt er in einem Spielstand, bleibt der
   des vorigen Charakters stehen.
3. **Alte Gruppenpositionen decken weiter Karte auf.** Die Gruppe wird beim
   Trennen und Wechseln nicht geleert, alte Positionen schreiben weiter in
   den Nebel des neuen Charakters.
4. **Speichern während des Wechsels.** Läuft das Öffnen in eine Zeitüberschreitung,
   kann das automatische Speichern den alten Zustand unter dem neuen
   Charakter ablegen.
5. **Reste beim neuen Spiel.** Truhen-Timer, Steinrose, Essen, Pip-Leihe und
   der Händlerbestand bleiben teils vom vorigen Charakter.

**Lösung.**
- Eine einzige Funktion `reset_character_state()` setzt **jeden**
  Charakterwert zurück: Nebel, Gruppe, Timer, Händler, Küche, Essen, Pip.
  Sie läuft vor jedem Laden, vor jedem neuen Spiel und beim Zurück ins Menü.
- Mischen nur noch beim echten Wiederverbinden desselben Charakters in
  derselben Sitzung, mit ausdrücklichem Kennzeichen.
- Kein automatisches Speichern, solange ein Charakter geladen wird oder ein
  Menü vor dem Spiel offen ist.
- Server prüft beim Speichern, ob Name und Klasse zum Charakter passen.
- **Reparatur:** Ein einmaliges Werkzeug auf dem Server listet verdächtige
  Spielstände (Quests oder Bosse, die nicht zum Level passen) und stellt sie
  aus den vorhandenen Sicherungen wieder her. Vorher zeige ich dir die Liste.
- **Test:** Charakter A laden, zu B wechseln, B muss exakt seinem
  Serverstand entsprechen (Quests, Nebel, Wegsteine, Truhen).

### A2. Spiel stabilisieren (L, in Schritten)

1. **Spielstand-Schema mit Versionen.** Jeder Spielstand bekommt eine
   Version und Umwandlungsschritte. Neue Felder bekommen Standardwerte statt
   „was gerade im Speicher stand“.
2. **Automatischer Spieltest in der CI.** Ein Bot spielt headless eine feste
   Runde: einloggen, laufen, kämpfen, Truhe, Wegstein, reisen, Haus betreten,
   speichern, Charakter wechseln, neu laden. Jeder Schritt prüft den Zustand.
3. **Bildvergleich in der CI.** Feste Szenen (Dorf, Kapelle, HUD, Menüs)
   werden gerendert und mit freigegebenen Bildern verglichen. Fehler wie die
   orangenen Rahmen fallen dann vor dem Live-Gang auf.
4. **Fehlerberichte aus dem Spiel.** Skriptfehler im Browser werden gesammelt
   und an den Server geschickt (ohne persönliche Daten), mit Build-Nummer.
5. **Testserver vor live.** Eine zweite Adresse (z. B. `beta.sonnenhainrpg.de`)
   bekommt jeden Stand zuerst. Du testest dort und gibst dann frei.
6. **Leistung messen.** Die CI misst im Browser die Bilder pro Sekunde in drei
   Szenen und warnt bei Einbrüchen.
7. **`main.gd` weiter zerlegen**, dort wo ohnehin gearbeitet wird: Spieler,
   Eingabe, Zeichnen der Welt, Netzwerk.

---

## B. Schnelle Komfortpunkte (je S)

### B1. F11: komplettes Vollbild im Browser
- F11 (und ein Knopf „Vollbild“ im Spielmenü) schaltet das Spiel über die
  Vollbild-Funktion des Browsers in echtes Vollbild, ohne Browserleisten.
- Das Spielbild füllt den ganzen Bildschirm, ohne schwarze Ränder links und
  rechts: Die Welt wird breiter gezeigt statt mit Balken aufgefüllt.
- Escape oder F11 beendet das Vollbild wieder.
- Hinweis: Manche Browser lassen F11 nicht abfangen. Dann bleibt der Knopf im
  Menü der sichere Weg.

### B2. Tippgeräusch beim Schreiben
- Neuer Oberflächenklang „Tippen“ (3 Varianten, leise, 16-Bit-Märchenstil),
  bei jedem Zeichen in allen Textfeldern: Anmeldung, Name, Chat, Einladecode.
- Löschen klingt etwas tiefer. Bei schnellem Tippen höchstens 25 Klänge pro Sekunde.
- Vorher in der Klangprobe zum Anhören.

### B3. Reisen über die Karte (M)
- **Nicht am Wegstein:** Klick auf ein Reiseziel in der Karte (M) zeigt
  „Gehe zu einem Wegstein, um zu teleportieren.“
- **In der Nähe eines Wegsteins** (gleicher Abstand wie die F-Anzeige) ist die
  Karte mit M automatisch die Reisekarte. Ein Klick auf ein Ziel reist sofort.
- Test: Klick fern vom Wegstein reist nicht und zeigt die Meldung. Klick nah
  am Wegstein reist.

---

## C. Spielgefühl

### C1. Start im Dunkeln, Sicht deckt dauerhaft auf (M)
- Die Welt ist am Anfang **komplett dunkel**, auch im Spielbild, nicht nur auf
  der Karte. Sichtbar ist nur, was der Charakter schon gesehen hat.
- **20 m Sichtweite:** Ein Meter sind 32 Pixel (eine Bodenkachel), 20 m also
  640 px. Heute deckt die Karte 430 px auf.
- Aufgedeckt bleibt aufgedeckt (dauerhaft, pro Charakter gespeichert). Am Rand
  gibt es einen weichen Übergang statt harter Kachelkanten.
- Das Dorf Sonnenhain ist beim Start schon aufgedeckt, damit der Einstieg
  nicht im Schwarzen beginnt. **Frage an dich:** Soll auch das Dorf dunkel sein?
- Gruppenmitglieder decken nur auf, solange sie wirklich in der Nähe sind.
- Hängt an A1, weil der Nebel dort zuerst sauber pro Charakter werden muss.

### C2. Körper mit WASD, Kopf mit der Maus (M–L)
- Der Körper dreht sich **nur** in Laufrichtung (WASD). Steht die Figur, bleibt
  die letzte Richtung.
- Die Maus dreht nur den **Kopf**, höchstens bis über die Schulter: etwa 110°
  zu jeder Seite, nicht nach hinten.
- **Angriffe:** Sie gehen in Blickrichtung des Kopfes, also auch höchstens
  über die Schulter. Zeigt die Maus hinter die Figur, schlägt sie zur nächsten
  erlaubten Seite. **Frage an dich:** So, oder sollen Angriffe immer in
  Körperrichtung gehen?
- Controller: linker Stick Körper, rechter Stick Kopf, mit derselben Grenze.
- Braucht für jede Blickrichtung getrennte Kopf- und Körperbilder. Das passt am
  besten zusammen mit D1/D2, wenn die Figuren ohnehin neu aufgebaut werden.

---

## D. Grafik auf ein neues Level

### D1. Was ist mit den Krieger-Animationen passiert?

**Befund (Git-Verlauf und Dateien geprüft).** Es liegt kein fertiger Stand auf
einem vergessenen Branch. Hergestellt wurde nur sehr wenig:
- Der „Golden-Sprite-Pilot“ (4.–5.10.) plante 9 Animationen in 8 Richtungen
  (stehen, gehen, rennen, 2 Angriffe, Fähigkeit, Treffer, Tod, Ausweichen).
- **Fertig wurden nur „Stehen“ und „Sprung“**, und nur für den männlichen
  Menschen-Krieger.
- „Stehen“ ist eine kleine, alte 24-px-Figur. Sie erscheint nur **ohne Rüstung
  und Helm**, also fast nie.
- Der Sprung ist hochaufgelöst in einem anderen Stil. Beide passen nicht
  zusammen.
- Alle anderen Animationen wurden nie hergestellt. Seit dem 5.10. ist daran
  nichts mehr passiert, die Arbeit ging zu Monstern, Klängen und HUD.
- Die Übergabedatei dazu lag außerhalb des Repos und ging verloren.

### D2. Neues Figuren-System: 3D-Körper, flüssige Animationen, Ragdoll (XL)

**Ziel.** Jede Figur (Spieler, NPC, Gegner) hat einen echten Körper aus Teilen:
Kopf, Hals, Brust, Bauch, Oberarme, Unterarme, Hände, Oberschenkel,
Unterschenkel, Füße. Das ermöglicht flüssige Animationen, Ragdoll beim Tod
und bei harten Treffern, Treffer-Zonen und Rüstung pro Körperteil.

**Drei Wege im Vergleich:**

| | 1 · 3D-Figuren in der 2D-Welt | 2 · 2D-Skelett aus Pixelteilen | 3 · Vorgerenderte 3D-Sprites |
|---|---|---|---|
| Wie | Figuren sind 3D-Modelle mit Skelett, gerendert in Pixel-Optik (niedrige Auflösung, Umriss, begrenzte Farben) | Pixel-Körperteile an einem 2D-Skelett, je Blickrichtung eigene Teile | 3D-Modell wird vorab in Pixelbilder gerendert |
| Flüssige Animation | ja, beliebig viele, Übergänge automatisch | gut, aber je Richtung Arbeit | ja, aber jede Animation als Bilder |
| Echte Ragdoll | **ja** (Physik-Knochen) | eingeschränkt (flach) | **nein** |
| Rüstung pro Teil | ja, jedes Teil ein eigenes Modell | ja, je Richtung Bilder | jede Kombination neu rendern, praktisch nein |
| Kopf frei drehen (C2) | ja | ja | nur in festen Schritten |
| Aufwand | groß am Anfang, danach schnell | mittel, wächst mit jeder Rüstung | klein am Anfang, wächst stark |
| Browser-Leistung | prüfen (WebGL) | gut | sehr gut |

**Empfehlung: Weg 1.** Nur er schafft alles auf einmal: Ragdoll, Teil-Rüstung
und freien Kopf. Die Welt bleibt 2D-Pixelart, nur die Figuren werden 3D und
sehen durch einen Pixel-Filter aus wie Pixelart.

**Ablauf in Stufen:**
1. **Prototyp (L):**
   - ein Krieger-Modell mit Skelett, Pixel-Filter und den Animationen stehen,
     gehen, rennen, Schlag und Ragdoll-Tod
   - Messung im Browser mit 20 Figuren gleichzeitig
   - **Du entscheidest am Prototyp, ob der Look passt.**
2. **Spieler (XL):** 3 Klassen × 3 Völker × 2 Geschlechter auf einem gemeinsamen
   Skelett, Körperformen über Regler (Ork breiter, Roboter kantig). Alle
   Animationen teilen sich das Skelett, also nicht 18 Mal neu.
3. **Gegner und NPCs (XL)** nach und nach. Wölfe und Käfer bekommen eigene Skelette.
4. **Mehrspieler:** Der Server kennt nur einfache Körperformen (Kapseln je
   Zone) für Treffer. Die Ragdoll ist reine Anzeige auf jedem Gerät.

### D3. Treffer-Zonen: Kopf-, Bein- und Körpertreffer (L, nach D2)
- Jede Figur hat Zonen: **Kopf, Rumpf, Arme, Beine**.
- Geschosse fliegen in einer Höhe: Pfeile in Brusthöhe, Zauber je nach Art.
  Zielen auf den Kopf (Maus über dem Kopf des Gegners) hebt den Schuss an.
- Vorschlag Schaden: Kopf ×1,6, Rumpf ×1,0, Arme ×0,8, Beine ×0,7 und
  verlangsamt kurz. Nahkampf trifft meist den Rumpf, von oben den Kopf.
- Eigene Treffer-Anzeige: „KOPFTREFFER“ in Gold, eigener Klang.
- Gilt auch für Gegner gegen dich. Ein Helm schützt dann wirklich den Kopf.

### D4. Rüstung pro Körperteil wie in Swords and Sandals (L, nach D2)
- **Neue Plätze:** Helm, Brust, Schulter links und rechts, Armschienen links
  und rechts, Handschuhe, Gürtel, Beinschienen links und rechts, Stiefel,
  dazu Waffe, Schild oder Zweithand, Umhang, Ringe und Halskette wie bisher.
- Jedes Teil ist **sichtbar am Körper** und schützt **seine Zone** (Helm den
  Kopf, Beinschienen die Beine). Gewicht beeinflusst Tempo und Ausdauer.
- Sets aus mehreren Teilen geben Boni (z. B. 3 Teile „Sonnenwache“).
- Händler und Beute bekommen die neuen Teile. Fenna färbt jedes Teil.
- **Spielstände:** Die heutige Rüstung wird beim ersten Laden in Brust,
  Schultern und Beinschienen gleicher Stufe aufgeteilt, nichts geht verloren.

### D5. Optik allgemein
- **Einheitliche Pixelgröße:** eine Grundauflösung für alles. Heute mischen
  sich 24-, 32- und hochauflösende Bilder.
- **Licht:** 2D-Lichter mit Normalmaps für Laternen, Kristalle und Zauber;
  weiche Schatten; Tag und Nacht mit echtem Licht statt Farbschleier.
- **Partikel und Glühen** für Magie, Funken und Staub; leichtes Bloom nur auf
  Leuchtendem.
- **Treffergefühl:** kurzes Einfrieren beim Treffer (Hitstop), Bildschirmwackeln
  bei schweren Schlägen, Aufblitzen.
- **Kunst-Bibel im Repo:** Farbpalette, Umrissregeln, Lichtrichtung,
  Beispielbilder. Jedes neue Bild wird daran gemessen.

---

## E. Fusionen

### E1. Fusionsstein updaten (Größe offen)
**Frage an dich: Was genau soll am Fusionsstein neu werden?** Meine Vorschläge:
- **Aussehen:** größerer, animierter Kristall mit Lichtsäule, der beim Nahen
  aufleuchtet und summt (passt zum Teleport-Brummen).
- **Menü:** Rezepte nach Element sortiert, Suchfeld, zeigt nur, was du
  verschmelzen kannst, Kosten und Rang auf einen Blick.
- **Ablauf:** kurze Verschmelzungs-Animation mit Klang statt sofortigem Wechsel.

### E2. Vorschau vor dem Fusionieren (M, später 3D)
- Im Fusionsmenü zeigt ein Fenster eine **Live-Simulation**: Eine Übungspuppe
  steht vor deiner Figur, die Fusion wird mit der echten Spiellogik gewirkt.
  Die Vorschau zeigt also genau, wo sie zündet, wie oft und wie weit.
- Knopf „Nochmal“, Anzeige von Schaden und Abklingzeit.
- **Stufe 1** nutzt die heutige 2D-Darstellung und geht sofort.
- **Stufe 2** wird zur 3D-Simulation, sobald D2 steht: drehbare Kamera, Figur und
  Puppe als 3D-Körper mit Treffer-Zonen.

---

## F. Neue Inhalte

### F1. Spielbare Instrumente (M–L)
- **Instrumente** als Gegenstände: Laute, Flöte, Trommel, Harfe. Zu kaufen in der
  Steinrose oder als Beute.
- **Spielmodus:** Instrument ausrüsten, Taste drücken, dann spielen die Tasten
  1–8 Töne. Die Töne liegen auf einer Tonleiter, auf der alles gut klingt
  (Pentatonik). Mit Umschalt eine Oktave höher.
- Klang im 16-Bit-Märchenstil, je Instrument eigener Klang.
- **Mehrspieler:** Andere in der Nähe hören mit, die Töne gehen über den Server.
- Die Figur spielt sichtbar (eigene Pose, mit D2 als Animation).
- **Frage an dich:** Nur zum Spaß, oder später mit Wirkung (Lieder, die die
  Gruppe heilen oder stärken)?

---

## G. Noch offen vom Morgen

- **Paket 4:** sichtbares Tor zu den Aschebergen (S–M). Der Arkanhüter steht
  schon im Kristallmoor.
- **Paket 5:** Umhänge, Fenna-Oberfläche, Accessoires für Mensch und Ork (M–L).
  Bei D2/D4 fließt das in das neue Figuren-System ein. **Vorschlag:** nur noch
  die Fenna-Oberfläche (A3) jetzt, Umhänge und Accessoires mit D4.
- **Paket 6:** neue Hausaccessoires (M). Die orangenen Rahmen (B4) sind erledigt.

---

## Reihenfolge (Vorschlag)

| Nr. | Was | Größe | Warum jetzt |
|---|---|---|---|
| 1 | A1 Charakterwechsel reparieren | M | zerstört Spielstände, dauerhaft |
| 2 | B3 Reisen über die Karte | S–M | schnell, oft gebraucht |
| 3 | B1 Vollbild mit F11 | S | schnell |
| 4 | B2 Tippgeräusch (mit Klangprobe) | S | schnell |
| 5 | C1 Start im Dunkeln, 20 m Sicht | M | braucht A1 |
| 6 | A2 Stabilität, Schritte 1–3 und 5 | L | schützt alles Weitere |
| 7 | Paket 4 Ascheberge-Tor | S–M | schließt das Morgenkonzept ab |
| 8 | E2 Fusionsvorschau Stufe 1 | M | sofort nützlich |
| 9 | E1 Fusionsstein (nach deiner Antwort) | M | |
| 10 | F1 Instrumente (nach deiner Antwort) | M–L | |
| 11 | D2 Prototyp 3D-Krieger mit Ragdoll | L | **Richtungsentscheidung** für alles Grafische |
| 12 | C2, D3, D4 auf dem neuen Figuren-System | XL | baut auf D2 |
| 13 | D5 Licht, Partikel, Treffergefühl | L | unabhängig, jederzeit |

## Entscheidungen (Angelo, 9.10.2026, 22:19)

- Konzept freigegeben bis auf A2 Punkte 2, 4, 5, 6 und 7 (Bot-Spieltest,
  Fehlerberichte, Testserver, Leistung messen, `main.gd` zerlegen). Dafür steht
  unten ein anderer Vorschlag (A2-neu).
- **C1:** Auch das Dorf ist am Anfang dunkel.
- **C2:** Angriffe gehen in Kopfrichtung, höchstens über die Schulter.
- **D2:** Prototyp 3D-Figuren in Pixel-Optik starten.
- **E1:** Alle drei Vorschläge: neues Aussehen, besseres Menü, Verschmelzungs-Animation.
- **F1:** Instrumente erst zum Spaß, Wirkung später.

**Nachtrag 22:25:** A2-neu und F1 (Instrumente, zum Spaß) nach hinten
verschoben. Dorf am Anfang dunkel, Fusionsstein mit allen drei Funktionen
bestätigt. Start mit A1.

## A2-neu. Stabilität ohne Zusatzbetrieb (Vorschlag)

Statt Bot, Testserver, Fehlerberichten im Hintergrund und Messungen:
1. **Vorschau-Link pro Änderung:** Jeder PR baut das Spiel zusätzlich als
   Einzelspieler-Version unter einer eigenen Adresse auf der Website
   (z. B. `/vorschau/pr-80/`). Du klickst vor dem Live-Gang einmal rein, ohne
   eigenen Testserver.
2. **„Fehler melden“ im Spiel (F8):** Erst auf deinen Knopfdruck werden ein
   Bildschirmfoto, die letzten Meldungen und der Spielstand an den Server
   geschickt. Nichts läuft heimlich im Hintergrund.
3. **Leistungsanzeige (F3) und automatische Qualität:** Bilder pro Sekunde
   sichtbar, bei schwachen Geräten werden Effekte von selbst reduziert.
4. **Aufräumen nur durch den Neubau der Darstellung (H):** Kein eigenes
   Zerlegen von `main.gd`, sondern jedes Teil, das in die neue Darstellung
   wandert, verlässt dabei `main.gd`.

## H. Darstellung: wie das Spiel heute gezeichnet wird und wie es besser geht

**Heute.**
- Ein einziges Objekt zeichnet jedes Bild alles von Hand: Boden, Häuser,
  Figuren, Effekte, HUD und Menüs. Das sind rund 1.000 Zeichenbefehle im Code
  (`draw_rect`, `draw_circle`, `draw_texture` …).
- Nur der Boden wird in Stücken zwischengespeichert. Alles andere wird jedes
  Bild neu in GDScript berechnet.
- Figuren und viele Objekte bestehen aus Rechtecken und Kreisen statt aus Bildern.
- Das Bild ist fest 1152 × 648 groß und wird gestreckt, daher die schwarzen
  Ränder und uneinheitliche Pixelgrößen.
- Menüs sind gemalte Kästen mit festen Klickflächen. Jede Änderung braucht
  neue Koordinaten.

**Besser: Szenen statt Malen.**
1. **Welt aus Knoten:** Boden als Kachel-Ebenen, Häuser und Objekte als
   Sprites, automatische Tiefensortierung, eine echte Kamera mit weichem
   Folgen. Godot zeichnet das gebündelt auf der Grafikkarte. Nur was sich
   bewegt, kostet Rechenzeit.
2. **Pixelgenaue Darstellung:** Die Welt wird in kleiner, fester Auflösung
   gerendert (z. B. 640 × 360) und in ganzen Schritten hochskaliert. Jeder
   Pixel ist überall gleich groß und scharf. HUD und Schrift liegen getrennt
   darüber in voller Auflösung. Breitbild füllt den Schirm ohne Ränder.
3. **Licht und Schatten:** 2D-Lichter für Laternen, Kristalle und Zauber,
   Nacht durch echte Dunkelheit statt Farbschleier. Damit wird auch das
   Dunkel aus C1 schön: Sicht ist Licht.
4. **Shader statt Handarbeit:** Nebel, Wasser, Wind in Gras und Bäumen,
   Trefferblitz, Umrisse als kleine Grafikprogramme.
5. **Partikel** für Funken, Staub, Magie und Blätter.
6. **Menüs aus echten Bedienelementen** mit gemeinsamem Stil: Hover, Fokus,
   Controller und verschiedene Bildschirmgrößen funktionieren von selbst.
7. **Figuren** kommen als 3D-Modelle mit Pixel-Filter in diese Welt (D2).

**Ablauf ohne Stillstand.** Das alte und das neue Zeichnen laufen eine Zeit
nebeneinander. Reihenfolge: Kamera und HUD-Ebene trennen → Boden →
Objekte und Häuser → Figuren und Gegner → Effekte und Licht → Menüs nach und
nach. Jeder Schritt geht einzeln live.
