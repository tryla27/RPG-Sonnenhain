# Golem-Leistung, Musik und mobile Rezeptansicht

## Befund und Änderung (10.10.2026)

Beim nicht erreichbaren Ziel konnte eine leere Wegliste die Wiederholpause
der Golem-Wegsuche umgehen. Ein Verhaltenstest mit blockiertem Weg zählte
vorher 60 Suchaufrufe in einer simulierten Sekunde, nachher einen. Ändert
sich das Ziel deutlich, wird trotzdem sofort neu gesucht. Das Erwärmen des
Rasters ist auf acht Zellen und ungefähr 750 µs pro Bild begrenzt; eine
einzelne Zellenberechnung wird noch fertiggestellt.

Charakterbewegungen sendeten das gesamte Profil einschließlich unveränderter
Quests und Fähigkeiten. Jetzt werden die notwendigen Bewegungsfelder und
Änderungen gesendet; jede Sekunde folgt ein vollständiger Stand. Serverseitig
werden die Pakete weiterhin validiert und auch die Weiterleitung reduziert.

Weltpakete übertragen Zeilen als Spaltenwerte statt wiederholter Feldnamen.
Größere Pakete werden verlustfrei mit Zstandard komprimiert. Welt- und
Bewegungspakete werden bei mehr als 64 KiB ausstehender WebSocket-Ausgabe
zurückgestellt. Belohnungen, Schaden, Inventar und andere zuverlässige
Spielaktionen werden dadurch nicht übersprungen.

WebSocket überträgt auch als „unreliable“ markierte RPCs geordnet; es kann
daher bei Überlast alte Zustände aufstauen. Kleinere Pakete und diese
Begrenzung reduzieren die zusätzliche Warteschlange. Sie entfernen keine
Pakete, die bereits an TCP übergeben wurden.

## Messungen im lokalen synthetischen Test

| Fall | Vorher | Nachher |
|---|---:|---:|
| Charakterprofil / unveränderte Bewegung | 1.600 Bytes | 232 Bytes |
| Weltzustand mit 100 Gegnern | 24.936 Bytes | 900 Bytes |
| Suchaufrufe bei blockiertem Weg, erste Sekunde | 60 | 1 |

Der Weltzustand wurde bytegenau in seine ursprünglichen Daten zurückgewandelt;
die erste gemessene Kodierung dauerte etwa 1,5 ms auf dem lokalen Rechner.
Die Bytezahlen betreffen serialisierte Godot-Daten ohne Transport-Overhead.
Der synthetische Test enthält viele ähnliche Gegner und ist kein gemessener
Live-Kampf. Er belegt weder einen bestimmten Live-Ping noch, dass 2400 ms
ausschließlich durch diese Ursachen entstanden sind.

`SERVER_PERF` misst nach Veröffentlichung alle 60 Sekunden CPU-Durchschnitt,
CPU-Spitze, Weltpaket-KiB/s, Kodierungszeit und zurückgestellte Weltpakete.
Die vorhandene `GOLEM_PERF`-Messung bleibt erhalten. Damit lassen sich
Rechenlast und Warteschlangen beim nächsten echten Kampf unterscheiden.

## Musik

Das bestätigte WAV bleibt unverändert. Ein expliziter Ressourcenverweis hält
es im Export. Die zuverlässige Beschwörungsantwort startet die Musik am Altar
bereits vor der ersten Gegnerzeile; der aktive Kampfzustand im Himmelsgarten
übernimmt danach. Die sechssekündige Einblendung und Lautstärkeregler bleiben.
Diese Änderungen machen den Start robuster; der frühere Live-Ausfall konnte
lokal noch nicht hörend reproduziert werden.

## Rezepte unterwegs

Der Reiter „Rezepte“ im Questbuch verwendet direkt Almas gespeicherten
Lernstand, zeigt Zutaten, vorhandene / erforderliche Mengen, fehlende Mengen,
Fundgebiete und Wirkung. Lesen ist kostenlos und verbraucht nichts. Kochen
bleibt bei Alma. Vorschau: `recipe-journal-preview.png`.

## Veröffentlichung

Netzwerkprotokoll 10: Browser und Server müssen zusammen aktualisiert werden.
Nach Veröffentlichung müssen bestehende Browserfenster neu geladen werden.
Angelo hat die Veröffentlichung am 11.10.2026 ausdrücklich freigegeben:
„Ok lade zuerst hoch und gehe live mit den fertigen Bereichen dann gestalte
ein Konzept für die anderen Schritte“. Veröffentlichung über einen geprüften
Pull Request und gemeinsamen Website-/Server-Deploy. Die Android-Auslieferung
bleibt gemäß Projektregel ein eigener Vorgang.
