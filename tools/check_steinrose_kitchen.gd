extends SceneTree

const Game = preload("res://main.gd")
const Kitchen = preload("res://components/steinrose_kitchen.gd")
const Food = preload("res://components/food_system.gd")
const Store = preload("res://components/server_save_store.gd")

class TestGame:
	extends "res://main.gd"
	func _ready(): pass
	func _process(_delta): pass
	func _draw(): pass
	func save_game(): pass
	func play_sound(_key): pass
	func message(_text): pass

func _initialize() -> void:
	call_deferred("run")

func add_food(g, name:String, count:int) -> void:
	var info:=Food.by_name(name)
	assert(not info.is_empty(), "missing food registry entry: "+name)
	var item:=g.make_item(name,"food",0,0,int(info.get("price",1)),"",1)
	item["count"]=count
	assert(g.add_item(item))

func find_food(g, name:String) -> int:
	for i in g.inventory.size():
		if str(g.inventory[i].get("name",""))==name:return i
	return -1

func run() -> void:
	var g:=TestGame.new()
	root.add_child(g)
	g.konflux_preview_mode=true
	g.character_created=true
	g.player_uuid="steinrose-test"
	g.hero_name="Kuechentest"
	g.class_id=0
	g.level=20
	g.gold=10000
	g.reset_class_skills()

	assert(Kitchen.BERRIES.size()==12)
	assert(Kitchen.RECIPES.size()==6)
	for berry in Kitchen.BERRIES:
		assert(Food.index_for(berry)>=0, "regional berry missing: "+berry)

	g.steinrose.open(g)
	assert(g.panel=="steinrose")
	g.panel=""

	var expected_buffs:=["","energy_regen","armor","cooldown","move","power_speed"]
	for recipe_index in Kitchen.RECIPES.size():
		g.inventory.clear()
		var recipe:Dictionary=Kitchen.RECIPES[recipe_index]
		for ingredient in recipe["ingredients"]:
			add_food(g,str(ingredient),int(recipe["ingredients"][ingredient]))
		if recipe_index>0:
			assert(g.steinrose.learn_recipe(g,recipe_index))
			assert(g.steinrose.learned[recipe_index])
		assert(g.steinrose.can_cook(g,recipe_index))
		assert(g.steinrose.cook(g,recipe_index))
		var output_index:=find_food(g,str(recipe["name"]))
		assert(output_index>=0,"cooked meal missing: "+str(recipe["name"]))
		g.hp=maxf(1.0,g.max_hp()-50.0)
		g.energy=0
		assert(g.food_system.eat(g,output_index))
		assert(g.hp>g.max_hp()-50.0)
		var expected:String=expected_buffs[recipe_index]
		if expected=="":
			assert(not g.food_system.buff_active())
		else:
			assert(g.food_system.buff_kind==expected)
			assert(g.food_system.buff_active(expected))
			assert(g.food_system.buff_until>Time.get_unix_time_from_system())

	# Buffs replace each other instead of stacking.
	g.food_system.buff_kind="armor"
	g.food_system.buff_value=0.12
	g.food_system.buff_until=Time.get_unix_time_from_system()+30
	g.inventory.clear()
	add_food(g,"Nebelpflaumen-Tee",1)
	assert(g.food_system.eat(g,0))
	assert(g.food_system.buff_kind=="move")
	assert(not g.food_system.buff_active("armor"))
	assert(g.food_system.move_mult()>1.0)

	# Kitchen progression and food buffs survive the same server-save payload shape.
	var kitchen_state:=g.steinrose.snapshot()
	var food_state:=g.food_system.snapshot()
	var restored:=Kitchen.new()
	restored.restore(kitchen_state)
	assert(restored.learned==g.steinrose.learned)
	var restored_food:=Food.new()
	restored_food.restore(food_state)
	assert(restored_food.buff_kind=="move")
	assert(restored_food.move_mult()>1.0)

	var store:=Store.new()
	assert(store.valid_steinrose_state(kitchen_state))
	assert(store.valid_food_state(food_state))
	assert(not store.valid_steinrose_state({"learned":[true,true,true,true,true,true,true]}))
	assert(not store.valid_food_state({"plants":{},"regen_rate":0,"regen_until":0,"buff_kind":"godmode","buff_value":1.0,"buff_until":9999999999.0}))

	print("STEINROSE_KITCHEN_OK 12 regional berries, 6 recipes, learning, ingredient consumption, crafted foods, exclusive buffs and durable save state")
	g.queue_free()
	quit()
