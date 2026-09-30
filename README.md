# Sonnenhain RPG

Ein lokales, farbiges Top-down-Action-RPG für Godot 4.7. Die Welt, Figuren, Gegenstände, Fähigkeiten und Menüs werden im Projekt gezeichnet; Musik und Effekte sind als WAV-Dateien enthalten. Zum Spielen ist kein Webserver nötig.

## Start

1. Archiv in einen **neuen Ordner** entpacken. In Godot die `project.godot` aus `Sonnenhain-RPG-v24` importieren. In der Projektliste muss „Sonnenhain RPG - Pixelwelt v24“ stehen. Eine eventuell bereits importierte alte Kopie entfernen, damit nicht versehentlich diese gestartet wird.
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
| E am Haus „Zur Steinrose“ | Taverne betreten; drinnen mit Alma sprechen oder an der Tür hinausgehen |
| F | Wegstein aktivieren; im Dorf Reiseziel wählen |
| Q / R | Heil- / Energie- bzw. Manatrank |
| Esc | Pause, speichern, Hauptmenü, Lautstärke für Musik/Effekte und Testmodus |

Im Hauptmenü und unter **Esc → Tasten** kannst du alle 19 Aktionen neu belegen: Bewegung, Angriff, Ausweichen, Interaktion, Wegstein, Tränke, vier Fähigkeiten, Menüs und Pause. Klicke einen Eintrag an und drücke eine Taste oder eine der drei Maustasten. Bereits belegte Tasten tauschen ihre Aktionen; beim Wechsel der Pausentaste kann die andere Aktion vorübergehend unbelegt sein. **Standard wiederherstellen** setzt alles zurück. Esc bleibt als sichere Rückkehr ins Pausenmenü reserviert. Die Belegung gilt für alle drei Spielstände und liegt getrennt unter `user://sonnenhain_tasten.json`.

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

## Licht, Nebel und Gewölbe (v22.4)

Ruinen, Kristallmoor, Ascheberge, Sternenbruch und weitere düstere Regionen haben stärkere Schatten, schwebenden Nebel und Fackeln an Wegen und markanten Orten. Die Lichtkegel lassen die Wege und Orientierungspunkte lesbar, während entfernte Flächen dunkler werden. Das friedliche Dorf und die hellen Wiesen bleiben klar.

An drei markierten Eingängen öffnet **E** ein eigenes Gewölbe: das Turmgewölbe am verfallenen Turm, die Kristallgruft am Altar und die versunkene Krypta am Brunnen. Darin siehst du den Boden um deine Figur sowie kleinere Lichtinseln an Fackeln; weiter entfernte Räume liegen im Sichtnebel. Gegner erscheinen nur im jeweiligen Raum. Links führt die Tür mit **E** hinaus, rechts öffnet sich nach dem Kampf eine einmalige Relikttruhe. Die Truhen werden pro Speicherplatz gespeichert. Beim Laden kehrst du sicher vor den Eingang zurück. Die runde Minimap zeigt im Gewölbe nur den sichtbaren Ausschnitt; die Weltkarte markiert deinen Eingang.

Der Schatten in Gewölben fällt nun als weichere, dunkle Vignette mit einem leichten Schwerpunkt unter der Figur. Fackeln öffnen helle Inseln im Schatten. In dunklen Außengebieten verlaufen die Schatten ebenfalls weicher. Beide runden Kampfarenen haben einen Radius von 490 statt 270 Welteinheiten und entsprechend mehr Bodenmuster und Randfackeln. Die Kamera folgt in der Arena der Figur; Gegner einer Welle erscheinen ringsum in kampfbarer Entfernung und verfolgen dich auch über die vergrößerte Fläche.

Der Gewölbeschatten lässt im oberen Blickfeld den Weg länger erkennbar, schließt sich unter der Figur aber dunkler wie auf der Bildvorlage. Fackeln bekommen mehrstufige warme oder kristallblaue Lichtscheine mit weichem Abfall. Dadurch treten Eingänge und Bedrohungen in Lichtinseln hervor, ohne die direkte Sicht um den Helden zu verdecken.

## Pixelwelt v23

Ein eigener handgezeichneter Atlas mit 32 Pixelkacheln (16 × 16 Pixel) liefert jetzt Rasen, Pflaster, Dächer, Wände, Fenster, Türen, Böden, Fackeln, Möbel und Details. Das Skript `tools/build_pixel_art.py` erzeugt den Atlas reproduzierbar; die mitgelieferte PNG-Datei funktioniert ohne Python im Spiel. Alle Kacheln werden mit nächstem Nachbarpixel ohne Weichzeichnung dargestellt. Die CraftPix-Beispiele sind eine gestalterische Referenz; ihre Bilder wurden nicht kopiert oder benötigt.

