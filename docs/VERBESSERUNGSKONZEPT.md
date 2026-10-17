# Sonnenhain – ein Dorf, das mit deinem Abenteuer wächst

Eigenes Gestaltungskonzept von Codex für Angelo, 16. Oktober 2026.
Status: Entwurf. Neue Inhalte, Balancewerte und Zeitziele sind Vorschläge,
noch keine umgesetzten oder gemessenen Verbesserungen.

## 1. Die Richtung

**Ein märchenhaftes Action-RPG mit lesbaren Kämpfen, überraschenden kleinen
Abenteuern und einem Heimatdorf, in dem deine Erfolge sichtbar werden.**

Die Spielschleife: Im Dorf ein konkretes Anliegen kennenlernen → draußen
einen Ort entdecken und eine Herausforderung lösen → eine neue Möglichkeit
oder Geschichte erhalten → heimkehren und die Wirkung sehen.

Sonnenhains besondere Stärke sehe ich in der Verbindung von Heimatdorf,
Klassen und Fusionen. Diese drei Dinge sollen zusammen das Spielerlebnis
prägen. Der erste Qualitätsgewinn muss in einer kurzen Spielsession spürbar sein.

## 2. Befund und Annahmen

Grundlagen sind die lokalen Arbeitspläne, Mechanikübersicht sowie unter
anderem `components/game_content.gd` und `components/mob_combat.gd`.
Ein neuer vollständiger Spieldurchgang wurde für dieses Konzept nicht gemacht.
Die Mechanikübersicht enthält historische Abschnitte; aktuelle Regeln vor
Umsetzung am tatsächlich verwendeten Code prüfen.

- Klassen, Fusionen, Ausrüstung, Kochen, Gebiete und Quests bestehen bereits.
- Viele Questdatensätze verwenden Gegnerziel und Abschusszahl. Hier liegt
  ein konkreter Ansatz für abwechslungsreichere Aufgaben.
- Gegner haben bereits Vorbereitung, aktive Angriffszeit, Erholung und
  artspezifische Fähigkeiten. Ihre sichtbare Darstellung soll diese Regeln
  verständlicher machen; ein zweites Kampfsystem ist dafür unnötig.
- Tessa, Rika, Odo und Serin liefern vorhandene Ansatzpunkte für kleine Geschichten.
- Offene Browser-, Golem-, Speicher- und Fortschrittsprüfungen aus dem
  Arbeitsplan bleiben wichtig. Vermutete Spielgefühlprobleme sind zunächst
  Hypothesen für den Vergleichsdurchgang.

## 3. Fünf Verbesserungen mit großer Wirkung

### A. Der Einstieg wird ein abgeschlossenes kleines Abenteuer

Mira gibt einen konkreten Anlass: Am Wiesenweg fehlen Nachrichten von Tessa.
Kurze, überspringbare Dialoge und ein Hauptziel vermitteln Handlung und Ort.
Der bestätigte dunkle Beginn bleibt erhalten; Weglicht und Silhouetten
sichern die Orientierung.

| Abschnitt | Spielerhandlung | Gewünschte Wirkung |
|---|---|---|
| Ankommen | Mira finden, Anlass erfahren, Dorf verlassen | Verstehen, wohin und warum |
| Erste Begegnung | Einen Schleim beobachten und nach seiner Vorbereitung reagieren | Eine Kampfregel praktisch lernen |
| Tessa am Weg | Vorhandene Begegnung zu einer kurzen Schutzsituation ausarbeiten | Einen Menschen und seinen Weg schützen |
| Freie Abzweigung | Einer Blütenspur zu einem optionalen Fund folgen | Neugier belohnen |
| Waldkante | Pilzling und Mooswolf erst einzeln, dann in kleiner Kombination erleben | Gelernte Regeln kombinieren |
| Heimkehr | Belohnung und sichtbare Dorfreaktion erhalten | Einen Erfolg abschließen und das nächste Ziel sehen |

Ziel ist eine ungefähr 20–30 Minuten lange Runde. Das ist eine zu prüfende
Spielzeit, keine Wartezeit oder Vorgabe für künstlich langsames Leveln.
Alle drei Klassen müssen den Hauptweg schaffen. Bestehende Questketten,
Levelgrenzen und Freischaltungen bleiben bei der ersten Erprobung erhalten.
Neue Aufgaben ergänzend mit stabilen IDs anlegen, alte Questindizes erhalten.

### B. Kämpfe geben verständliche Entscheidungen

