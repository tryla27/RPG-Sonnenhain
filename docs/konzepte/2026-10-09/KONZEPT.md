# Konzept zu Angelos Rückmeldungen vom 9. Oktober 2026

Für jeden Punkt steht hier, was im Code gefunden wurde, die Ursache, die
geplante Lösung und wie sie geprüft wird. Umgesetzt wird erst nach Angelos
Okay. Bilder vom Ist-Stand liegen in diesem Ordner.

Aufwand: S = unter 1 Stunde, M = 1–3 Stunden, L = mehr als 3 Stunden.

---

## A. Charakter und Fenna

### A1. Fenna-Änderungen nach dem Login verschwunden

**Befund.** Fenna speichert bei jeder Änderung lokal und stellt den Stand in die
Server-Warteschlange (`click_appearance` → `save_game`). Die Kosmetikfelder
(`cosmetic_hair`, `cosmetic_cloak`, `cosmetic_jewelry`, `cosmetic_accent`)
stehen im Spielstand und werden auch vom Server vollständig gespeichert.

**Ursache (sehr wahrscheinlich).** Beim Anmelden über das Konto lädt
`open_account_character` den Serverstand, setzt den Abgleich zurück
(`dirty = false`, `latest = {}`) und übernimmt den Serverstand ungeprüft. Ein
lokal neuerer Stand fällt dabei weg. Das passiert immer dann, wenn die letzte
Fenna-Änderung den Server nicht mehr erreicht hat, zum Beispiel weil der Tab
kurz nach „Fertig“ geschlossen wurde oder die Verbindung kurz weg war. Die
Statuszeile „Verbindung weg · lokal gesichert, Abgleich folgt“ ist auf den
Testbildern sichtbar.

**Lösung (M).**
1. Beim Konto-Login vor dem Laden den lokalen Spielstand mit derselben
   Charakter-ID lesen. Ist er als „noch nicht bestätigt“ markiert und mindestens
   so neu wie der Serverstand, gewinnt er und wird sofort hochgeladen, statt
   verworfen zu werden.
2. Ist der Serverstand neuer, bleibt der lokale Stand als Konfliktkopie
   erhalten (wie heute schon beim normalen Laden).
3. „Fertig“ bei Fenna wartet sichtbar auf die Serverbestätigung („Gespeichert ✓“)
   und warnt beim Verlassen, solange die Bestätigung aussteht.

**Prüfung.** Neuer Test: Fenna-Änderung, Verbindung trennen, neu anmelden. Die
Änderung muss erhalten bleiben. Zusätzlich prüfe ich gegen das Server-Log, ob
bei dir echte `revision_conflict`-Fälle auftreten.

### A2. Umhänge zeigen Fehler

**Befund** (Bild `umhaenge-ist.png`, alle Völker, 3 Umhänge, 8 Richtungen):
- Die drei Umhangformen sind fast nicht zu unterscheiden.
- Von der Seite (Ost/West) ragt ein spitzer Zipfel unter die Füße.
- Der Farbakzent färbt den Umhang nicht; alle bleiben braun.
- Beim Laufen bewegt sich der Umhang nicht sichtbar mit.
- Nebenbefund: Beim Ork fehlt in Blickrichtung Nord der Kopf.

**Lösung (M–L).**
1. Drei klar verschiedene Schnitte: kurzer Schulterumhang, langer
   Reiseumhang bis zur Wade, Kapuzenmantel. Unterkante immer über dem Fuß.
2. Umhangfarbe aus Fennas Farbpalette (Stoff), Saum aus dem Akzent.
3. Zwei Laufphasen mit Schwung, beim Rennen weiter nach hinten.
4. Ork-Kopf in Nord-Richtung reparieren.

**Prüfung.** Vorschautafel wie `umhaenge-ist.png` vor und nach der Änderung, zur
Freigabe durch dich. Dazu ein Test, dass keine Umhangkante unter der Fußlinie
liegt.

### A3. Fenna überarbeiten