Sonnenhains Boden und Häuser, der Ankunftsplatz und alle drei Gewölbe verwenden den neuen Atlas. Ein Haus südöstlich des Dorfplatzes ist nun die betretbare Taverne **Zur Steinrose**. Ein eigener Innenraum hat Holzboden, gemusterten Teppich, Theke, Kamin, Regale, Tische, Fackeln und blockierende Möbel. Wirtin Alma heilt dich bei Bedarf für 9 + 2 × Level Gold. Drücke **E** an der Tür zum Verlassen. Die lokale Minimap zeigt den Raum; Musik und Weltkarte bleiben auf Sonnenhain bezogen. Speichern in der Taverne bringt dich beim Laden sicher vor ihren Eingang zurück. Die übrigen Außengebiete und Figuren verwenden weiterhin ihre bisherigen Darstellungen. Dieser Abschnitt dient als durchgehende Vorlage für den späteren Umbau der weiteren Welt.

## Steuerung und Reparatur v24

Der beim Zeichnen des Dorfbodens falsch eingerückte Kachelaufruf wurde korrigiert. Alle spielrelevanten Eingaben lesen jetzt die frei belegbaren Aktionen; die untere Leiste und die Interaktionsanzeige zeigen die tatsächlich zugewiesenen Tasten.

## Prüfstand

Die mitgelieferte Inhaltsprüfung unter `tools/check_content.py` kontrolliert Gebiete, Portale, Gegner, Quests, Fähigkeiten, Spielzustand und Audiodateien. Eine Ausführung in Godot war in der Erstellungsumgebung nicht möglich; bitte importiere das Projekt und prüfe Bewegung, Kauf, Skillvergabe, drei Spielstände, beide Arenen sowie Ein- und Ausgang und Sichtweite der drei Gewölbe im Editor. Wenn der Editor beim Import eine Fehlermeldung zeigt, bitte den genauen Text und die Zeilennummer schicken.


## Pixelwelt v26 – vollständiger visueller Anschluss

- Die Oberwelt nutzt weiterhin den eigenen 16-Pixel-Atlas, wurde aber über alle Regionen mit dichterer, gebietstypischer Vegetation, neuen Buschgruppen, stärker strukturierten Hindernissen und klareren Ruinen-, Kristall-, Küsten-, Asche- und Spätspielformen vereinheitlicht. Wege und Kollisionen bleiben an die bestehende Navigation gekoppelt.
- Sonnenhains Häuser wurden erneut aufgebaut: kräftigere Sockel, gestufte Dächer, Traufen, Firste, Fachwerk, Fensterlicht, Vordächer, Türstufen und mehrere funktional lesbare Fassadenvarianten. Die Taverne bleibt betretbar und hebt sich sichtbar von Wohnhäusern ab.
- Die vorhandenen Landmarken erhielten je Gebiet unterschiedliche Materialien und Details. Türme, Schreine, Tore, Docks und Pilzlichtungen wirken nicht mehr wie dieselbe neutrale Form in anderer Umgebung.
- Gegnerrollen wurden geschärft: Staubwächter → Steingolem, Splittergeist → Kristallgolem und der bestehende Glutgolem wurde zum Lavagolem weiterentwickelt. Der Ruinenbeholder bleibt ein eigener schwebender Fernkämpfer. Schwere Golems und Fernkämpfer zeigen zusätzliche visuelle Angriffsvorbereitungen.
- Bodenkontaktschatten wurden als dezente, mehrstufige Schatten statt harter eingebrannter Flächen umgesetzt. Trefferblitz, Elite-/Champion-Ringe und vorhandene Statusdarstellungen bleiben erhalten.
- Die drei Klassen behalten ihre getrennten Silhouetten. Ausgerüstete Waffen bleiben im Stand, beim Laufen und Angreifen sichtbar; die bereits in v25 eingeführten Axt- und Armbrustformen bleiben an die existierenden Waffen-/Inventarsysteme gekoppelt.
- Skill- und Projektilsysteme bleiben vollständig angeschlossen. Feuer, Eis, Blitz, Gift, arkane Effekte und Pfeilfähigkeiten verwenden weiterhin eigene Flug-, Einschlag- und Flächenformen statt einer einzigen umgefärbten Vorlage.

### Prüfung v26

