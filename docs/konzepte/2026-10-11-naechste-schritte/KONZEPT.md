# Sonnenhain – Konzept für die nächsten Schritte

Stand: 11. Oktober 2026. Erstellt nach der erfolgreichen Veröffentlichung
von [PR #133](https://github.com/tryla27/RPG-Sonnenhain/pull/133).
Live-Commit: `3180af0b5897a160bd60c179cff0f9994389b9ab`.

Angelos Auftrag: fertige Bereiche zuerst hochladen und live schalten, danach
die übrigen Schritte planen. Seine anschließende Entscheidung gilt weiterhin:
**Erst weitere Spielupdates, danach die Android-App.** Dieses Dokument ist
ein Konzept; es setzt die nachstehenden Änderungen noch nicht um.

## Ausgangspunkt

Rezeptbuch, robuster Golem-Musikstart und kleinere Netzwerkpakete sind live.
Website und Server liefern denselben Stand. Die PR-CI, Web-/Serverexporte,
öffentliche WebSocket-Verbindung und Mehrspieler-Speicherprüfung waren grün.
Die lokale Prüfung umfasst 132 Projektprüfungen. Einzelheiten und Grenzen
der Leistungsbefunde stehen im [Golem-Bericht](../../golem-network-performance.md).

Auch der aktuelle Hauptstand ist enthalten: goldener menschlicher Krieger,
Golem v2, legendäre Rüstungen, erneuerte Waldgegner, neue Schleimbewegung und
Himmelsfalter, Ascheberge-Tor, Dorf- und Bedienungsreparaturen.
Die Android-Steuerung ist im Quellstand vorhanden; die APK wurde nicht neu
ausgeliefert. Die bisherige APK braucht später für Online-Spiel ein Update
auf Netzwerkprotokoll 10.

Die Außenwelt besitzt echte 3D-Landschaftskörper. Die vollständig räumlichen
Spielerfiguren mit Skelett und Ragdoll fehlen noch. Die 3D-Darstellung in
Brave ist nicht abschließend geklärt; der vorhandene Rückfall auf 2D bleibt
bis zur nachgewiesenen Reparatur bestehen.

## Reihenfolge

| Paket | Inhalt | Ergebnis für Spieler | Abschlusskriterium |
|---|---|---|---|
| 1 | Startbereich und tatsächliche Darstellungsprobleme | Verlässlicher Einstieg und gut lesbare Kämpfe | Dorf → Blütenwiesen → Pilzwald ohne blockierte Wege, unsichtbare Gegner oder verlorenen Fortschritt spielbar |
| 2 | Fortschritt, Händler und kleine Komfortfunktionen | Einheitliches Weiterleveln, passende Angebote und verständliche Freischaltungen | Level 40, 41, 99, 100 und 101 bleiben nach Relog und im Koop korrekt; Angebote und Entdeckungen gehören zum jeweiligen Charakter |
| 3 | Krieger als 3D-Prototyp | Sichtbare, vollständige Bewegungen als Grundlage des neuen Figurensystems | Eine isolierte Vorschau zeigt alle Grundaktionen und bewährt sich mit 20 Figuren im Browser; Angelo beurteilt den Look |
| 4 | Übrige Monster, Gebiet für Gebiet | Gleiche Qualität und nachvollziehbares Verhalten wie bei den Waldgegnern | Je Gebiet acht Ansichten, vollständige Aktionen und geprüfte Nah-/Fernkämpfe sowie freie Wege |
| 5 | Figuren, Trefferzonen, Ausrüstung und Fenna | Körperteile, sichtbare Ausrüstung und stimmige Gestaltung | Erst ein kompletter Krieger mit alten Spielständen und Koop, dann die weiteren Identitäten |
| 6 | Fusionsvorschau und Fusionsstein; Instrumente später | Fusionen vor dem Kauf verstehen und besser bedienen | Vorschau entspricht der echten Fähigkeit und verbraucht nichts; Fusionen bleiben nach Relog erhalten |
| 7 | Android-App nach den weiteren Updates | Passende App-Version zum dann freigegebenen Serverstand | Separate Freigabe und APK-Prüfung auf einem echten Handy |

Die Größenordnung wächst von kleinen Reparaturpaketen zu größeren
Grafikumbauten. Paket 3 ist bewusst nur ein Prototyp. Die gesamte Umstellung
von Figuren und Ausrüstung erfolgt in mehreren eigenen Veröffentlichungen.

## Paket 1 – Einstieg und Landschaft

Ein vollständiger Durchgang vom neuen Charakter bis zum ersten Waldstück
prüft Sicht, Wegführung, Hauszugänge, Questanzeige, Gegnerankündigungen und
die Rückkehr nach Sonnenhain. Der bestätigte dunkle Start bleibt dabei erhalten.

Die Ursache des leeren 3D-Bildes wird anhand der vorhandenen `CLIENT_3D`-
Diagnose und einer reproduzierbaren Brave-Szene untersucht. Schatten,
Vegetation und Tiefensortierung müssen gemeinsam erscheinen. Eine lokale
Aufnahme allein genügt nicht als Nachweis für den betroffenen Browser.

Beim Golem wird mit den vorhandenen `SERVER_PERF`-/`GOLEM_PERF`-Werten und
der F3-Anzeige zwischen Wegsuche, Netzwerkstau und Darstellung unterschieden.
Der nächste echte Kampf prüft außerdem den hörbaren Musikstart und den
Übergang zu den Hälften. Aus kleineren Testpaketen wird kein verbesserter
Live-Ping abgeleitet.

Pfeilklänge werden nur dort ergänzt, wo noch eine Materialreaktion fehlt,
etwa Wasser oder Pflanzen. Bereits vorhandene Holz-/Stein-/Metallklänge
werden weiterverwendet. Ein Klang darf keine neue unsichtbare Sperre erzeugen;
begehbare Büsche bleiben begehbar und die tatsächliche Geschosskollision
bestimmt, ob ein Aufprall stattfindet.

## Paket 2 – Fortschritt und Komfort

### Level über 40 und 100

Der aktuelle `gain_xp()`-Pfad besitzt bereits keinen festen Stopp bei 40.
Die Einschränkungen sind uneinheitlich: Testmodus und Reparaturmenü begrenzen
auf 40, mehrere Netzwerk-/Kampfpfade auf 99. Deshalb wird eine gemeinsame
Levelregel eingeführt, statt nur eine einzelne Grenze zu entfernen.

Bis einschließlich des Aufstiegs auf Stufe 100 bleibt der vorhandene
XP-Verlauf erhalten: `120 + (L−1) × 85 + (L−1)² × 10` für die aktuelle Stufe L.
Der Nutzerwunsch „ab Level 100 jedes Level 4× schwerer“ wird für den Entwurf
als vierfacher XP-Bedarf gegenüber dem jeweils vorigen Aufstieg ausgelegt:

| Aufstieg | XP-Bedarf im Entwurf |
|---|---:|
| 99 → 100 | 104.490 |
| 100 → 101 | 417.960 |
| 101 → 102 | 1.671.840 |
| 102 → 103 | 6.687.360 |

Diese Auslegung wird bei der Umsetzung ausdrücklich in den Änderungsnotizen
benannt. Skillpunkte, Essenz, Lernränge, HP-/Schadensgrenzen, Arena,
Händlerwerte und serverseitige Validierung verwenden dieselbe Regel.
Vorhandene Level, XP und ausgegebene Punkte gehen beim Laden nicht verloren.

Der vierfache Bedarf wächst schnell über 64-Bit-Ganzzahlen hinaus. Dafür wird
vor dem unbegrenzten Fortschritt eine genaue Darstellung großer XP-Werte
festgelegt, mit rückwärtskompatiblem Laden bisheriger Ganzzahlen. Ein
Überlauf darf weder kostenlose Aufstiege noch einen versteckten Deckel erzeugen.
Die Regeln gehören in ein Fortschrittsmodul; `main.gd` ruft es nur auf.

### Händler, Alma und neue Gebiete

Die Händlererzeugung verwendet bereits das Spielerlevel. Geprüft und
vereinheitlicht werden jetzt Aktualisierung bei Levelaufstieg,
Charakterwechsel und Relog, Bestand, Preis, Vergleichsanzeige und
serverseitiger Kauf. Ein bestehendes Angebot behält seine Identität und
seinen Preis; ein Levelwechsel darf es nicht nachträglich verteuern.
Neue Angebote werden mit dem Käuferlevel erzeugt. Besondere Bossbeute
behält ihre gesonderten Regeln; die Golem-Rüstung bleibt außerhalb des Shops.

Alma erhält eine einzige Hauptseite „Kochen“. Rezeptwahl, Lernkosten,
Zutaten und Kochen liegen dort zusammen. Das unterwegs lesbare Rezeptbuch
bleibt mit demselben Lernstand verbunden und wird nicht doppelt geführt.

Beim ersten Betreten eines Gebiets erscheint eine schließbare Übersicht mit
Bild und Namen der dort freigeschalteten Gegenstände. Sie wird pro Charakter
gespeichert, erscheint nach Relog nicht erneut und pausiert keinen
Mehrspielerkampf. Die Daten kommen aus den tatsächlichen Gegenstands- und
Gebietsregeln. Alte Spielstände werden anhand ihrer bereits entdeckten
Gebiete übernommen; keine nachträgliche Flut aller Hinweise.

## Paket 3 – Krieger zuerst als Prototyp

Der vorhandene goldene Ritter ist die verbindliche optische Referenz.
Ein eigener Prototyp zeigt einen räumlichen Krieger mit Skelett,
Pixelmaterialien, Waffe und gemeinsam sortierter Darstellung in der
bisherigen Spielperspektive. Er enthält Stehen, Gehen, Sprinten, Schlag,
Fähigkeit, Sprung, Ausweichen, Treffer und Niederlage mit Ragdoll.

Körper und Kopf werden getrennt geführt: Körper nach Laufrichtung, Kopf
nach Maus beziehungsweise rechtem Stick, maximal über die Schulter.
Angriffe gehen in die erlaubte Kopfrichtung, wie bereits entschieden.
Die Richtung der Waffe, Trefferform und sichtbare Aktion müssen zusammenpassen.

Verglichen werden eine einzelne Figur und 20 gleichzeitige Figuren im
Browser, bei 70 % und 100 % Zoom, vor/hinter Landschaftskörpern und mit
angelegter Ausrüstung. Der bestehende 2D-Krieger bleibt die verfügbare
Darstellung, bis Aussehen und Betrieb des Prototyps bestätigt sind.

## Paket 4 – Monster in überschaubaren Gruppen

Die Waldgegner und der erneuerte Himmelsfalter werden als Qualitätsmaßstab
verwendet. Erste Folgegruppe sind die noch alten Gegner der Alten Ruinen,
danach Kristallmoor/Tiefenquell und anschließend Ascheberge/Dämmergrat sowie
Sternenbruch/Himmelsgarten. Übrige frühe Gebiete erhalten ihren fehlenden
Grafikdurchgang nach tatsächlichem Gebietslevel, nicht nach Kartennummer.

Jede Gruppe erhält erkennbare Silhouetten, acht Blickrichtungen und
artspezifische Aktionen. Verfolgung um Hindernisse, Angriffsreichweite,
Vorwarnung, Erholungsphase, Treffer und Tod werden gemeinsam geprüft.
Stationäre Pilze, springende Tiere und fliegende Gegner behalten ihre
Unterschiede. Der erste Grafikdurchgang verändert die Kampfwerte nicht;
notwendige Balanceänderungen werden anschließend gesondert beschrieben.

## Paket 5 – Figuren und Ausrüstung auf der bestätigten Grundlage

Nach dem Krieger-Prototyp folgt zuerst ein vollständiger spielbarer Krieger.
Erst danach wird das System auf 3 Klassen × 3 Völker × 2 Erscheinungen
übertragen. Geeignete Körper teilen Animationen; Tiere benötigen eigene
Skelette. Ragdoll ist Darstellung auf dem Client, kein dauernder Versand
aller Knochen über das Netzwerk.

Die größeren Themen werden getrennt umgesetzt: Kopf-/Rumpf-/Arm-/Beinzonen,
sichtbare Rüstungsteile, Schutz der jeweiligen Zone, anschließend Farben,
Umhangbewegung und Fenna-Vorschau. Eine heutige Gesamtrüstung wird erst
migriert, wenn die neue Teilezuordnung feststeht und an alten Spielständen
geprüft ist. Identität, Seltenheit, Werte und angelegte Teile müssen erhalten
bleiben; wiederholtes Laden darf nichts vervielfachen.

Der Golem besitzt bereits eigene Trefferzonen. Diese werden beim Ausbau
berücksichtigt; das neue allgemeine Figurensystem setzt seine vorhandene
Mechanik nicht versehentlich zurück.

## Paket 6 – Fusionen verständlich machen

Zuerst entsteht eine isolierte 2D-Vorschau mit Figur und Übungspuppe.
Sie nutzt dieselben Fähigkeitsdaten und Wirkabläufe wie das Spiel und zeigt
Reichweite, Trefferfolge, Schaden und Abklingzeit. „Nochmal“ startet erneut.
Es werden keine Live-Gegner, Zutaten, Gold oder Spielstände verändert.

Danach folgt der bereits bestätigte Fusionsstein: neuer animierter Kristall,
klarere Auswahl nach Element, Suche, ausführbare Rezepte und sichtbare
Verschmelzung. Die bestehenden Rückgabe-, Rang- und Fusionsregeln bleiben
maßgeblich. Ein Durchgang umfasst Erlernen → Fusion → Relog → Wiederanwenden
und gegebenenfalls Rückgabe bei Borin.

Instrumente folgen später als eigene Inhalte: Laute, Flöte, Trommel und
Harfe zunächst zum Spielen ohne Kampfboni. Die bereits bestätigten
Musikregeln und Klangproben werden dabei angewendet. Das neue Spawn-Brummen
wird ebenfalls erst nach Beurteilung der vorgesehenen Klangprobe eingebaut.

## Paket 7 – Android zum dann aktuellen Spielstand

Der Zeitpunkt bleibt nach den weiteren Updates. Welche der größeren
Grafikpakete bis dahin übernommen werden, wird am dann erreichten Stand
entschieden; dieses Konzept legt keinen automatischen App-Termin fest.

Die App wird separat gebaut und veröffentlicht. Auf einem echten Handy
werden Login, Bildschirmtastatur, Bewegung, Ziehen/Abbrechen von Fähigkeiten,
Zielhilfe, Knopfanordnung, Rezeptbuch, Einkaufen und Golem-Kampf geprüft.
Versionscode und Signatur müssen ein Update der vorhandenen Installation
erlauben. Online-Protokoll, Website und Server müssen zusammenpassen.

## Nächster konkreter Auftrag

Mit Paket 1 beginnen, danach Paket 2 als gemeinsames Fortschritts- und
Komfortpaket ausarbeiten. Anschließend den Krieger-Prototyp als eigene
Vorschau liefern. Die großen Figurenthemen bekommen damit zuerst eine
sichtbare Grundlage, bevor alle Klassen und Rüstungsteile umgebaut werden.

Für jeden Spiel-Release gelten weiterhin Bilder bei sichtbaren Änderungen,
passende Verhaltenstests, grüne CI und Angelos Freigabe für den jeweiligen
Live-Gang. Die heutige Freigabe gilt für den bereits abgeschlossenen Release,
nicht für spätere Pakete. Die pausierte flächige Modularisierung, ein neuer
Testserver und automatische Hintergrund-Fehlerberichte werden nicht als
zusätzliche Projekte gestartet.

Quellen: [bisherige Ziele](../../NAECHSTE_ZIELE.md),
[Entscheidungen vom 9. Oktober](../2026-10-09-abend/KONZEPT.md),
[Golem v2](../2026-10-10-golem-v2/KONZEPT.md),
[Waldschleim und Himmelsfalter](../2026-10-10-waldschleim-falter/KONZEPT.md).
