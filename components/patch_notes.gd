extends RefCounted
const VERSION="PATCH 06.10.2026"
const NOTES=[
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
static func draw(g)->void:
	var BuildInfo=preload("res://components/build_info.gd")
	g.text_at(Vector2(170,135),VERSION,25,Color("ffe2aa"))
	g.text_at(Vector2(760,135),"BUILD "+str(BuildInfo.SHORT),13,Color("b8cbc5"),HORIZONTAL_ALIGNMENT_RIGHT,210)
	g.text_at(Vector2(170,166),"Neueste Änderungen zuerst · Production-Build sichtbar",14,Color("b8cbc5"))
	var visible_count:=mini(10,NOTES.size())
	for i in visible_count:
		var y:float=198+i*38
		g.text_at(Vector2(170,y),NOTES[i][0],13,Color("ffe2aa"))
		g.text_at(Vector2(330,y),NOTES[i][1],11,Color("d8e6dc"),HORIZONTAL_ALIGNMENT_LEFT,640)
	g.text_at(Vector2(170,590),"%d weitere ältere Einträge im Patch-Verlauf." % maxi(0,NOTES.size()-visible_count),11,Color("9fb4ac"))