**Befund.** Fenna bietet vier Zeilen mit `<` `>` und Text wie „2 / 4“. Man sieht
erst in der kleinen Vorschau, was man gewählt hat. Es gibt keine Farbwahl für
den Stoff und keine Möglichkeit, Änderungen zu verwerfen.

**Lösung (M).**
- Auswahl als Kachelreihen mit kleinen Bildern statt Zahlen.
- Getrennte Farben für Umhang-Stoff und Akzent, als Farbmuster.
- Große Vorschau mit Drehen (8 Richtungen) und Laufen/Rennen auf Knopfdruck.
- Knöpfe „Übernehmen“ und „Verwerfen“. Gespeichert wird nur bei
  „Übernehmen“, mit sichtbarer Serverbestätigung (siehe A1).
- Bedienung mit Maus und Tastatur/Controller.

**Prüfung.** Vorschaubild der neuen Oberfläche zur Freigabe.

### A4. Mensch und Ork bekommen gleich viele Accessoires wie der Roboter

**Befund.** Roboter: 10 gestaltete Kopfteile (Antennen, Radar, Hörner …).
Mensch und Ork: 3 Stufen einer einfachen Pixelreihe als „Frisur“.

**Lösung (M).** Je 10 gestaltete Kopfteile, im selben Pixelstil wie die
Roboterteile:
- Mensch: Kurzhaar, Zopf, Locken, Haarknoten, Stirnband, Federhut,
  Blumenkranz, Lorbeerkranz, Kapuze, Diadem.
- Ork: Irokese, Kriegszopf, Knochenreif, Federschmuck, Stammesband,
  Hornhelm, Ohrringe, Hauerringe, Fellkappe, Schädelkappe.

Alte Spielstände behalten ihre Wahl (Stufe 1–3 wird auf passende neue Teile
abgebildet).

**Prüfung.** Vorschautafel aller 30 Kopfteile in 8 Richtungen zur Freigabe.

---

## B. Welt und Dorf

### B1. Ascheberge erst nach dem Magier-Boss (sichtbares Tor)

**Befund.** Die Wand zwischen Ruinen und Aschebergen verlangt schon heute den
Arkanhüter (`bosses_defeated[1]`), aber nur als unsichtbare Sperre. Außerdem
steht der Arkanhüter selbst im Sternenbruch, und auch dessen Zugang verlangt
den Arkanhüter. Ob es einen anderen Weg zu ihm gibt, muss ich noch prüfen.

**Lösung (M).**
1. Sichtbares, verschlossenes Tor mit Arkansiegel an beiden Zugängen zu den
   Aschebergen. Beim Berühren erscheint der Hinweis „Das Siegel des Arkanhüters
   versperrt den Weg“. Nach dem Sieg öffnet sich das Tor mit kurzer Animation
   und Klang.
2. Erreichbarkeit aller Gebiete per Test prüfen (Wände, Torbogen, Wegsteine).
   Kein Boss darf hinter seiner eigenen Sperre stehen, und kein Wegstein darf
   die Sperre umgehen.

**Offene Frage:** Wo soll der Arkanhüter stehen, damit man ihn vor den
Aschebergen erreicht? Mein Vorschlag: am Ende des Kristallmoors.

### B2. Kirche innen

**Befund.** Die Bänke sind vier große, durchgehende Blöcke
(277 × 106 Pixel je Block). Zwischen den Reihen gibt es keinen Durchgang, und
die Heilfläche liegt flach vor dem Altar.

**Lösung (S–M).**
- Jeder Block wird in einzelne Bankreihen mit Gängen dazwischen aufgeteilt.
  Mittelgang und Seitengänge sind frei, Elara ist von allen Seiten erreichbar.
- Die Heilfläche wird zu einem erhöhten, begehbaren Podest mit zwei Stufen;
  die Heilung wirkt, sobald man darauf steht.

**Prüfung.** Test, dass Elara und das Podest von der Tür aus auf mehreren Wegen
erreichbar sind. Dazu Vorschaubild des Raums.

### B3. Wegsteine: von überall überall hin reisen