`python3 tools/check_content.py` prüft weiterhin Regionen, Gegner, Quests, Fähigkeiten, Dungeons, Taverne, Eingaben, Musik, Audio und den Pixelatlas. Zusätzlich wurde vor dem Packen nach doppelten Top-Level-Funktionen und fehlenden Projektdateien gesucht. In der Erstellungsumgebung ist kein Godot-Executable installiert; deshalb konnte kein echter Godot-Laufzeit- oder Spieltest durchgeführt werden.

## Pixelwelt v27 – Charaktere, Koop und Pixel-Art

v27 führte gebietsspezifische Pixelatlanten ein. v27.5 beruhigt den großflächigen Untergrund wieder mit breiten Farbflächen; die detaillierten Pixeltexturen bleiben für Wege, Gebäude, Mauern und Objekte erhalten. Charaktere, NPCs, Gegner, Waffen, Skill-Icons und zusätzliche Effekte verwenden die Atlanten unter `art/`.

Bei **Neues Spiel** wird der Charakter einmalig erstellt: Name, Mann/Frau, Mensch/Ork/Roboter und die Klasse werden im Speicherstand gesichert. Der Name erscheint auch im Koop-Chat.

### Koop

Im Hauptmenü öffnet **KOOP** die Mehrspielersteuerung. Ein Spieler wählt **HOSTEN** und teilt den angezeigten Einladungscode mit bis zu drei Freunden. Die Freunde geben den Code unter **BEITRETEN** ein. Das Spiel verwendet ENet über UDP-Port `27844`. Beim Hosten wird automatisch UPnP versucht. Wenn der Router keine UPnP-Portfreigabe erlaubt, muss UDP 27844 auf den Host-Rechner weitergeleitet werden. GitHub verteilt den Spielstand/Build, stellt aber keinen dauerhaften Relay-Server bereit.

**ENTER** oder **T** öffnet im Spiel den Gruppenchat.

Der Koop-Modus in v27 ist eine Host/P2P-Beta: Bewegung, Profile, Ausrüstung, Gegnerzustände, Chat und zentrale Kampfschäden werden synchronisiert. Einige entfernte Spezialeffekte sind noch nicht vollständig als identische VFX-Replikation umgesetzt.

### Grafik und Animation v27.5

- Großflächiger Untergrund wieder ruhiger und nahe am Kartenstil aus v24; weniger sichtbares 16×16-Kachelrauschen.
- Charakter-Sprites mit vier Blickrichtungen und gezielteren Gesichtsdetails; classenspezifische Kleidung und animierte Arme ergänzt.
- Schwerter und Äxte schwingen in unterschiedlichen Bögen; der Magier führt den Stab in einer eigenen Bewegung; Bogen und Armbrust zeigen Zug beziehungsweise Rückstoß.
- Mauertexturen bedecken nun die gesamte sichtbare Mauerbreite. Kollision folgt der kompletten Wandstärke und lässt freigeschaltete Tore frei.
- Wege sind deutlich breiter und besitzen jetzt mehrschichtige Ränder, regional unterschiedliche Beläge, Steinchen und sichtbare Wegranddetails.

### Figuren, Wege und Tageszeit v27.5

Gegner verwenden jetzt eigene größere Modelle mit individuellen Körperformen und Details; Champions und Bosse bleiben klar erkennbar. Der bewaffnete Arm sitzt am Schulterpunkt, Magierstabb und Bogen haben getrennte Formen und Animationsbewegungen. Die Startdorfhäuser bekommen zusätzliche Dach-, Fenster-, Schornstein- und Türdetails. Die breiten Wege werden als durchgehende Fahrspur gerendert, damit keine einzelnen Texturkacheln über der Karte schweben. Ein dezenter Tag-Nacht-Rhythmus färbt die Oberwelt um; die FOW-Zeichnung arbeitet mit einem gröberen Raster und die Bildrate ist auf 60 FPS gedeckelt.


### Koop, Chat und Webexport v27.5

Der Gruppenchat blendet ältere Nachrichten nach kurzer Ruhezeit weich aus. Im Koopfenster führt **WELT STARTEN** den Host in die gewählte Welt; verbundene Freunde erhalten **WELT BEITRETEN**. Ohne vorhandenen Spielstand geht es in die Charaktererstellung, mit Spielstand wird dieser geladen. Der Browserexport ist über `export_presets.cfg` vorbereitet; die Schritte und der Koop-Hinweis stehen in [WEB_EXPORT.md](WEB_EXPORT.md).
