# Lags im Online-Spiel seit den 3D-Landschaftsmodellen

Stand: 16. Oktober 2026. Meldung von Angelo:
„Lags auf dem Server seit wir [3D-]Modelle auf den Maps haben“.
Die Schreibweise „ed“ wird im Gesprächskontext als „3D“ verstanden.

**Status: Serveranteil lokal nachgewiesen und verbessert (17.10.), Live-Bestätigung offen. Priorität P1; bei unspielbaren
Kämpfen, Abbrüchen oder Fortschrittsverlust P0. Vor weiterem breitem
3D-Ausbau untersuchen. Betrifft die Maps allgemein, nicht nur den Golem.**

## Befund 17.10.: Serverspitzen durch Gegner-Wegsuche

Lokaler Nachbau mit echtem dediziertem Server und zwei Spielerprozessen
(`tools/benchmark_coop_network.gd`, je 70 s Laufen in der Blütenwiese, rund
12 Gegner). Beide Spieler sahen gleichzeitig Pausen von 300–350 ms, in denen
weder Bewegung des anderen noch Weltpakete ankamen. Ursache war der Server:
Einzelne Serverbilder dauerten bis 306 ms, fast vollständig in
`advance_mob()` → `MobNavigation.route()`.

- Die Wegsuche (eingeführt 09.10., einen Tag vor den 3D-Modellen) prüft bei
  nicht direkt erreichbaren Zielen bis zu ~15.000 Punkte auf Hindernisse.
- Jede Prüfung kostete rund 26 µs, davon etwa die Hälfte, weil
  `blocked_by_region_wall()` bei jedem Aufruf seine Mauerliste neu aufbaute.
- Unerreichbare Ziele wurden alle 0,6 s erneut voll durchsucht.

Der zeitliche Zusammenhang mit den 3D-Modellen ist damit erklärbar, ohne dass
die Modelle selbst den Server belasten: Der Server rendert keine Landschaft.

Änderungen:

- Mauerliste als Konstante (`REGION_WALLS`); Prüfung 12,8 → 3,6 µs.
- Wegsuche merkt sich bereits geprüfte Punkte und bricht nach 1.500 echten
  Prüfungen mit dem besten Teilweg ab. Unerreichbare Ziele erst nach 1,5 s neu.
- Höchstens drei neue Wegsuchen pro Serverbild (`MOB_ROUTES_PER_FRAME`);
  weitere Gegner planen im nächsten Bild.

| Messung (lokal, 2 Kerne) | vorher | nachher |
|---|---:|---:|
| Längstes Serverbild | 306 ms | 42–71 ms |
| Längste Lücke Bewegung anderer Spieler | 300 / 334 ms | 84–100 ms |
| Bewegungslücken über 150 ms | 3 / 3 | 0 / 0 |
| Längste Lücke Weltpakete | 350 ms | 150–167 ms |

Ein zweiter Lauf mit künstlich blockiertem Client (190 ms alle 2 s) zeigt
den anderen Anteil: Der andere Spieler sieht dann 250 ms Lücken in dessen
Bewegung. Clientruckler (z. B. Modellaufbau) wirken für Mitspieler also
ebenfalls wie Lag; dafür sind Atlas- und Modellbudget im Client zuständig.

Vier Spieler (50 s, 16 Gegner): längste Bewegungslücke 98–100 ms, keine über
150 ms, längstes Serverbild 47 ms. Ein früherer Vier-Spieler-Lauf zeigte
einzelne 300-ms-Lücken ohne passende Serverspitze; bei fünf Prozessen auf zwei
Kernen ist das am ehesten Rechenzeitmangel der Prüfmaschine. Hinderniskreise
je Zelle sind jetzt zwischengespeichert (`obstacle_blocker`), Prüfung 9,4 → 8,0 µs.

## Browser 17.10.: Brave und Edge auf der RTX 3060

