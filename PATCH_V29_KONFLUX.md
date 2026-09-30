# Sonnenhain v29 · Konflux

Zusätzliche PvP-Welt hinter dem Himmelsgarten. Das Tor steht bei (14800, 9120); mit E betreten. Eintritt und Wiederbelebung führen zum geschützten Mittelpunkt (40000, 40000). Rückkehr durch das Tor am Spawn. Normale Spielstände behalten eine gültige Position in der bisherigen Welt.

## Inhalt

- 80.000 × 80.000 Welteinheiten, 32-Pixel-Raster: 2500 × 2500 logische Zellen. Die Welt wird deterministisch erzeugt; maximal 48 sichtnahe Boden-Chunks bleiben im Speicher.
- Vier Biome: Smaragdforst, Frostweite, Blütenmeer, Kupfersteppe. Große freie Flächen, einzeln gesetzte Deckungsobjekte, zwölf Event-Orte und vier Gebäude.
- Durchgehender Fluss mit zwei Armen um die zentrale Insel, sieben Brückenkorridore, passierbares Flachwasser und gesperrtes Tiefwasser. Die Spieler-Kollisionsfläche wird an den Wassergrenzen mitgeprüft.
- Terrassen mit 48, 96 und 144 Pixel Höhe. Breite Südrampen verbinden die Ebenen. Höhenwerte treiben Bewegung, Darstellung, Projektilprüfung, Kamera und Mauszielrichtung. Rollen und Sprungfähigkeiten bewegen sich in kleinen Kollisionsschritten.
- Vier betretbare Gebäude: Jagdloge, Frostschrein, botanisches Haus und Werkstatt, jeweils mit eigenem Innenraum. E öffnet und verlässt sie. Möbel und Außenkörper haben Kollisionsflächen; Innenräume bleiben PvP-Gebiete.
- Drei rotierende Runenpunkte sind gleichzeitig aktiv. E startet eine zehnsekündige Eroberung; Treffer oder Verlassen des Punktes brechen sie ab. Der Multiplayer-Server prüft die Eroberung.
- PvP-Treffer, Abklingzeiten, Schutzkreis und Wiederbelebung werden auf dem Server berechnet. Klassenfähigkeiten verwenden eigene Arena-Schadenswerte statt PvE-Ausrüstungsschaden. Schutzschilde, Gift, Verlangsamung und Ausweichschutz werden berücksichtigt. Inventartränke sind in der Arena deaktiviert; im Spawnkreis regeneriert Leben.
- Die zuvor überarbeiteten Startbereich-Texturen sind enthalten. Einzelne Grafiken werden als verlustfreie WebP-Atlanten geliefert; alle sichtbaren Pixel wurden mit den PNG-Originalen verglichen. Keine komplette Map wird als Hintergrundbild eingefügt.
- Kleine Waffen- und Spell-Polygone werden lokal gezeichnet, damit große Weltkoordinaten keine Formen verschwinden lassen. Die Darstellung bleibt auf 1152 × 648 ausgelegt und wird mit erhaltenem Seitenverhältnis skaliert.
- Die neueren GitHub-Korrekturen für automatische Multiplayer-Verbindung und Spielerpräsenz wurden übernommen.

## Vorlagen und Testversion

72 Material-/Objektvorlagen plus vier Innenraumkonzepte: `website/konflux-gallery/index.html`. Originale und Engine-Screenshots liegen lokal unter `pvp-design/`. Die Spielgrafiken stehen unter `art/start32/` und `art/konflux/`.

Lokale Vorschau: `http://localhost:8787/konflux-game/index.html`. Sie startet einen Stufe-40-Testhelden direkt in Konflux und verändert keine normalen Spielstände. Im normalen Spiel erfolgt der Zugang am Ende der bisherigen Kartenkette.

## Prüfungen

- Godot 4.7.2 Parser und Web-Export.
- `tools/check_konflux.gd`: Kartengröße, Spawn, Brücken, Tiefwasser, Rampen/Klippen, Hauskörper/Türen, Innenraumgrenzen, Schutz vor Crossfire, PvP-Projektile/Abklingzeiten, Transparenz und begrenzter Chunk-Speicher.
- Bestehende Prüfungen: Kartenlogik, sechs Rüstungen und Sterbeanimationen, 31 aktive PvE-Fähigkeiten auf Rang 1 und 5 und drei passive Fähigkeiten, native 32-Pixel-Tiles im Startbereich.
- Zwei echte WebSocket-Testclients am lokalen Dedicated Server: gegenseitige Sichtbarkeit, Arena-Eintritt und serverseitiger PvP-Schaden außerhalb des Schutzkreises.
- Native Bilder für Spawn, alle vier Gebäude, Fluss, Terrasse und alle Innenräume; zusätzlich Browser-Start und klickbare Karte.

Dies ist die erste spielbare Konflux-Version. Langzeit-Balancing und Lasttests mit großen Spielergruppen sind durch diese Funktionsprüfungen nicht abgedeckt.
## v29.1 – Synchronisierung und Controller

Monster wählen ihre Ziele innerhalb des eigenen Kartenbereichs. Die Multiplayer-Prüfung verlangt nun tatsächlich bewegte Monster. Ausbleibende Serverantworten lösen nach zwölf Sekunden eine neue Verbindung aus, auch bei geöffnetem Pausenmenü. Website und Server werden vor dem Serverwechsel auf dieselbe Commit-Version geprüft.

Controller: Öffnen/Interagieren liegt auf X/Quadrat und lässt sich umbelegen. Ein-/Ausschalten, Erkennen, Totzone, Trigger, Menüfokus und gespeicherte Belegung sind verfügbar. Automatische Prüfungen bestehen; ein physischer Controller wurde nicht angeschlossen.

Der Spawnwegstein in Konflux führt zurück zum Map-0-Spawn. Monster-XP sinken mit zunehmendem Abstand unterhalb des Spielerlevels. Der Bogengriff sitzt an der Hand. Beim Patch wird einmal „Server wird gepatcht.“ in den Spielchat gesendet.
