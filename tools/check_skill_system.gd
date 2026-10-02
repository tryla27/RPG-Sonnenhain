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
	# Universeller Kampfbaum: auch der Magier muss Kampfskills kaufen und ausführen können.
	g.class_id=1
	g.reset_class_skills();g.level=20;g.skill_points=30;g.energy=1000
	assert(g.buy_skill(0))
	g.slots[0]=0
	g.player_pos=Vector2(6000,1000);g.facing=Vector2.RIGHT
	g.enemies=[g.make_enemy(4,g.player_pos+Vector2(80,0))]
	var hp_before:float=g.enemies[0]["hp"]
	g.use_ability(0)
	assert(float(g.enemies[0]["hp"])<hp_before,"Magier-Kampfskill verursacht keinen Schaden")
	g.enemies.clear()
	g.reset_class_skills();g.level=40;g.skill_points=30;g.gold=20000
	assert(g.buy_skill(0));assert(g.buy_skill(16))
	var f:Dictionary=g.FUSIONS[0];var sp:=g.fusion_skill_cost(f);var before:=g.skill_points;var cash:=g.gold
	assert(sp==(g.skill_point_cost(0)+g.skill_point_cost(16))*2);assert(g.buy_fusion(0))
	assert(g.learned[40] and g.learned[0] and g.learned[16]);assert(g.skill_points==before-sp and g.gold==cash-int(f["gold"]))
	# Klassenboni kommen aus genau einem Relikt des passenden Bosses.
	assert(g.region_at(g.CLASS_BOSS_SITES[0])==6 and g.region_at(g.CLASS_BOSS_SITES[1])==7 and g.region_at(g.CLASS_BOSS_SITES[2])==8)
	for boss_index in 3:
		var relic:Dictionary=g.class_relic_item(boss_index)
		assert(bool(relic.get("class_relic",false)) and int(relic.get("mastery_class",-1))==boss_index)
	# Falsche Klasse darf ein fremdes Relikt besitzen, aber nicht verwenden.
	g.class_id=0;g.class_mastery_unlocked=false;g.arcane_step_learned=false;g.inventory.clear()
	assert(g.add_item(g.class_relic_item(1)))
	g.use_item(0)
	assert(not g.class_mastery_unlocked and g.inventory.size()==1)
	# Magier-Relikt schaltet Arkanen Schritt ohne Skillpunktkosten frei.
	# Arkaner Sprung ist kein Startskill: vor Level 15 nicht kaufbar, ab Level 15 nur gegen Skillpunkte.
	g.class_id=1;g.reset_class_skills();g.level=1;g.skill_points=30
	assert(not g.learned[19] and not g.buy_skill(19))
	g.level=15
	var jump_points_before:=g.skill_points
	assert(g.buy_skill(19) and g.learned[19] and g.skill_levels[19]==1)
	assert(g.skill_points<jump_points_before)
	# Pip verleiht pro Spielstand genau eine klassenpassende Startwaffe.
	g.inventory.clear();g.pip_loan_received=false;g.class_id=1
	g.pip_dialogue()
	assert(g.pip_loan_received and g.inventory.size()==1 and g.inventory[0]["icon"]=="staff")
	var loan_count:=g.inventory.size();g.pip_dialogue();assert(g.inventory.size()==loan_count)
	# Borin besitzt genau drei Meilensteinprüfungen auf 3 / 20 / 39.
	assert(g.BORIN_QUESTS.size()==3)
	assert(int(g.BORIN_QUESTS[0]["req"])==3 and int(g.BORIN_QUESTS[1]["req"])==20 and int(g.BORIN_QUESTS[2]["req"])==39)
	g.class_id=1;g.class_mastery_unlocked=false;g.arcane_step_learned=false;g.inventory.clear()
	assert(g.add_item(g.class_relic_item(1)))
	var mastery_points_before:int=g.skill_points
	g.use_item(0)
	assert(g.class_mastery_unlocked and g.arcane_step_learned and g.inventory.is_empty())
	assert(g.skill_points==mastery_points_before)
	# Reservierung schützt die ersten 15 Sekunden nur die passende Klasse.
	var reserved_drop:Dictionary={"reserved_class":2,"reserve_until_ms":Time.get_ticks_msec()+10000}
	assert(g.class_relic_locked_for_player(reserved_drop,0))
	assert(not g.class_relic_locked_for_player(reserved_drop,2))
	reserved_drop["reserve_until_ms"]=0
	assert(not g.class_relic_locked_for_player(reserved_drop,0))
	g.player_pos=Vector2(6000,1035)
	g.class_id=2;g.class_mastery_unlocked=true;g.ranger_hunt_meter=90;g.ranger_hunt_buff=0;g.normal_attack();assert(g.ranger_hunt_buff==60 and g.ranger_hunt_meter==0);g.dodge();assert(g.ranger_stealth_timer>g.dodge_duration)
	g.class_id=0;g.class_mastery_unlocked=true;g.warrior_rage=0;g.normal_attack();assert(g.warrior_rage>0)
	print("BORIN_SKILL_SYSTEM_OK universal trees; fusion cost; Map06/07/08 class relics; reservation; rage; arcane step; hunt rush; stealth roll");g.free();quit()
