extends SceneTree

class TestGame:
	extends "res://main.gd"
	var recorded_hits:Array=[]
	func _ready()->void: pass
	func _process(_delta:float)->void: pass
	func save_game()->void: pass
	func announce_multiplayer_context()->void: pass
	func play_sound(_name:String)->void: pass
	func damage_enemy(index:int,amount:int,push:Vector2,stun:bool=false,element:String="",source_peer:int=0,_apply_runes:bool=true)->void:
		if index<0 or index>=enemies.size():return
		recorded_hits.append({"uid":int(enemies[index]["uid"]),"pos":Vector2(enemies[index]["pos"]),"amount":amount,"element":element,"peer":source_peer})

func _initialize()->void:
	call_deferred("run")

func run()->void:
	var g:=TestGame.new()
	g.reset_class_skills()

	# Jede feste Fusion muss eine eindeutige Ortsregel besitzen.
	for fusion in g.FUSIONS:
		var id:=int(fusion["id"])
		assert(not g.fusion_impact_profile(id).is_empty())
	assert(g.fusion_spawn_rule(40)=="DAMAGE_IMPACT_POSITION")
	assert(g.fusion_spawn_rule(42)=="DAMAGE_IMPACT_POSITION")
	assert(g.fusion_spawn_rule(43)=="DAMAGE_IMPACT_POSITION")
	assert(g.fusion_spawn_rule(41)=="PLAYER_POSITION")

	# Flammenwirbel wirkt am Trefferpunkt, nicht am Spieler.
	g.player_pos=Vector2.ZERO
	g.enemies=[
		{"uid":1,"pos":Vector2(1000,1000)},
		{"uid":2,"pos":Vector2(1070,1000)},
		{"uid":3,"pos":Vector2(20,0)}
	]
	g.apply_fusion_impact(40,Vector2(1000,1000),100,1,2,77)
	assert(g.recorded_hits.size()==2)
	for hit in g.recorded_hits:
		assert(Vector2(hit["pos"]).distance_to(Vector2(1000,1000))<150.0)
		assert(int(hit["peer"])==77)
		assert(str(hit["element"])=="feuer")

	# Blitzkern benutzt Blitzlanze als Träger und löst Teslawelle am Impact aus.
	g.recorded_hits.clear()
	g.enemies=[
		{"uid":10,"pos":Vector2(2100,400)},
		{"uid":11,"pos":Vector2(2220,400)},
		{"uid":12,"pos":Vector2(0,30)}
	]
	g.apply_fusion_impact(42,Vector2(2100,400),120,10,3,88)
	assert(g.recorded_hits.size()==2)
	for hit in g.recorded_hits:
		assert(Vector2(hit["pos"]).distance_to(Vector2(2100,400))<170.0)
		assert(str(hit["element"])=="blitz")
		assert(int(hit["peer"])==88)

	# Carrier-Metadaten müssen mit dem tatsächlichen Projektilpfad übereinstimmen.
	var fire_whirl:Array=g.ability_projectiles(40,Vector2.ZERO,Vector2.RIGHT,1,100)
	var lightning_core:Array=g.ability_projectiles(42,Vector2.ZERO,Vector2.RIGHT,1,100)
	var iceball:Array=g.ability_projectiles(43,Vector2.ZERO,Vector2.RIGHT,1,100)
	assert(fire_whirl.size()==1 and int(fire_whirl[0]["spell_id"])==40 and not bool(fire_whirl[0]["pierce"]))
	assert(lightning_core.size()==1 and int(lightning_core[0]["spell_id"])==42 and bool(lightning_core[0]["pierce"]))
	assert(iceball.size()==1 and int(iceball[0]["spell_id"])==43 and not bool(iceball[0]["pierce"]))

	print("FUSION_IMPACT_RULES_OK damage fusion effects use impact position; reactor wall remains player-position cast")
	g.free()
	quit()
