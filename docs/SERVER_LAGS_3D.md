# Lags im Online-Spiel seit den 3D-Landschaftsmodellen

Stand: 16. Oktober 2026. Meldung von Angelo:
„Lags auf dem Server seit wir [3D-]Modelle auf den Maps haben“.
Die Schreibweise „ed“ wird im Gesprächskontext als „3D“ verstanden.

**Status: gemeldeter Fehler, Ursache offen. Priorität P1; bei unspielbaren
Kämpfen, Abbrüchen oder Fortschrittsverlust P0. Vor weiterem breitem
3D-Ausbau untersuchen. Betrifft die Maps allgemein, nicht nur den Golem.**

## Was feststeht

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
