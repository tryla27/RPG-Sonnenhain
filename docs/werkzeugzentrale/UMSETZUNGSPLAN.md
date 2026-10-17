# Werkzeugzentrale: detaillierter Umsetzungsplan

Stand: 17.10.2026. Von Angelo beauftragte Projektaufnahme und Planung.
Ergänzt das [Optimierungskonzept](OPTIMIERUNGSKONZEPT.md).
**Status: verbindliche Arbeitsrichtung. Paket 0 und 1 umgesetzt (Linux geprüft,
Windows-Nachprüfung offen), Pakete 2–7 offen. Details: [Prüfstand](PRUEFSTAND.md).**

## Ziel und Ausgangspunkt

Die Zentrale soll einen klaren Sonnenhain-Auftrag mit fünf Fachprogrammen
reproduzierbar ausführen, sein Ende zuverlässig erkennen und Grenzen durchsetzen.
Der Benutzer sieht vorher Umfang und Kostenklasse sowie anschließend geprüfte
Ausgaben. Der Agent bekommt eine kurze maschinenlesbare Zusammenfassung.

Vorhanden: Python-CLI, Tkinter-Fenster, 15 feste Aktionen, ein Grafikworkflow,
Auftragslogs, einfache Sperre und Einzelkommando-Timeouts. Sechs Runner-Tests
und vier Versionsabfragen bestanden. ComfyUI-Dateien vorhanden; erfolgreiche
API-Verbindung und kompletter Grafikdurchlauf noch nicht nachgewiesen.

Der Prototyp liegt im übergeordneten Projektordner unter `werkzeugzentrale/`.
Er ist damit noch kein regulär versionierter Teil des Spiel-Repositories.
Dieses Planpaket wird zusätzlich unter `docs/werkzeugzentrale/` in den verwendeten
Checkouts abgelegt. Keine Spiel-, Konto- oder Serveränderung durch diese Planung.

## Paket 0 – verlässlicher Projektbezug und Versionierung

**Ergebnis:** Die Zentrale gehört nachvollziehbar zum Spielprojekt.

- Aktuellen Git-Hauptstand und lokale Änderungen vor der Umsetzung abgleichen.
- Prototyp in einem eigenen Branch nach `tools/werkzeugzentrale/` des
  Spiel-Repositories übernehmen. Dokumentation liegt unter `docs/werkzeugzentrale/`.
- Bisherigen Einstieg als Weiterleitung erhalten; keine zweite abweichende
  Codekopie dauerhaft pflegen. Lokale Pfade und Auftragsdaten nicht einchecken.
- Beispielkonfiguration mit relativen Projektpfaden und separat wählbarem
  Werkzeugverzeichnis. Keine automatische Wahl anhand des jüngsten Ordnerdatums.
- Vor Start Projektpfad, Branch/Commit und relevante uncommittete Quellen nennen.
  Andere Arbeitsstände nicht zurücksetzen, aktualisieren oder überschreiben.
- Laufende alte Oberfläche bei einem Wechsel kontrolliert schließen; neue
  Versionskennung sichtbar anzeigen, damit alte Prozesse nicht verwechselt werden.

**Abnahme:** Start aus einem Pfad mit Leerzeichen; richtige Projektidentität;
neuer Checkout ohne Maschinenkonfiguration meldet verständlich fehlende Pfade;
keine Spielstände oder bestehenden Grafikdateien verändert.

## Paket 1 – Ausführung begrenzen und abbrechen

**Ergebnis:** Ein Hänger kann den Rechner nicht unbegrenzt weiterbeschäftigen.

- Aktionsbeschreibung als geprüftes Schema: Eingaben, Ausgaben, Klasse,
  Werkzeug, Argumente, Deadline, maximale Schritte und Wiederholungen.
- Startwerte aus dem Optimierungskonzept verwenden: 12 Schritte, 15 Minuten
  für normale Produktionsaufträge, keine automatischen Wiederholungen.
  Speziell deklarierte Generierungsaufträge haben eigene sichtbare Grenzen.
- Gemeinsame monotone Deadline; jeder Unterbefehl bekommt nur die verbleibende
  Zeit. Eine Folge von sechs Kommandos erhält nicht sechsmal das Gesamtbudget.
- Produktionsprozesse mit Windows Job Objects verwalten, einschließlich
  sauberer Handle-Lebensdauer und Beendigung des eigenen Prozessbaums.