Messmodus `?bench=1` im echten Webexport (`components/web_benchmark.gd`).
Mauertor und Pilzwald liefen in Brave und Edge mit P50 21–29 ms und P95
26–41 ms, also rund 35–48 Bilder/s. Die Blütenwiesen-Route hatte P95 um
125 ms und rund 78 Bilder über 50 ms, auch mit `noanim=1` und `no3d=1`.
Die 3D-Landschaft war also nicht die Ursache, sondern die Gegner-Wegsuche des
Einzelspielers (Blütenweiler-Angriff) ohne Begrenzung im Client.
Behoben wie auf dem Server, plus Kreis-Cache für Kollisionen (siehe CHANGELOG).
Brave verhält sich wie Edge; ein Brave-spezifischer Fehler zeigte sich nicht.

Offen: Live-Server-Protokolle (`SERVER_PERF cpu_max`) nach dem nächsten
Live-Gang vergleichen; Golem-Kampf als Belastungsfall.

## Golemkampf zu viert 17.10.: Weltpakete

Werkzeug `tools/benchmark_golem_server.gd`: dedizierter Server, vier Spieler
über echte WebSockets, Kampf bis zum Sieg (≈ 210 s Spielzeit, bis 12 Gegner,
24 Brocken, 130–270 Gegnergeschosse gleichzeitig). Gemessen im Container:

| Messgröße | vorher | nachher |
|---|---:|---:|
| Serverschritt (Gegner, Golem) P50 / P95 | 1,4 / 3,5 ms | 1,3 / 3,3 ms |
| Weltpaket je Sendung P50 | 7,0–7,2 ms | 3,6–5,7 ms |
| Weltpaket P95 | 15–17 ms | 6–10 ms |
| Weltpaket max | 25–26 ms | 14–24 ms |

Ursache: Jeder Spieler bekam ein eigenes, neu gepacktes und komprimiertes
Paket (≈ 1,2 ms je Spieler), auch wenn alle dasselbe sahen. Jetzt teilen sich
Spieler mit gleichem Ausschnitt ein kodiertes Paket
(`WorldSnapshot.for_peer` liefert einen Inhaltsschlüssel, `transmit` packt je
Schlüssel einmal). Geschosszeilen behalten ihre festen Felder und erneuern
nur Ort, Richtung, Lebenszeit, Schaden, Radius und Alter.
Rest: Die Geschosszeilen (bis 270 je Paket) und das Packen bleiben der größte
Anteil; Geschosse könnten später auf dem Client weitergerechnet statt jedes
Mal gesendet werden (Protokolländerung, nicht umgesetzt).
Messbedingung: gemeinsamer Container, Werte schwanken je Lauf; der lokale
Lauf ersetzt keine Live-Messung.

## Was feststeht

Ergänzung 16.10. nach Umsetzung: Die Kamerabewegung umgeht den Sammelabstand
nicht mehr; ruhende Atlasseiten werden ereignisabhängig aktualisiert.
Die Minimap verwendet begrenzte Geländecaches. Drei lokale Vergleichsrouten
zeigen kürzere P95-Bildzeiten und beide Außenmaps liefern im Chromium-Browser
3D-Ausgabe. Messgrenzen und verbleibende Lade-/Onlineprüfung:
[Umsetzungsbericht](QUALITY_V1_UMSETZUNG.md). Die folgenden Befunde zur
laufenden Darstellung beschreiben den Ausgangsstand vor diesem Paket.

- Angelo beschreibt einen zeitlichen Zusammenhang mit der Einführung der
  räumlichen Landschaftskörper. Dieser Zusammenhang ist eine wichtige
  Regressionsspur, noch kein technischer Ursachennachweis.
- Im lokalen Stand verhindert `WorldObstacles3D.enabled()` die Darstellung
  bei `dedicated_server_mode` und Headless-Betrieb. `update()` kehrt dort
  vor Modellsammlung und Viewport-Erzeugung zurück.