**Befund.** Nur der Dorf-Wegstein öffnet die Reiseauswahl. Jeder andere
Wegstein aktiviert sich und schickt dich sofort ins Dorf.

**Lösung (S).** Jeder Wegstein öffnet dieselbe Reiseauswahl. Ein neuer Stein
wird beim ersten Benutzen aktiviert, danach öffnet sich die Auswahl. Das Dorf
ist darin immer ein Ziel. Gesperrte Gebiete bleiben gesperrt.

### B4. Orangene Ecken bei Rathaus, Borin, Fenna, Kirche und Alma

**Befund.** Alle fünf Häuser stehen auf eigenen Grundstücksflächen
(`PROPERTY_PADS` in `components/map0_ground_plan_32.gd`; insgesamt sieben,
dazu Schmiede und Arena). Auf meinen Testbildern zeichnen sich deren Ränder
als Rechteck ab (Bild `rathaus-ist.png`). Vermutlich setzen die Ecken dieser
Flächen Übergangskacheln, die keine passende Eckvariante finden. Warum
Schmiede und Arena nicht betroffen sind, kläre ich bei der Umsetzung.

**Lösung (M).** Eckübergänge der Grundstücksflächen korrigieren (passende
Eckkacheln bzw. abgerundete Ecken), Randlinie entfernen. Dazu ein
Prüfwerkzeug, das alle Eckzellen auf fehlende Übergänge prüft.

**Bitte:** ein Screenshot einer orangenen Ecke aus dem Spiel. Mein Testbild
zeigt die Fläche, aber nicht den genauen Farbfehler.

### B5. Wege an den beiden Dorfeingängen sauber abschneiden

**Befund.** Die Überlandwege beginnen innerhalb des Dorfes (bei 900/960 und
900/1300) und werden mit runden Kappen gezeichnet. Dadurch laufen sie unsauber
in die Eingangsflächen hinein.

**Lösung (S–M).** Beide Wege beginnen genau an der Torschwelle (Osttor
1780/1120, Südtor 875/2600) und werden an der Dorfmauer gerade abgeschnitten.
Die Eingangsfläche liegt dann sauber darüber.

### B6. Hausaccessoires (je 2) ersetzen

**Befund.** Die 14 Gegenstände vor den Häusern (`village_forecourts.gd`,
Grafiken `art/village/forecourts/v2/`) passen nicht zum Stil.

**Lösung (M–L).** Neue Gegenstände passend zu jedem Haus (Schmiede: Amboss und
Wassertrog; Kirche: Kerzenständer und Blumenkübel; Taverne: Fass und
Kreidetafel; usw.) im Stil der Häuser. Ich erstelle eine Vorschautafel mit
Vorschlägen. Erst nach deiner Freigabe ersetze ich sie im Spiel.

**Frage:** Hast du für die Hausgrafiken ein Werkzeug oder eine Vorlage, mit der
die Gegenstände entstehen sollen? Sonst zeichne ich sie selbst im Pixelstil und
lege sie dir zur Abnahme vor.

### B7. Laterne auf der Mauer an der Arena, keine Laternen und Büsche auf Pflaster

**Lösung (S).** Prüfwerkzeug und Test: Jede Laterne und jeder Busch muss auf
Gras stehen, mit Abstand zu Mauern, Wegen und Türen. Falsch platzierte Teile
werden auf die nächste freie Grasfläche verschoben (die Laterne an der Arena
zuerst).

---

## C. Oberfläche

### C1. Patch Notes lesbar machen

**Befund.** Alle Einträge stehen mit 11-Punkt-Schrift in einer langen Spalte.

**Lösung (S–M).** Eine Liste nur mit den Überschriften (größer, gut lesbar).
Ein Klick öffnet den Eintrag mit dem ganzen Text. Neueste Einträge stehen oben.

### C2. HUD verschlanken

**Befund** (Bild `rathaus-ist.png`): farbige Kästen für Leben, Energie,
Ausdauer und XP; die Zahlen liegen teils über den Balken. Das Questfeld steht
oben links, und die Minimap überdeckt rechts oben „Sonnenhain · LV 1“.

