extends RefCounted
const VERSION="PATCH 09.10.2026"
const NOTES=[
["Welt · Neue Wegsteine", "Alle Wegsteine außerhalb des Dorfs stehen jetzt auf einem erhöhten Steinplateau mit Treppe, Runenkreis und einem Obelisk, über dem ein Kristall schwebt. Aktivierte Wegsteine leuchten. Hinauf und hinunter geht es über die Treppe."],
["Fehlerbehebung · Spielstände im Startmenü", "Angemeldet zeigte das Startmenü die Spielstände, die zufällig im Browser lagen, manchmal von einem anderen Konto oder einem alten Charakter. Jetzt zeigen die drei Speicherplätze genau die Charaktere deines Kontos, wie bei der Anmeldung, mit aktueller Stufe. „Spielstand laden“ lädt sie vom Server."],
["Welt · Start im Dunkeln", "Die Welt liegt jetzt im Dunkeln, auch Sonnenhain. Du siehst 20 Meter weit, und alles, was du einmal gesehen hast, bleibt dauerhaft aufgedeckt: im Spielbild, auf der Minikarte und auf der Weltkarte. Bisher erkundete Gebiete bleiben erhalten. Gruppenmitglieder decken nur mit auf, wenn sie in deiner Nähe sind."],
["Klänge · Tippgeräusch", "Beim Schreiben klickt jetzt jede Taste leise: im Anmelde- und Registrierformular, beim Koop-Code, beim Charakternamen und im Chat. Löschen klingt etwas tiefer. Die Lautstärke folgt dem Regler „Oberfläche“."],
["Reisen · Über die Karte", "Stehst du an einem Wegstein oder am Spawn, wird die Karte mit M zur Reisekarte: Ein Klick auf ein aktiviertes Ziel reist sofort. Weiter weg sagt dir ein Hinweis: „Gehe zu einem Wegstein, um zu teleportieren.“"],
["Oberfläche · Vollbild", "F11 oder der neue Knopf „Vollbild“ in den Einstellungen schaltet das Spiel in echtes Vollbild, ohne Browserleisten. Auf 16:9-Bildschirmen füllt es dann den ganzen Schirm. Escape oder F11 beendet das Vollbild."],
["Fehlerbehebung · Charakterwechsel", "Wer ohne Neustart zu einem anderen Charakter wechselte, bekam Quests, Bosse, Ereignisse und Kartenfortschritt des vorigen Charakters untergemischt. Jetzt startet jeder geladene Charakter sauber mit genau seinem eigenen Stand. Auch der Kartennebel, die Gruppe und Truhen-Timer werden nicht mehr übernommen, und während des Ladens wird nicht mehr automatisch gespeichert."],
["Klänge · Schritte je Untergrund", "Deine Schritte klingen jetzt nach dem Boden unter dir: Gras, Waldboden, Erde und Wege, Kopfsteinpflaster, der Spawnstein, Holzdielen in Häusern, Stein in Kapelle, Gewölben und Ruinen, Sand an der Küste und in der Arena, Moor und Pfützen sowie Asche und Kies in den Aschebergen."],
["Sonnenhain · Keine orangenen Rahmen mehr", "Um Rathaus, Kirche, Borin, Fenna, Alma, Schmiede und Arena lag ein halbtransparenter orangener Rahmen mit gestrichelter Kante auf dem Boden. Er stammte aus einer alten Dorfversion und ist entfernt."],
["Kapelle · Sauberer Steinboden", "Zwischen Altar und vorderen Bänken war der Steinboden seit der Verbreiterung verschmiert. Dort liegt jetzt richtiger Steinboden in Originalgröße."],
["Klänge · Alle Büsche rascheln", "Auch Blütenbüsche, Kräuter, Büsche an Bäumen und Ruinen sowie die Büsche auf den Wiesen rascheln jetzt, wenn du hindurchläufst."],
["Klänge · Summen am Spawnstein", "Rund um den Spawnstein summt leise ein magisches Teleport-Brummen; es wird mit Abstand leiser und verstummt in Häusern."],
["Oberfläche · Aufgeräumt", "Die Steuerungszeile über der unteren Leiste ist entfernt. In der Charaktererstellung heißt der Knopf jetzt „Weiter“."],
["Fusionen · Wirkung am Trefferpunkt", "Alle Fusionen zünden jetzt dort, wo ihr Angriff trifft: am ersten getroffenen Gegner, sonst am Hindernis oder am Ende der Reichweite. Bisher lösten viele Fusionen ihren zweiten Teil einfach am Spieler aus. Fusionen aus zwei Schutz- oder Hilfsfähigkeiten schicken einen kurzen Impuls in Blickrichtung. Schilde, Heilung und Stärkungen wirken weiter auf dich. Fächer und Durchschläge zünden höchstens fünfmal pro Einsatz. Enthält eine Fusion den Sprungangriff, springst du weiterhin; sein Landeschlag zündet am Treffer. Der Reaktorwall schützt dich sofort, seine Wand entsteht am Einschlag."],
["Reisen · Weltkarte an Wegsteinen", "Spawn und Wegsteine öffnen die Weltkarte. Ein Klick auf eine Region oder einen aktivierten Wegstein reist direkt dorthin; Aktivierungen und Boss-Siegel bleiben gültig. Wegsteine schicken dich beim Öffnen nicht mehr sofort ins Dorf zurück."],
["Bossgaben · Zuordnung und Anhänger", "Die drei Meistergaben erkennen ihre Boss- und Klassenzuordnung auch bei älteren Gegenständen zuverlässig. Ungültige Kennungen werden nicht mehr als Kriegergabe behandelt. Anhänger und Amulette tragen Kettenoptik, werden im Halskettenplatz angelegt und behalten ihre Werte."],
["Kristallmoor · Dunkler Arkanhüter", "Der Arkanhüter heißt jetzt Dunkler Arkanhüter und besitzt sein Kampfgebiet samt Haus im Kristallmoor. Quest- und Kartenangaben folgen dem neuen Standort. In Elaras Kapelle sind die Wege links und rechts am Heilungsfeld breiter."],
["Oberfläche · Größere, eckige Minimap", "Die Minimap oben rechts ist größer, quadratisch und schlicht mit goldenem Rahmen; Kompass und Ringe entfallen. Ein Klick darauf öffnet weiter die große Karte. Kartenname und Stufe stehen direkt darunter."],
["Oberfläche · Aktionshinweis unter der Minimap", "Hinweise wie „F · Wegstein“ stehen jetzt rechts unter der Minimap, sind nur so breit wie ihr Text und haben einen hellen Rahmen."],
["Fehlerbehebung · Kein Ton im Browser", "Im Browser waren seit dem Klang-Update Musik, Effekte und Menüklänge stumm. Die Lautstärkekanäle sind jetzt fest im Spiel angelegt, damit der Browser sie abspielt."],
["Oberfläche · Durchsichtige untere Leiste", "Die Leiste unten hat keinen Hintergrund mehr. Nur Knöpfe und belegte Fähigkeitsplätze haben einen Rahmen; die Knopfbeschriftungen passen wieder vollständig hinein."],
["Menüs · Rückfrage beim Verlassen", "„Speichern & zur Startseite“ und „Speichern & Hauptmenü“ fragen jetzt nach, ob du das Spiel wirklich verlassen willst. Abbrechen oder Escape bringt dich zurück ins Menü."],
["Klänge · Klick für alle Menüknöpfe", "Jeder Knopf in Menüs und Fenstern klickt hörbar, ebenso die Lautstärkeregler. Knöpfe mit eigenem Klang klicken nicht doppelt."],
["Oberfläche · Schlankeres HUD", "Leben, Energie und Ausdauer sind jetzt schmale Balken ohne Kasten; die Zahlen samt XP und Gold erscheinen beim Darüberfahren. XP läuft als dünne Linie unter der Fähigkeitenleiste. Das aktuelle Ziel steht als eine halbtransparente Zeile unten über der Leiste und zeigt beim Darüberfahren die Details. Kartenname und Stufe stehen unter der Minimap. Die Speicherzeile erscheint nur noch bei Problemen."],
["Oberfläche · Patch Notes als Liste", "Die Patch Notes zeigen nur noch die Überschriften, neueste oben. Ein Klick öffnet den ganzen Text; mit „Neuer“ und „Älter“ blätterst du weiter, Escape führt zurück zur Liste. Das Mausrad blättert durch ältere Einträge."],
["Fehlerbehebung · Fenna-Änderungen nach dem Login", "Änderungen bei Fenna, die den Server vor dem Schließen nicht mehr erreicht haben, gehen beim nächsten Anmelden nicht mehr verloren. Ist der Server neuer, wird der lokale Stand als Kopie gesichert. Fenna zeigt an, wann der Server gespeichert hat."],
["Wegsteine · Reisen von überall", "Jeder aktivierte Wegstein öffnet die Reiseauswahl und bringt dich zu jedem anderen aktivierten Wegstein; Sonnenhain ist immer ein Ziel. Ein neuer Wegstein wird beim Berühren aktiviert, ohne dich ins Dorf zu schicken."],
["Kapelle · Freie Gänge und Heilpodest", "Zwischen den Kirchenbänken kann man jetzt hindurchgehen, und Elara ist bequem erreichbar. Das Heilfeld liegt auf einem erhöhten, begehbaren Steinpodest vor dem Altar."],
["Sonnenhain · Eingänge, Laternen und Büsche", "Die Wege enden an beiden Dorfeingängen sauber an der Mauer. Die Laterne auf der Mauer unten bei der Arena steht jetzt im Gras daneben; Laternen und Büsche stehen nicht mehr auf Pflaster."],
["Klänge · Menüs und Fortschritt", "Knöpfe, Fenster, Gespräche, Kaufen und Verkaufen klingen eigen; was gerade nicht geht, meldet ein kurzer Fehlerton. Quests, Level-Aufstieg, Skillpunkte, Freischaltungen, Wegsteine, Reisen, Truhen, Heilung und Boss-Auftritte haben eigene Klänge im 16-Bit-Märchenstil. Neuer Lautstärkeregler „Oberfläche“ in den Einstellungen."],
["Klänge · Büsche", "Wer durch Büsche und Sträucher läuft, hört sie rascheln."],
["Klänge · Kampf im 16-Bit-Märchenstil", "Schwert, Stab und Bogen klingen eigen. Treffer hören sich je nach Gegner weich, gepanzert, fellig, steinern, geisterhaft oder metallisch an. Waldschleim, Blütenkäfer, Pilzling und Mooswolf haben eigene Angriffslaute, die ersten drei auch eigene Niederlagenlaute; entfernte Gegner sind leiser. Neue Klänge für Schaden, Ausweichen, Tränke, Niederlage, Rückkehr und das Betreten der Welt sowie Gold und seltene Beute. Unter 25 % Leben schlägt ein Herz, bis du dich erholst."],
["Technik · Gegenstandsregeln als Modul", "Erzeugung von Gegenständen und Beute, Stapelgrößen, Verkaufswerte und Anzeigenamen liegen jetzt in einem eigenen, getesteten Modul. Beutechancen und Werte bleiben unverändert."],
["Technik · Weltgeometrie als Modul", "Gebietsgrenzen, Wegabstände, Wegsteine sowie Lage der Klassenboss-Arenen und -Häuser liegen jetzt in einem eigenen, getesteten Modul. Karte, Spawns und Teleports verhalten sich unverändert."],
["Technik · Netzwerk-Hilfen als Modul", "Koop-Einladungscodes und die Prüfung eingehender Quest-, Ereignis- und Beutedaten liegen jetzt in einem eigenen, getesteten Modul. Spielverhalten und Einladungscodes bleiben unverändert."],
["Technik · Spielinhalte als eigenes Modul", "Gegner, Fähigkeiten, Quests, NPCs, Händler, Weltereignisse, Wahrzeichen, Wege und Torbogen liegen jetzt gebündelt in einer eigenen Inhaltsdatei. Werte und Spielverhalten bleiben unverändert."],
["Klänge · Pilzling", "Der Pilzling verwendet beim Giftstaubausstoß ein kurzes weiches Giftzischen ohne anfänglichen Klick, Quetschlaut oder Murmeln."],
["Mobs · Verfolgung und Hindernisse", "Mooswölfe bereiten ihren Sprung in 0,4 statt 0,8 Sekunden vor; Ziellinie und Landekreis entfallen. Erkannte Spieler werden von normalen Mobs auch außerhalb des Heimradius weiterverfolgt. Automatisches Zurückweichen entfällt; nach dem Angriff schließen die Gegner wieder auf. Bäume und andere Hindernisse werden mit geplanten Umwegen und passender Körperbreite umgangen. Blockierte Angriffe lösen Annäherung aus. Sicherheitszonen, Regionsgrenzen und Bosskampfgebiete bleiben gültig."],
["Waldmobs · Bewegliche Körper und Angriffe", "Auch Waldschleim, Blütenkäfer und Pilzling besitzen nun eigene Ruhe-, acht Bewegungs- und acht Angriffs-/Erholungsposen in allen acht Blickrichtungen. Käferbeine und Fühler arbeiten mit, die Drüsen schwellen vor dem Sekretschuss an. Der Pilzhut federt und hebt sich beim Giftstaubausstoß. Der Schleim komprimiert sich und federt beim Hüpfen nach. Dazu kommen Treffer- und Todesposen. Die Animation folgt der tatsächlichen Bewegung; Kampfwerte und Trefferzeiten bleiben unverändert."],
["Mooswolf · Lebendige Animationen", "Der Mooswolf verwendet jetzt eigene Posen für Ruhe, acht Laufphasen, Biss, geduckte Sprungvorbereitung, Absprung und abgefederte Landung in allen acht Blickrichtungen. Schwanz und Körper bewegen sich mit; die Pfoten folgen dem tatsächlichen Bewegungstempo. Dazu kommen Trefferreaktion, Zusammenbrechen und sanftes Ausblenden. Kampfwerte und Trefferzeiten bleiben unverändert."],
["Mobs · Drüsen, Giftstaub und Sprungbiss", "Blütenkäfer verschießen grünes Sekret aus ihren vorderen Drüsen statt Kontaktschaden. Pilzlinge kündigen einen Giftstaubkreis an; der Staub schädigt Spieler darin kurzzeitig in einzelnen Impulsen. Mooswölfe beißen aus der Nähe und springen aus mittlerer Entfernung mit sichtbarer Vorwarnung an. Sprünge beachten Hindernisse und treffen erst bei der Landung. Die Ost-/West-Blickrichtungen der neuen Mob-Bilder wurden berichtigt."],
["Mobs · Blütenwiesen und Pilzwald", "Waldschleim, Blütenkäfer, Pilzling und Mooswolf erhalten detaillierte Pixelart mit acht Blickrichtungen. Ihre Körper bleiben beim Bewegen und Angreifen im selben Stil. Der Blütenkäfer steht passend zu seinen Beinen auf dem Boden. Schaden, Trefferbereiche, Beute und Angriffstempo bleiben unverändert."],
["Sonnenhain · Laternen und Büsche", "Die orangefarbenen Lichtflecken an den Laternen wurden durch einen einzelnen sanft auslaufenden warmen Lichtschein ersetzt; tagsüber bleibt der Boden unverfärbt. Der orange Busch am Brunnen entfällt. Vier feste grüne Büsche stehen jetzt auf anderen freien Rasenflächen."],
["Sonnenhain · Zäune und Türen", "Die drei freistehenden Zaunreste ohne Grundstücksfunktion wurden samt ihren Kollisionen entfernt. Türen verwenden jetzt getrennte kurze Holzgeräusche zum Öffnen und Schließen statt synthetischer Töne, mit Riegel, Scharnier und gedämpftem Anschlag."],
["Sonnenhain · Hausgegenstände im Dorfstil", "Die zwei Gegenstände pro Haus verwenden jetzt detaillierte transparente Pixelart passend zu den neuen Gebäuden: Stoffe, Bücher, Holz, Metall und Stein mit klaren Materialschattierungen. Sie stehen dicht an den Fassaden und seitlich der freien Eingänge statt verstreut im Vorgarten."],
["Sonnenhain · Dorfvorplätze", "Das Atelier ist kleiner und nach links versetzt; Tür und Pflasteranschluss passen dazu. Alle sieben Häuser besitzen zwei passende Gegenstände vor dem Haus, mit freien Eingängen und geprüften Objektkollisionen."],
["Sonnenhain · Wege und Höhen", "Der rechte Dorfeingang ist direkt mit Borin und dem Spawnplatz verbunden. Pflasterübergänge sind abgerundet, das Kirchenfundament folgt der Gebäudebodenbreite. Im Nordwesten liegt ein grasbewachsener Berg mit sechs unregelmäßigen Höhenstufen, Felsen und Moos."],
["Arkanhalsketten · Für alle Klassen", "Eis-, Blitz- und Giftkerne werden zu tragbaren Arkanhalsketten. Ein eigener Halskettenplatz aktiviert ausschließlich den besonderen Effekt; keine zusätzlichen Grundwerte und kein Verbrauch. Bereits gelernte Blitzlanze bleibt erhalten."],
["Bossbeute · Drei besondere Halsketten", "Kriegsherr, Arkanhüter und Jagdmeister lassen zusätzlich ihre besondere Halskette fallen. Jede Klasse kann jede Halskette tragen. Die Anhänger sind sichtbar und werden im Koop übertragen."],
["Zoom · Feste Menüs", "ESC-Menü, Figurenansichten und Ausrüstungsdarstellung behalten bei 100 %, 85 % und 70 % ihre Größe und Position. Mausradereignisse werden nur im passenden Kamera- oder Menükontext verarbeitet."],
["Zoom · Vollständige Atmosphäre", "Nebel, Wolken und Dungeon-Dunkelheit decken auch beim Herauszoomen den gesamten sichtbaren Weltbereich ab."],
["Sonnenhain · Neues Bodenprofil", "Map 0 wurde ausschließlich am Boden neu gestaltet: großer heller Spawnplatz, warme Dorfwege, zusammenhängende Hausvorplätze und ruhige Gras-/Moosflächen mit organischen Übergängen. Die visuelle Höhen-/Treppenschicht wurde aus dem Map-0-Boden entfernt. Gebäude, Objekte, Kollisionen, Navigation und Gameplay bleiben unverändert."],
["Map 0 · Terrain-Polish", "Arenaflächen verwenden nun echten Boden statt einer vollflächigen Randkachel. Grundstücke und Plaza sind zusammenhängender, dunkle Einzelpflaster-Flecken entfallen und Übergänge zwischen Gras, Erde und Stein sind breiter und organischer."],
["Map 0 · Neues Terrain", "Sonnenhain verwendet neue 32px-Bodenfamilien für Gras, Wege, Pflaster, Hausvorplätze und Arena. Übergänge, dezente Details und visuelle Höhenstufen werden deterministisch gewählt; Gebäude, Türen, Kollisionen, Navigation, Saves und Multiplayer bleiben unverändert."],
["Kamera · Zielen beim Zoom", "Mauszielen bleibt bei 100 %, 85 % und 70 % Kamera-Zoom exakt am Cursor. Bildschirmkoordinaten werden wieder korrekt in Weltkoordinaten umgerechnet."],
["Dorf · Acht neue Innenräume", "Schmiede, Kapelle, Steinrose, Arena-Halle, Atelier, Ratshalle, Borins Haus und Pips Nebenraum verwenden die abgestimmten Pixelgrafiken. Möbel und Wände besitzen zur Grafik passende Hitboxen. Pips Werkstatt ist durch die Seitentür bei Borin erreichbar."],
["Dorf · Spawn, Brunnen und Pflanzen", "Der Kristall-Spawn besitzt eine große Steinplattform mit freier Treppe und festen Mauern. Brunnen, Herbstbäume, Runenbaum und drei Buscharten passen zu den Häusern. Pflanzen, Laternen und Zäune stehen außerhalb der Gebäude; der 2-Meter-Held bleibt die Größenreferenz."],
["Welt · Freiere Begehbarkeit", "Bäume blockieren nur noch am Stamm, Büsche sind durchgehbar und große prozedurale Hindernisse haben kleinere faire Kollisionsflächen. Hauptwege werden jetzt automatisch auf freie Begehbarkeit geprüft."],
["Map 0 · Szenerie bereinigt", "Die bisherigen normalen Bäume und Fässer wurden aus Sonnenhain entfernt. Borins eigener Zauberbaum bleibt bestehen; neue normale Bäume folgen erst mit der neuen Stilvorlage."],
["Kamera · Herauszoomen", "Im Spiel gibt es jetzt drei feste Zoomstufen: 100 %, 85 % und 70 %. Mausrad oder +/- ändern den sichtbaren Weltraum; HUD und Menüs bleiben in Originalgröße."],
["Multiplayer · Faire Gruppenquests", "Geteilter Questfortschritt zählt nur noch für Gruppenmitglieder in passender Reichweite und Instanz. Bei Bossen ist zusätzlich echte, aktuelle Kampfbeteiligung nötig."],
["Multiplayer · Einmalige Quests", "Quest-, Borin- und Welt-Event-Fortschritt kann beim Serverabgleich nicht mehr auf einen älteren Zustand zurückfallen. Abgeschlossene Aufgaben bleiben pro Charakter dauerhaft abgeschlossen."],
["Technik · Fusions-Lesemodell", "Fusions-Lookups, Impact-Profile und fehlende Quellen werden intern über ein separates Lesemodell ermittelt. Öffentliche Methoden und Spielverhalten bleiben unverändert."],
["Technik · Fusionszustand", "Angebotsprüfung, Verfügbarkeitsregeln und Slotwahl der Fusionen sind intern modularisiert. Bedienung, Saves, IDs und Kampfverhalten bleiben unverändert."],
["Dorf · Große Referenzgebäude", "Schmiede, Heilkapelle und Steinrose verwenden die neuen transparenten Referenzgrafiken. Die Arena ist deutlich größer und besitzt einen neuen Kampfplatz sowie eine größere Eingangshalle. Türen, Laufwege und Kollisionen sind auf den Heldenmaßstab abgestimmt."],
["Kristall · 528 Fusionen", "Alle eindeutigen Paare der 33 geeigneten Spells sind am Kristall sichtbar. Herstellbare Fusionen leuchten; gesperrte Rezepte nennen fehlende Spells, Level und Gold. Beide Quellen werden geopfert, die Fusion wird sofort ausgerüstet."],
["Atelier · Kopfschmuck und Abzeichen", "Roboter erhalten zehn unterschiedliche Kopfaufsätze. Zehn Brustabzeichen ersetzen den bisherigen Schmuck. Die Kosmetik wird mitgespeichert und im Mehrspieler synchronisiert; Umhänge bleiben hinter der Blickrichtung und folgen auch Rollen und Fallen."],
["Dorf · Brett und Laternen", "Das Schwarze Brett besitzt jetzt Holzmaserung und mehrere Aushänge. Alle Dorflaternen nutzen ein einheitliches warmes Licht, das nachts stärker sichtbar wird."],
["Atelier · Umhang-Layer", "Krieger-Umhänge werden jetzt richtungsabhängig gerendert: vorne hinter dem Körper, hinten über dem Rücken und seitlich mit sichtbarer Stoffkante. Der alte fest eingebaute braune Krieger-Umhang wurde entfernt; Kosmetik bleibt auch beim Sprung sichtbar."],
["Fusionen · Opferprinzip", "Beim Verschmelzen werden beide Ausgangsspells samt ihrer investierten Skillstufen dauerhaft geopfert. Der neue Fusionsspell wird automatisch in den frühesten möglichen aktiven Slot gelegt und ist sofort benutzbar."],
["Fusionen · Übersicht", "Der Verschmelzungskristall zeigt jetzt alle vier bekannten Fusionen dauerhaft an und nennt bei gesperrten Rezepten exakt die noch fehlenden Ausgangsattacken."],
["Atelier · Umhangform", "Die vier Umhänge liegen jetzt kompakt über Rücken und Schultern, enden vor den Füßen und besitzen je Blickrichtung eine schmalere, natürlichere Silhouette statt der bisherigen Rock-/Plattenform."],
["Skill-Items · BENUTZEN", "Arkankerne und andere Gegenstände mit Fähigkeitsfreischaltung besitzen im Inventar jetzt wieder einen aktiven BENUTZEN-Button und können ihre hinterlegte Fähigkeit lernen."],
["Atelier · Umhänge sichtbar", "Alle vier Umhangvarianten werden jetzt sichtbar gerendert. Der Umhang liegt hinter der Figur, besitzt einen sichtbaren Halsverschluss und Fennas Vorschau lässt sich nach links und rechts drehen."],
["Atelier · Umhänge & Farben", "Umhänge sitzen jetzt am Nacken hinter der Figur und reagieren auf Idle, Laufen, Sprint/Dash und Blickrichtung. Fennas Farbakzent bietet 20 Farbtöne für Frisur, Umhang und Schmuck."],
["Krieger · Sprunganimation LIVE", "Der männliche Menschen-Krieger der Morgenwache besitzt beim Ausweichen und beim Sturmsprung jetzt acht Blickrichtungen mit jeweils acht eigenen Bewegungsphasen."],
["Elara · Heilkapelle LIVE", "Elaras Map-0-Innenraum ist jetzt eine eigene 32px-Kapelle mit Mittelgang, Kirchenbänken, Podest, Altar, Alchemie-Nische, Lager und Kerzen. Das Heilungsfeld am Altar regeneriert HP/Energie und kann per E vollständig heilen."],
["Map 0 · Grünreste LIVE", "Die restlichen hellgrünen Bodenflecken wurden entfernt: Naturtextur, Grasbüschel, Blumenstiele, Grundstücks-Pads und statischer Chunk-Renderer verwenden jetzt dieselbe warme Herbstpalette."],
["Arkankern · Blitz LIVE", "Arkankern · Blitz ist jetzt ein echtes Attacken-Skill-Item: BENUTZEN lernt Blitzlanze auf Stufe 1 ohne Skillpunktkosten. Bereits gekaufte Kerne aus älteren Saves werden ebenfalls erkannt."],
["Map 0 · Ambiente LIVE", "Die komplette natürliche Bodenfläche von Sonnenhain nutzt jetzt die warmen orange-/rostfarbenen Ambiente-Sprites statt der bisherigen grünen Gras-, Moos- und Waldbodendarstellung. Wege und Pflaster bleiben unverändert."],
["Release · Produktion", "Golden-Sprite-Pilot und die Bereinigung der früheren separaten PvP-Großwelt sind für den Produktionsbuild freigegeben."],
["Grafik · Sprite-Pilot", "Menschlicher Krieger und Waldschleim nutzen erstmals echte 8-Richtungs-Idle-Sprites. Fehlende Bewegungs- und Kampfanimationen fallen weiterhin sicher auf den bisherigen Renderer zurück."],
["Welt · Bereinigung", "Die frühere separate PvP-Großkarte samt Weltgrafiken, Musik, Galerie und Spezialtests wurde entfernt; normale Oberwelt, Dungeons, Koop und Dorf-Arena bleiben erhalten."],
["Alma · Tastatur", "In Almas Rezept- und Kochlisten navigieren W/S jetzt hoch und runter; Pfeiltasten und Maus bleiben weiterhin nutzbar."],
["Runen · Wirkung", "Borins geskillte Runen wirken jetzt auf Krits, Lebensraub, Autoangriffe, Block, Notfallschutz, Regeneration, Bewegung, Cooldowns, Energie und Elektroketten. Gegnerbezogene Boni nutzen im Multiplayer die Runen des Angreifers."],
["Tränke & Kuchen", "Kleine Lebenstränke heilen 50% der maximalen HP, große 80%. Roter Sonnenkuchen füllt HP vollständig, Blauer Mondkuchen Mana vollständig; das Inventar zeigt die Wirkung korrekt."],
["Anmeldung · Tastatur", "Tab und Umschalt wechseln das Feld; Umschalt+Tab geht zurück. Großbuchstaben und Sonderzeichen bleiben im gewählten Feld. Funktioniert auch bei Registrierung und im Browser."],
["Händler · Sortiment", "Alle sieben Minuten kommen pro Händler drei rollengerechte Angebote hinzu. Bis 30 bleiben alte Waren kaufbar; danach ersetzen drei neue die ältesten drei. Zehn Seiten, Rotation und Sortiment werden gespeichert."],
["Spells", "K/HUD öffnet Fähigkeiten wieder überall: Lernen und Stufe 2–4 mit Skillpunkten. Borin ist dafür nicht erforderlich; gelernte Spells und Belegung bleiben erhalten."],
["Runen", "Borins Runenlehre ist getrennt von Spells und nutzt Essenzpunkte. Alle fünf Runenbäume werden für jede Klasse und Rasse vollständig im Multiplayer übertragen."],
["Bosshelme", "Alle drei Boss-Kopfbedeckungen sind für jede Klasse ausrüstbar; Inventarbutton und Server-Speichern nutzen dieselbe Regel. Alte Trophäen werden erkannt."],
["Händler", "Zehn vorbereitete Sortimente wechseln alle sieben Minuten ohne Wiederholung bis zum Umlaufende. Rotation und Restzeit bleiben gespeichert; Pip zeigt den Stand an."],
["NEU · Skillpunkte", "Jedes Level-Up vergibt jetzt +1 Skillpunkt zusätzlich zur Essenz. Bestehende Charaktere bekommen ihre bisherigen Level-Up-Punkte einmalig rückwirkend nachgetragen."],
["NEU · Fähigkeiten", "Normale gelernte Fähigkeiten folgen jetzt dem 4-Stufen-Prinzip: Stufe 1 gelernt; Stufen 2, 3 und 4 kosten jeweils 1 Skillpunkt und besitzen Level-Gates."],
["NEU · Multiplayer", "Fähigkeitsränge werden im Multiplayer auf Stufe 1–4 begrenzt und vom Server aus dem synchronisierten Skill-Rang übernommen statt dem Cast-Wert blind zu vertrauen."],
["NEU · Verschmelzung", "Sekundäreffekte von Damage-Fusionen entstehen am tatsächlichen Trefferpunkt. Flammenwirbel folgt dem Feuerball, Blitzkern der Blitzlanze und Eisball bleibt impactgebunden."],
["NEU · Fusionssystem", "Stabile Fusion-Keys, Save-Migration und serverseitige Multiplayer-Prüfung sind aktiv. Die universelle Regelbasis klassifiziert alle zulässigen Ausgangsskills."],
["NEU · Fusionsregeln", "Damage → DAMAGE_IMPACT_POSITION; Ziel/Markierung → TARGET_POSITION; Sprung → LANDING_POSITION; Schutz/Heilung → PLAYER_POSITION; Reaktion → ATTACKER_POSITION."],
["NEU · Fusionsränge", "Vier feste Stufen: Grundfusion; Signatur A; Signatur B; auf Rang 4 genau eine einzigartige Fusionsreaktion."],
["NEU · Kosten", "Verschmelzungen kosten nur Gold. Skillpunkte werden beim Verschmelzen nicht verbraucht; Ausgangsattacken bleiben erhalten."],
["NEU · Kopfrüstung", "Boss-Helme und Boss-Hüte sind klassenübergreifende Trophäen. Normale Klassen-Kopfbedeckungen bleiben klassengebunden."],
["NEU · Eisball", "Frostnova + Blitzlanze = Eisball: Slow; Blitzkette; Blitzstun; Rang 4 zusätzlich Eiswirbel."],
["Speichern", "Hybrid-Saves mit lokalem Stand, Serverstand und Backups; Recovery-Auswahl schützt vor stillem Überschreiben."],
["Accounts", "Account-Zuordnung und Sicherungen werden robuster; vorhandene Saves dürfen nicht mehr nur wegen fehlender Metadaten als leer gelten."],
["World Builder", "32px-Editor mit Boden, Wänden, Objekten, NPCs, Spawns, Triggern, Ambiente, Undo/Redo, Export und Map-Prüfung."],
["Map 0", "Die gesamte Bodenfläche wird als natives 32px-Tileraster aufgebaut; alte Grün-/Cobble-Overlays werden entfernt."],
["Gebäude", "Map-0-Häuser, Borins Haus und Arena wechseln vom alten Vollbild-Hausatlas auf native 32px-Tile-Komposition."],
["Dorf-Props", "Der alte Brunnen-Sprite wird entfernt; Map 0 nutzt jetzt einen eigenen nativen 32px-Tile-Brunnen ohne Legacy-Atlas-Fallback."],
["Essenz", "Borin lehrt jetzt fünf universelle Essenzbäume: Kampf, Durchhalten, Magie, Intelligenz und Elektro. Level 40 liefert maximal 40 von 100 möglichen Punkten; XP wird beim Skillen nicht verbraucht."],
["Magie", "Instabile Geschosse lässt Magier-Autoattacks ab Rang 1 im Flug erneut auslösen und kontrolliert detonieren; vier Ränge steigern Radius und Explosionswirkung."],
["Bücher", "Charaktergebundene Buchfortschritte sind als getrenntes System vorbereitet: Bücher können bis Rang 4 gelernt werden, aktive Buchplätze skalieren von 2 bis maximal 6 auf Level 40."],
["Audio", "Anziehbare Gegenstände spielen jetzt beim Ausrüsten und Ausziehen ein eigenes Ausrüstgeräusch; gilt für Waffen, Rüstung, Helme und Ringe."],
["Inventar", "Unverkäuflich markierte Items bleiben über Speichern/Login hinweg geschützt, werden nicht mit verkäuflichen Stapeln vermischt und im Inventar ausgegraut dargestellt."],
["Pip", "Pips Leihwaffe wird jetzt auf dem Ausleih-Level gespeichert. Nach dem nächsten Levelaufstieg fordert Pip sie mit fünf wechselnden Sprüchen zurück und nimmt ausschließlich sein eigenes Leih-Item."],
["Pip", "Wenn eine Rückgabe fällig ist, meldet sich Pip automatisch beim Ansprechen von Borin, da er direkt daneben steht; danach öffnet sich Borins Essenzlehre."],
["Pip", "Pip ist jetzt Borins Arkanhändler und verkauft Stäbe, Elementstäbe, Arkanroben, Fokusringe, Kristallreife und Arkankerne; seine Leihwaffen-Rolle bleibt erhalten."],
["Anmeldung", "Zu kurze Passwörter werden jetzt direkt im Formular rot markiert und mit Mindestlänge sowie aktuellem Zeichenstand angezeigt."],
["Alma", "Bei bereits gelernten Rezepten wird der funktionslose Lern-Button nicht mehr angezeigt; der Lernstatus bleibt nur als Kennzeichnung in der Liste sichtbar."],
["Fog of War", "Erkundung läuft über Regionsgrenzen hinweg; Gruppenmitglieder in derselben Weltinstanz teilen ihre Sicht."],
["Magier", "Risssprung auf Leertaste ersetzt Arkanen Schritt; Rissnova wird normaler Skill und Arkaner Sturm wird ab Level 40 freigeschaltet."],
["Menüs", "Login-Navigation per Tab/Shift+Tab; Spielmenü und Untermenüs erhalten konsistente Zurück-Navigation."],
["Audio", "Musik und Effekte erhalten eigene Mute-Schalter; eingestellte Lautstärken bleiben beim Stummschalten erhalten."],
["Patch-Ablauf", "Patch Notes sind ab jetzt Pflichtbestandteil jedes relevanten PRs; CI prüft, dass sie mit aktualisiert wurden."]]
## Ansicht: Liste nur mit Überschriften (neueste oben), Klick öffnet den
## vollen Text. Der Zustand liegt in main.gd als `patch_view`
## ({"open": Index oder -1, "scroll": erste sichtbare Zeile}).
const ROWS:=11
const ROW_TOP:=192.0
const ROW_H:=33.0
const LIST_RECT:=Rect2(160,ROW_TOP-4,820,ROWS*ROW_H)
const UP_RECT:=Rect2(160,560,44,32)
const DOWN_RECT:=Rect2(210,560,44,32)
const BACK_RECT:=Rect2(160,552,170,40)
const PREV_RECT:=Rect2(640,552,160,40)
const NEXT_RECT:=Rect2(810,552,160,40)

