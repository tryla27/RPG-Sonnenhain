extends SceneTree
## Echte Charakteranlage, Kollision und gespeicherter Fortschritt des Einstiegs.
class Game extends "res://main.gd":
	func _ready()->void:super._ready()
	func _process(_delta:float)->void:pass
	func ensure_live_multiplayer()->void:pass
	func join_live_multiplayer()->void:pass
	func announce_multiplayer_context()->void:pass
	func save_game()->void:pass
	func play_sound(_name:String)->void:pass
	func play_world_sound(_name:String,_pos:Vector2)->void:pass
	func slot_save_path(_index:int,_testing:bool=false)->String:return "user://start-journey-disposable.json"

var failures:=0
var samples:=0
const Store=preload("res://components/local_save_store.gd")
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("START_JOURNEY_FAIL "+label)

func walk(g, route:Array)->void:
	for destination:Vector2 in route:
		var count:=ceili(g.player_pos.distance_to(destination)/8.0)+4
		for i in count:
			var remaining:Vector2=destination-g.player_pos
			if remaining.length()<0.1:break
			g.move_with_collision(remaining.limit_length(8.0))
			g.world_fog.update_from_game(g)
			samples+=1
		check(g.player_pos.distance_to(destination)<1.0,"Weg zu %s endet bei %s" % [destination,g.player_pos])

