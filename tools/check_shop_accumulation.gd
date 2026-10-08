extends SceneTree
class Game:
	extends "res://main.gd"
	func _ready()->void:pass
	func _draw()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
	func play_sound(_name:String)->void:pass
	func announce_multiplayer_context()->void:pass
func _initialize()->void:call_deferred("run")
func run()->void:
	var g=Game.new();root.add_child(g)
	g.character_created=true;g.player_uuid="shop-accumulation";g.level=20
	g.reset_class_skills()
	for q in g.QUESTS:g.quests.append({"state":0,"progress":0})
	for q in g.BORIN_QUESTS:g.borin_quests.append({"state":0,"progress":0})
	for e in g.WORLD_EVENTS:g.event_states.append(0);g.event_progress.append(0)
	var allowed={"smith":["sword","armor","head"],"arcane":["staff","armor","ring","head","essence","necklace"],"alchemy":["potion","herb","essence"],"merchant":["sword","staff","bow","armor","ring","food"]}
	for hero_class in 3:
		g.class_id=hero_class;g.shop_stock.clear();g.shop_rotation=-1
		for cycle in 23:
			var before:Dictionary=g.shop_stock.duplicate(true)
			g.refresh_shop_stock()
			for role in allowed:
				var stock:Array=g.shop_stock[role]
				assert(stock.size()==mini(30,(cycle+1)*3))
				assert(stock.all(func(offer):return offer["icon"] in allowed[role]))
				if cycle>0:
					var old:Array=before[role]
					assert(stock.slice(0,stock.size()-3)==old.slice(maxi(0,old.size()-27)))
			var captured:Dictionary=g.capture_save_data().duplicate(true)
			g.apply_save_data(captured,true)
			assert(g.shop_stock==captured["shop_stock"])
			assert(preload("res://components/server_save_store.gd").new().valid_data(g.capture_save_data(),g.player_uuid))
		for role in allowed:
			g.merchant_kind=role;g.shop_page=0;g.inventory.clear();g.gold=1000000
			for page in 9:g.click_shop(Vector2(890,165))
			assert(g.shop_page==9)
			g.click_shop(Vector2(890,165));assert(g.shop_page==9)
			for offer in g.shop_stock[role].slice(27):
				var gold_before:int=g.gold;g.buy_item(offer)
				assert(g.gold==gold_before-int(offer["price"]))
		g.pending_purchase=29;g.pending_purchase_item=g.shop_stock["arcane"][29].duplicate(true)
		g.refresh_shop_stock()
		assert(g.pending_purchase==-1 and g.pending_purchase_item.is_empty() and g.shop_page==0)
	# Legacy stocks stay available, and are bounded on load even if an old save exceeded the cap.
	var old_save:Dictionary=g.capture_save_data().duplicate(true)
	old_save["shop_stock"]["smith"].append_array(old_save["shop_stock"]["smith"].slice(0,6))
	g.apply_save_data(old_save,true);assert(g.shop_stock["smith"].size()==30)
	print("SHOP_ACCUMULATION_OK four merchant roles, three classes, 23 deliveries each; +3 to 30, FIFO replacement, reload, ten pages, last-page purchases, stale confirmations, legacy cap")
	g.queue_free();quit()
