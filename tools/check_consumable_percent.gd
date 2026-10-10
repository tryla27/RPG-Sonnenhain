extends SceneTree
class Game:
 extends "res://main.gd"
 func _ready():pass
 func _process(_delta):pass
 func _draw():pass
 func save_game():pass
 func play_sound(_key):pass
 func message(_text):pass
func _initialize():call_deferred("run")
func run():
 var g=Game.new();root.add_child(g)
 for hero_class in 3:
  g.class_id=hero_class
  for hero_level in [1,13,40]:
   g.level=hero_level;g.reset_class_skills();g.skill_levels[10]=2;g.skill_levels[11]=3
   for potion in [{"name":"Heiltrank","ratio":0.5},{"name":"Großer Heiltrank","ratio":0.8}]:
    g.inventory.clear()
    var item:Dictionary=g.make_item(potion.name,"potion",0,0,35);item.count=2
    g.inventory.append(item);g.hp=1.0
    g.use_item(0)
    assert(is_equal_approx(g.hp,minf(g.max_hp(),1+g.max_hp()*potion.ratio)))
    assert(g.inventory[0].count==1)
    g.hp=g.max_hp()-1;g.use_item(0)
    assert(g.hp==g.max_hp() and g.inventory.is_empty())
   g.food_system.active_food_name="Testbuff";g.food_system.meal_hp_regen=2
   g.inventory=[g.make_item("Rotkuchen","food",0,0,20)];g.hp=1;g.energy=7
   g.use_item(0);assert(g.hp==g.max_hp() and g.energy==7 and g.inventory.is_empty())
   assert(g.food_system.active_food_name=="Testbuff" and g.food_system.meal_hp_regen==2)
   g.inventory=[g.make_item("Blaukuchen","food",0,0,20)];g.energy=1;g.hp=7
   g.use_item(0);assert(g.energy==g.max_energy() and g.hp==7 and g.inventory.is_empty())
   assert(g.food_system.active_food_name=="Testbuff")
 print("CONSUMABLE_PERCENT_OK all classes; levels 1/13/40; HP/mana bonuses; proportional healing; caps; stacks; full cakes; buffs preserved")
 g.queue_free();quit()
