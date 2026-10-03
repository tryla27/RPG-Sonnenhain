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
	assert(g.buy_skill(16));assert(g.buy_skill(20));assert(g.buy_skill(17));assert(g.buy_skill(18))
	var offers:Array=g.available_fusions()
	assert(not offers.is_empty(),"Gelernte Attacken müssen als Verschmelzungsangebote erscheinen")
	var f:Dictionary=offers[0]
	assert(g.learned[int(f["a"])] and g.learned[int(f["b"])],"Fusion darf nur gelernte Attacken anbieten")
	var before:=g.skill_points;var cash:=g.gold
	assert(g.buy_fusion(0))
	assert(g.learned[int(f["id"])] and g.learned[int(f["a"])] and g.learned[int(f["b"])])
	assert(g.skill_points==before and g.gold==cash-int(f["gold"]))
	# Das Belegungsmenü listet gelernte aktive Attacken separat von passiven Werten.
	var loadout:Array=g.learned_loadout_skills()
	assert(16 in loadout and 18 in loadout and 20 in loadout)
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
	# Magier-Relikt schaltet den Risssprung ohne Skillpunktkosten frei.
	# Rissnova ist kein Startskill: vor Level 15 nicht kaufbar, ab Level 15 nur gegen Skillpunkte.
	g.class_id=1;g.reset_class_skills();g.level=1;g.skill_points=30
	assert(not g.learned[19] and not g.buy_skill(19))
	g.level=15
	var jump_points_before:=g.skill_points
	assert(g.ABILITIES[19]["name"]=="Rissnova");assert(g.buy_skill(19) and g.learned[19] and g.skill_levels[19]==1)
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
	assert(g.class_mastery_unlocked and g.mage_rift_blink_unlocked() and g.inventory.is_empty())
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
	g.reset_class_skills();g.class_id=1;g.level=39;g.creative_mode=true;assert(g.ultimate_unlock_level()==40 and not g.learned[g.class_ultimate()]);g.set_creative_level(39);assert(not g.learned[g.class_ultimate()]);g.set_creative_level(40);assert(g.learned[g.class_ultimate()])
	print("BORIN_SKILL_SYSTEM_OK universal trees; gold-only fusion; relic mastery; mage Risssprung on Space; mage ultimate level 40; rage; hunt rush; stealth roll");g.free();quit()
