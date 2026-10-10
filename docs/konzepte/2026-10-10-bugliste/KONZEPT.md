# Bugliste 10.10.2026 – Konzept und Stand

Angelos Liste von 14:38 Uhr, umgesetzt ab 15:21 Uhr. Live geht alles erst nach
seiner Bestätigung.

| # | Wunsch | Ursache / Lösung | Stand |
|---|---|---|---|
| 1 | Pfeile verschwinden an Mauer, Spawn, Laterne ohne Klang | Online wurde der eigene, nur sichtbare Pfeil am Hindernis stumm entfernt; der Server kannte Laternen, Zäune, Brunnen, Dorfbäume nicht als Hindernis. Jetzt gleiche Regel auf Server und Spiel, eigener Schuss zerschellt sofort mit Bild und Klang, Material-Aufprall (Stein, Metall). | PR #111 gemergt |
| 2 | Bäume usw. weg (3D-Landschaft aus #105) | In Angelos Brave bleibt das 3D-Bild leer (nur Schatten sichtbar). Rückfall auf 2D (#108). Ursache noch offen: lokal (Chromium, Desktop) erscheint 3D. Jedes Spiel meldet jetzt das Prüfergebnis mit Grafikkarte und Browser an den Server (#115), damit die Ursache an echten Rechnern sichtbar wird. Hilfreich: Konsole (F12) und `brave://gpu` von Angelo. | #108 gemergt, #115 offen |
| 3 | Spawngeräusch entfernen | Brummen am Spawn-Stein abgeschaltet. Neuer Wunsch: neues, schlichtes Brummen (siehe Golem-Konzept v2, Punkt 1). | PR #112 gemergt |
| 4 | ESC soll Vollbild nicht beenden, Hinweis nach 2× ESC | Browser-Keyboard-Lock hält Escape im Vollbild (Chrome, Edge, Brave, Opera). Escape schließt Spielfenster, 2× Escape in 4 s → „Drücke F11 zum Beenden des Vollbildmodus.“ Escape gedrückt halten beendet es weiterhin (Browserregel). Firefox/Safari: wie bisher. | PR #112 gemergt |
| 5 | 8–12 Nahrungsbüsche pro Map | 8–12 Fruchtbüsche + 3 Kräuter je Gebiet, gleichmäßig verteilt, nie auf Wegen, Felsen, an Wegsteinen, Toren, Bossfeldern. Nebenbei: Skriptfehler in jedem Bild neben Kräutern behoben (kann ruckeln). Bild `nahrungsbuesche.png`. | PR #113 offen |
| 6 | Ausrüstung tauschen | Neues und altes Teil tauschen ihre Inventarplätze. | PR #112 gemergt |
| 7 | Item-Infos am Charakter | Maus über getragenem Teil zeigt die Infos. Bild `item-infos-charakter.png`. | PR #112 gemergt |
| 8 | Statusverbesserungen links kleiner | Essensanzeige als kleine Kacheln (92×28) nebeneinander, Details beim Darüberfahren. Bild `essensanzeige.png`. | PR #114 offen |
