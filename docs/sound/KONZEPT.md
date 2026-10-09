# Sonnenhain – Soundkonzept

Stand: 9. Oktober 2026. Ziel: Sounds, die sich hochwertig, warm und eindeutig
nach Sonnenhain anfühlen. Jede Aktion soll hörbar Rückmeldung geben, ohne dass
es nervt oder matscht.

## 1. Ausgangslage

Gemessen an den Dateien unter `audio/` und am Code in `main.gd`:

| Befund | Folge |
|---|---|
| Fast alle Effekte sind synthetisch erzeugt, mono, 22,05 kHz | klingen dünn und „piepsig“; Höhen fehlen |
| Magier- und Bogenfähigkeiten (16–33) folgen einer Vorlage: vier Längen im Wechsel (0,35/0,43/0,51/0,59 s), gleiche Lautstärke | 18 Fähigkeiten klingen fast gleich; Feuer und Eis sind nicht unterscheidbar |
| Spitzenpegel schwanken von 0,08 (Schritt) bis 0,81 (Fähigkeiten 5 und 13) | manche Sounds springen heraus, andere gehen unter |
| `menu` wird an 37 Stellen genutzt, `level` an 21 Stellen als allgemeiner Erfolgston | Klicks, Käufe, Fehler und Questabschluss klingen gleich |
| Gegner haben bis auf das Pilzzischen keine eigenen Laute; Treffer am Gegner, Spielerschaden und Tod sind kaum hörbar | Kampf fühlt sich stumm an, Treffer haben kein Gewicht |
| Wiedergabe über 8 nicht-räumliche `AudioStreamPlayer`; ein neuer Sound stoppt den ältesten | keine Richtung, keine Entfernung; in großen Kämpfen werden Sounds abgeschnitten |
| Keine Audio-Busse: Musik und Effekte nur über Lautstärke-dB getrennt | kein gemeinsames Mischen, kein Ducking, kein eigener UI- oder Umgebungsregler |
| Keine Umgebungsgeräusche, Schritte nur ein einziger Klang | die Welt wirkt leer zwischen den Kämpfen |
| Gut gelöst und als Maßstab geeignet: Türen v2 (44,1 kHz, echte Holzcharakteristik), Pilz-Giftzischen (48 kHz, sauber), Ausrüstungsklänge | beweisen, dass der Ansatz „wenige, gezielte, saubere Sounds“ funktioniert |

## 2. Klangidentität

**Leitbild: handgemachtes Märchen in Pixelart.** Natürliche, weiche, warme
Klänge statt Retro-Piepsen. Holz, Stoff, Leder, Laub, Wasser, Glas und Kristall.
Magie klingt glitzernd und luftig, nicht elektronisch.

Grundregeln:

1. **Natürlich vor synthetisch.** Waffen, Schritte, Tiere und Gegenstände
   klingen nach echtem Material. Nur Magie und Benutzeroberfläche dürfen
   künstlich glänzen.
2. **Kurz und klar.** Kampfsounds unter 0,4 s mit schnellem Einsatz; der
   wichtigste Teil liegt in den ersten 50 ms.
3. **Jedes Element hat eine Klangfarbe.** Feuer: Fauchen und Knistern. Eis:
   Klirren und kristallines Knacken. Blitz: trockenes Knallen und Surren.
   Gift: Blubbern und Zischen. Arkan: gläserne Glocken, Hall. Physisch:
   Holz, Metall, Leder.
4. **Gegner erkennt man am Ohr.** Jeder Gegnertyp hat mindestens Angriffs-,
   Treffer- und Todeslaut in seiner Materialfarbe (Schleim nass, Käfer
   chitinartig, Pilz weich, Wolf tierisch).
5. **Nichts nervt nach 100 Wiederholungen.** Häufige Sounds (Schritte, Schläge,
   Treffer, Klicks) haben 3–5 Varianten und leichte Tonhöhenstreuung.
6. **Nichts ist schrill.** Kein harter Anteil über 8 kHz bei häufigen Sounds,
   keine Clipping-Spitzen; Pegel einheitlich.

## 3. Technik

Neues Modul `components/sound_bank.gd` (Regeln in `AGENTS.md`), dazu wenige
Verdrahtungszeilen in `main.gd`.

- **Audio-Busse:** `Master` → `Musik`, `Effekte`, `Oberfläche`, `Umgebung`.
  Eigene Regler im Pausenmenü für Effekte, Oberfläche und Umgebung (Musik gibt
  es schon). Auf `Effekte` ein leichter Limiter gegen Übersteuerung.
