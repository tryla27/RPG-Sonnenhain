# Dunkler Golem – Klangentwurf (10.10.2026)

Wunsch von Angelo: Die Golem-Klänge sollen **klar, brutal, brechend und schwer**
sein. Für jede Aktion gibt es drei Vorschläge neben dem jetzigen Klang.
Erzeugt mit `python3 tools/build_golem_sfx_draft.py <zielordner>`; angehört und
gewählt wird auf der Klangprobe-Seite (Artifact „Golem-Klangprobe“).

## Richtungen

| | Name | Charakter |
|---|---|---|
| A | Felsbruch | Trocken und nah: harte Bruchkante vorne, dann kurzer tiefer Schlag. Am klarsten. |
| B | Tonnengewicht | Tiefe zuerst: wuchtiger Unterbau, längerer Nachhall, rieselnder Schutt. Am schwersten. |
| C | Zermalmen | Verzerrt und gepresst: gesättigte Schläge und Mahlen. Am brutalsten, passt zu Hardtekk. |

## Aktionen

| Aktion | Sound | Wann | Ziel | A | B | C |
|---|---|---|---|---|---|---|
| Schritt | `golem_schritt` | jeder Schritt, ~0,9 s | Tonnen Stein setzen auf | Bruch + trockener Schlag | tiefer Stampfer, Beben, Schutt | verzerrter Schlag, Knirschen |
| Schild | `golem_schild` | Schild an (8 s) | Steinplatten schlagen zu | 2 Schläge, Riss, Brummen | tiefes Zuschlagen, Mahlen, Dröhnen | 2 verzerrte Schläge, Mahlen |
| Schaben | `golem_schaben` | vor dem Wurf | Stein reißt den Boden auf | helles Kratzen, Splitter | tiefes Schleifen, Schutt | verzerrtes Sägen |
| Wurf | `golem_wurf` | Brocken fliegt los | Fels wird herausgerissen | Riss, Ruck, Luftzug | tiefer Ruck, schwerer Luftzug | verzerrter Ruck |
| Brocken landet | `brocken_landen` | Aufschlag, Stampfer | Fels schlägt ein und zerbricht | Einschlag + Bruchkante | Einschlag, Beben, langer Schutt | verzerrtes Krachen |
| Steinhagel | `steinhagel` | jeder Hagelstein | kleine Steine knallen auf | heller Knall | dumpfer Aufschlag | verzerrter Schlag |
| Schrei | `golem_schrei` | unter 40 % Leben | ein Berg brüllt | Brüllen + knisterndes Gestein | sehr tiefes Brüllen, Beben, Echo | verzerrtes Brüllen |
| Zerfall | `golem_zerfall` | Golem zerbricht | Körper bricht Stück für Stück | 5 harte Brüche | 3 tiefe Brüche, Steinregen | 5 verzerrte Brüche |

## Nach der Auswahl

Die gewählten Rezepte wandern nach `tools/build_sfx.py` (gleiche Namen wie
oben), die Dateien unter `audio/sfx/golem/` werden neu erzeugt. Alle Klänge
bleiben unter 2 s (Prüfung in `tests/audio/check_sound_bank.gd`).
