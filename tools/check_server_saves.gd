extends SceneTree
const Store = preload("res://components/server_save_store.gd")
class TestGame:
	extends "res://main.gd"
	func _ready(): pass
	func _process(_delta): pass
	func _draw(): pass
	func save_game(): pass
func _initialize(): call_deferred("run")
func run():
	var g = TestGame.new()
	root.add_child(g)
	g.konflux_preview_mode = true
	g.character_created = true
	g.player_uuid = "save-test"
	g.hero_name = "Speichertest"
	g.class_id = 1
	g.reset_class_skills()
	for q in g.QUESTS: g.quests.append({"state":0,"progress":0})
	for e in g.WORLD_EVENTS:
		g.event_states.append(0)
		g.event_progress.append(0)
	g.add_item(g.make_item("Ring A","ring",1,9,10))
	g.add_item(g.make_item("Ring B","ring",1,13,10))
	var baseline: float = g.max_hp()
	assert(g.toggle_equipment_item(0) and g.toggle_equipment_item(1))
	assert(g.equipped_ring_uid != g.equipped_ring2_uid and g.equipped_ring2_uid >= 0)
	assert(g.max_hp() >= baseline+22 and g.is_equipped_uid(g.equipped_ring2_uid))
	g.add_item(g.make_item("Frosthalskette","necklace",2,0,20))
	g.toggle_equipment_item(2)
	var data: Dictionary = g.capture_save_data()
	assert(data["equipped_necklace_uid"]==g.equipped_necklace_uid and data["inventory"][2]["power"]==0)
	var store = Store.new()
	var directory := OS.get_environment("TEMP").path_join("sonnenhain-save-test-"+str(Time.get_ticks_usec())) if OS.has_feature("windows") else "/tmp/sonnenhain-save-test-"+str(Time.get_ticks_usec())
	assert(store.configure(directory) == OK)
	var token := "a".repeat(64)
	assert(store.valid_data(data,g.player_uuid))
	assert(store.open(2,token,g.player_uuid)["revision"] == 0)
	assert(store.open(3,token,g.player_uuid)["error"] == "already_online")
	assert(store.put(3,token,g.player_uuid,0,"unauthorized",data)["error"] == "unauthorized")
	assert(store.put(2,token,g.player_uuid,0,"write1",data)["revision"] == 1)
	assert(store.put(2,token,g.player_uuid,0,"write1",data)["revision"] == 1)
	assert(store.put(2,token,g.player_uuid,0,"stale",data)["error"] == "revision_conflict")
	data["gold"] = 23456
	assert(store.put(2,token,g.player_uuid,1,"write2",data)["revision"] == 2)
	var reloaded = Store.new()
	assert(reloaded.configure(directory) == OK)
	var opened: Dictionary = reloaded.open(4,token,g.player_uuid)
	assert(opened["revision"] == 2 and opened["data"]["gold"] == 23456)
	g.apply_save_data(opened["data"],true)
	assert(g.inventory.size() == 3 and g.equipped_necklace_uid>=0 and g.equipped_ring2_uid >= 0 and g.max_hp() >= baseline+22)
	var invalid: Dictionary = data.duplicate(true)
	invalid["inventory"][1]["uid"] = invalid["inventory"][0]["uid"]
	assert(not store.valid_data(invalid,g.player_uuid))
	invalid = data.duplicate(true)
	invalid["class_id"] = 0
	assert(not store.valid_data(invalid,g.player_uuid))
	invalid = data.duplicate(true)
	invalid["position"] = [NAN,5]
	assert(not store.valid_data(invalid,g.player_uuid))
	invalid = data.duplicate(true)
	invalid["slots"] = [0,0,-1]
	invalid["learned"][0] = true
	assert(not store.valid_data(invalid,g.player_uuid))
	invalid = data.duplicate(true)
	invalid["learned"][40] = true
	assert(not store.valid_data(invalid,g.player_uuid))
	# Relikt-Meisterschaft ist questunabhängig, aber Arkaner Schritt bleibt Magier-exklusiv.
	invalid = data.duplicate(true)
	invalid["class_id"] = 0
	invalid["class_mastery_unlocked"] = true
	invalid["arcane_step_learned"] = true
	assert(not store.valid_data(invalid,g.player_uuid))
	invalid = data.duplicate(true)
	invalid["class_mastery_unlocked"] = true
	invalid["arcane_step_learned"] = false
	assert(not store.valid_data(invalid,g.player_uuid))
	var valid_mastery:Dictionary=data.duplicate(true)
	valid_mastery["class_mastery_unlocked"] = true
	valid_mastery["arcane_step_learned"] = true
	assert(store.valid_data(valid_mastery,g.player_uuid))
	invalid = data.duplicate(true)
	invalid["oversize"] = "x".repeat(262145)
	assert(not store.valid_data(invalid,g.player_uuid))
	assert(reloaded.open(5,token,"wrong-character")["error"] == "already_online")
	reloaded.release(4)
	assert(reloaded.open(5,token,"wrong-character")["error"] == "identity_mismatch")
	var filename: String = store.filename(store.key_for(token))
	var file := FileAccess.open(filename,FileAccess.WRITE)
	file.store_string("broken"); file.close()
	assert(reloaded.open(5,token,g.player_uuid)["revision"] == 1)
	file = FileAccess.open(filename+".bak",FileAccess.WRITE)
	file.store_string("broken"); file.close()
	assert(reloaded.put(5,token,g.player_uuid,1,"blocked",data)["error"] == "corrupt")
	assert(FileAccess.get_file_as_string(filename) == "broken")
	var unavailable = Store.new()
	unavailable.directory = directory.path_join("missing/subdirectory")
	assert(unavailable.open(6,token,g.player_uuid)["ok"])
	assert(unavailable.put(6,token,g.player_uuid,0,"diskfail",data)["error"] == "disk_error")
	g.class_id = 0
	g.validate_equipment_slots()
	assert(g.equipped_ring2_uid == -1)
	print("SERVER_SAVES_OK: rings, reload, deduplication, stale/foreign writes, invalid skill/class consistency/oversize data, backup recovery, corruption and disk failure")
	g.queue_free()
	quit()