- **Räumlicher Klang:** Weltgeräusche (Gegner, Treffer, Zauber, Truhen) über
  `AudioStreamPlayer2D` am Ereignisort, mit Lautstärke-Abfall über die
  Entfernung und leichter Stereo-Richtung. Oberfläche und eigene
  Spieleraktionen bleiben nicht-räumlich.
- **Stimmen-Pool mit Vorrang:** Pro Sound eine Höchstzahl gleichzeitiger
  Wiedergaben (z. B. Treffer 4, Schritte 1, Gegnerlaute 3). Ist alles belegt,
  verdrängt ein wichtiger Sound (Spielerschaden, Boss) einen unwichtigen, nie
  umgekehrt.
- **Varianten und Streuung:** Ein Sound-Eintrag kann mehrere Dateien haben; pro
  Abspielen zufällige Variante (ohne direkte Wiederholung) und ±4 % Tonhöhe.
- **Ducking:** Bei Level-Aufstieg, Bossauftritt und Questabschluss wird die
  Musik kurz um 6 dB abgesenkt.
- **Katalog statt verstreuter Namen:** Ein Eintrag pro Sound mit Dateien, Bus,
  Lautstärke, Vorrang, Höchstzahl und räumlich ja/nein. `play_sound("name")`
  bleibt als Aufruf erhalten, damit bestehender Code weiterläuft.

**Dateiformat und Pegel:** WAV, 44,1 kHz, 16 Bit, mono (Umgebung stereo).
Spitzenpegel höchstens −3 dBFS. Effekte werden auf ähnliche Lautheit
eingemessen (kurze Effekte etwa −18 LUFS kurzzeitig, Umgebung etwa −28 LUFS);
die Feinabstimmung erfolgt im Katalog, nicht in der Datei.

**Ablage:** `audio/sfx/<bereich>/<name>_<variante>.wav`, z. B.
`audio/sfx/kampf/schwert_schwung_01.wav`, `audio/sfx/mobs/schleim_tod_02.wav`.
Rohmaterial und Projektdateien unter `audio/source/` (nicht im Spiel geladen).

## 4. Soundkatalog und Reihenfolge

### Paket 1 – Kampfgefühl im Startbereich (zuerst)

Das bringt am meisten: Die ersten Minuten fühlen sich sofort wertiger an.

| Bereich | Sounds |
|---|---|
| Spielerangriffe | Schwert: Schwung ×4, Treffer ×3. Stab: Schwung ×3, Magie-Einschlag ×3. Bogen: Spannen, Abschuss ×3, Pfeiltreffer ×3, Pfeil prallt ab |
| Treffer nach Material | weich/nass (Schleim, Pilz), Chitin (Käfer), Fell/Fleisch (Wolf), Stein (Golems, später) je ×3 |
| Spieler | Schaden nehmen ×3, kritischer Lebensstand (leiser Herzschlag), Ausweichrolle ×2, Tod, Wiederbeleben, Trank trinken |
| Waldschleim | Hüpfen ×3, Angriff, Tod (Platschen) |
| Blütenkäfer | Zirpen/Flügel ×2, Drüsenschuss, Sekret-Einschlag, Tod |
| Pilzling | Giftzischen (vorhanden), Ankündigung des Giftkreises, Tod |
| Mooswolf | Knurren ×2, Sprungansatz, Sprung, Biss, Jaulen beim Tod |
| Beute | Münzen ×3, Gegenstand aufheben, seltene Beute (heller Glanz), epische/legendäre Beute (eigener Akzent) |

### Paket 2 – Oberfläche und Fortschritt

Klick, Darüberfahren, Fenster öffnen/schließen, Inventar sortieren, Kaufen,
Verkaufen, „geht nicht“ (Fehler), Quest angenommen, Questfortschritt, Quest
abgeschlossen, Level-Aufstieg (kurze Fanfare, 1–1,5 s), Fähigkeitspunkt
vergeben, Wegstein aktiviert, Reise/Teleport, Truhe öffnen, Speichern bestätigt.

### Paket 3 – Fähigkeiten

Alle 33 Klassenfähigkeiten nach Elementfamilien neu: jeweils Auslösen,
gegebenenfalls Flug-Schleife und Einschlag. Feuerball, Frostnova, Blitzlanze,
Meteorschauer, Pfeilhagel usw. bekommen klar unterscheidbare Klangfarben nach
Abschnitt 2. Klassenfähigkeiten auf Taste 4 erhalten einen eigenen, größeren
Klang mit Ducking.

