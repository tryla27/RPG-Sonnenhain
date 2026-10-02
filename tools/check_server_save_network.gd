extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var g = load("res://main.gd").new()
	g.name = "Sonnenhain"
	g.konflux_preview_mode = true
	root.add_child(g)
	g.set_process(false)
	g.set_process_input(false)
	g.character_created = true
	g.player_uuid = "network-save-test"
	g.hero_name = "Netztest"
	g.class_id = 1
	g.gold = 34567
	g.add_item(g.make_item("Netzring A","ring",1,11,10))
	g.add_item(g.make_item("Netzring B","ring",1,17,10))
	g.toggle_equipment_item(g.inventory.size()-2)
	g.toggle_equipment_item(g.inventory.size()-1)
	g.add_item(g.make_class_head(40))
	g.toggle_equipment_item(g.inventory.size()-1)
	assert(g.head_visual()==1)
	var peer := WebSocketMultiplayerPeer.new()
	assert(peer.create_client(g.command_arg_value("--save-test-url=","ws://127.0.0.1:31876")) == OK)
	g.multiplayer.multiplayer_peer = peer
	g.network_mode = "client"
	var deadline := Time.get_ticks_msec()+12000
	while peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		if Time.get_ticks_msec() > deadline: quit(2); return
		await process_frame
	g.server_save.uuid = g.player_uuid
	g.server_save.token = "b".repeat(64)
	g.server_save.latest = g.capture_save_data()
	g.server_save.dirty = true
	g.rpc_zz_save_open.rpc_id(1,g.server_save.token,g.player_uuid)
	while g.server_save.revision < 1 or not g.server_save.ready or g.server_save.dirty:
		g.server_save.update(g)
		if Time.get_ticks_msec() > deadline:
			push_error(g.server_save.status); quit(3); return
		await process_frame
	assert(g.gold in [34567,34568] and g.equipped_ring2_uid >= 0)
	var initial_revision: int = g.server_save.revision
	# Existing public fixture may predate the head slot: equip after download.
	if g.head_visual()!=1:
		g.add_item(g.make_class_head(40))
		g.toggle_equipment_item(g.inventory.size()-1)
	# Every run must also persist a fresh revision, even if a previous test snapshot exists.
	g.gold = 34568
	var has_food:=false
	for owned in g.inventory:
		if owned.get("name")=="Heidelbeeren":has_food=true
	if not has_food: g.add_item(g.make_item("Heidelbeeren","food",0,0,4,"",1))
	g.food_system.configure(g)
	var food_plant:Vector2=g.food_system.plants[0]["point"]
	g.food_system.harvested[g.FoodSystem.key(food_plant)]=Time.get_unix_time_from_system()+300
	g.food_system.regen_rate=2.0
	g.food_system.regen_until=Time.get_unix_time_from_system()+30
	# Current multiplayer save must also preserve regional herbs, learned Alma recipes and long meals.
	var herb_info:Dictionary=g.FoodSystem.herb_for_region(1)
	var has_regional_herb:=false
	for owned in g.inventory:
		if str(owned.get("name",""))==str(herb_info["name"]):has_regional_herb=true
	if not has_regional_herb:
		g.add_item(g.make_item(str(herb_info["name"]),"herb",0,0,3,"",1))
	g.steinrose.learned[1]=true
	g.food_system.active_food_name="Nebelpflaumen-Tee"
	g.food_system.meal_hp_regen=2.0
	g.food_system.meal_mana_regen=0.0
	g.food_system.meal_until=Time.get_unix_time_from_system()+360
	g.food_system.buff_kind="move"
	g.food_system.buff_value=0.05
	g.food_system.buff_until=g.food_system.meal_until
	g.server_save.latest = g.capture_save_data()
	g.server_save.dirty = true
	while g.server_save.revision <= initial_revision or g.server_save.dirty:
		g.server_save.flush(g)
		if Time.get_ticks_msec() > deadline: quit(6); return
		await process_frame
	initial_revision = g.server_save.revision
	# Real connection loss; reopen against persisted snapshot and private capability.
	peer.close()
	g.server_save.disconnected()
	await create_timer(0.4).timeout
	peer = WebSocketMultiplayerPeer.new()
	peer.create_client(g.command_arg_value("--save-test-url=","ws://127.0.0.1:31876"))
	g.multiplayer.multiplayer_peer = peer
	g.network_mode = "client"
	while peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		if Time.get_ticks_msec() > deadline: quit(4); return
		await process_frame
	g.gold = 1
	g.equipped_ring2_uid = -1
	g.equipped_head_uid = -1
	g.server_save.latest = g.capture_save_data()
	g.server_save.dirty = false
	g.rpc_zz_save_open.rpc_id(1,g.server_save.token,g.player_uuid)
	while not g.server_save.ready:
		if Time.get_ticks_msec() > deadline: quit(5); return
		await process_frame
	assert(g.head_visual()==1)
	assert(g.gold == 34568 and g.equipped_ring2_uid >= 0 and g.server_save.revision == initial_revision)
	var found_food:=false
	for owned in g.inventory:
		if owned.get("name")=="Heidelbeeren" and owned.get("icon")=="food":found_food=true
	assert(found_food and not g.food_system.ready_at(food_plant,Time.get_unix_time_from_system()))
	assert(g.food_system.regen_rate==2.0)
	var found_regional_herb:=false
	for owned in g.inventory:
		if str(owned.get("name",""))==str(herb_info["name"]) and str(owned.get("icon",""))=="herb":found_regional_herb=true
	assert(found_regional_herb)
	assert(g.steinrose.learned[1])
	assert(g.food_system.active_food_name=="Nebelpflaumen-Tee")
	assert(g.food_system.meal_hp_regen==2.0 and g.food_system.buff_kind=="move")
	assert(g.food_system.meal_remaining()>300)
	print("SERVER_SAVE_NETWORK_OK: regional herb, Alma recipe, six-minute meal, harvest timers, real WebSocket upload/acknowledgment, reconnect and server download revision=",initial_revision)
	peer.close()
	g.queue_free()
	await process_frame
	await process_frame
	quit()
