# Sonnenhain RPG

Ein lokales, farbiges Top-down-Action-RPG für Godot 4.7. Die Welt, Figuren, Gegenstände, Fähigkeiten und Menüs werden im Projekt gezeichnet; Musik und Effekte sind als WAV-Dateien enthalten. Zum Spielen ist kein Webserver nötig.

## Start

1. Archiv in einen **neuen Ordner** entpacken. In Godot die `project.godot` aus `Sonnenhain-RPG-v22-2` importieren. In der Projektliste muss „Sonnenhain RPG - Weltenupdate v22.2“ stehen. Eine eventuell bereits importierte alte Kopie entfernen, damit nicht versehentlich diese gestartet wird.
2. Mit **F5** starten. Krieger, Magier oder Bogenschütze wählen und **Neues Spiel** drücken.
3. Für eine Windows-EXE im Godot-Editor die Windows-Exportvorlage installieren und unter **Projekt → Exportieren** exportieren.

Ein neues Spiel beginnt in Sonnenhain auf Stufe 1 mit leerer Tasche und ohne Fähigkeiten. Wähle im Hauptmenü einen von drei Speicherplätzen. Ein neues Spiel sichert den bisherigen Inhalt des gewählten Platzes als lokale Backupdatei. Automatisches Speichern erfolgt alle 15 Sekunden sowie bei wichtigen Ereignissen; **Esc** bietet Speichern und die Rückkehr ins Hauptmenü.

| Eingabe | Aktion |
| --- | --- |
| WASD / Pfeiltasten | Laufen |
| Maus / Linksklick halten | Zielen / wiederholt angreifen |
| Leertaste | Ausweichrolle |
| 1, 2, 3 | Drei frei belegte Fähigkeiten |
| 4 | Feste Klassenfähigkeit ab Stufe 20 |
| K / I / J / M | Fähigkeiten / Inventar / Questbuch / Weltkarte |
| E | NPC, Truhe oder alten Torbogen benutzen |
| F | Wegstein aktivieren; im Dorf Reiseziel wählen |
| Q / R | Heil- / Energie- bzw. Manatrank |
| Esc | Pause, speichern, Hauptmenü, Lautstärke für Musik/Effekte und Testmodus |

## Reise und Fortschritt

Die 16.000 × 9.600 Einheiten große Welt umfasst **13 Gebiete**: Sonnenhain (1), Blütenwiesen (1), Mondküste (5), Pilzwald (8), Nebelheide (12), Alte Ruinen (15), Bernsteinforst (19), Kristallmoor (22), Tiefenquell (26), Ascheberge (29), Dämmergrat (33), Sternenbruch (36) und Himmelsgarten (40). Ein neues Gebiet öffnet sich erst mit der angezeigten Mindeststufe. Einige Durchgänge verlangen zusätzlich einen besiegten Boss. Alte Torbogen verbinden die fünf neuen Regionen mit den bisherigen Gebieten; **E** betritt sie und bringt dich auch zurück. Geschwungene Wege führen um sichtbare Hindernisse herum. Die große Karte zeigt Levelgrenzen, Wegsteine und Tore; die kleine Karte bleibt auf die Umgebung der Figur zentriert.

Wegsteine werden **vor Ort** mit **F** dauerhaft aktiviert. Dann bringen sie dich nach Sonnenhain zurück. Der Dorfstein öffnet eine Auswahl aller freigeschalteten Reiseziele. Die Aktivierungen werden gespeichert.

Es gibt drei Klassen mit eigenen Angriffen, Waffen und Fähigkeiten: Krieger mit Schwert, Magier mit Stab und Bogenschütze mit Bogen. Die erste frei belegbare Fähigkeit ist ab Stufe 3 zugänglich, die zweite ab 8 und die dritte ab 12. Weitere acht bis neun Fähigkeiten je Klasse werden später freigeschaltet und sind bis Rang 5 verbesserbar. Ab Stufe 20 erhält jede Klasse eine eigene feste Fähigkeit auf Taste 4, deren Rang automatisch steigt. Stärke, Beweglichkeit und Intelligenz auf Gegenständen beeinflussen die Klassen unterschiedlich.

