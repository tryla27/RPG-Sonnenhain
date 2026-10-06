# Entwurf: Monster, Waffen und Fähigkeiten
Stand: 1. Oktober 2026. Entwurf, noch nicht im Live-Spiel.
Bilder werden nativ in Godot aus components/monster_design_32.gd gerendert.
Die acht Spalten zeigen N, NO, O, SO, S, SW, W, NW. Es sind Ansichten einer Laufphase, noch keine vollständigen Animationszyklen.
Die neuen Formen sind ein erster technischer Blockout. Besonders Geister, Golems und Tiere brauchen weitere artspezifische Silhouetten und Details.

## Schwierigkeit nach tatsächlichem Gebietslevel
Die Mapnummer ist keine Schwierigkeitsskala: Mondküste (Map 6) ist ein frühes Gebiet.
- Map 1 Blütenwiesen und Map 6 Mondküste: exakt EIN Angriff pro normalem Mob. Keine versteckten Zusatzattacken, keine Statusschäden.
- Map 2 Pilzwald und Map 8 Nebelheide: weiterhin EIN Angriff; größere Reichweite oder klar angekündigter Anlauf.
- Map 3 Alte Ruinen und Map 9 Bernsteinforst: höchstens zwei Fähigkeiten, nacheinander.
- Map 4 Kristallmoor und Map 10 Tiefenquell: zwei Fähigkeiten, erste kurzzeitige Bodeneffekte.
- Map 5 Ascheberge und Map 11 Dämmergrat: zwei bis drei Fähigkeiten, mit sichtbaren Erholungsfenstern.
- Map 7 Sternenbruch und Map 12 Himmelsgarten: maximal drei Fähigkeiten und erkennbare Kombinationen.
- Bosse sind separat: zwei Kernfähigkeiten und später eine dritte Phase, niemals alle Angriffe gleichzeitig.

## Angriffsplan für alle vorhandenen 27 Typen
| Monster | Map | Erster Angriff | Spätere Ergänzung |
|---|---:|---|---|
| Waldschleim | 1 | Langsamer Körperstoß | Keine |
| Blütenkäfer | 1 | Kurzer Biss | Keine |
| Pilzling | 2 | Einzelner Sporenball | Keine |
| Mooswolf | 2 | Angekündigter Sprungbiss | Keine |
| Steingolem | 3 | Schwerer Hammerhieb | Kurzer Bodenschlag |
| Ruinenbeholder | 3 | Einzelner Augenstrahl | Langsame Fächerladung |
| Kristallkrabbe | 4 | Scherenschlag | Kristallsplitter nach Ausholen |
| Kristallgolem | 4 | Kristallhammer | Markierte Bodenlinie |
| Ascheläufer | 5 | Gerader Ansturm | Kurze Glutspur |
| Lavagolem | 5 | Basalthammer | Verzögerter Lavafleck, später Schockwelle |
| Strandkrabbe | 6 | Scherenschnappen | Keine |
| Wassergeist | 6 | Einzelner Wasserball | Keine |
| Turmwächter | 3 | Schwerer Schwerthieb | Schildstoß; Bossphase: Bodenwelle |
| Kristallhüter | 4 | Kristallkeulenhieb | Splitterfächer; Bossphase: markierte Kristallfelder |
| Aschefürst | 7 | Flammenschwerthieb | Feuerlinie; Bossphase: drei verzögerte Eruptionen |
| Sternenschatten | 7 | Runenstabprojektil | Schattenversatz und angekündigter Sternfächer |
| Bruchwächter | 7 | Zweihandhammer | Bruchlinie und markierte Trümmerzone |
| Nebelhirsch | 8 | Angekündigter Geweihstoß | Keine |
| Irrlicht | 8 | Einzelner Lichtimpuls | Keine |
| Harzbestie | 9 | Beißangriff | Kleiner Harzfleck |
| Wurzelhexe | 9 | Einzelnes Stabprojektil | Markierte Wurzelzone |
| Quellkriecher | 10 | Sprungstoß | Wasserstoß nach Erholungsphase |
| Perlengeist | 10 | Perlenprojektil | Langsamer Wellenring |
| Gratgreif | 11 | Gerader Sturzflug | Flügelschlag; spätere Federsalve |
| Schattenritter | 11 | Runenschwerthieb | Schildstoß; spätere geradlinige Klingenwelle |
| Himmelsfalter | 12 | Lichtstaubprojektil | Windfächer und markierter Staubkreis |
| Sternenwächterin | 12 | Sternenklingenhieb | Sternenlinie und kurze angekündigte Schutzphase |

