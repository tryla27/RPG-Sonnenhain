extends SceneTree

class TestGame:
	extends "res://main.gd"
	func _ready()->void: pass
	func _process(_delta:float)->void: pass
	func save_game()->void: pass
	func play_sound(_name:String)->void: pass
	func announce_multiplayer_context()->void: pass

func _initialize()->void:
	call_deferred("run")

func run()->void:
	var g:=TestGame.new()
	g.reset_class_skills()

	# Jedes echte Level-Up vergibt genau einen Skillpunkt.
	g.level=3
	g.xp=0
	g.skill_points=0
	g.skill_level_points_granted=2
	var needed:=g.xp_required()
	g.gain_xp(needed)
	assert(g.level==4)
	assert(g.skill_points==1)
	assert(g.skill_level_points_granted==3)

	# Alte Saves bekommen fehlende Level-Up-Punkte genau einmal nachgetragen.
	g.level=20
	g.skill_points=4
	g.skill_level_points_granted=0
	var migrated:=g.restore_level_skill_point_progress({})
	assert(migrated==19)
	assert(g.skill_points==23)
	assert(g.skill_level_points_granted==19)
	var migrated_again:=g.restore_level_skill_point_progress({"skill_level_points_granted":19})
	assert(migrated_again==0)
	assert(g.skill_points==23)

	# Rang 1 = gelernt. Rang 2-4 kosten je 1 SP und besitzen Level-Gates.
	var fireball:=16
	g.ensure_skill_state_size()
	g.learned[fireball]=true
	g.skill_levels[fireball]=1
	assert(g.skill_rank_level(fireball,2)==6)
	assert(g.skill_rank_level(fireball,3)==11)
	assert(g.skill_rank_level(fireball,4)==18)

	g.level=6
	g.skill_points=1
	assert(g.can_upgrade_skill(fireball))
	assert(g.upgrade_skill(fireball))
	assert(int(g.skill_levels[fireball])==2)
	assert(g.skill_points==0)

	# Ohne Level-Gate kein Hochstufen.
	g.skill_points=2
	g.level=10
	assert(not g.can_upgrade_skill(fireball))
	assert(not g.upgrade_skill(fireball))
	assert(int(g.skill_levels[fireball])==2)
	assert(g.skill_points==2)

	g.level=11
	assert(g.upgrade_skill(fireball))
	assert(int(g.skill_levels[fireball])==3)
	g.level=18
	assert(g.upgrade_skill(fireball))
	assert(int(g.skill_levels[fireball])==4)
	assert(not g.can_upgrade_skill(fireball))
	assert(not g.upgrade_skill(fireball))
	assert(int(g.skill_levels[fireball])==4)

	# Hohe Grundanforderungen können Stufe 4 spätestens auf Level 40 erreichen.
	assert(g.skill_rank_level(14,4)==40)

	# Multiplayer akzeptiert nur Ränge 1-4 und dedupliziert Skill-IDs.
	var rows:=g.sanitize_skill_rank_rows([[16,9],[16,2],[18,3],[-1,4],[999,4]])
	assert(rows.size()==2)
	assert(int(rows[0][0])==16 and int(rows[0][1])==4)
	assert(int(rows[1][0])==18 and int(rows[1][1])==3)
	assert(g.skill_rank_from_network_state({"skill_ranks":rows},16)==4)
	assert(g.skill_rank_from_network_state({"skill_ranks":rows},17)==0)

	# Fusionen bleiben am Kristall und werden nicht mit normalen SP verbessert.
	g.learned[43]=true
	g.skill_levels[43]=1
	assert(not g.can_upgrade_skill(43))

	print("SKILL_RANK_PROGRESSION_OK +1 SP/level; legacy backfill; ranks 1-4; 1 SP upgrades; gates; network rank cap")
	g.free()
	quit()