static func new_view()->Dictionary:return {"open":-1,"scroll":0}

## Bereich und Überschrift eines Eintrags. Ältere Einträge ohne eigene
## Überschrift bekommen den ersten Satz ihres Textes, gekürzt.
static func category(index:int)->String:
	return String(NOTES[index][0]).get_slice(" · ",0)

static func headline(index:int)->String:
	var title:=String(NOTES[index][0])
	if " · " in title:return title.substr(title.find(" · ")+3)
	var sentence:=String(NOTES[index][1]).get_slice(". ",0).trim_suffix(".")
	return sentence if sentence.length()<=72 else sentence.left(70).strip_edges()+"…"

static func max_scroll()->int:return maxi(0,NOTES.size()-ROWS)

static func row_rect(slot:int)->Rect2:
	return Rect2(LIST_RECT.position.x,ROW_TOP-4+slot*ROW_H,LIST_RECT.size.x,ROW_H-3)

## Eintrag unter der Maus in der Liste, sonst -1.
static func row_at(view:Dictionary,mouse:Vector2)->int:
	if int(view["open"])>=0:return -1
	for slot in ROWS:
		var index:=int(view["scroll"])+slot
		if index<NOTES.size() and row_rect(slot).has_point(mouse):return index
	return -1

static func scroll(view:Dictionary,delta:int)->void:
	if int(view["open"])>=0:return
	view["scroll"]=clampi(int(view["scroll"])+delta,0,max_scroll())

