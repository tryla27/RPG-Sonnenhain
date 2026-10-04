extends RefCounted
const VERSION="PATCH 04.10.2026"
const NOTES=[
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