- `cancel <job_id>` und Stoppschaltfläche auf denselben Abbruchpfad führen.
- Beim Runnerabsturz bleiben endliche eigene Produktionsprozesse nicht bestehen.
  Dienste wie Spiel und ComfyUI ausdrücklich getrennt behandeln.
- Kostenklassen schon hier verpflichtend machen. Externe und unbekannte
  Produktionsklassen ohne passende Freigabe vor Start ablehnen.

**Abnahme:** Künstlicher Hänger, verschachtelter Kindprozess, Benutzerstopp,
Runnerabsturz und Zeitüberschreitung im zweiten Teilkommando. Keine eigenen
verwaisten Worker; fremde Godot-/Python-Prozesse bleiben unangetastet.

## Paket 2 – persistente Aufträge und Schutz vor Doppelstarts

**Ergebnis:** Doppelklick, zwei Fenster oder ein Neustart erzeugen keine
unbemerkte zweite Produktion.

- SQLite-Auftragsspeicher mit kurzen atomaren Transaktionen. Externe Prozesse
  nicht innerhalb einer langen Datenbanktransaktion ausführen.
- Auftrag, Schritte, Ereignisse, Ausgaben und Dienste getrennt erfassen.
- Fingerabdruck über relevante Eingaben, Skript- und Werkzeugversionen,
  Parameter, Seed und Projektidentität. Welche Dateien relevant sind, deklarieren.
- Gleicher laufender Fingerabdruck liefert bestehende ID zurück. Unterschiedliche
  Aufträge zunächst seriell; kein automatischer Aufbau einer unbegrenzten Queue.
- Dateischreibbereiche als Ressourcensperren berücksichtigen: Auch unterschiedliche
  Rezepte dürfen nicht zugleich dieselben Ziele bearbeiten.
- Prozessbesitz über PID und Startzeit prüfen. Alte Sperre nur zurücknehmen,
  wenn der zugehörige Prozess nachweislich nicht mehr existiert.
- Unklare Jobs nach Neustart als `unknown` anzeigen. Keine automatische
  Generierungswiederholung; vorhandene Prompt-ID beziehungsweise Queue prüfen.
- Nach zwei gleichen Fehlschlägen Aktion für diesen Fingerabdruck sperren;
  erneuter Versuch mit Ursache und eigenem Ereignis im Protokoll.

**Abnahme:** Zwei gleichzeitige CLI-Starts, Doppelklick, PID-Wiederverwendung,
Abbruch beim Schreiben des Status, beschädigter alter Datensatz und belegtes
Ausgabeverzeichnis. Keine doppelten Worker oder verlorenen terminalen Zustände.

## Paket 3 – Ausgaben schützen, prüfen und wiederverwenden

**Ergebnis:** Erfolgreiche Arbeit liefert nachweisbare Dateien; unnötiger Neubau entfällt.

- Bestehende Produktionsskripte um explizite Eingabe-/Ausgabepfade ergänzen.
  Der erste Pilot schreibt in einen Auftragsordner, nicht direkt über Spielgrafiken.
- Vorher nur externe Voraussetzungen prüfen; intern erzeugte Dateien als
  Schritt-Abhängigkeiten auflösen. Pfade nach Auflösung gegen erlaubte Ziele prüfen.
- PNG öffnen und Größe/Transparenz prüfen; GLB in isolierter Godot-Prüfszene
  importieren; KRA durch tatsächlichen Rückexport prüfen; SVG mit Inkscape rendern.
- Bereits vorhandene Dateien zählen ohne passende Herkunft und Fingerabdruck
  nicht als frische Ausgabe des Auftrags.
- Validierte Ausgaben mit Manifest übernehmen. Ersetzte Dateien sichern,
  Übernahmefehler zurückrollen. Eine dateiübergreifende Übernahme ist nicht
  automatisch atomar; Wiederherstellung muss ausdrücklich implementiert werden.
- Cache nur bei unveränderten relevanten Eingaben und intakten Ausgaben verwenden.
  Treffer, eingesparte Schritte und optionaler erzwungener Neubau sichtbar machen.
- Sichtqualität bleibt eine separate Bildprüfung; sie folgt nicht aus einem Hash.

**Abnahme:** Exitcode 0 ohne Datei, kaputtes PNG, falsche Abmessungen, altes GLB,
geänderte Textur, voller Datenträger und Unterbrechung mitten in der Übernahme.
Keine beschädigten bisherigen Ausgaben; zweiter identischer Lauf nutzt den Cache.

