# Werkzeugzentrale v2: begrenzte Aufträge und sichtbarer Verbrauch

Stand: 17.10.2026. Auftrag von Angelo: Fehlerquellen wie Schleifen reduzieren
und verhindern, dass unbemerkt KI-Verbrauch entsteht.
**Status: Konzept nach Codeprüfung, noch keine implementierten v2-Schutzfunktionen.**

## 1. Was wir zuverlässig zusagen können

Die Zentrale soll feste, nachvollziehbare Aufträge ausführen. Ein normaler
Export braucht weder einen selbstständig planenden Agenten noch einen
Modellaufruf. Während Blender arbeitet, wartet ein lokaler Prozess; ein
Sprachmodell muss nicht jede Sekunde über den Zustand nachdenken.

Fehler lassen sich nicht vollständig ausschließen. Wir begrenzen stattdessen
ihre Laufzeit, Folgen und Wiederholungen und machen den Abbruch sichtbar.

Zwei Verbrauchsbereiche getrennt anzeigen:

| Bereich | Kontrolle |
|---|---|
| Von der Zentrale gestartete lokale Exporte | Laufzeit, Prozesszahl, Dateiausgaben, Protokollgröße; keine beabsichtigten externen Modellaufrufe |
| Lokale ComfyUI-Workflows | Anzahl Bilder, Schritte, Auflösung, Warteschlange, GPU-Laufzeit und erlaubte Nodes |
| Künftige externe KI-API-Aufträge | Standardmäßig gesperrt; vorab sichtbare Anzahl, Preisgrundlage und verbindlich begrenzter Auftrag |
| Codex-Chat und integrierte Generierungswerkzeuge außerhalb der Zentrale | Nicht durch den lokalen Runner messbar oder hart begrenzbar; unbekannte Werte ausdrücklich als unbekannt anzeigen |

Der aktuelle Hub enthält keinen eigenen Cloud-KI-Client. Das ist keine
Netzwerksperre: gestartete Skripte, Programme und ComfyUI-Erweiterungen können
selbst weitere Verbindungen aufbauen. Die v2 muss diese Ausführung mitprüfen.

## 2. Tatsächlich gefundene Lücken

| Befund im jetzigen Code | Folge | Verbesserung |
|---|---|---|
| Timeout je Einzelkommando | Sechs Krita-Kommandos können das Zeitlimit sechsmal ausschöpfen | Gemeinsame monotone Deadline für Auftrag und Schritt |
| Hintergrundstart wird nur eine Sekunde beobachtet | Doppelte oder später abgestürzte Dienste bleiben unklar | Prozessregister und separate Betriebsbereitschaft |
| API-Timeout bedeutet beim Startversuch möglicherweise einen zweiten ComfyUI-Prozess | Langsame und nicht laufende Dienste werden verwechselt | Prozessidentität, Portbelegung und API-Zustand gemeinsam prüfen |
| Timeout beendet nicht verlässlich alle Kindprozesse | Verwaiste Render-/Generatorprozesse können weiterarbeiten | Verwalteter Prozessbaum, unter Windows Job Object |
| Sperre kann nach Absturz liegen bleiben | Zentrale blockiert weitere Aufträge | PID plus Prozessstartzeit, Besitzer-ID und kontrollierte Wiederherstellung |
| Exitcode 0 wird als Erfolg gewertet | Fehlende, alte oder ungültige Dateien können unbemerkt bleiben | Ausgaben deklarieren und Inhalt beziehungsweise Import prüfen |
| Skripte werden aus dem aktiven Checkout geladen | Änderungen können das Verhalten eines bekannten Aktionsnamens verändern | Projekt-, Rezept- und Skriptfingerabdruck vor Ausführung festhalten |
| Ungekappte Logs, umfangreiche JSON-Pläne | Große Dateien und unnötig große Chat-Eingaben | Begrenzte Protokolle und kurze Standardantworten |
| Kein Verbrauchsledger für KI-Aufträge | Keine belastbare Einzelkostenübersicht | Kostenklasse, Reservierung und Ergebnis je Auftrag |

Die jetzige GUI prüft ihre lokale Ergebnisqueue alle 150 ms. Das löst keinen
Modellaufruf aus. Diese Ereignisschleife ist kein tokenverbrauchender Agentenloop.