**Lösung (M).**
- Oben links nur noch schmale Balken für Leben, Energie und Ausdauer ohne
  farbigen Hintergrund. Die Zahlen erscheinen beim Darüberfahren. XP wird
  eine dünne Linie unter der Fähigkeitenleiste.
- Questfeld unten (über der Fähigkeitenleiste, halbtransparent, eine Zeile).
- Kartenname und Stufe unter die Minimap statt dahinter.
- Die Statuszeile zum Speichern erscheint nur noch bei Problemen.

**Prüfung.** Vorschaubild vorher und nachher, bei 100 %, 85 % und 70 % Zoom.

---

## D. Fusionen

### D1. Regel: Fusionseffekte zünden immer am Trefferpunkt, nie beim Spieler

**Befund.**
- Handgebaute Fusion 41 (Reaktorwall) zündet beim Wirken am Spieler.
- In den 528 automatisch erzeugten Fusionen zünden alle Fusionen mit Schutz-,
  Heil- oder Buffträger am Spieler (`PLAYER_POSITION`), Sprungträger am
  Landepunkt, also ebenfalls beim Spieler.

**Neue Regel (in `docs/FUSION_SYSTEM.md` als verbindlich).**
1. Jede Fusion hat einen Träger, der etwas trifft. Ihr Effekt zündet dort, wo
   dieser Treffer landet: erster getroffener Gegner, sonst das Hindernis, sonst
   das Ende der Reichweite.
2. Ist keine der beiden Fähigkeiten ein Angriff (z. B. Schildwall plus
   Energieschild), bekommt die Fusion einen kurzen Träger-Impuls in
   Zielrichtung. Der Effekt zündet an dessen Einschlag.
3. Sprungfusionen zünden dort, wo der Sprung trifft, nicht dort, wo der
   Spieler landet.
4. Schutz und Heilung werden am Einschlag zu einem Feld. Wer darin steht,
   erhält die Wirkung; der Spieler nur, wenn er selbst im Feld steht.
5. Mehrfachtreffer (Fächer, Durchschlag, Kette): Der Effekt zündet am ersten
   Treffer jedes Geschosses, höchstens dreimal pro Wirken.
6. Erlaubte Zündorte: Trefferpunkt, Zielpunkt, Angreiferposition. Spieler-
   und Landeposition sind verboten.

**Umsetzung (M–L).** Regeln in `fusion_rules.gd` und `fusion_catalog.gd`
umstellen, Träger-Impuls ergänzen, Reaktorwall anpassen, Mehrspieler-Prüfung
auf dem Server ebenso.

**Prüfung.** Test über alle 528 Fusionen plus die 4 handgebauten: Kein
Zündort ist Spieler- oder Landeposition, jede Fusion hat einen treffenden
Träger. Im Spiel: Vorschau-GIF von 3 Beispielen.

**Offene Frage zu Regel 4:** Soll ein eigener Schild aus einer Fusion den
Spieler weiterhin immer schützen? Oder wirklich nur, wenn er im Feld am
Einschlag steht? Ich empfehle das Feld, weil es die Regel konsequent hält.

---

## E. Vorgeschlagene Reihenfolge

| Paket | Inhalt | Aufwand |
|---|---|---|
| 1 | A1 Speicherfehler, B3 Wegsteine, B7 Laterne/Büsche, B5 Eingangswege, B2 Kirche | M |
| 2 | C1 Patch Notes, C2 HUD | M |
| 3 | D1 Fusionsregel | M–L |
| 4 | B1 Ascheberge-Tor und Erreichbarkeit | M |
| 5 | A2 Umhänge, A3 Fenna, A4 Accessoires (mit Vorschautafeln) | L |
| 6 | B4 orangene Ecken (nach deinem Screenshot), B6 Hausaccessoires | M–L |

Paket 1 behebt zuerst echte Fehler. Alles mit sichtbaren Änderungen bekommt
vorher ein Vorschaubild zur Freigabe. Live geht wie immer nur nach deinem Ja.