## Waffenprogression als sichtbares Design
- Lv 1–7: Holz, Wurzel oder einfache Knüppel.
- Lv 8–14: abgenutzte Bronze, Steinbeschläge.
- Lv 15–21: Stahl mit klaren Schneiden und stabiler Parierstange.
- Lv 22–28: Kristallwaffen und eingearbeitete Runen.
- Lv 29–35: Glut-, Basalt- oder Schattenwaffen passend zum Gebiet.
- Ab Lv 36: aufwendige Sternen- und Meisterwaffen mit gezieltem Leuchten.
Bewaffnete Typen: Pilzling, Steingolem, Kristallgolem, Ascheläufer, Lavagolem, alle drei Bosse, Sternenschatten, Bruchwächter, Wurzelhexe, Schattenritter, Sternenwächterin.
Tiere, Insekten und reine Geister behalten natürliche Angriffe. Ihre Stärke zeigt sich in Panzer, Geweih, Klauen oder magischem Kern.
Diese Stufen ändern noch KEINE Kampfwerte oder Beute. Für spätere Integration müssen Waffenmodell und Angriffswerte auf dieselbe Stufe zugreifen.
Waffen beim Ausholen, Treffen und Erholen an die tatsächliche Hand und Blickrichtung binden. Hintere Ansichten verdecken die Hand korrekt.

## Für ein einheitliches fertiges System
- Pro Monster: acht Blickrichtungen; Idle, vier Gehphasen, Ausholen, Treffer, Erholung, Schaden und Tod.
- Körper bleiben aufrecht; kein Drehen eines Frontbildes als Ersatz für Seitenansichten.
- Größen: kleine Gegner ca. ein Tile breit, normale Körper zwei Tiles, Bosse drei bis vier. Trefferkreis separat von dekorativen Waffen.
- Schatten, Kontur und Palette mit den neuen Spielerfiguren abstimmen.
- Angriff zunächst 0,6–0,9 Sekunden ankündigen; später mindestens 0,35 Sekunden, passend zur echten Ausweichdauer testen.
- Pro normalem Angriff genau ein Trefferereignis; keine mehrfachen Treffer durch Rendering oder Netzwerkpakete.
- Bewegung, Ziel, Startzeit, Fähigkeit und Treffer werden vom Server entschieden. Clients zeigen denselben Angriff mit derselben Startzeit.
- Gruppenbossfortschritt separat bestätigen, keine doppelte XP/Beute.
- Prüfungen: alle acht Richtungen, Hindernisse/Tore, PvE/PvP-Trennung, hoher Ping, Reconnect, Paketduplikate und mehrere Gruppenspieler.

## Angriffstempo: Codebefund und vorgeschlagene Startwerte
Codeprüfung am 1. Oktober 2026, keine Änderungen an Live-Kampfwerten:
- ENEMY_TYPES.speed ist Bewegungstempo in Welteinheiten pro Sekunde, kein Angriffstempo.
- Nahkampfschaden erfolgt derzeit direkt über Distanz und einen hit-Timer.
- Lokal hit=1,0 s; Dedicated Server hit=0,75 s. Unter gleichen Bedingungen ergibt das serverseitig bis zu 33 Prozent mehr Angriffe pro Sekunde.
- Boss-Nahkampfreichweite lokal 61, Server allgemein 42. Das muss aus einer gemeinsamen Definition kommen.
- Kontaktangriff prüft in diesen Zweigen nicht stun. Ein betäubter Mob kann dadurch weiter Kontaktschaden verursachen.
- Fernangriffe nutzen shot=2,4–3,1 s. Projektile bewegen sich mit 265, bei Bossen 310 Welteinheiten/s.
- Einige Fernkämpfer können aktuell zusätzlich Kontaktschaden verursachen. Für frühe Maps mit exakt einem Move muss die Kontaktattacke entfallen oder der einzige Move Nahkampf sein.

