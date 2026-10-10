# Echte 3D-Körper auf den Außenkarten

Maps 1–12 erhalten jeweils sechs unterschiedliche Körper. Map 0 und ihre beiden Dorfmauern bleiben unverändert.

Die Körper bestehen aus echter räumlicher Mesh-Geometrie mit 64×64-Pixel-Materialtexturen, Licht und Tiefe. Ihre Geometrie wird einmal pro Motiv erstellt und geteilt. 58 der 78 Modelle besitzen kurze, nicht wiederholte Animationen mit 18–90 Sekunden Ruhe zwischen Ereignissen. Nur sichtbare Instanzen bleiben aktiv. Für Steine und feste Körper gibt es keine dauernde Bewegung.

Die bestehende Welt ist weiterhin ein 2D-Spiel. Ein gemeinsamer 3D-Viewport rendert die Modelle während des Spielens. Die laufenden Projektionen werden mit Spielern, Gegnern, NPCs und Wegsteinen nach ihrem Fußpunkt sortiert. Das ist keine Umstellung des gesamten Spiels auf eine frei drehbare 3D-Kamera und verwendet keine vorgerenderten Sprites. Auch die Animationen bewegen räumliche Modellteile.

Die verbindlichen Kollisionspunkte aus der bisherigen Welt bleiben erhalten. Die sichtbaren Körper werden diesen Punkten zugeordnet. Neue niedrige Pflanzen sind Dekoration und begehbar. Wege, Wegsteinplateaus, Portale und Bossflächen erhalten weiterhin ihre bestehenden Freiräume. Architekturkörper ersetzen feste Hindernisse, kleine Bögen abseits der Wege bleiben Dekoration.

## Bilder aus dem Spiel

Erstellt mit `tools/capture_obstacles_3d.gd`, derselben Darstellung und denselben Modellinstanzen wie im Spiel. Die aufgedeckte Karte dient nur der Sichtprüfung.

| Karte | Vorschau |
|---|---|
| 0 Sonnenhain | [Unverändertes Dorf](map00.png) |
| 1 Blütenwiesen | [Spielansicht](map01.png) |
| 2 Pilzwald | [Spielansicht](map02.png) |
| 3 Alte Ruinen | [Spielansicht](map03.png) |
| 4 Kristallmoor | [Spielansicht](map04.png) |
| 5 Ascheberge | [Spielansicht](map05.png) |
| 6 Mondküste | [Spielansicht](map06.png) |
| 7 Sternenbruch | [Spielansicht](map07.png) |
| 8 Nebelheide | [Spielansicht](map08.png) |
| 9 Bernsteinforst | [Spielansicht](map09.png) |
| 10 Tiefenquell | [Spielansicht](map10.png) |
| 11 Dämmergrat | [Spielansicht](map11.png) |
| 12 Himmelsgarten | [Spielansicht](map12.png) |

## Prüfung

`tests/rendering/check_obstacles_3d.gd` prüft alle 78 Körper, ihre echten Meshes und 64×64-Materialien, die 58 kurzen Animationen, alle sechs Motive je Außenkarte, die Freiräume und das Fehlen der Darstellung auf Map 0 und im Headless-Server. `tools/run_all_tests.sh` prüft die übrigen Spielregeln.

Weitere Sichtprüfungen: [freies Tor](mauer-tor.png), [Mauerverbindung](mauer-ecke.png), [70 % Zoom](zoom-70.png), [Figur hinter einem Körper](held-hinter-baum.png), [Figur davor](held-vor-baum.png).

Der lokale Web-Export wurde aus seinem ausgelieferten Ressourcenpaket geprüft. Der Modellkatalog wird ausdrücklich in Web- und Server-Export eingeschlossen.

Veröffentlichungsprüfung: 113 lokale Projektprüfungen bestanden. Die aktuellen Bossmechaniken einschließlich umgeworfener Bäume sind übernommen; die freie Altarmitte bleibt frei. Außenprojektionen werden an Map 0 abgeschnitten, sodass auch Nachbarmauern keine Dorfpixel verändern. Grasflecken, Blumen und Wasserwellen bleiben Teil des Geländes.