Skillpunkte erhältst du an jedem geraden Level und zusätzlich bei 3, 8 und 12. Die Ränge einer Fähigkeit haben weitere Levelgrenzen: Grundfreischaltung, danach +3, +8, +15 und +24 Level. Bei Feuerball heißt das: Rang 1 ab Level 3, Rang 2 ab 6, Rang 3 ab 11, Rang 4 ab 18 und Rang 5 ab 27. Im Testmodus kannst du Ränge frei verteilen.

Schwerter und Stäbe verändern mit höherem **Itemlevel und Seltenheit** sichtbar ihre Form: Klinge, Parierstange, Edelstein und Stabkrone werden schrittweise aufwendiger. Die jeweilige Ausrüstung erscheint ebenso an deiner Figur. Krieger, Magier und Bogenschütze haben eigene Körpersilhouetten, Kleidung und Rüstungsicons. Beim Magier heißt die Ressource Mana. Sie regeneriert mit 4 Punkten pro Sekunde, die Energie des Kriegers mit 5 und die des Bogenschützen mit 6. Normale Angriffe verursachen zu Beginn weniger Schaden.

Zusätzlich besitzt jedes Ausrüstungsteil eine von vier Formvarianten, die vom Namen des Gegenstands abhängt und mitgespeichert wird. Schwerter unterscheiden sich etwa durch gerade, gebogene, breite und gezackte Klingen; Stäbe durch Kristall, Sichel, Geäst und Zinken; Bögen durch unterschiedliche Arme und Hornenden. Klassenrüstungen bekommen eigene Schulter-, Mantel- oder Gurtformen. Die gewählte Form erscheint auch am ausgerüsteten Helden.

Die Geschichte führt zum angegriffenen Blütenweiler. Dort musst du 20 Angreifer über mehrere Wellen abwehren. Feuer, Rauch und Dorfbewohner machen die Bedrohung sichtbar; nach der Verteidigung überreicht Nela eine Waffe passend zu deiner Klasse, Gold und Erfahrung. Questzeichen über Mira, Borin und Liora unterscheiden neue, laufende und abgabebereite Aufgaben. Zehn zusätzliche Quests führen durch die neuen Regionen. Bosse öffnen wichtige Wege und hinterlassen besondere Waffen.

Bei einem neuen Spiel eröffnet ein kurzer, überspringbarer Prolog das erste Kapitel. Mira steht direkt neben dem Ankunftsplatz. Vier weitere Begegnungen entlang der Wege geben der Reise lokale Ziele: Tessa schützt den Weg zum überfallenen Dorf, Odo seinen Anleger, Rika eine Lichtung und Serin die Spuren am Turm. Sprich jeweils mit **E**, vertreibe Gegner in ihrer Nähe und hole dir danach die Belohnung und einen Hinweis. Der Fortschritt wird gespeichert und auf den Karten markiert. Der Dorfplatz hat Pflaster, Marktstände, Laternen, Beete und eine eigene Steinrose beim Start. Der Wegstein steht in einem Runenkreis mit Säulen; Wege zeigen Pflaster, eingefahrene Spuren, Steinkanten und Blumen.

Über jedem Gegner steht sein Level; Bosse haben eine eigene Kennzeichnung. Normale Angriffe und Fähigkeiten verursachen etwas mehr Schaden. Magierfähigkeiten verhalten sich unterschiedlich: Feuerbälle explodieren, die Frostnova hält Gegner in der Nähe auf, die Blitzlanze durchschlägt Ziele, Sternenfunken verfolgen nahe Gegner und der Elementarwirbel sendet drei verschiedenfarbige Schadenswellen aus. Beim Bogenschützen durchschlägt der Präzisionsschuss Gegner und markiert sie für Folgetreffer, Mehrfachschuss fächert auf, Giftpfeile hinterlassen eine zeitlich begrenzte Wolke, Frostpfeile treffen auch Gegner am Einschlagspunkt und Blitzpfeile springen zu weiteren Zielen. Die Fähigkeiten zeigen eigene Flugformen, Trefferanimationen und bereits vorhandene eigene Sounds. Die Schadenskurve ist als Spielgefühl-Anpassung gedacht und sollte im Editor beim tatsächlichen Spielen beurteilt werden.