Ein wichtiger Angriff beantwortet drei Fragen: **Was kommt? Wo trifft es?
Wann kann ich reagieren?** Pose, Bodenform und Effekt verwenden dieselben
Angriffsdaten. Farbe wird durch Form oder Bewegung ergänzt.

| Gegner | Rolle im Einstieg | Entscheidung |
|---|---|---|
| Waldschleim | Einfacher Nahgegner mit deutlicher Vorbereitung | Kurz Abstand gewinnen, in der Erholung angreifen |
| Blütenkäfer | Fernkämpfer mit sichtbarer Schussrichtung | Seitlich ausweichen, anschließend Distanz schließen |
| Pilzling | Ortsgebundene Gefahr durch Giftstaub | Wolke verlassen und aus sicherer Position handeln |
| Mooswolf | Beweglicher Gegner mit vorbereitetem Sprung | Landepunkt lesen, nach dem Sprung reagieren |

Zuerst Animation, Treffergeometrie und Zeitpunkt auf Übereinstimmung prüfen.
Schaden, Lebenspunkte und Immunitäten bleiben in diesem Durchgang unverändert.
Vorhandene Bewegungs-/Ausweichfunktionen vor Anpassungen prüfen. Eine neue
Ausdauerleiste ist für den Piloten unnötig.

Dann kleine Begegnungen gestalten: ein Fernkämpfer hinter einem Nahgegner,
ein Wolf neben einer begrenzten Pilzgefahr. Freie Auswege und genügend Platz
für jede Klasse vorsehen. Sichere Wege, NPC-Abstände, Spawnbegrenzungen und
Navigation bleiben verbindlich.

Treffer vermitteln sich über Pose, kleinen Blitz und passenden Materialklang.
Kamerawackeln ist abschaltbar. Eine globale Trefferpause passt nicht zum Koop;
lokale Animationsakzente ändern keine Schadenszeitpunkte.

### C. Erkundung bekommt Bedeutung

Jedes überarbeitete Gebiet erhält zunächst ein erkennbares Wahrzeichen,
einen freiwilligen Fund und eine kleine Begegnung mit Abschluss.

Im Piloten dient ein markanter alter Wegbaum als Wahrzeichen. Eine kurze
Blütenspur führt zu einer Notiz oder einem Rezeptfund. Tessa und Rika
verbinden die Orte mit bekannten Figuren. Belohnung und Platzierung werden
nach Prüfung der vorhandenen Inventar-, Quest- und Levelregeln festgelegt.

Hauptwege bleiben klar. Dekoration blockiert keine Zugänge. Interaktive
Objekte bekommen eine erkennbare Form und Hinweise in Reichweite. Für den
ersten Ausbau genügen die bestehenden Karten.

### D. Das Dorf zeigt deinen Fortschritt

Die Steinrose am Ankunftsplatz wird zum wiederkehrenden Zeichen der Heimat.

| Persönlicher Meilenstein | Dorfreaktion |
|---|---|
| Erste Hilfe für Tessa abgeschlossen | Blüten und eine kurze Dankeszeile bei der Heimkehr |
| Bestehende Verteidigung von Blütenweiler geschafft | Schmuck am Platz und passende NPC-Zeile |
| Bestehendes Finale abgeschlossen | Vorhandene Feiergestaltung mit der Steinrose verbinden |

Reaktionen zuerst aus vorhandenem gespeichertem Quest-/Storyfortschritt
ableiten. Bestehende Feierdekoration wiederverwenden. Nur bei fehlender
eindeutiger Information ein versioniertes Charaktermerkmal ergänzen.
Dekoration vergibt keine zusätzlichen Belohnungen und ändert keine Kollision.

Im Koop zeigt die Rose auf jedem Client den eigenen Fortschritt. Gemeinsame
Kampfobjekte und Navigation bleiben identisch. Gemeinsam gespeicherter
Dorfausbau wäre ein eigenes späteres System.

### E. Klassen und Fusionen geben einen Grund weiterzuspielen

Vorhandene Fähigkeiten sollen die Klassen deutlicher ausdrücken: Krieger
nutzt Nähe und Schlagfenster, Magier kontrolliert Flächen, Bogenschütze
arbeitet mit Distanz und Schusslinien. Das ist zunächst eine Richtung für
Animation und Begegnungen. Builds erst nach Messung gezielt anpassen.

Die geplante Fusionsvorschau wird zum wichtigen Folgepaket: Figur,
Übungspuppe, Reichweite, Wirkablauf, Ressourcen und Abklingzeit. Sie verwendet
dieselben Wirkregeln wie das Spiel und verbraucht beim Probieren nichts.

