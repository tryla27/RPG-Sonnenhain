extends SceneTree
class TestGame:
	extends "res://main.gd"
	func save_game(): pass
	func announce_multiplayer_context(): pass
func _initialize(): call_deferred("run")
func run():
	var g:=TestGame.new();g.reset_class_skills();g.level=40;g.skill_points=30;g.gold=20000
	for race in 3:
		g.hero_race=race
		assert(g.SKILL_TREES.size()==3 and g.is_slot_skill(0) and g.is_slot_skill(16) and g.is_slot_skill(34))
	assert(g.buy_skill(0));assert(g.buy_skill(16))
	var f:Dictionary=g.FUSIONS[0];var sp:=g.fusion_skill_cost(f);var before:=g.skill_points;var cash:=g.gold
	assert(sp==(g.skill_point_cost(0)+g.skill_point_cost(16))*2);assert(g.buy_fusion(0))
	assert(g.learned[40] and g.learned[0] and g.learned[16]);assert(g.skill_points==before-sp and g.gold==cash-int(f["gold"]))
	g.class_id=1;g.class_mastery_unlocked=false;g.arcane_step_learned=false;assert(not g.claim_class_mastery());g.final_completed=true;assert(g.claim_class_mastery() and g.arcane_step_learned)
	g.class_id=2;g.class_mastery_unlocked=true;g.ranger_hunt_meter=90;g.ranger_hunt_buff=0;g.normal_attack();assert(g.ranger_hunt_buff==60 and g.ranger_hunt_meter==0);g.dodge();assert(g.ranger_stealth_timer>g.dodge_duration)
	g.class_id=0;g.class_mastery_unlocked=true;g.warrior_rage=0;g.normal_attack();assert(g.warrior_rage>0)
	print("BORIN_SKILL_SYSTEM_OK universal trees; fusion cost; mastery; rage; arcane step; hunt rush; stealth roll");g.free();quit()
