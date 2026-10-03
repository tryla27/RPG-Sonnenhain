extends SceneTree
class TestGame:
	extends "res://main.gd"
	var saved:Dictionary={}
	func save_game():saved={"arena_reward_item":arena_reward_item.duplicate(true)}
	func announce_multiplayer_context():pass
func _initialize():call_deferred("run")
func run():
	var g:=TestGame.new();g.reset_class_skills();g.player_uuid="choice-test";g.level=40
	for cls in 3:
		g.class_id=cls;g.inventory.clear();g.equipped_head_uid=-1
		assert(g.head_visual()==-1)
		var hat:Dictionary=g.make_class_head(40)
		g.inventory=[hat];g.toggle_equipment_item(0)
		assert(g.head_visual()==cls and g.primary_attribute()>=22)
		g.class_id=(cls+1)%3;g.validate_equipment_slots();assert(g.equipped_head_uid==-1)
		# Boss-Kopfrüstungen sind Trophäen und bleiben für jede Klasse tragbar.
		g.class_id=cls;g.inventory.clear();g.equipped_head_uid=-1
		var boss_hat:Dictionary=g.class_boss_hat_item((cls+1)%3)
		g.inventory=[boss_hat];g.toggle_equipment_item(0)
		assert(g.equipped_head_uid==int(boss_hat["uid"]))
		assert(g.head_visual()==int(boss_hat["head_class"]))
		g.class_id=(cls+2)%3;g.validate_equipment_slots();assert(g.equipped_head_uid==int(boss_hat["uid"]))
		g.class_id=cls
		var found:Dictionary={}
		for i in 1000:
			var w:Dictionary=g.make_arena_weapon(30)
			assert(w["icon"]==g.class_weapon_icon())
			assert(int(w["new_weapon_id"])/5==cls)
			found[w["name"]]=true
		assert(found.size()==5)
	assert(g.arena_new_weapon_chance(4)==0 and g.arena_new_weapon_chance(5)==.20)
	assert(g.arena_new_weapon_chance(10)==.35 and g.arena_new_weapon_chance(20)==.50 and g.arena_new_weapon_chance(30)==.65)
	g.class_id=1;g.arena_reward_wave=30;g.arena_reward_claimed=false;g.arena_reward_item.clear()
	g.inventory.clear()
	for i in 42:g.inventory.append(g.make_item("Full%d"%i,"gem",0,0,0))
	g.claim_arena_chest();assert(not g.arena_reward_claimed and not g.arena_reward_item.is_empty())
	var uid:int=g.arena_reward_item["uid"]
	g.claim_arena_chest();assert(g.arena_reward_item["uid"]==uid)
	g.inventory.clear();g.claim_arena_chest();assert(g.arena_reward_claimed and g.inventory.size()==1 and g.inventory[0]["uid"]==uid)
	g.claim_arena_chest();assert(g.inventory.size()==1)
	g.reset_class_skills();g.skill_points=2;g.class_id=0;g.level=3;g.skill_tree_tab=0
	var offers:Array=g.skill_choices();assert(not offers.is_empty() and offers==g.skill_choices())
	var pick:int=offers[0];var cost:int=g.skill_point_cost(pick);g.upgrade_skill(pick);assert(g.skill_points==2-cost and g.learned[pick])
	assert(pick not in g.skill_choices())
	g.upgrade_skill(pick);assert(g.skill_points==2-cost)
	g.creation_name="Test";g.creation_class_selected=false;g.panel="creation"
	g.review_character_creation();assert(g.panel=="creation")
	g.creation_class_selected=true;g.review_character_creation();assert(g.panel=="creation_review")
	print("HEADGEAR_ARENA_CHOICES_OK class heads stay class-bound; boss hats universal; 15 weapons; chances; full-inventory stable roll; single reward; Borin direct purchase; creation guard")
	g.free();quit()