Belohnungen bedienen bessere Werte, erkennbare Spielentscheidungen und
sichtbare Identität. Zunächst vorhandene Waffenvarianten, Rezepte und
kosmetische Möglichkeiten nutzen. Keine neue Zufallswertschicht oder
zusätzlichen Ausrüstungsplätze für den Piloten.

## 4. Grafik und Oberfläche

Top-down-Perspektive und bestehende Stilreferenzen bleiben maßgeblich.
Figuren, Boden und Icons teilen Palette und Materialwirkung. Spielfigur,
Angriffsankündigungen und Wege bekommen Vorrang vor Dekorationsdetails.

| Werkzeug | Erstes Ergebnis | Aufgabe |
|---|---|---|
| Blender | Goldener Krieger mit Skelett, Waffe und Grundaktionen | Verlässliche Bewegung und sichtbare Ausrüstung |
| Krita | Materialpalette, Kriegertexturen und lesbare Pilz-/Wolfseffekte | Einheitlicher Look in tatsächlicher Spielgröße |
| Inkscape | Sechs Symbole: Angriff, Fähigkeit, Quest, Wegstein, Kochen, Fusion | Zusammengehörige visuelle Sprache |
| ComfyUI | Wenige Entwürfe für Wegbaum und Steinrose aus eigenen Referenzen | Ideen auswählen und manuell in den Spielstil übertragen |

Der Krieger entsteht isoliert nach dem vorhandenen Prototypplan, mit 1/20
Figuren im Browser. Übernahme nach optischer Beurteilung und Leistungstest.
Die vier Installationsdateien sind heruntergeladen; Installation,
ComfyUI-Umgebung und Modelle sind zum Konzeptzeitpunkt noch offen.

Die Oberfläche verbessert zuerst drei Aufgaben: aktuelles Ziel erkennen,
Gegenstände vergleichen, nächste Freischaltung verstehen. Ein Hauptziel mit
aufklappbaren Details genügt. Hinweise verdecken keine Kampfgefahren und
funktionieren bei 70 %/100 % Zoom mit vorhandener Maus-/Tastenbedienung.

## 5. Erstes Paket: „Heimkehr nach Sonnenhain“

Ein überschaubarer Spielabschnitt umfasst bessere Einstiegsführung,
Tessas Schutzbegegnung, einen freiwilligen Fund, klarere Angriffe der vier
frühen Gegner, die erste Steinrosen-Reaktion und eine kleine Icongruppe.
Alle Klassen spielen denselben Abschnitt zunächst mit bestehenden Kampfwerten.
Der Krieger-Prototyp ist eine getrennte Vorschau; der Spielabschnitt bleibt
mit bisherigen Figuren prüfbar.

| Reihenfolge | Arbeit | Greifbares Ergebnis |
|---|---|---|
| 0 | Hauptstand abgleichen, offene P0-/P1-Prüfungen bearbeiten | Verlässliche Basis; Blockaden behoben, Browser-/Golem-Restpunkte dokumentiert |
| 1 | Einstieg mit drei Klassen aufnehmen | Vergleichsbilder, Zeiten und die drei größten Reibungspunkte |
| 2 | Werkzeugbasis, Stilblatt und Importprobe vorbereiten | Bearbeitbare Quellen, funktionierender Modell-/Textur- und Iconexport |
| 3 | Fortschritts-/Händlerregeln abschließen | Gemeinsame Regeln einschließlich großer XP-Werte, Relog und Koop |
| 4 | Einstiegsführung und Tessa-Begegnung verbessern | Hauptziel, freier Rückweg, eindeutige einmalige Belohnung |
| 5 | Frühe Gegner und freiwilligen Fund bearbeiten | Vier lesbare Rollen, bewusste Begegnung, gespeicherter Fund |
| 6 | Steinrose und Icons ergänzen | Heimkehrreaktion ohne Zustandsvermischung |
| 7 | Krieger-Prototyp fertigstellen | Vollständige Vorschau mit Ausrüstung, Aktionen, Verdeckung und Browsermessung |
| 8 | Gesamtpaket mit Ausgangsbasis vergleichen | Abnahmekriterien erfüllt; Bilder und Änderungsnotizen vorhanden |
| 9 | Nach konkreter Freigabe veröffentlichen | Vorlage für Alte Ruinen und weitere Figuren |

Schritt 2 kann bei offenen Prüfzugängen vorbereitend entstehen. Bestätigte
P0-Fehler unterbrechen Inhaltsarbeit. Kleine Umsetzungspakete statt einer
festen Wochenfrist; Android folgt separat nach weiteren Spielupdates.

## 6. Abnahmeziele für den Piloten

