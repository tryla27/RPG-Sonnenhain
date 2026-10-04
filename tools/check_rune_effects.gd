extends SceneTree

class TestGame:
	extends "res://main.gd"
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func _draw()->void:pass
	func save_game()->void:pass
	func play_sound(_name:String)->void:pass

func _initialize()->void:call_deferred("run")

func game():
	var g=TestGame.new()
	root.add_child(g)
	g.reset_class_skills()
	g.class_id=1;g.level=40;g.arena_mode="test";g.panel=""
	g.player_pos=g.ARENA_CENTER;g.facing=Vector2.RIGHT
	g.hp=g.max_hp();g.energy=g.max_energy()
	return g

func target(g,offset:Vector2=Vector2(60,0))->Dictionary:
	var e=g.make_enemy(0,g.player_pos+offset)
	e["hp"]=10000.0;e["max_hp"]=10000.0;e["target_peer"]=0;e["facing"]=Vector2.LEFT
	g.enemies.append(e)
	return e

func hit_damage(g,e,element:String="")->float:
	var before:float=e["hp"]
	g.damage_enemy(0,100,Vector2.ZERO,false,element)
	return before-float(e["hp"])

func cast(g)->int:
	g.learned[3]=true;g.skill_levels[3]=1;g.slots[0]=3
	g.cooldowns[3]=0.0;g.energy=g.max_energy()
	g.use_ability(0)
	return int(g.projectiles.back()["damage"])