## 3. Regeln gegen Schleifen und doppelte Arbeit

- Rezepte sind endliche Listen. Keine Aktion darf den Hub erneut starten,
  sich selbst aufrufen oder während der Ausführung weitere Schritte erfinden.
- Geplanter Standard: höchstens 12 Schritte und 15 Minuten pro endlichem
  Produktionsauftrag. Zusätzlich passende Grenzen pro Schritt. Abweichungen
  stehen vor dem Start sichtbar im konkreten Auftrag; keine automatische Verlängerung.
- Für lokale Bildgenerierung eigener Rahmen: zunächst maximal vier Bilder,
  maximal 24 Sampling-Schritte je Bild und 20 Minuten insgesamt. Das sind
  vorgeschlagene Startwerte, keine bereits gemessenen Leistungsversprechen.
- Automatische Wiederholungen zunächst **0**. Eine fehlgeschlagene Generierung
  wird nicht erneut eingereicht. Ein neuer Versuch ist ein neuer sichtbarer Auftrag.
- Wiederkehrende gleichartige Fehler sperren die betreffende Aktion nach zwei
  gescheiterten Versuchen mit gleichem Eingabefingerabdruck. Entsperren erst nach
  geänderter Eingabe oder ausdrücklich gewähltem erneutem Versuch.
- Ein Auftragsfingerabdruck enthält Projektpfad, relevante Quellen,
  Werkzeugversionen, Skripte, Einstellungen und Seed. Ein zweites Einreichen
  desselben laufenden Auftrags gibt dessen ID zurück, statt neu zu starten.
- Nach Absturz gilt bei einer Generierung: zuerst Queue und bekannte Prompt-ID
  abgleichen. Unklarer Zustand wird `unknown`, nicht automatisch erneut erzeugt.
- Abfragen nutzen einen lokalen begrenzten Warteplan, etwa 2/4/8 Sekunden bis
  zur gemeinsamen Deadline. Chat oder Sprachmodell werden dafür nicht aufgerufen.
- Keine Hintergrundautomationen, Agentenketten oder neuen Unteragenten als Teil
  eines Exportrezepts. Solche Erweiterungen wären eigene sichtbare Funktionen.

## 4. Kontrolle von Prozessen und Ergebnissen

Auftragszustände: `planned → validated → running → passed` oder
`failed / timed_out / cancelled / unknown`. Bei einem unsicheren Ergebnis
keine Erfolgsmeldung und keine Fortsetzung der Kette.

Vor dem Start alle externen Voraussetzungen und das gesamte Rezept prüfen.
Dateien, die erst ein früherer Schritt erzeugt, sind deklarierte Abhängigkeiten
und werden erst danach geprüft. So blockiert die Vorprüfung keinen sauberen Erstbau.

Endliche Produktionsprozesse gehören in einen verwalteten Prozessbaum.
Stoppschaltfläche und Deadline beenden ausschließlich die Prozesse dieses
Auftrags. Unter Windows verhindert ein Job Object mit geeigneter
Beendigungsregel, dass Kindprozesse beim Runnerabbruch weiterlaufen.
Keine pauschalen Befehle wie „alle python.exe beenden“.

Spiel und ComfyUI-Server sind langlebige Dienste und bekommen ein eigenes
Register. Ihr Startauftrag endet nach begrenzter Bereitschaftsprüfung; der
Dienst bleibt mit Zustand und Stoppschaltfläche sichtbar. Beim Stoppen einer
ComfyUI-Generierung nur die zugehörige Arbeit entfernen beziehungsweise
unterbrechen. Unterstützt die installierte API keine präzise Trennung, wird
eine isolierte Instanz benötigt; fremde Queue-Aufträge dürfen nicht betroffen sein.

Ausgaben möglichst zunächst im Auftragsordner erzeugen. Erst nach Validierung
in die Zielpfade übernehmen, mit Sicherung ersetzter Dateien und einem Manifest.
Dazu müssen die bestehenden Skripte Ausgabeverzeichnisse als Parameter erhalten.
Ein Exitcode reicht nicht: PNG lesbar und erwartete Größe, GLB importierbar,
KRA vorhanden und exportierbar, Godot-Prüfung erfolgreich. Sichtqualität bleibt
zusätzlich eine eigene Beurteilung.