## Paket 4 – ComfyUI kontrolliert betreiben

**Ergebnis:** Ein begrenzter lokaler Bildauftrag läuft ohne doppelte Einreichung.

- Aktuellen API-Zustand untersuchen: Port frei/belegt, eigener/fremder Prozess,
  Backend erreichbar/noch startend/fehlerhaft. API-Timeout ist kein Startsignal
  für eine zweite Instanz.
- Explizit gestartete Dienste registrieren, Startzeit begrenzen und im Fenster
  sichtbar halten. Vorhandene fremde Instanzen nur als solche erkennen.
- Erstversion auf geprüfte lokale Nodes und ein vorhandenes Modell begrenzen.
  Keine automatischen Downloads, Plugins oder Anbieterwechsel.
- Vor Einreichung Prompt- und Einstellungsmanifest speichern. Zurückgelieferte
  Prompt-ID sofort sichern; ein unklarer Versand wird nicht erneut abgesendet.
- Auftragsbezogene Queue-Beobachtung mit Gesamtlaufzeit statt Chat-Polling.
- Abbruchfähigkeit der installierten API konkret prüfen. Wenn nur globale
  Unterbrechung möglich ist, für verwaltete Generierungen eine eigene isolierte
  Instanz verwenden; fremde Aufträge nicht abbrechen.
- Rahmen zunächst höchstens vier Bilder und 24 Schritte je Bild. Für den
  ersten Pilot reicht genau ein kleines Bild; keine automatische Variantenserie.

**Abnahme:** Langsamer Start, belegter Port, Verbindungsabbruch beim Senden,
Neustart nach Prompt-Annahme und Abbruch bei fremder Queue. Genau eine
Einreichung oder sichtbarer Zustand `unknown`, niemals blinder Neuversuch.

## Paket 5 – transparente Kosten und Isolation

**Ergebnis:** Alle Aufträge zeigen ihre Kostenklasse; externe Generierung bleibt
ohne konkrete Freigabe gesperrt.

- Kostenstatus und Grenzen bereits im Plan sowie dauerhaft im Fenster anzeigen.
- Lokale GPU-/CPU-Laufzeit getrennt von extern abgerechneten Modellaufrufen führen.
  Strom- und Hardwarekosten nicht ohne Messgrundlage als Eurobetrag berechnen.
- Für mögliche spätere API-Aufträge: Budgetreservierungen und Freigaben an
  Modell, Mengen, Eingaben und Preisgrundlage binden. Verbrauch und offene
  Reservierungen gemeinsam berücksichtigen.
- Fake-Anbieter und künstliche Verbrauchsdaten verwenden; keine bezahlten
  API-Anfragen zur Prüfung dieser Schutzlogik erforderlich.
- Isolationsmöglichkeit unter Windows anhand eines kleinen Workers untersuchen.
  Internetzugang, Dateizugriff und lokale ComfyUI-Verbindung gezielt testen.
  Administrative Systemänderungen nicht als stillen Nebenschritt vornehmen.
- Bis geprüfte Isolation verfügbar ist, Begrenzung auf bekannte lokale Rezepte
  und sichtbarer Hinweis auf fehlende Netzwerksperre. Keine Garantie gegen
  beliebige Netzwerkanfragen eines außerhalb der Zentrale gestarteten Programms.
- Keine API-Integration nur um ihrer selbst willen einbauen. Ein echter
  externer Gateway folgt erst bei einem konkreten Produktionsbedarf.

**Abnahme:** Budget 0 sendet keinen Aufruf; zwei Reservierungen überziehen kein
Budget; unbekannte Preise blockieren; Timeout reserviert weiter; Modellwechsel
verwendet keine alte Freigabe. Netzwerkversuch im isolierten Worker scheitert,
während ausdrücklich erlaubte lokale Verbindung funktioniert.

## Paket 6 – verständliche Oberfläche und sparsame Agent-Schnittstelle

**Ergebnis:** Du erkennst Zustand und Grenzen ohne Roh-JSON lesen zu müssen.

- Übersichtskarten für fünf Programme mit getrennten Angaben für installiert,
  erreichbar, aktiv und zuletzt geprüft.
