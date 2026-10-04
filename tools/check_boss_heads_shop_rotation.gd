extends SceneTree
const Store=preload("res://components/server_save_store.gd")
class Game extends "res://main.gd":
	func _ready()->void:pass
	func _draw()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
func _initialize()->void:call_deferred("run")
func run()->void:
	var g:=Game.new()
	root.add_child(g)
	g.konflux_preview_mode=true;g.character_created=true;g.player_uuid="head-shop-regression"
	g.level=14;g.reset_class_skills()
	for q in g.QUESTS:g.quests.append({"state":0,"progress":0})
	for q in g.BORIN_QUESTS:g.borin_quests.append({"state":0,"progress":0})
	for e in g.WORLD_EVENTS:g.event_states.append(0);g.event_progress.append(0)
	var store:=Store.new()
	var folder:String=(OS.get_environment("TEMP") if OS.has_feature("windows") else "/tmp").path_join("head-shop-test-%d"%Time.get_ticks_usec())
	assert(store.configure(folder)==OK)
	var token:String="d".repeat(64)
	assert(store.open(901,token,g.player_uuid)["ok"])
	var revision:=0
	for hero_class in 3:
		g.class_id=hero_class;g.reset_class_skills()
		for boss_class in 3:
			g.inventory.clear();g.equipped_head_uid=-1
			var hat:Dictionary=g.class_boss_hat_item(boss_class)
			g.inventory=[hat]
			assert(g.inventory_item_usable(hat),"Inventory button enabled")
			g.selected_item=0;g.click_inventory(Vector2(700,550))
			assert(g.equipped_head_uid==hat["uid"] and g.head_visual()==boss_class)
			var data:Dictionary=g.capture_save_data().duplicate(true)
			assert(store.valid_data(data,g.player_uuid),"All nine class / boss hat combinations save")
			var saved:Dictionary=store.put(901,token,g.player_uuid,revision,"head-%d-%d"%[hero_class,boss_class],data)
			assert(saved["ok"]);revision=int(saved["revision"])
			g.apply_save_data(store.read_record(store.key_for(token))["data"])
			assert(g.equipped_head_uid==hat["uid"] and g.head_visual()==boss_class)
			g.inventory[0].erase("boss_hat")
			g.validate_equipment_slots()
			assert(g.equipped_head_uid==hat["uid"] and g.inventory[0]["boss_hat"],"Legacy named trophy repaired")
			g.click_inventory(Vector2(700,550));assert(g.equipped_head_uid==-1)
		g.inventory=[g.make_class_head(14)];g.equipped_head_uid=g.inventory[0]["uid"]
		g.class_id=(hero_class+1)%3
		assert(not g.inventory_item_usable(g.inventory[0]))
		assert(not store.valid_data(g.capture_save_data(),g.player_uuid),"Normal foreign class hats stay blocked")
		g.validate_equipment_slots();assert(g.equipped_head_uid==-1)
	g.class_id=1;g.reset_class_skills();g.inventory.clear();g.shop_rotation=-1;g.shop_stock.clear()
	var seen:Dictionary={}
	var first:Dictionary={}
	for cycle in 10:
		g.pending_purchase=0;g.pending_purchase_item={"name":"old"};g.shop_page=1
		g.refresh_shop_stock()
		assert(g.shop_rotation==cycle and g.pending_purchase==-1 and g.pending_purchase_item.is_empty() and g.shop_page==0)
		var signature:String=JSON.stringify(g.shop_stock["arcane"])
		assert(not seen.has(signature),"Ten unique Pip offers")
		seen[signature]=true
		if cycle==0:first=g.shop_stock.duplicate(true)
		var snapshot:Dictionary=g.capture_save_data().duplicate(true)
		g.apply_save_data(snapshot)
		assert(g.shop_rotation==cycle and g.shop_stock["arcane"]==snapshot["shop_stock"]["arcane"])
		assert(store.valid_data(g.capture_save_data(),g.player_uuid))
		g.gold=1000000;g.inventory.clear();g.merchant_kind="arcane"
		for offer in g.shop_stock["arcane"]:
			var before:int=g.gold;g.buy_item(offer)
			assert(g.gold==before-int(offer["price"]))
		assert(g.inventory.size()<=mini(30,(cycle+1)*3) and not g.inventory.is_empty())
		assert(store.valid_data(g.capture_save_data(),g.player_uuid),"Every rotating offer buys and saves")
		for owned in g.inventory:
			if owned["icon"]=="head":assert(owned["head_class"]==1 and g.inventory_item_usable(owned))
	g.refresh_shop_stock()
	assert(g.shop_rotation==0 and g.shop_stock["arcane"].slice(27)==first["arcane"],"Full stock retains nine batches and adds the new first batch")
	var legacy:Dictionary=g.capture_save_data().duplicate(true);legacy.erase("shop_rotation")
	g.apply_save_data(legacy);assert(g.shop_rotation==0)
	g.refresh_shop_stock();assert(g.shop_rotation==1)
	var bad:Dictionary=g.capture_save_data().duplicate(true)
	for value in [-2,10,1.5,"invalid"]:
		bad["shop_rotation"]=value;assert(not store.valid_data(bad,g.player_uuid))
	store.release(901)
	var file:String=store.filename(store.key_for(token))
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists(file+suffix):DirAccess.remove_absolute(file+suffix)
	DirAccess.remove_absolute(folder)
	print("BOSS_HEADS_SHOP_ROTATION_OK nine wearable/save/load combos, legacy trophies, normal class restriction, ten unique rotations, wrap, reload, growing stocks and purchases up to 30 offers, stale-confirm reset, schema")
	g.queue_free();quit()