func run()->void:
	# Every class/race receives universal passive stat and healing bonuses.
	for hero_class in 3:
		for race in 3:
			var g=game();g.class_id=hero_class;g.hero_race=race
			var energy:float=g.max_energy();var speed:float=g.sprint_acceleration();var damage:int=g.normal_attack_power()
			g.essence.ranks[4][0]=2;assert(is_equal_approx(g.max_energy(),energy*1.2))
			g.essence.ranks[3][1]=2;assert(g.sprint_acceleration()>speed and g.essence.movement_mult()>1)
			g.essence.ranks[0][2]=2;assert(g.normal_attack_power()>damage)
			g.essence.ranks[1][4]=2;g.hp=10.0;g.heal_player(10.0);assert(is_equal_approx(g.hp,21.6))
			g.essence.ranks[2][0]=2;g.hp=10.0;g.heal_player(10.0,true);assert(g.hp>21.6)
			g.hp=0.0;g.heal_player(100);assert(g.hp==0.0)
			g.free()
	var g=game();var e=target(g)
	assert(hit_damage(g,e)==100.0)
	g.essence.ranks[0][1]=2;g.hp=50.0;hit_damage(g,e);assert(g.hp>50.0) # Bloodthirst
	g.essence.reset();g.essence.ranks[0][4]=2;g.hp=g.max_hp()*.2
	assert(hit_damage(g,e)>100.0) # Low-health damage
	g.essence.reset();g.essence.ranks[3][2]=2;e["hp"]=e["max_hp"]
	assert(hit_damage(g,e)>100.0) # Healthy target
	g.essence.reset();g.essence.ranks[3][3]=2;e["target_peer"]=-1
	assert(hit_damage(g,e)>100.0)
	assert(float(g.mob_targets(e,false)[0]["detection_mult"])<1.0)
	e["target_peer"]=0
	g.essence.reset();g.essence.ranks[3][4]=4;e["facing"]=Vector2.RIGHT
	assert(hit_damage(g,e)>100.0 and e["stun"]>=.35)
	e["facing"]=Vector2.LEFT
	# Crits also work for a mage, without a warrior's inherent chance.
	g.essence.reset();g.essence.ranks[0][0]=4;seed(42)
	var crits:=0
	for i in 60:
		e["hp"]=10000.0
		if hit_damage(g,e)>100.0:crits+=1
	assert(crits>0)
	g.essence.reset();g.essence.ranks[0][2]=4
	g.normal_attack();var first:int=g.projectiles.back()["damage"]
	g.normal_attack();g.normal_attack();g.normal_attack()
	assert(int(g.projectiles.back()["damage"])>first)
	g.essence.reset();g.essence.ranks[0][3]=4;g.hp=g.max_hp();seed(42)
	var blocks:=0
	for i in 60:
		var before:float=g.hp
		g.apply_player_damage(1)
		if g.hp==before:blocks+=1
	assert(blocks>0 and g.rune_counter_ready)
	g.normal_attack();assert(not g.rune_counter_ready and int(g.projectiles.back()["damage"])>g.normal_attack_power())
	g.essence.reset();g.essence.ranks[1][0]=2;g.enemies.clear();g.attack_timer=0;g.swing_timer=0;g.hurt_until=0;g.hp=50
	g.update_rune_effects(1.0);assert(g.hp==52.0)
	target(g);g.update_rune_effects(1.0);assert(g.hp==52.0)
	g.essence.ranks[1][0]=3;g.update_rune_effects(1.0);assert(g.hp>52.0)
	g.essence.reset();g.essence.ranks[1][2]=2;g.hp=g.max_hp()*.1;g.update_rune_effects(0)
	assert(g.rune_emergency_timer>0 and g.rune_emergency_cooldown>0)
	var before:float=g.hp;g.apply_player_damage(10);assert(before-g.hp<10)
	g.rune_emergency_timer=0;g.essence.reset();g.essence.ranks[1][1]=2;g.essence.ranks[1][3]=2
	g.sprint_blend=1.0;g.sprint_block_timer=0.0;g.apply_player_damage(1)
	assert(g.sprint_blend>.084 and g.sprint_block_timer<.25)
	g.essence.reset();g.essence.ranks[4][3]=2;g.hp=g.max_hp()*.2;g.update_rune_effects(0)
	assert(g.shield_timer>0 and g.rune_auto_shield_cooldown>0)
	g.shield_timer=0;g.update_rune_effects(0);assert(g.shield_timer==0)
	g.hp=g.max_hp();g.essence.reset()
	var base_cast:=cast(g);var base_cd:float=g.cooldowns[3]
	g.essence.ranks[3][0]=2;cast(g);assert(g.cooldowns[3]<base_cd)
	g.essence.reset();g.essence.ranks[4][4]=2;g.rune_overload=0
	assert(cast(g)==base_cast);cast(g);cast(g);assert(cast(g)>base_cast and g.rune_overload==0)
	g.essence.reset();g.essence.ranks[2][4]=2;g.arcane_resonance=0
	cast(g);assert(g.arcane_resonance==0) # Casting alone cannot charge resonance.
	e=g.enemies[0]
	for i in 4:hit_damage(g,e,"eis")
	assert(g.arcane_resonance==4 and cast(g)>base_cast and g.arcane_resonance==0)
	g.essence.reset();e["hp"]=10000
	var lightning_base:=hit_damage(g,e,"blitz")
	g.essence.ranks[4][1]=2;assert(hit_damage(g,e,"blitz")>lightning_base)
	g.essence.ranks[4][2]=2
	var second=target(g,Vector2(120,0));var third=target(g,Vector2(200,0))
	hit_damage(g,e,"blitz");assert(second["hp"]<10000 and third["hp"]<10000)
	# Remote builds use their own ranks, irrespective of the host's allocation.
	g.essence.reset();g.essence.ranks[0][4]=4
	var ranks=g.EssenceSystem.new();ranks.ranks[3][2]=2
	g.remote_players[5]={"rune_ranks":ranks.ranks,"hp":100,"max_hp":100,"pos":[g.player_pos.x,g.player_pos.y]}
	e["hp"]=e["max_hp"]
	assert(g.rune_rank(0,4,5)==0 and g.rune_rank(3,2,5)==2)
	assert(is_equal_approx(g.rune_damage_mult(e,5),1.12))
	g.free()
	print("RUNE_EFFECTS_OK universal stats, combat, healing, regeneration, protection, cooldowns, resonance, overload, chains and remote rank isolation")
	quit()
