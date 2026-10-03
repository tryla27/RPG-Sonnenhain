extends RefCounted
const VERSION="PATCH 03.10.2026"
const NOTES=[
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
["Fog of War", "Erkundung läuft über Regionsgrenzen hinweg; Gruppenmitglieder in derselben Weltinstanz teilen ihre Sicht."],
["Magier", "Risssprung auf Leertaste ersetzt Arkanen Schritt; Rissnova wird normaler Skill und Arkaner Sturm wird ab Level 40 freigeschaltet."],
["Menüs", "Login-Navigation per Tab/Shift+Tab; Spielmenü und Untermenüs erhalten konsistente Zurück-Navigation."],
["Audio", "Musik und Effekte erhalten eigene Mute-Schalter; eingestellte Lautstärken bleiben beim Stummschalten erhalten."],
["Patch-Ablauf", "Patch Notes sind ab jetzt Pflichtbestandteil jedes relevanten PRs; CI prüft, dass sie mit aktualisiert wurden."]]
static func draw(g)->void:
	g.text_at(Vector2(170,135),VERSION,25,Color("ffe2aa"))
	g.text_at(Vector2(170,166),"Alle Änderungen auf einer Seite · Stand und Planung",14,Color("b8cbc5"))
	for i in NOTES.size():
		var y:float=198+i*40
		g.text_at(Vector2(170,y),NOTES[i][0],14,Color("ffe2aa"))
		g.text_at(Vector2(330,y),NOTES[i][1],12,Color("d8e6dc"),HORIZONTAL_ALIGNMENT_LEFT,640)