## 5. Keine unbemerkten externen KI-Aufträge

**Voreinstellung: externe KI-Aufrufe deaktiviert, freigegebenes Zusatzbudget 0.**
Damit ist keine Änderung an Angelos Konto oder Abonnement gemeint, sondern eine
Startregel der künftigen lokalen Zentrale. Unbekannte Kosten werden nicht als 0 angezeigt.

Jede Aktion erhält eine Kostenklasse: `local_compute`, `external_metered` oder
`unknown`. Statusabfragen sind gesondert als nicht generierend gekennzeichnet.
Unbekannte Kostenklassen dürfen keine Produktionsaufträge starten.

Für einen später freigegebenen externen Auftrag zeigt die Zentrale VORHER:

- Anbieter, Modell, Aufgabe und Ziel des Datenversands;
- maximale Anzahl Aufrufe/Bilder sowie Eingabe- und Ausgabegrenzen;
- Preisquelle mit Datum, geschätzte Kosten und separat die belastbare Obergrenze;
- bereits verbrauchtes und für laufende Aufträge reserviertes Budget;
- Umfang der Freigabe: genau dieses Rezept, diese Eingaben und dieses Limit.

Kein stiller Wechsel auf ein anderes Modell, einen Cloudanbieter, eine höhere
Auflösung oder weitere Varianten. Freigaben verfallen bei entsprechenden Änderungen.
Ein normaler lokaler Export soll dafür keine zusätzliche Bestätigung benötigen.

Vor dem Versand maximal mögliche Kosten atomar in einem lokalen Ledger
reservieren, zum Beispiel per SQLite-Transaktion. Mehrere Aufträge dürfen das
gleiche Restbudget nicht gleichzeitig ausgeben. Ohne berechenbare Obergrenze
kein automatischer Aufruf. Modell-, Tool-, Bild- und andere Zusatzgebühren gehören
in diese Rechnung. Bei ungewisser Preisgrundlage bleibt die Aktion gesperrt.

Nach Antwort tatsächliche Anbieter-Verbrauchsdaten speichern, Reservierung
abgleichen und Schätzung als Schätzung kennzeichnen. Nach Netzabbruch bleibt
die Reservierung bestehen, bis der Verbrauch geklärt ist. Nicht blind erneut senden.
Abbruch kann bereits entstandene Kosten nicht rückgängig machen.