Diese Kriterien sind Ziele, keine bereits erzielten Ergebnisse:

- Eine unvertraute Testperson findet nach Miras Gespräch ohne mündliche Hilfe
  Ausgang und nächstes Ziel. Ziel: höchstens zwei Minuten Orientierung;
  tatsächliche Zeit und nötige Hilfen notieren.
- Nach zwei Begegnungen kann sie den Angriffshinweis und eine passende
  Reaktion erklären. Video und Schadenszeitpunkt stimmen überein.
- Die Runde enthält eine freiwillige Entdeckung und eine sichtbare Reaktion
  bei der Heimkehr. Für 20–30 Minuten Spielzeit entstehen keine Wartephasen.
- Fortschritt, Fund, Belohnung und Rose überstehen Laden, Relog und
  Charakterwechsel. Wiederholtes Laden verdoppelt nichts.
- Solo und Zwei-Spieler-Koop funktionieren; vier Spieler vor breitem Ausbau
  ebenfalls prüfen. Persönlicher Fortschritt verändert keine gemeinsamen Wege.
- Dieselbe dokumentierte Hardware, Auflösung und Browserszene dient zum
  Leistungsvergleich. Durchschnitt und 95. Perzentil der Framezeiten sowie
  Ladeverhalten berichten. Die bestehende 60-FPS-Ausrichtung bleibt Ziel;
  zusätzliche Budgets erst nach Basismessung festlegen.
- In einer kurzen Befragung sind Ziel, eigener Erfolg und Klassenunterschied
  verständlich. Kleine Spieltests liefern qualitative Hinweise, keine
  statistisch gesicherten Erfolgsversprechen.

## 7. Technischer Rahmen

Vorhandene Module für Inhalte, Questführung, Gegnerkampf, Darstellung und
Speichern erweitern. Neue Dateien nur bei tatsächlicher Lücke. `main.gd`
bekommt höchstens Verdrahtung; kein allgemeiner Architekturumbau nebenbei.

Aufgaben und Funde erhalten stabile IDs; abgeschlossene alte Quests behalten
ihre Bedeutung. Migrationen wiederholt laden und beschädigte/fehlende Werte
prüfen. Online vergibt die vorhandene maßgebliche Serverlogik einmalige
Belohnungen; Wiederholung und gleichzeitige Anfragen duplizieren nichts.

Die bestätigte XP-Auslegung ab Level 100 bleibt bestehen. Große Zahlen werden
im Fortschrittspaket gelöst. Eine neue XP-Kurve gehört nicht zu diesem Entwurf.

Jedes Paket erhält Vorher-/Nachher-Bilder, gezielte Verhaltenstests und die
erforderlichen Gesamtprüfungen/CI. Balance-, Grafik- und Speicheränderungen
klar benennen. Historische grüne Prüfungen ersetzen keine neue Prüfung.
Live-Schaltung gemäß `AGENTS.md` mit Freigabe des konkreten Pakets.

## 8. Meine Entscheidung für den Anfang

Aktualisierung auf Angelos weiteren Auftrag vom 16.10.:
[Feste Architektur und Leistungspilot](GRAFIK_GAMEPLAY_PERFORMANCE_KONZEPT.md)
gehen dem breiten Grafik-/Gameplayausbau voraus. Erst dieselbe Szene
messbar flüssiger machen, danach die hier beschriebene Erlebnisqualität
auf dieser Grundlage ausbauen.

Nachtrag 16.10.: Angelo meldet allgemeine Lags seit Einführung der
3D-Modelle auf den Maps. [Fehlereintrag](SERVER_LAGS_3D.md).
Diese Regression vor zusätzlicher breiter 3D-Integration untersuchen;
die Zuordnung zu Client, Server oder Netzwerk ist noch offen.

Zuerst den Einstieg aufnehmen und seine drei größten Reibungspunkte
festhalten. Daraus das erste kleine Spielpaket bauen. Parallel im Sinne
unabhängiger Vorbereitung Stilblatt und Exportprobe erstellen, danach den
vollständigen Krieger entwickeln.

Der erste Erfolg ist erreicht, wenn ein neuer Spieler selbstständig ins
Abenteuer findet, Gegner bewusst liest, etwas freiwillig entdeckt und bei
der Heimkehr sieht, dass seine Hilfe etwas verändert hat.

Grundlagen: [Arbeitsplan](ARBEITSPLAN.md),
[Werkzeugplan](NEXT_LEVEL_PLAN.md),
[bisherige Detailkonzepte](konzepte/2026-10-11-naechste-schritte/KONZEPT.md).