## Verarbeitet einen Klick; true, wenn er die Ansicht geändert hat.
static func click(view:Dictionary,mouse:Vector2)->bool:
	var open:=int(view["open"])
	if open>=0:
		if BACK_RECT.has_point(mouse):
			view["open"]=-1
			return true
		if PREV_RECT.has_point(mouse) and open>0:
			view["open"]=open-1
			return true
		if NEXT_RECT.has_point(mouse) and open<NOTES.size()-1:
			view["open"]=open+1
			return true
		return false
	var index:=row_at(view,mouse)
	if index>=0:
		view["open"]=index
		return true
	if UP_RECT.has_point(mouse):
		scroll(view,-ROWS)
		return true
	if DOWN_RECT.has_point(mouse):
		scroll(view,ROWS)
		return true
	return false

## Escape im Detailtext führt zurück zur Liste; true, wenn das passiert ist.
static func back(view:Dictionary)->bool:
	if int(view["open"])<0:return false
	view["open"]=-1
	return true

static func draw(g)->void:
	var BuildInfo=preload("res://components/build_info.gd")
	var view:Dictionary=g.patch_view
	var mouse:Vector2=g.get_viewport().get_mouse_position()
	g.text_at(Vector2(170,135),VERSION,25,Color("ffe2aa"))
	g.text_at(Vector2(760,135),"BUILD "+str(BuildInfo.SHORT),13,Color("b8cbc5"),HORIZONTAL_ALIGNMENT_RIGHT,190)
	var open:=int(view["open"])
	if open>=0:
		draw_detail(g,open)
		return
	g.text_at(Vector2(170,166),"Neueste zuerst · Eintrag anklicken für Details",14,Color("b8cbc5"))
	var first:=int(view["scroll"])
	for slot in ROWS:
		var index:=first+slot
		if index>=NOTES.size():break
		var rect:=row_rect(slot)
		var hovering:=rect.has_point(mouse)
		g.draw_rect(rect,Color("1b3b54",0.85) if hovering else Color("0d2236",0.55 if slot%2==0 else 0.25))
		if hovering:g.draw_rect(rect,Color("ffe0a0"),false,1.0)
		g.text_at(rect.position+Vector2(12,21),category(index),13,Color("c9a45e"),HORIZONTAL_ALIGNMENT_LEFT,180)
		g.text_at(rect.position+Vector2(200,21),headline(index),16,Color("fff1ce") if hovering else Color("e6eadf"),HORIZONTAL_ALIGNMENT_LEFT,560)
		g.text_at(rect.position+Vector2(rect.size.x-26,21),"›",18,Color("ffe0a0") if hovering else Color("7f8f8a"))
	g.ui_button(UP_RECT,"^",first>0)
	g.ui_button(DOWN_RECT,"v",first<max_scroll())
	var last:=mini(first+ROWS,NOTES.size())
	g.text_at(Vector2(270,582),"%d–%d von %d Einträgen · Mausrad blättert" % [first+1,last,NOTES.size()],13,Color("9fb4ac"))

static func draw_detail(g,index:int)->void:
	g.text_at(Vector2(170,170),category(index).to_upper(),14,Color("c9a45e"))
	var title:=String(NOTES[index][0])
	g.text_at(Vector2(170,200),title.substr(title.find(" · ")+3) if " · " in title else title,22,Color("ffe2aa"),HORIZONTAL_ALIGNMENT_LEFT,800)
	g.draw_rect(Rect2(170,214,800,2),Color("9d845e",0.7))
	g.draw_multiline_string(g.font,Vector2(170,250),String(NOTES[index][1]),HORIZONTAL_ALIGNMENT_LEFT,800,17,-1,Color("e6eadf"))
	g.ui_button(BACK_RECT,"< Zur Liste")
	g.ui_button(PREV_RECT,"< Neuer",index>0)
	g.ui_button(NEXT_RECT,"Älter >",index<NOTES.size()-1)
	g.text_at(Vector2(345,578),"Eintrag %d von %d" % [index+1,NOTES.size()],13,Color("9fb4ac"))
# Production deploy trigger: Map 0 terrain rework 2026-10-06
