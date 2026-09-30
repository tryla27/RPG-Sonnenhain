extends SceneTree
func _initialize() -> void:
	var g = load("res://main.gd").new()
	g.reset_class_skills()
	for id in g.ABILITIES.size():
		if float(g.ABILITIES[id]["cd"])<=0:
			g.learned[id]=true
			g.slots[0]=id
			g.use_ability(0)
			assert(g.cooldowns[id]==0,"Passive skill starts cast cooldown")
			continue
		for rank in [1,5]:
			g.player_pos=Vector2(1680,1120)
			g.facing=Vector2.RIGHT
			g.level=70
			g.energy=1000
			g.learned[id]=true
			g.skill_levels[id]=rank
			g.cooldowns[id]=0.0
			g.slots[0]=id
			g.projectiles.clear()
			g.effects.clear()
			g.spell_visuals.clear()
			g.use_ability(0)
			assert(g.player_pos.is_finite(),"Spell corrupts player position")
			assert(g.player_pos.x<1729,"Spell crosses closed gate")
			assert(g.energy>=0 and g.cooldowns[id]>0,"Spell cost or cooldown invalid")
			for shot in g.projectiles:
				assert(shot["pos"].is_finite() and shot["dir"].is_finite(),"Spell projectile invalid")
	g.free()
	print("SPELL_LOGIC_OK 31 active abilities at ranks 1 and 5, 3 passives, walls respected")
	quit()