### Paket 4 – Welt und Atmosphäre

- Umgebungsschleifen je Gebiet (30–60 s, nahtlos): Dorf (Vögel, ferne
  Stimmen, Brunnen), Blütenwiesen (Bienen, Wind im Gras), Pilzwald (Tropfen,
  Knarzen), Mondküste (Brandung, Möwen), Ruinen (Wind, Hall) usw.
- Punktquellen in der Welt: Brunnen, Schmiede-Amboss, Feuerstellen, Laternen,
  Wasserfälle.
- Schritte nach Untergrund: Gras, Erde, Kopfsteinpflaster, Holzboden innen,
  Stein in Dungeons, je ×4.
- Tag und Nacht: abends Grillen statt Vögel.

### Paket 5 – Übrige Gegner und Bosse

Die restlichen 23 Monster nach demselben Muster wie in Paket 1, sobald ihre
neue Grafik kommt. Bosse zusätzlich mit Auftritts-, Phasen- und Siegesklang.

## 5. Herstellung

Drei Wege, kombiniert nach Art des Sounds:

| Weg | Wofür | Qualität | Hinweis |
|---|---|---|---|
| **A. Freie Aufnahmen mit CC0-Lizenz** (z. B. Kenney-Sammlungen, CC0-Sounds auf Freesound, Sonniss-GDC-Pakete) | Waffen, Schritte, Gegenstände, Tiere, Umgebung | hoch, weil echte Aufnahmen | Dateien muss Angelo herunterladen und anhängen; Claudes Arbeitsumgebung kann diese Seiten nicht abrufen. Quelle und Lizenz je Datei in `audio/LIZENZEN.md` |
| **B. Gestaltete Synthese** (Schichten aus Rauschen, Filtern, Hüllkurven, Hall; 44,1 kHz) | Magie, Oberfläche, Glanz-Akzente | gut, wenn sorgfältig geschichtet | erledigt Claude vollständig per Skript; keine Lizenzfragen; leicht anpassbar |
| **C. Mischung** | Gegnerlaute, Einschläge | hoch | Aufnahme als Grundlage, mit Tonhöhe, Filtern und synthetischen Schichten zu einem eigenen Sonnenhain-Klang verändert |

Alle Sounds durchlaufen dieselbe Nachbearbeitung per Skript
(`tools/build_sfx.py`): Stille kürzen, Ein-/Ausblenden, Pegel angleichen,
44,1 kHz, Prüfung auf Clipping. So bleibt die Qualität einheitlich, egal woher
ein Sound kommt.

Generierte KI-Sounds sind möglich, wenn der Dienst kommerzielle Nutzung
erlaubt; dann ebenfalls in `audio/LIZENZEN.md` vermerken.

## 6. Qualitätssicherung und Freigabe

- **Hörvorschau-Seite:** Zu jedem Paket gibt es eine Seite, auf der Angelo alle
  neuen Sounds anhören, mit dem alten Klang vergleichen und je Sound „passt“
  oder „ändern“ markieren kann. Claude kann Sounds nicht selbst hören; die
  Freigabe durch Angelo ist deshalb Pflicht.
- **Automatische Prüfung** `tests/audio/check_sound_bank.gd`: Jeder
  Katalogeintrag hat existierende Dateien, richtige Abtastrate, Spitzenpegel
  unter −3 dBFS, keine führende Stille über 10 ms, Varianten wo vorgeschrieben.
- **Im Spiel prüfen:** Ein Kampf gegen 6 Gegner gleichzeitig darf nicht
  übersteuern; nach 10 Minuten Spielen darf kein Sound nerven.
- Live geht ein Paket nur nach Angelos Bestätigung (siehe `AGENTS.md`).

## 7. Offene Entscheidungen für Angelo

1. **Klangrichtung:** Passt das Leitbild „handgemachtes Märchen, natürlich statt
   Retro-Piepsen“? Oder soll es bewusster nach klassischem 16-Bit klingen?
2. **Quellen:** Dürfen CC0-Aufnahmen verwendet werden (Weg A/C), oder soll alles
   selbst erzeugt sein (nur Weg B)? Weg B ist schneller, Weg A/C klingt bei
   Waffen, Tieren und Schritten deutlich besser.
3. **Referenzen:** Ein bis drei Spiele, deren Klang dir gefällt, helfen bei der
   Abstimmung.