func _initialize()->void:call_deferred("run")
func run()->void:
	# Größter Körper, danach alle anderen Identitäten am Startpunkt.
	var g:=Game.new();root.add_child(g)
	g.pending_class=0;g.pending_race=1;g.pending_gender=0;g.creation_name="Wegprüfung"
	g.start_new_game();g.finish_intro()
	check(g.character_created and g.level==1 and g.inventory.is_empty(),"neuer Charakter ohne fremden Fortschritt")
	check(g.world_fog.explored_fraction()==0.0,"bestätigter dunkler Start")
	# Tatsächlicher Dorfweg, nicht die ältere geradlinige TRAILS-Abkürzung.
	walk(g,[Vector2(825,1136),Vector2(825,1408),Vector2(1648,1408),Vector2(1648,1184)])
	check(not g.opened_village_gates.has(Vector2(1780,1120)),"neuer Charakter: Osttor geschlossen")
	g.interact()
	check(g.opened_village_gates.has(Vector2(1780,1120)),"Osttor regulär per Aktion geöffnet")
	walk(g,[Vector2(1780,1120),Vector2(2250,1280),Vector2(2600,1740),Vector2(3150,2350)])
	check(g.region_at(g.player_pos)==1,"Blütenwiesen erreicht")
	walk(g,[Vector2(2990,2950),Vector2(2720,3550),Vector2(2900,4200),Vector2(3150,4780)])
	check(g.region_at(g.player_pos)==2,"Pilzwald erreicht")
	g.quests[0]={"state":1,"progress":2}
	for index in g.WAYSTONES.size():
		if g.region_at(g.WAYSTONES[index])==2:g.last_waystone=index
	var path:String=g.slot_save_path(1)
	check(Store.write(path,g.capture_save_data())==OK,"Spielstand auf Datenträger geschrieben")
	var saved:Dictionary=Store.read(path)
	check(not saved.is_empty(),"Spielstand vom Datenträger gelesen")
	var restored:=Game.new();root.add_child(restored);restored.reset_character_state();restored.apply_save_data(saved)
	check(restored.player_pos.distance_to(g.player_pos)<1.0,"Position nach Laden")
	check(restored.level==1 and restored.last_waystone==g.last_waystone,"Empfehlungslevel verändert weder Level noch letzten Wegstein")
	check(int(restored.quests[0].get("state",-1))==int(g.quests[0]["state"]) and int(restored.quests[0].get("progress",-1))==int(g.quests[0]["progress"]),"Questfortschritt nach Laden: %s / %s" % [restored.quests[0],g.quests[0]])
	check(restored.opened_village_gates.has(Vector2(1780,1120)),"geöffnetes Tor nach Laden")
	check(restored.world_fog.explored_world(Vector2(2250,1280)) and restored.world_fog.explored_world(Vector2(3150,4780)),"besuchte Gebiete nach Laden sichtbar")
	# Dorfstein und tatsächlich versiegelte Gebiete unterscheiden sich von
	# bloßen Level-Empfehlungen. Alle Prüfungen durchlaufen JSON auf Datenträger.
	var village_save:Dictionary=saved.duplicate(true)
	village_save["last_waystone"]=0
	check(Store.write(path,village_save)==OK,"Dorfstein gespeichert")
	restored.reset_character_state();restored.apply_save_data(Store.read(path))
	check(restored.last_waystone==0,"Dorfstein bleibt nach Laden Dorfstein")
	var sealed_index:=-1
	for index in g.WAYSTONES.size():
		if not g.region_available(g.region_at(g.WAYSTONES[index])):
			sealed_index=index;break
	check(sealed_index>=0,"versiegeltes Gebiet als Gegenprobe vorhanden")
	if sealed_index>=0:
		var sealed:Dictionary=saved.duplicate(true)
		var stone:Vector2=g.WAYSTONES[sealed_index]
		sealed["position"]=[stone.x,stone.y];sealed["last_waystone"]=sealed_index
		check(Store.write(path,sealed)==OK,"versiegelten Standort gespeichert")
		restored.reset_character_state();restored.apply_save_data(Store.read(path))
		check(restored.region_at(restored.player_pos)==0 and restored.last_waystone==0,"versiegeltes Gebiet führt sicher ins Dorf")
		check(Store.write(path,restored.capture_save_data())==OK,"sicheren Rückfall erneut gespeichert")
		restored.reset_character_state();restored.apply_save_data(Store.read(path))
		check(restored.last_waystone==0,"sicherer Rückfall bleibt bei zweitem Laden erhalten")
	# Fusionen über denselben Speicher-/Ladepfad prüfen, einschließlich einer
	# erneuten Speicherung und dem folgenden Wechsel zum frischen Charakter.
	var fusion_save:Dictionary=saved.duplicate(true)
	fusion_save["class_id"]=1;fusion_save["level"]=30
	fusion_save["learned_fusions"]={"17:18":{"fusion_id":43,"rank":3}}
	check(Store.write(path,fusion_save)==OK,"Fusion gespeichert")
	for cycle in 2:
		restored.reset_character_state();restored.apply_save_data(Store.read(path))
		check(int(restored.learned_fusions.get("17:18",{}).get("rank",0))==3 and restored.learned[43] and int(restored.skill_levels[43])==3,"Fusionsrang nach Ladezyklus %d" % cycle)
		check(Store.write(path,restored.capture_save_data())==OK,"Fusion erneut gespeichert")
	restored.pending_class=0;restored.start_new_game();restored.finish_intro()
	check(restored.learned_fusions.is_empty() and restored.fusion_history.is_empty() and not restored.learned[43],"neuer Charakter übernimmt keine Fusion")
	walk(g,[Vector2(2900,4200),Vector2(2720,3550),Vector2(2990,2950),Vector2(3150,2350),Vector2(2600,1740),Vector2(2250,1280),Vector2(1780,1120),Vector2(1648,1184),Vector2(1648,1408),Vector2(825,1408),Vector2(825,1136)])
	check(g.region_at(g.player_pos)==0,"Rückweg ins Dorf")
	for cls in 3:
		for race in 3:
			for gender in 2:
				g.pending_class=cls;g.pending_race=race;g.pending_gender=gender;g.start_new_game();g.finish_intro()
				walk(g,[Vector2(825,1136)])
				check(g.quests[0]["progress"]==0,"Charakteranlage löscht fremde Questwerte")
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists(path+suffix):DirAccess.remove_absolute(path+suffix)
	g.queue_free();restored.queue_free()
	print("START_JOURNEY samples=",samples," failures=",failures)
	quit(1 if failures else 0)
