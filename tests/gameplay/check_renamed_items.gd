extends SceneTree
# Umbenennungen vom 10.10.2026: Die alten Golem-Mobs heißen Wächter (der neue
# Endgegner ist der einzige Golem), die Kuchen heißen Rotkuchen und Blaukuchen.
# Alte Spielstände mit alten Kuchennamen werden beim Laden umbenannt.

const FoodSystem=preload("res://components/food_system.gd")

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("RENAMED_ITEMS_FAIL "+label)

func _initialize()->void:call_deferred("run")

func run()->void:
	var g=load("res://main.gd").new()
	for i in g.ENEMY_TYPES.size():
		var e:Dictionary=g.ENEMY_TYPES[i]
		# Nur der Endgegner (27) und seine Hälften (28) heißen Golem.
		if i in [27,28]:
			check(str(e["name"]).contains("Golem"),"Endgegner heißt Golem: %s" % e["name"])
			continue
		check(not str(e["name"]).to_lower().contains("golem"),"kein Mob heißt Golem: %s" % e["name"])
	var names:=[]
	for e in g.ENEMY_TYPES:names.append(str(e["name"]))
	for n in ["Steinwächter","Kristallwächter","Lavawächter"]:check(n in names,n+" vorhanden")
	check(not FoodSystem.by_name("Rotkuchen").is_empty() and not FoodSystem.by_name("Blaukuchen").is_empty(),"neue Kuchennamen")
	check(FoodSystem.by_name("Roter Sonnenkuchen")==FoodSystem.by_name("Rotkuchen"),"alter Name findet Rotkuchen")
	g.reset_class_skills()
	for i in g.WORLD_EVENTS.size():g.event_states.append(0);g.event_progress.append(0)
	for i in g.QUESTS.size():g.quests.append({"state":0,"progress":0})
	for i in g.BORIN_QUESTS.size():g.borin_quests.append({"state":0,"progress":0})
	g.character_created=true;g.player_uuid="cake"
	var data:Dictionary=g.capture_save_data()
	data["inventory"]=[{"uid":3,"name":"Roter Sonnenkuchen","icon":"food","rarity":1,"power":0,"count":2},{"uid":4,"name":"Blauer Mondkuchen","icon":"food","rarity":1,"power":0,"count":1}]
	data["next_uid"]=10
	var store=load("res://components/server_save_store.gd").new()
	check(store.valid_data(JSON.parse_string(JSON.stringify(data)),"cake"),"Server nimmt alten Stand an")
	g.apply_save_data(data)
	var inv_names:=[]
	for item in g.inventory:inv_names.append(str(item["name"]))
	check("Rotkuchen" in inv_names and "Blaukuchen" in inv_names,"Inventar umbenannt (%s)" % [inv_names])
	g.free()
	if failures>0:
		print("RENAMED_ITEMS_FAILED ",failures)
		quit(1)
		return
	print("RENAMED_ITEMS_OK guardians instead of golems, Rotkuchen/Blaukuchen with save migration")
	quit()
