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

**Leitbild (von Angelo festgelegt, 9.10.2026): 16-Bit, märchenhaft.** Der Klang
der großen Konsolen-Rollenspiele der 16-Bit-Zeit: kurze, warme Klangmuster statt
8-Bit-Piepsen, mit dem typischen weichen Hall und einem Hauch Körnigkeit.
Freundlich, verspielt, magisch; nie hart oder realistisch-brutal.

Was „16-Bit“ hier konkret heißt:

- **Klangmuster statt reiner Töne:** Jeder Sound ist aus kurzen, gestalteten
  Bausteinen geschichtet (Anschlag, Körper, Ausklang), wie bei den
  Sample-Chips der Zeit.
- **Warme, leicht gedeckte Höhen:** Wir erzeugen in 44,1 kHz, filtern aber
  die obersten Höhen weich ab (etwa ab 12 kHz) und geben eine zarte
  Bitreduktion dazu. Das klingt nach Konsole, ohne zu rauschen.
- **Der typische Echo-Hall:** kurzer, heller Hall mit leichtem Echo, für Magie
  und Fanfaren deutlicher, für Schläge und Schritte kaum.
- **Melodische Akzente:** Beute, Level-Aufstieg, Quests und Truhen bekommen
  kleine Melodien in einer gemeinsamen Tonart (D-Dur), damit sie zur Musik
  passen und als „Sonnenhain-Klang“ wiedererkennbar sind.
- **Märchenhaft:** Glöckchen, Harfen- und Glockenspielfarben für Gutes,
  hölzerne und gedämpfte Töne für Alltägliches, tiefe weiche Pauken für Bosse.

Grundregeln:

1. **Kurz und klar.** Kampfsounds unter 0,4 s mit schnellem Einsatz; der
   wichtigste Teil liegt in den ersten 50 ms.
2. **Jedes Element hat eine Klangfarbe.** Feuer: fauchendes Rauschen mit
   Knistern. Eis: hohe, klirrende Glockentöne. Blitz: trockenes Knallen mit
   surrender Modulation. Gift: blubbernde, abwärts gleitende Töne. Arkan:
   gläserne Glocken mit langem Hall. Physisch: kurze, holzige Schläge.
3. **Gegner erkennt man am Ohr.** Jeder Gegnertyp hat mindestens Angriffs-,
   Treffer- und Todeslaut in seiner Farbe (Schleim nass und federnd, Käfer
   klickend, Pilz weich und dumpf, Wolf knurrend).
4. **Nichts nervt nach 100 Wiederholungen.** Häufige Sounds (Schritte, Schläge,
   Treffer, Klicks) haben 3–5 Varianten und leichte Tonhöhenstreuung.
5. **Nichts ist schrill.** Keine harten Spitzen, kein Clipping, einheitliche
   Pegel.

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

Durch die 16-Bit-Richtung entstehen die Sounds **hauptsächlich per Skript**
(`tools/build_sfx.py`): geschichtete Klangbausteine aus Oszillatoren, Rauschen,
Filtern, Hüllkurven, Bitreduktion und Echo-Hall. Vorteile: keine Lizenzfragen,
einheitlicher Stil, jede Änderung ist reproduzierbar und schnell gemacht.

Wo ein Klang natürlicher sein muss (z. B. Wolfsknurren, Laub), kann eine freie
Aufnahme mit CC0-Lizenz als Grundlage dienen und durch dieselbe
16-Bit-Bearbeitung laufen. Solche Dateien lädt Angelo herunter; Quelle und
Lizenz je Datei stehen in `audio/LIZENZEN.md`.

Alle Sounds durchlaufen dieselbe Nachbearbeitung: Stille kürzen,
Ein-/Ausblenden, Pegel angleichen, Prüfung auf Clipping. Die Erzeugung ist
deterministisch (feste Saat), damit ein erneuter Lauf dieselben Dateien ergibt.

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

## 7. Stand

- **Paket 1 umgesetzt** (9.10.2026): 41 Sounds in 71 Dateien unter
  `audio/sfx/{kampf,treffer,spieler,mobs,beute}/`, erzeugt mit
  `python3 tools/build_sfx.py`. Katalog, Busse (`Musik`, `Effekte` mit
  Begrenzer, `Oberfläche`, `Umgebung`), Stimmenlimits, Varianten,
  Entfernungsdämpfung und Ducking in `components/sound_bank.gd`;
  Test `tests/audio/check_sound_bank.gd`.
- Noch nicht in Paket 1: Stereo-Richtung (zurzeit nur Entfernung), eigene
  Regler für Oberfläche und Umgebung (Paket 2), Laute der übrigen Monster
  (Paket 5). `bogen_spannen` ist vorbereitet, wird aber noch nicht abgespielt.
- Runde 1 der Freigabe: 30 passt, 11 überarbeitet (Schwert schlitzt statt
  pfeift, Stab nach Alchemie, Bogen trocken mit 10 Varianten, Spannen ohne
  Ton, Krit als brechende Rüstung, Geisttreffer wie Pappe, Schaden als
  stimmhaftes „Uff“, Trank nur Schlucke, Wolf landet auf Gras und winselt).
  Wenig Leben ist jetzt ein Herzschlag als Schleife, solange das Leben unter
  25 % liegt.
- Runde 2: 36 passt. Geisttreffer geisterhafter (Pappe-Kern plus Seufzen und
  Nachklang), Trank als schnelles Gluckern. Wolf-Landung und eigener
  Wolf-Todeslaut auf Wunsch entfernt; der Mooswolf nutzt „tod_fell“. Der
  Rückkehr-Klang spielt auch beim Betreten der Welt (Fortsetzen, Koop-Start,
  nach dem Prolog). Bogenschuss: alle 10 Varianten im Spiel.
- Alle Sounds sind selbst erzeugt; es gibt keine Fremdlizenzen.
- Freigabe läuft über die Hörvorschau „Sonnenhain Klangprobe“.

## 8. Entscheidungen

- 9.10.2026: Klangrichtung **16-Bit, märchenhaft** (Angelo).
- Offen: Referenzspiele, deren Klang gefällt (hilft beim Feinschliff).
