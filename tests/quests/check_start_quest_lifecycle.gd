extends SceneTree
## Reguläre Mira-Interaktion und Klassenangriffe; kein Ersatz für Balance-Spieltests.
class Game extends "res://main.gd":
	func _process(_delta:float)->void:pass
	func ensure_live_multiplayer()->void:pass
	func join_live_multiplayer()->void:pass
	func announce_multiplayer_context()->void:pass
	func save_game()->void:pass
	func play_sound(_name:String)->void:pass
	func play_world_sound(_name:String,_pos:Vector2)->void:pass
	func slot_save_path(_index:int,_testing:bool=false)->String:return "user://quest-lifecycle-disposable.json"

const Store=preload("res://components/local_save_store.gd")
var failures:=0
var attacks:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("START_QUEST_FAIL "+label)

func talk_to_mira(g)->void:
	g.player_pos=g.village_house_door(g.village_house("Mira"))+Vector2(0,48)
	g.interact()
	check(g.interior_id==g.VillageInteriors32.id_for_name("Mira"),"Ratshalle über Haustür betreten")
	g.player_pos=g.INTERIOR_CENTER+g.VillageInteriors32.actor_offset(g.interior_id,"Mira")+Vector2(0,64)
	check(str(g.nearby_interior_actor().get("name",""))=="Mira","Mira als Interaktionsziel")
	g.interact()
	g.player_pos=g.INTERIOR_CENTER+g.VillageInteriors32.exit_offset(g.interior_id)
	g.interact()
	check(g.interior_id==-1 and g.region_at(g.player_pos)==0,"Ratshalle über Ausgang verlassen")

func defeat_with_normal_attacks(g,type:int)->void:
	g.enemies.clear();g.projectiles.clear()
	g.player_pos=Vector2(2250,1280);g.facing=Vector2.RIGHT
	g.enemies.append(g.make_enemy(type,g.player_pos+Vector2(60,0)))
	for attempt in 100:
		if g.enemies.is_empty():break
		# Gegner bleibt für die Trefferprüfung stehen. KI und Kampf-Balance
		# werden separat geprüft; Schaden stammt aus dem echten Klassenangriff.
		g.enemies[0]["pos"]=g.player_pos+Vector2(60,0)
		g.attack_timer=0.0
		g.normal_attack();attacks+=1
		for frame in 15:g.update_projectiles(1.0/60.0)
	check(g.enemies.is_empty(),"Klasse %d besiegt Gegner %d mit regulärem Angriff" % [g.class_id,type])

func reload_from_disk(g,path:String)->void:
	check(Store.write(path,g.capture_save_data())==OK,"Queststand auf Datenträger geschrieben")
	var data:Dictionary=Store.read(path)
	check(not data.is_empty(),"Queststand vom Datenträger gelesen")
	g.reset_character_state();g.apply_save_data(data)

func _initialize()->void:call_deferred("run")
func run()->void:
	seed(120102026)
	var g:=Game.new();root.add_child(g)
	var path:String=g.slot_save_path(1)
	for cls in 3:
		g.pending_class=cls;g.pending_race=0;g.pending_gender=0;g.creation_name="Questprüfung"
		g.start_new_game();g.finish_intro()
		for quest_index in 2:
			talk_to_mira(g)
			check(int(g.quests[quest_index]["state"])==1,"Auftrag %d regulär angenommen" % quest_index)
			var target:int=int(g.QUESTS[quest_index]["target"])
			var goal:int=int(g.QUESTS[quest_index]["count"])
			for count in goal:
				defeat_with_normal_attacks(g,target)
				check(int(g.quests[quest_index]["progress"])==count+1,"ein Abschuss zählt genau einmal")
				if count==goal/2:
					reload_from_disk(g,path)
					check(int(g.quests[quest_index]["state"])==1 and int(g.quests[quest_index]["progress"])==count+1,"Teilfortschritt nach Relog erhalten")
			check(int(g.quests[quest_index]["state"])==2,"Auftrag abgabebereit")
			reload_from_disk(g,path)
			check(int(g.quests[quest_index]["state"])==2,"abgabebereit nach Relog")
			var gold_before:int=g.gold
			var items_before:int=g.inventory.size()
			talk_to_mira(g)
			check(int(g.quests[quest_index]["state"])==3,"Auftrag abgeschlossen")
			check(g.gold==gold_before+int(g.QUESTS[quest_index]["gold"]),"Goldbelohnung genau einmal")
			check(g.inventory.size()==items_before+1,"Gegenstandsbelohnung genau einmal")
			check(str(g.inventory[-1]["name"])==str(g.QUESTS[quest_index]["reward"]),"richtige Gegenstandsbelohnung")
			if quest_index==0:check(str(g.inventory[-1]["icon"])==g.class_weapon_icon(),"Waffenbelohnung passt zur Klasse")
			reload_from_disk(g,path)
			check(int(g.quests[quest_index]["state"])==3 and g.gold==gold_before+int(g.QUESTS[quest_index]["gold"]) and g.inventory.size()==items_before+1,"Abschluss und Belohnung nach Relog erhalten")
			g.quest_dialogue("Mira")
			check(g.gold==gold_before+int(g.QUESTS[quest_index]["gold"]) and g.inventory.size()==items_before+1,"erneutes Gespräch dupliziert keine Belohnung")
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists(path+suffix):DirAccess.remove_absolute(path+suffix)
	g.queue_free()
	print("START_QUEST_LIFECYCLE attacks=",attacks," failures=",failures)
	quit(1 if failures else 0)