- Auftragsansicht mit Zweck, Eingaben, Dateifolgen, Deadline, Kostenklasse und
  Versuchen; währenddessen Schritt, Zeit und Stop.
- Ergebnisansicht mit Vorschau, Validierungsbefund, Cachetreffern und kurzen Fehlern.
- CLI-Befehle für `status`, `plan`, `run`, `cancel`, `jobs`, `job` und `logs`;
  Standardantworten höchstens etwa 4 KiB, Details gezielt paginiert.
- Protokolle begrenzen und rotieren; unter anderem große Ausgaben, API-Schlüssel
  und Zugangstokens nicht ungefiltert in den Chat zurückliefern.
- Statusfenster lokal aktualisieren, beispielsweise ereignisgesteuert. Dafür
  keine Agentenrunden oder automatischen Modellaufrufe verwenden.
- Fehlerzustände bis zur Kenntnisnahme erkennbar halten; kein grünes Gesamtbild
  nach einer fehlgeschlagenen Stufe.

**Abnahme:** Bedienung mit Tastatur, lange Pfade, große Logs, lange laufender
Auftrag und Neustart des Fensters. Statusabfragen erzeugen keinen Produktionsjob.

## Paket 7 – Sonnenhain-Pilot und reguläre Übernahme

**Ergebnis:** Ein sichtbares kleines Asset beweist den Ablauf vom Quellmaterial
bis zur Spielvorschau.

Pilotmotiv: ein kleines Basalt-/Violett-Material für einen Golem-Altarstein.
Kein Umbau des bestehenden Bosskampfs und keine neue Musik.

1. Vorhandene Referenzen, Dateiziele und Grenzen im Plan zeigen.
2. Reproduzierbare lokale Materialquelle erstellen; optionale ComfyUI-Variante
   erst nach bestandener lokaler Verbindung und begrenzter Einreichung.
3. Krita-Projekt und PNG exportieren; ein kleines Blender-Testobjekt texturieren.
4. GLB in einer isolierten Godot-Prüfszene importieren und Vorschaubild erzeugen.
5. Quellen, Einstellungen und Dateien validieren; zweiten Lauf auf Cache prüfen.
6. Einen absichtlich fehlerhaften Lauf kontrolliert abbrechen und vorherige
   Ausgabe wiederherstellen; Ergebnisse im Prüfbericht festhalten.
7. Werkzeugänderungen per PR und passenden Prüfungen übernehmen. Live-Schaltung
   des Spiels ist hierfür weder erforderlich noch automatisch beauftragt.

**Abnahme:** Nachvollziehbare Dateikette, sichtbares Ergebnis, eingehaltene
Grenzen, keine externen Modellkosten, erfolgreicher Wiederholungslauf und
kontrollierter Fehlerfall. Erst danach breitere Grafikpakete darüber ausführen.

## Modulaufteilung und bewusst begrenzter Umfang

Nach der Übernahme geeignete kleine Module statt eines wachsenden `hub.py`:
`cli`, `recipes`, `runner`, `processes_windows`, `store`, `validation`,
`cost_policy`, `comfy_client` und `gui`. Nur mit tatsächlichem Bedarf aufteilen;
keine Plugin-Plattform als Voraussetzung des ersten Piloten bauen.

Zunächst ein lokaler Rechner und serielle Produktion. Nicht Bestandteil dieser
Pakete: Cloud-Hosting, unbeaufsichtigte Kreativagenten, automatischer Spieldeploy,
REA-Installation oder ein neuer kostenpflichtiger Modellanschluss.
MCP bleibt eine spätere dünne Hülle über den geprüften CLI-/Runner-Funktionen.

## Fortschritt und nächste konkrete Arbeit

| Paket | Stand |
|---|---|
| Projektregeln und Konzeptdokumente verankern | Mit diesem Dokument erledigt |
| 0: Codeversionierung und Projektbezug | offen |
| 1: begrenzter Runner und Stop | offen; erste technische Priorität |
| 2–7 | offen; abhängig von den jeweiligen Vorpaketen |

Nächster Umsetzungsauftrag: Paket 0 und danach Paket 1 als zusammenhängende
Grundlage. Vor Beginn aktuellen Branch, laufende Prozesse und lokale Änderungen
prüfen. Nach jedem Paket Prüfbericht, echte Grenzen und Restpunkte aktualisieren.
Keine Behauptung, dass die beschriebenen Schutzfunktionen bereits existieren.
