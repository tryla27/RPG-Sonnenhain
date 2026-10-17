extends RefCounted
## Architektur-Set v2: Blender-Modelle für Mauern, Ecken, Endstücke, Torpfeiler
## und Ruinenbauteile sowie Felsen (in Godot gebaut) ersetzen die bisherigen Klötzchenmodelle derselben IDs.
## Erzeugt von tools/art_pipeline/build_architecture_v2.py; jedes Modell hat
## exakt die Begrenzung des alten Modells, Atlasplatz, Projektion, Sortierung
## und Kollision bleiben also gleich. Fehlt eine Datei, bleibt das alte Modell.
## Keine Spielregeln, keine Kollisionen.

const ROOT:="res://art/models/architecture_v2/"
const IDS:=["common-wall-01","common-wall-02","common-wall-03","common-wall-04","common-wall-05","common-wall-06",
	"map03-obj01","map03-obj02","map03-obj03","map03-obj04","map03-obj05","map11-obj04","map12-obj04","map12-obj05",
	# Felsen (17.10., tools/art_pipeline/build_rocks.gd): Moosfels, Säulenbasalt,
	# salzverwitterter Fels, Schieferstapel.
	"map01-obj05","map05-obj05","map06-obj04","map11-obj03"]
## Zum Vergleichen/Abschalten (z. B. in Prüfwerkzeugen).
static var enabled:=true

static func path_for(id:String)->String:
	return ROOT+id+".glb"

static func replaces(id:String)->bool:
	return enabled and id in IDS and ResourceLoader.exists(path_for(id))

## Szene des Bauteils oder null, wenn das alte Modell bleiben soll.
static func scene_for(id:String)->PackedScene:
	if not replaces(id):return null
	var scene:=load(path_for(id)) as PackedScene
	return scene