Im Inventar siehst du deine Figur und genau drei Ausrüstungsplätze: Waffe, Rüstung und Ring. Beim Überfahren eines Items erscheinen Werte, Attribute, Seltenheit und ein farbiger Vergleich zum ausgerüsteten Gegenstand. Normale Beute kann selten, episch oder in hohen Gebieten äußerst selten legendär sein. Der Goldwert folgt Stufe, Stärke, Attributen und Seltenheit. Torvald der Schmied, Fenna die Händlerin und Pip der Alchemist bieten Ausrüstung und Tränke an. Ihre auf deine Stufe angepassten Angebote wechseln alle sieben Spielminuten. Händlerangebote zeigen beim Überfahren denselben Wertevergleich; vor jedem Kauf kommt eine Bestätigung. Tränke stapeln bis 16, Essenzen und Kräuter ohne begrenzte Stapelgröße. Beim einzelnen Verkauf geht nur ein Stück aus dem Stapel; **Alles verkaufen** verkauft die vollständigen Stapel, braucht einen zweiten Klick und behält getragene Ausrüstung.

In Sonnenhains Mitte heilt Elara alle HP für 8 + 3 × Level + einen kleinen HP-Zuschlag Gold. Die runde Minimap zeigt einen größeren Ausschnitt um die Figur. Die Weltkarte verwendet einen dunkleren Pixelatlas mit Wegen, Geländezeichen und gut lesbaren Gebietstafeln.

Über **Esc → Testmodus starten** wird eine getrennte Kopie des aktuellen Spielstands angelegt. Im Testmodus kannst du Level 1–40 in Schritten von 1 oder 10 einstellen, bekommst Gold und Skillpunkte, bist gegen Schaden geschützt und erreichst alle Wegsteine über **Reisen**. Bosse bleiben für Kämpfe verfügbar. **Testmodus verlassen** lädt deinen normalen Spielstand wieder; Aktionen im Testmodus schreiben nur in `user://sonnenhain_testmodus.json`.

Deine acht MIDI-Kompositionen ersetzen die Musik von Sonnenhain, Blütenwiesen, Mondküste, Pilzwald, Alten Ruinen, Kristallmoor, Aschebergen und Sternenbruch. Beim Gebietswechsel blendet der bisherige Track in 1,35 Sekunden aus und der neue ein. Die übrigen fünf Gebiete behalten ihre bisherigen Stücke. Im Finale und in Arvens Arena läuft eigene Kampfmusik. Die Gebietsmusik bleibt bei gewöhnlichen Bosskämpfen bestehen. Die Original-MIDI-Dateien liegen unter `music/source/`; wegen fehlender Soundfont wurden sie mit dem mitgelieferten einfachen Synthesizer in `tools/render_midi.py` vertont. Die Komposition bleibt erhalten, die Instrumentfarben können von deinem MIDI-Player abweichen. Mit `python3 tools/build_music.py` lassen sich die OGG-Dateien erneut erstellen (benötigt NumPy und FFmpeg). Alle Klassenfähigkeiten haben eigene kurze Klänge. Feuerball explodiert, Meteore und Pfeilhagel kündigen ihren Einschlag an; die Klassenfähigkeiten auf Taste 4 erzeugen mehrere Trefferwellen. Musik und Effekte haben im Pausenmenü getrennte Schieberegler, die im Spielstand gespeichert werden. Das Spiel speichert Klassenwahl, Quests, Beute, Fähigkeiten, Wegsteine, Händlerangebote und Storyfortschritt lokal.


## Weltenupdate v21

