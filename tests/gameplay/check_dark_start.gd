extends SceneTree
# C1 Start im Dunkeln: Neuer Charakter sieht nur 20 m (640 px) um sich, auch im
# Dorf. Aufgedecktes bleibt über Speichern und Laden, alte grobe Spielstände
# werden umgerechnet, und der Server nimmt den neuen Nebel an.

const WorldFog=preload("res://components/world_fog.gd")
const ServerSaveStore=preload("res://components/server_save_store.gd")

class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("DARK_START_FAIL "+label)

func _initialize()->void:call_deferred("run")

func run()->void:
	var spawn:=Vector2(825,1020)
	var g:=Game.new()
	g.reset_class_skills()
	g.world_fog.configure(g.WORLD)
	g.world_fog.clear()
	g.player_pos=spawn
	g.character_created=true
	check(g.world_fog.explored_fraction()==0.0,"Start: alles dunkel")
	check(not g.world_fog.explored_world(Vector2(1700,1020)),"Dorf ist am Anfang dunkel")
	g.world_fog.update_from_game(g)
	check(g.world_fog.explored_world(spawn+Vector2(600,0)),"20 m Sicht: 600 px aufgedeckt")
	check(g.world_fog.explored_world(spawn+Vector2(0,-420).rotated(0.7)),"Sicht ist rund")
	check(not g.world_fog.explored_world(spawn+Vector2(800,0)),"25 m bleibt dunkel")
	check(g.world_fog.corner_dark(g.world_fog.world_cell(spawn).x,g.world_fog.world_cell(spawn).y)==0.0,"um den Spieler keine Dunkelheit")

	# Weggehen: Der alte Ort bleibt aufgedeckt (dauerhaft).
	g.player_pos=spawn+Vector2(2000,0)
	g.world_fog.update_from_game(g)
	check(g.world_fog.explored_world(spawn) and g.world_fog.explored_world(spawn+Vector2(2000,0)),"aufgedeckt bleibt aufgedeckt")

	# Speichern und Laden.
	var data:Dictionary=g.capture_save_data()
	check(data.get("world_fog_fine","") is String and String(data["world_fog_fine"]).length()<16384,"feiner Nebel als Text gespeichert")
	check((data.get("world_fog",[]) as Array).size()<=512,"altes Feld bleibt klein")
	check(WorldFog.valid_snapshot(data["world_fog_fine"],g.WORLD),"Server-Prüfung: gültig")
	check(not WorldFog.valid_snapshot("AAAA",g.WORLD) and not WorldFog.valid_snapshot(12,g.WORLD),"Server-Prüfung: Unsinn abgelehnt")
	var h:=Game.new()
	h.reset_class_skills()
	for i in h.WORLD_EVENTS.size():
		h.event_states.append(0)
		h.event_progress.append(0)
	for i in h.QUESTS.size():h.quests.append({"state":0,"progress":0})
	for i in h.BORIN_QUESTS.size():h.borin_quests.append({"state":0,"progress":0})
	h.apply_save_data(data)
	check(h.world_fog.explored_world(spawn) and h.world_fog.explored_world(spawn+Vector2(2000,0)),"nach dem Laden aufgedeckt")
	check(not h.world_fog.explored_world(spawn+Vector2(1000,1500)),"nach dem Laden Rest dunkel")

	# Alter Spielstand (256-px-Raster, nur das Feld world_fog): wird umgerechnet.
	var legacy:Array=[]
	legacy.resize(300);legacy.fill(0)
	var legacy_cols:=ceili(g.WORLD.x/256.0)
	var cell:=Vector2i(20,10)
	var index:=cell.y*legacy_cols+cell.x
	legacy[index>>3]=1<<(index&7)
	var old_fog:=WorldFog.new()
	old_fog.restore(legacy,g.WORLD,"")
	check(old_fog.explored_world(Vector2(20*256+10,10*256+10)) and old_fog.explored_world(Vector2(21*256-10,11*256-10)),"alter Stand: Zelle ganz aufgedeckt")
	check(not old_fog.explored_world(Vector2(22*256,10*256)),"alter Stand: Nachbar dunkel")
	check(old_fog.legacy_snapshot()==legacy,"alter Stand: grobes Feld unverändert zurück")

	# Gruppe: nur wer in der Nähe ist, deckt mit auf.
	g.world_fog.clear()
	g.player_pos=spawn
	g.party_state={"members":[
		{"uuid":"nah","context":"world","instance_id":"world","pos":[spawn.x+1200,spawn.y]},
		{"uuid":"fern","context":"world","instance_id":"world","pos":[9000.0,6000.0]}]}
	g.world_fog.update_from_game(g)
	check(g.world_fog.explored_world(spawn+Vector2(1700,0)),"Gruppe nah deckt auf")
	check(not g.world_fog.explored_world(Vector2(9000,6000)),"Gruppe fern deckt nicht auf")

	g.free();h.free()
	if failures>0:
		print("DARK_START_FAILED ",failures)
		quit(1)
		return
	print("DARK_START_OK dark start incl. village, 640 px sight, permanent, saved, legacy converted, party only nearby")
	quit()
