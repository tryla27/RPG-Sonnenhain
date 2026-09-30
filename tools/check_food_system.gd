extends SceneTree
const Food=preload("res://components/food_system.gd")
const Store=preload("res://components/server_save_store.gd")
class TestGame:
 extends "res://main.gd"
 func _ready():pass
 func _process(_delta):pass
 func _draw():pass
 func save_game():pass
func _initialize():call_deferred("run")
func run():
 var g=TestGame.new()
 root.add_child(g)
 g.konflux_preview_mode=true;g.character_created=true
 g.player_uuid="food-test";g.hero_name="Nahrungstest"
 g.reset_class_skills()
 for q in g.QUESTS:g.quests.append({"state":0,"progress":0})
 for e in g.WORLD_EVENTS:g.event_states.append(0);g.event_progress.append(0)
 g.food_system.configure(g)
 assert(g.food_system.plants.size()==36)
 var region_kinds={}
 for plant in g.food_system.plants:
  var region:int=g.region_at(plant["point"])
  assert(int(plant["food"])==Food.REGION_FOOD[region])
  region_kinds[region]=int(plant["food"])
 assert(region_kinds.size()==12)
 assert(Food.FOODS.size()==31)
 # Every edible item stacks and retains its exact fruit design index.
 for info in Food.FOODS:
  var item:Dictionary=g.make_item(info["name"],"food",0,0,info["price"],"",1)
  assert(item["design"]==Food.index_for(info["name"]))
  assert(g.item_design(item)==Food.index_for(info["name"]))
  assert(g.stack_limit(item)==30)
  assert(item["value"]==info["price"])
 # Pick, reject second harvest, survive reconnect, and regrow.
 var test_plant:Vector2=g.food_system.plants[0]["point"]
 assert(g.region_at(test_plant)==1)
 g.player_pos=test_plant+Vector2(0,20)
 assert(g.food_system.harvest(g))
 assert(g.inventory.size()==1 and g.inventory[0]["count"]==3)
 assert(g.inventory[0]["name"]=="Himbeeren")
 assert(g.food_system.harvest(g) and g.inventory[0]["count"]==3)
 var restored=Food.new();restored.restore(g.food_system.snapshot())
 assert(not restored.ready_at(test_plant,Time.get_unix_time_from_system()))
 restored.harvested[Food.key(test_plant)]=Time.get_unix_time_from_system()-1
 assert(restored.ready_at(test_plant,Time.get_unix_time_from_system()))
 # Immediate heal, ongoing regen, no resurrection, cap and non-stacking.
 g.hp=20
 assert(g.food_system.eat(g,0) and g.hp==24 and g.inventory[0]["count"]==2)
 var previous:float=g.hp
 g.food_system.tick(g,2)
 assert(is_equal_approx(g.hp,previous+2))
 g.hp=g.max_hp()-0.5
 g.food_system.tick(g,2);assert(g.hp==g.max_hp())
 g.hp=0
 assert(not g.food_system.eat(g,0) and g.inventory[0]["count"]==2)
 g.hp=20;g.inventory.clear()
 g.add_item(g.make_item("Sonnenhain-Eintopf","food",0,0,48,"",1))
 g.add_item(g.make_item("Apfel","food",0,0,5,"",1))
 assert(g.food_system.eat(g,0))
 var end:float=g.food_system.regen_until
 assert(g.food_system.eat(g,0))
 assert(g.food_system.regen_rate==3 and g.food_system.regen_until==end)
 g.food_system.regen_until=0
 previous=g.hp;g.food_system.tick(g,2);assert(g.hp==previous)
 # Full bags retain ripe fruit.
 g.inventory.clear();g.food_system.harvested={}
 for i in 42:g.inventory.append(g.make_item("Belegt","ring",0,0,1))
 assert(g.food_system.harvest(g))
 assert(g.food_system.ready_at(test_plant,Time.get_unix_time_from_system()))
 # Server accepts valid food, rejects unknown foods and malformed effects.
 g.inventory.clear();g.add_item(g.make_item("Heidelbeeren","food",0,0,4,"",1))
 var data:Dictionary=g.capture_save_data()
 var store=Store.new()
 assert(store.valid_data(data,g.player_uuid))
 var directory=OS.get_environment("TEMP").path_join("sonnenhain-food-"+str(Time.get_ticks_usec())) if OS.has_feature("windows") else "/tmp/sonnenhain-food-"+str(Time.get_ticks_usec())
 assert(store.configure(directory)==OK)
 var token="f".repeat(64)
 assert(store.open(91,token,g.player_uuid)["revision"]==0)
 assert(store.put(91,token,g.player_uuid,0,"food-save",data)["revision"]==1)
 store.release(91)
 var reread=Store.new();assert(reread.configure(directory)==OK)
 var record:Dictionary=reread.open(92,token,g.player_uuid)
 assert(record["data"]["inventory"][0]["name"]=="Heidelbeeren")
 data["inventory"][0]["name"]="Unbekannte Frucht"
 assert(not store.valid_data(data,g.player_uuid))
 data["inventory"][0]["name"]="Heidelbeeren"
 data["food_state"]["regen_rate"]=999
 assert(not store.valid_data(data,g.player_uuid))
 assert(not store.valid_food_state({"plants":[]}))
 print("FOOD_SYSTEM_OK 31 foods, 12 regional palettes, 36 plants, no fruit in Map 0, harvest cooldown, inventory limits, healing, regen caps, non-stacking and durable server saves")
 quit()