- Auf Clients sammelt `update()` sichtbare Körper, erzeugt/entfernt
  Instanzen und ordnet den Renderatlas an. Bei geänderter Kamerasignatur
  kann die Arbeit vor Ablauf der 0,25-Sekunden-Pause erneut erfolgen.
  Der Viewport rendert im aktiven Zustand laufend. Diese Pfade vermessen.
- Die vorhandenen `SERVER_PERF`- und `GOLEM_PERF`-Protokolle sowie die
  F3-Anzeige liefern Ansatzpunkte. Frühere lokale Optimierungstests
  belegen keine Behebung dieser allgemeineren Lag-Meldung.
- Die aktuelle laufende Serverversion, Live-Protokolle und reproduzierte
  Verzögerungen wurden für diesen Eintrag nicht geprüft.

## Untersuchung in dieser Reihenfolge

1. Haupt-, Browser- und Serverversion abgleichen. Gleichen Ort, Route,
   Auflösung, Zoom, Browser und Zahl der Spieler für Vergleiche festhalten.
2. Map 0 als Kontrollort und eine Außenmap entlang einer festen Route
   vergleichen: Stillstand, Laufen, Gebietswechsel und Kampf. Derselbe
   Test möglichst offline und online; andere Spieler am selben Ort prüfen.
3. In einer getrennten lokalen Prüfszene dieselbe Außenmap mit und ohne
   3D-Darstellung vergleichen. Kollisionen, Gegner, Route und Spielregeln
   identisch halten. Ein bloßer Vergleich unterschiedlicher Maps reicht
   nicht. Abschalten nur zur Diagnose, kein beschlossener Grafik-Rückbau.
4. Client-Framezeiten einschließlich Spitzen/95. Perzentil, Modellzahl,
   Sammel-/Instanzerzeugungszeit und Änderungen der Renderfläche erfassen.
   Prüfen, ob Modelle beim Laufen häufig neu entstehen und ob Material- oder
   Shaderaufbau zu Spitzen führt. Einmalkosten und dauernde Last trennen.
5. Gleichzeitig Server-Rechenzeiten, Paketmenge, Kodierungsdauer,
   zurückgestellte Weltpakete und beobachtete Antwortzeiten erfassen.
   Vorhandene Servermessung beginnt erst in `process_dedicated_server()`;
   bei unklaren Spitzen auch Arbeit davor und tatsächliche Tick-Abstände
   betrachten. Ein langsamer Client kann Nachrichten verspätet verarbeiten.
6. Je nach Messbefund gezielt optimieren: Instanzen wiederverwenden,
   Sammelarbeit räumlich begrenzen, Renderflächen stabilisieren oder
   getrennt Wegsuche/Serverlast/Netzwerkstau bearbeiten. Keine pauschale
   Senkung von Grafikqualität oder Netzwerkrate ohne Vergleichsnachweis.

## Fertig, wenn

- Ein reproduzierbarer Fall vorliegt und erklärt ist, welche Anteile vom
  Client, der Serversimulation oder dem Netzwerk kommen.
- Vorher-/Nachher-Messungen derselben Szene zeigen, dass die bestätigte
  Ursache verbessert ist. Messbedingungen und verbleibende Spitzen nennen.
- Wege, Kollisionen, Sichtbarkeit, Tiefensortierung und der bestehende
  Browser-Rückfall funktionieren weiterhin.
- Solo, Zwei-Spieler-Koop und vor breitem Ausbau vier Spieler sind geprüft;
  Golem-Kampf bleibt ein zusätzlicher Belastungsfall.
- Betroffene Verhaltenstests und Projektprüfungen bestehen. Ein Erfolg der
  lokalen Tests wird nicht als nachgewiesene Verbesserung des Live-Pings
  ausgegeben. Veröffentlichung nach konkreter Freigabe gemäß `AGENTS.md`.

Bezug: [Arbeitsplan](ARBEITSPLAN.md),
[3D-Landschaft](design/obstacles-live-3d/README.md),
[bisherige Netzwerk-/Golem-Optimierung](golem-network-performance.md).
