extends SceneTree

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
	var info:Dictionary=Food.by_name(name)
	assert(not info.is_empty(), "missing food registry entry: "+name)
	var item:Dictionary=g.make_item(name,"food",0,0,int(info.get("price",1)),"",1)
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
	g.class_id=1
	g.level=20
	g.gold=10000
	g.reset_class_skills()

	assert(Kitchen.BERRIES.size()==12)
	assert(Kitchen.RECIPES.size()==12)
	assert(Food.FOODS.size()==43)
	assert(int(Kitchen.RECIPES[0]["learn_cost"])==0)
	for recipe_info in Kitchen.RECIPES:
		assert(int(recipe_info["learn_cost"])<=18, "Alma recipe fee should stay small")
	for berry in Kitchen.BERRIES:
		assert(Food.index_for(berry)>=0, "regional berry missing: "+berry)

	g.steinrose.open(g)
	assert(g.panel=="steinrose")
	assert(g.steinrose.tab==0)
	g.steinrose.set_tab(g,1);assert(g.steinrose.tab==1)
	g.steinrose.set_tab(g,2);assert(g.steinrose.tab==2)
	g.steinrose.set_tab(g,3);assert(g.steinrose.tab==3)
	g.steinrose.set_tab(g,0)
	g.panel=""

	var allowed_buffs:=["","armor","cooldown","move","damage","gather"]
	for recipe_index in Kitchen.RECIPES.size():
		g.inventory.clear()
		var recipe:Dictionary=Kitchen.RECIPES[recipe_index]
		for ingredient in recipe["ingredients"]:
			add_food(g,str(ingredient),int(recipe["ingredients"][ingredient]))
		if recipe_index>0:
			assert(g.steinrose.learn_recipe(g,recipe_index))
		assert(g.steinrose.learned[recipe_index])
		assert(g.steinrose.can_cook(g,recipe_index))
		var gold_before_cook:int=g.gold
		assert(g.steinrose.cook(g,recipe_index))
		assert(g.gold==gold_before_cook, "cooking should not charge extra gold")
		var output_index:=find_food(g,str(recipe["name"]))
		assert(output_index>=0,"cooked meal missing: "+str(recipe["name"]))
		var info:Dictionary=Food.by_name(str(recipe["name"]))
		assert(bool(info.get("meal",false)))
		assert(int(info.get("meal_duration",0))==360)
		assert(str(info.get("buff","")) in allowed_buffs)
		g.hp=maxf(1.0,g.max_hp()-50.0)
		g.energy=0
		assert(g.food_system.eat(g,output_index))
		assert(g.food_system.active_food_name==str(recipe["name"]))
		assert(g.food_system.meal_remaining()>=359 and g.food_system.meal_remaining()<=360)
		assert(g.food_system.meal_until>Time.get_unix_time_from_system()+358.0)
		if recipe_index>=10:
			assert(float(info.get("meal_hp_regen",0))==0.0)
			assert(float(info.get("meal_mana_regen",0))>0.0)
			assert(str(info.get("buff",""))=="")
			var before_hp:float=g.hp
			var before_mana:float=g.energy
			g.food_system.tick(g,1.0)
			assert(is_equal_approx(g.hp,before_hp))
			assert(g.energy>before_mana)
		else:
			assert(float(info.get("meal_hp_regen",0))>=2.0)
			assert(float(info.get("meal_mana_regen",0))==0.0)

	# One long meal only: a new dish replaces every effect from the previous one.
	g.food_system.clear_meal()
	g.inventory.clear()
	add_food(g,"Steinbeeren-Riegel",1)
	assert(g.food_system.eat(g,0))
	assert(g.food_system.buff_active("armor"))
	assert(g.food_system.active_food_name=="Steinbeeren-Riegel")
	g.inventory.clear()
	add_food(g,"Nebelpflaumen-Tee",1)
	assert(g.food_system.eat(g,0))
	assert(g.food_system.active_food_name=="Nebelpflaumen-Tee")
	assert(g.food_system.buff_active("move"))
	assert(not g.food_system.buff_active("armor"))
	assert(g.food_system.move_mult()>1.0)

	# Mana food is deliberately pure mana regeneration and replaces the movement meal.
	g.inventory.clear()
	add_food(g,"Blauer Mondkuchen",1)
	assert(g.food_system.eat(g,0))
	assert(g.food_system.active_food_name=="Blauer Mondkuchen")
	assert(g.food_system.meal_hp_regen==0)
	assert(g.food_system.meal_mana_regen==6)
	assert(g.food_system.buff_kind=="")
	assert(not g.food_system.buff_active())
	var mana_hp:float=g.hp
	var mana_before:float=g.energy
	g.food_system.tick(g,1.0)
	assert(is_equal_approx(g.hp,mana_hp))
	assert(g.energy>mana_before)

	# Recipe progress and absolute expiry survive reconnect/save; time keeps running offline.
	var kitchen_state:Dictionary=g.steinrose.snapshot()
	var food_state:Dictionary=g.food_system.snapshot()
	var restored:=Kitchen.new()
	restored.restore(kitchen_state)
	assert(restored.learned==g.steinrose.learned)
	var restored_food:=Food.new()
	restored_food.restore(food_state)
	assert(restored_food.active_food_name=="Blauer Mondkuchen")
	assert(restored_food.meal_mana_regen==6)
	assert(restored_food.meal_remaining()>350)

	var store:=Store.new()
	assert(store.valid_steinrose_state(kitchen_state))
	assert(store.valid_food_state(food_state))
	assert(not store.valid_steinrose_state({"learned":[true,true,true,true,true,true,true,true,true,true,true,true,true]}))
	var bad_food:=food_state.duplicate(true)
	bad_food["meal_mana_regen"]=50
	assert(not store.valid_food_state(bad_food))
	bad_food=food_state.duplicate(true)
	bad_food["active_food_name"]="Gefälschtes Essen"
	assert(not store.valid_food_state(bad_food))
	bad_food=food_state.duplicate(true)
	bad_food["meal_until"]=Time.get_unix_time_from_system()+500
	assert(not store.valid_food_state(bad_food))

	print("STEINROSE_KITCHEN_OK 4 distinct Alma pages, 12 regional fruits, 12 low-fee recipes, free cooking with ingredients, 360s single active meal, pure mana regeneration and durable save/reconnect state")
	g.queue_free()
	quit()