- Sonnenhains Häuser unterscheiden sich in Dachform, Fachwerk, Fenstern und Schmuck. Bewohner haben individuelle Farben und Kleidung; der Dorfplatz wird nach dem Ende geschmückt. Schatztruhen zeigen mehr Bänder, Holz und ein Schloss.
- Der Krieger trägt eine länger dargestellte Klinge. Elitegegner und Champions fallen durch größere Silhouetten, eigene Farben und deutlich mehr Leben auf. Beute liegt in einem klar umrandeten Feld; Gold erscheint als eine, zwei oder mehrere Münzen. Gegner lassen Gold am Boden fallen.
- Die Verteidigung von Blütenweiler zählt **20** Angreifer; die sonstigen Jagdaufträge brauchen ebenfalls mehr Abschüsse. Beim Schmied und bei Fenna gibt es teure Ausrüstung, für die sich Sparen lohnt.
- Die große Karte markiert deine Position, freigegebene Eingänge, Aufgaben und Bosse; gesperrte Gebiete behalten gut lesbare Levelangaben. Die Minimap ist rund. Fähigkeiten zeigen ihre Ränge als fünf leuchtende oder graue Sterne und kennzeichnen Levelgrenzen und verfügbare Verbesserungen. Feuerball und Meteor hinterlassen kurzzeitig brennende Zonen; Schildwall schafft einen Schutzbereich, der deine Angriffe verstärkt.
- Nach dem Sieg über alle drei Siegelbosse öffnet sich die **Letzte Wache**: zehn Angriffswellen aus allen Richtungen in einer runden Arena. Nach dem Sieg kehrst du zum jubelnden Sonnenhain zurück und kannst im freien Modus weiterspielen. Stirbst du, kannst du über Arven erneut antreten.
- **Arven** steht im Dorf und bietet eine getrennte endlose Arena. Die Wellen werden größer und stärker; Gegner hinterlassen dort weder Beute noch Erfahrung. Nach dem Tod wartet eine Truhe, deren Inhalt von Level und überstandener Welle abhängt. Die zehn besten Läufe bleiben pro Speicherplatz erhalten. Für die Truhe muss vor Betreten mindestens ein Taschenplatz frei sein.
- Musik ist bei unverändertem Reglerwert hörbar lauter. Deine individuellen Schiebereglerwerte bleiben erhalten. Drei Spielstände verwalten Klasse, Reise und Arenafortschritt getrennt.

## Licht, Nebel und Gewölbe (v22.2)

Ruinen, Kristallmoor, Ascheberge, Sternenbruch und weitere düstere Regionen haben stärkere Schatten, schwebenden Nebel und Fackeln an Wegen und markanten Orten. Die Lichtkegel lassen die Wege und Orientierungspunkte lesbar, während entfernte Flächen dunkler werden. Das friedliche Dorf und die hellen Wiesen bleiben klar.

An drei markierten Eingängen öffnet **E** ein eigenes Gewölbe: das Turmgewölbe am verfallenen Turm, die Kristallgruft am Altar und die versunkene Krypta am Brunnen. Darin siehst du den Boden um deine Figur sowie kleinere Lichtinseln an Fackeln; weiter entfernte Räume liegen im Sichtnebel. Gegner erscheinen nur im jeweiligen Raum. Links führt die Tür mit **E** hinaus, rechts öffnet sich nach dem Kampf eine einmalige Relikttruhe. Die Truhen werden pro Speicherplatz gespeichert. Beim Laden kehrst du sicher vor den Eingang zurück. Die runde Minimap zeigt im Gewölbe nur den sichtbaren Ausschnitt; die Weltkarte markiert deinen Eingang.

## Prüfstand

Die mitgelieferte Inhaltsprüfung unter `tools/check_content.py` kontrolliert Gebiete, Portale, Gegner, Quests, Fähigkeiten, Spielzustand und Audiodateien. Eine Ausführung in Godot war in der Erstellungsumgebung nicht möglich; bitte importiere das Projekt und prüfe Bewegung, Kauf, Skillvergabe, drei Spielstände, beide Arenen sowie Ein- und Ausgang und Sichtweite der drei Gewölbe im Editor. Wenn der Editor beim Import eine Fehlermeldung zeigt, bitte den genauen Text und die Zeilennummer schicken.