Vorschlag für vollständige Angriffszzyklen, Dauer von Angriffsbeginn bis zum nächsten Angriffsbeginn:
| Profil | Ausholen | Trefferfenster | Erholen | Restpause | Gesamt | Angriffe/s |
|---|---:|---:|---:|---:|---:|---:|
| Früher normaler Nahkampf | 0,65 s | 0,12 s | 0,55 s | 0,88 s | 2,20 s | 0,45 |
| Mittlerer Nahkampf | 0,55 s | 0,12 s | 0,48 s | 0,65 s | 1,80 s | 0,56 |
| Später schneller Nahkampf | 0,45 s | 0,12 s | 0,43 s | 0,50 s | 1,50 s | 0,67 |
| Schwerer Hammer | 0,90 s | 0,18 s | 0,75 s | 0,77 s | 2,60 s | 0,38 |
| Einfacher Fernkampf | 0,70 s | 0,10 s | 0,60 s | 1,30 s | 2,70 s | 0,37 |

Alle Werte sind vorgeschlagene Startwerte, keine bereits eingestellten oder spielgetesteten Balancewerte.
Angriffstempo = 1 / gesamte Zykluszeit. Ein Trefferfenster darf pro Angriff und Ziel genau einmal Schaden auslösen.
DPS zum Vergleich = Schaden pro Treffer / Zykluszeit; das ist Rohschaden vor Rüstung und tatsächlicher Trefferquote.
Animation wird aus dem zeitlichen Angriffszustand abgeleitet. Nicht Gameplay-Schaden an Renderframes koppeln.
Die GIFs laufen zur Sichtprüfung mit einheitlichem Tempo, nicht mit den geplanten individuellen Kampfzeiten.

## Tipps zur Bearbeitung
1. Zuerst dieselben Reichweiten und Timer für Server und Einzelspieler herstellen.
2. Pro Mob gemeinsame Daten: movement_speed, attack_cycle, windup, active_time, recovery, attack_range, hit_radius, projectile_speed, aggro_range, leash_range und damage. Fähigkeitensatz separat.
3. Move zuerst festlegen: Schaden, Reichweite und Trefferform müssen zu sichtbarer Waffe passen. Breite Hammerbewegung erhält einen Bogen; Strahl erhält eine Linie, kein unsichtbarer Rundumtreffer.
4. Nur ein bis zwei Stärkeparameter pro Gebietswechsel deutlich erhöhen. Schaden, Lebenspunkte und Angriffstempo nicht alle gleichzeitig stark multiplizieren.
5. Schnelle Wölfe: kurze Reichweite und kleinere Treffer; schwere Golems: langsam, kräftig, lange Erholung. Fernkämpfer: Distanz halten und sichtbare Projektile.
6. Keine ständige Zielverfolgung bis zum Treffer: Blickrichtung am Ende des Ausholens fixieren, damit Ausweichen hilft.
7. Angriff bei Betäubung/Tod abbrechen, nach Abbruch keinen verzögerten Treffer zulassen. Fähigkeiten teilen sich eine gemeinsame Sperre.
8. Aggro und Rückkehrdistanz getrennt behandeln. Frühe Gebiete müssen Rückzug erlauben; mehrere Mobs sollten nicht gleichzeitig ohne Vorwarnung treffen.
9. Waffenstufe beeinflusst sichtbare Qualität und ausgewählte Kampfwerte gemeinsam. Kein zusätzlicher versteckter Schadensmultiplikator, wenn der Levelschaden bereits skaliert.
10. Zur Balance messen: Zeit bis Mob stirbt, Anzahl benötigter Spielerangriffe, Zeit bis Spieler stirbt, Trefferquote, Ausweichfenster und Gruppenkampf. Erst solo ohne Ausrüstung, dann mit levelgerechter Ausrüstung testen.

## Umsetzungsstand
Die gemeinsamen Monsterprofile, KI, Trefferformen, Timer, Unterbrechung, Rückzug und Angriffs-Snapshots sind jetzt implementiert. Alle Standardnahkämpfer nutzen 2,2 Sekunden, schwere Gegner 2,6 Sekunden, Fernkämpfer 2,7 Sekunden; Gebietslevel erhöht nicht zusätzlich das Angriffstempo. Acht-Richtungs-Renderer ist ins Spiel eingebunden. Balance-CSV enthält idealisierte Solozeiten und synthetische Ausweichversuche, keine abgeschlossene manuelle Balanceabnahme. Zusätzliche Bodenfelder, dauerhaft wirkende Statuszonen und vollständige Tod-/Schadensanimationszyklen bleiben spätere Erweiterungen.
