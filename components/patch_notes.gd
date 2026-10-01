extends RefCounted
const VERSION="PATCH 01.10.2026"
const NOTES=[
["Speichern", "Direkt im ersten Escape-Menü. Lokal- und Serverbestätigung werden getrennt angezeigt."],
["Spielstände", "Geprüfte lokale Schreibvorgänge, Rückfallkopie, Serverrevisionen und Wiederholungen."],
["Menüs", "3 animierte Fähigkeiten je Klasse; passende Vorschauwaffen; Spielmenü und Patch-Seite."],
["Multiplayer", "Healthbars, Schadensfeedback, Teleport-Sprung und gemeinsame Weltgegner."],
["Kampf", "Wandtreffer mit Effekten und Sound; Slime-/Käferbewegung; Turmboss mit zwei Wächtern."],
["Ausrüstung", "Kopfslot; zwei Magierringe nebeneinander und an beiden Händen; Arena-Basiswaffen."],
["Website", "Ein Passwortfeld für die gesamte Website; durchblätterbare Patch-Übersichten."],
["Spawn", "512px-Plattform auf 32px-Tiles, drei Stufen, breite Treppe und gemeinsamer Kollisionskern."],
["In Arbeit", "Neue Waffenpassive, Rüstungsteile, Umhänge und universelles Ausrüsten."],
["Noch ausstehend", "Gemeinsame Boden-Drops mit 6 Minuten Lebensdauer und sicherer Händler-Tausch."]]
static func draw(g)->void:
	g.text_at(Vector2(170,135),VERSION,25,Color("ffe2aa"))
	g.text_at(Vector2(170,166),"Alle Änderungen auf einer Seite · Stand und Planung",14,Color("b8cbc5"))
	for i in NOTES.size():
		var y:float=198+i*40
		g.text_at(Vector2(170,y),NOTES[i][0],14,Color("ffe2aa"))
		g.text_at(Vector2(330,y),NOTES[i][1],12,Color("d8e6dc"),HORIZONTAL_ALIGNMENT_LEFT,640)