Anbieterlimits sind eine zusätzliche Ebene. OpenAI unterscheidet Kostenwarnungen
und harte API-Ausgabelimits; Warnungen stoppen keine Aufträge. Auch harte Limits
können wegen verzögerter Durchsetzung geringfügig überschritten werden. Sie
ersetzen daher unsere auftragsbezogene Vorabreservierung nicht.
[Offizielle OpenAI-Dokumentation](https://developers.openai.com/api/docs/guides/spend-limits),
geprüft am 17.10.2026. Keine Kontoänderung vorgenommen.

## 6. Lokale Ausführung darf die Kostenregel nicht umgehen

Registry-Metadaten allein verhindern keine Netzwerkaufrufe eines Kindprozesses.
Geprüfte Skripte, Plugins und ComfyUI-Nodes gehören deshalb in ein versioniertes
Manifest. Änderungen invalidieren die bisherige Einstufung.

Für echte Durchsetzung benötigt der Produktionsworker eine isolierte
Ausführungsumgebung mit begrenzten Schreibpfaden, ohne übernommene API-Schlüssel
und ohne ausgehenden Internetzugang. Nur der separat kontrollierte API-Gateway
darf später kostenpflichtige Anfragen senden. Lokale ComfyUI-Kommunikation muss
gezielt erlaubt bleiben. Keine automatischen Plugin-/Modell-Downloads.

Bis diese Isolation auf diesem Windows-Rechner implementiert und geprüft ist,
lautet die Anzeige **„Kostenregeln im Runner; Netzwerkausführung nicht isoliert“**.
Wir behaupten keine technisch garantierte Sperre aller externen Kosten.
Das Entfernen einiger Schlüssel aus Umgebungsvariablen allein genügt nicht:
Programme könnten Zugangsdaten auch aus Dateien oder eigenen Einstellungen laden.

## 7. Tokenarme Zusammenarbeit mit dem Chat

- Standardantwort des Hubs: ID, Zustand, Fortschritt, Dauer, Kostenklasse,
  Verbrauch soweit bekannt und Pfad zum Detailprotokoll; maximal etwa 4 KiB.
- Vollständige Logs bleiben lokal. Bei Fehlern nur begrenzten relevanten Auszug
  liefern; weitere Details auf gezielten Abruf. Rotierende Logs, beispielsweise
  10 MiB je Datei und 50 MiB je Auftrag, statt ungebremstem Wachstum.
- Gültige Ausgaben bei identischen Eingaben wiederverwenden. Cachetreffer sind
  sichtbar und setzen geprüfte Dateiintegrität voraus; erzwungener Neubau bleibt möglich.
- Status lokal abfragen; keine wiederholten kompletten Threadverläufe oder
  Projektdateien für unveränderte Informationen lesen.
- Im Chat vor größeren Arbeiten Zweck, Umfang und erwartete Zeit nennen.
  Bei Stillstand Ursache und nächsten sinnvollen Schritt melden. Keine
  unbemerkte Verlängerung in eine neue Reparatur- oder Generierungsserie.
- Exakte Chat-Token oder Eurobeträge nur aus einer tatsächlich verfügbaren
  Messquelle nennen. Sonst steht dort **„nicht messbar“**, nicht eine erfundene Zahl.

Die lokale Zentrale kann den Codex-Chat selbst nicht hart budgetieren. Dieses
Konzept verhindert daher keine beliebigen Modellaufrufe außerhalb ihres
kontrollierten Ausführungspfads. Für integrierte Bild-/Videotools gelten ebenfalls
eigene Mess- und Abbruchmöglichkeiten. Ein lokaler Stopp ist kein Beweis,
dass ein bereits beim Anbieter gestarteter Auftrag kostenfrei abgebrochen wurde.

## 8. Was du im Fenster sehen sollst

Oben dauerhaft: Projektstand, aktive Aufträge, externe KI gesperrt/freigegeben,
Kostenmessung verfügbar/unbekannt und Isolationsstatus.

Auftragskarte: „Was wird gemacht?“, „Welche Dateien werden ersetzt?“,
„Wie lange höchstens?“, „Wie viele Versuche?“, „Welche Kostenklasse?“.
Währenddessen: Schritt, verstrichene Zeit, Restzeit, laufender Prozess und Stop.
Danach: validierte Ausgaben, tatsächliche Aufrufe, gemeldeter Verbrauch,
Cachetreffer und Abbruchgrund. Ein abgeschlossener Fehler verschwindet nicht
unbemerkt hinter einer grünen Gesamtmeldung.

## 9. Umsetzung und Abnahme in kleinen Paketen

1. **Runner begrenzen:** Gesamtdeadline, Stop, Prozessbaum, Prozessregister,
   robuste Sperrverwaltung und kurze Antworten. Danach Hänger und Runnerabsturz
   simulieren; keine eigenen Kindprozesse dürfen weiterrechnen.
2. **Doppelarbeit verhindern:** Fingerabdrücke, Wiederholungssperre, Cache und
   Ausgabeverifikation. Doppelklick, zwei parallele CLI-Starts, fehlendes PNG,
   veraltetes GLB und verändertes Skript testen.
3. **Verbrauch offenlegen:** Kostenklassen, dauerhafte Anzeige und gesperrter
   externer Pfad. Mit Fake-Anbieter testen, dass Budget 0 keinen Aufruf zulässt,
   zwei Reservierungen kein Budget doppelt ausgeben und Timeout nicht neu sendet.
4. **Isolation und echter Pilot:** Netzwerksperre unter Windows und bekannte
   lokale ComfyUI-Nodes prüfen. Erst dann ein kleines Asset vom Entwurf bis zum
   Godot-Import vollständig ausführen; Ergebnisse und Limits dokumentieren.

Reale kostenpflichtige Modellaufrufe sind für diese Schutztests nicht nötig.
Erfolg bedeutet gemessene Abnahme der jeweiligen Schutzfunktion, nicht nur
vorhandener Konfigurationstext. REA bleibt für diesen Ausbau optional.
