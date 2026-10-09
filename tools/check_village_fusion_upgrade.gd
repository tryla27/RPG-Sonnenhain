extends SceneTree

class TestGame:
	extends "res://main.gd"
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func _draw()->void:pass
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass

func _initialize()->void:
	call_deferred("run")

func run()->void:
	var g:=TestGame.new()
	root.add_child(g)
	g.reset_class_skills()
	g.character_created=true;g.player_uuid="fusion-test";g.hero_name="Fusionsprobe"
	for quest in g.QUESTS:g.quests.append({"state":0,"progress":0})
	for event in g.WORLD_EVENTS:g.event_states.append(0);g.event_progress.append(0)
	g.level=50;g.gold=100000;g.player_pos=Vector2(2500,1600);g.facing=Vector2.RIGHT
	assert(g.FUSIONS.size()==528)
	var keys:Dictionary={};var ids:Dictionary={}
	var csv:="Spell 1;Spell 2;Fusionsspell;ID;Gold;Mindestlevel\n"
	for recipe in g.FUSIONS:
		var a:=int(recipe["a"]);var b:=int(recipe["b"]);var id:=int(recipe["id"])
		var key:String=g.FusionRules.normalized_key(a,b)
		assert(a<b and not keys.has(key) and not ids.has(id))
		keys[key]=true;ids[id]=true
		assert(g.fusion_definition_by_id(id)==recipe)
		assert(g.fusion_definition_by_key(key)==recipe)
		assert(g.FusionRules.normalized_key(b,a)==key)
		assert(float(g.ABILITIES[id]["cd"])>0 and int(g.ABILITIES[id]["cost"])>0)
		csv+="%s;%s;%s;%d;%d;%d\n" % [g.ABILITIES[a]["name"],g.ABILITIES[b]["name"],g.ABILITIES[id]["name"],id,int(recipe["gold"]),int(g.ABILITIES[id]["req"])]
		# Each generated output runs its carrier; the partner fires at the hit (rule D1).
		g.execute_ability_effects(id,2,40,g.player_pos,g.facing)
		g.projectiles.clear();g.impact_zones.clear();g.battle_zones.clear();g.effects.clear();g.spell_visuals.clear()
		g.player_pos=Vector2(2500,1600)
	assert(FileAccess.get_file_as_string("res://docs/spell-fusionen.csv").replace("\r","")==csv,"Fusion documentation differs from live catalog")
	assert(g.FusionRules.template_for_pair(9,16).is_empty())
	assert(g.FusionRules.template_for_pair(40,16).is_empty())
	assert(g.FusionRules.template_for_pair(16,16).is_empty())
	var recipe:Dictionary=g.fusion_definition_by_key("3:35")
	var id:=int(recipe["id"])
	g.learned[3]=true;g.learned[35]=true;g.skill_levels[3]=2;g.skill_levels[35]=3
	g.slots=[3,35,-1]
	assert(g.can_fuse(recipe))
	g.gold=0;assert(not g.can_fuse(recipe));g.gold=100000
	g.level=1;assert(not g.can_fuse(recipe));g.level=50
	assert(g.buy_fusion(g.fusion_offer_index(id)))
	assert(g.learned[id] and not g.learned[3] and not g.learned[35] and int(g.slots[0])==id)
	var snapshot:=g.fusion_progress_snapshot()
	g.restore_fusion_progress(snapshot,g.fusion_history)
	assert(not g.learned[3] and not g.learned[35],"Reload resurrected sacrificed spells")
	assert(g.fusion_rank_from_network_state({"fusions":g.fusion_progress_rows()},id)==1)
	# Regel D1: Der Pfeil fliegt, die Reparatur zündet an seinem Ende und heilt den Spieler.
	g.hp=1;g.projectiles.clear()
	g.execute_ability_effects(id,1,40,g.player_pos,g.facing)
	assert(not g.projectiles.is_empty(),"Repair/blade fusion must shoot")
	for frame in 90:g.update_projectiles(1.0/60.0)
	assert(g.hp>1,"Repair/blade fusion must heal at the impact")
	# Source support components must still work in support/support combinations (via impulse).
	g.shield_timer=0;g.rage_timer=0
	g.execute_ability_effects(int(g.fusion_definition_by_key("1:4")["id"]),1,40,g.player_pos,g.facing)
	for frame in 60:g.update_projectiles(1.0/60.0)
	assert(g.shield_timer>0 and g.rage_timer>0)
	var enemy:Dictionary=g.make_enemy(1,g.player_pos+Vector2(40,0))
	enemy["hp"]=100000;enemy["max_hp"]=100000
	g.enemies=[enemy]
	g.execute_ability_effects(int(g.fusion_definition_by_key("0:39")["id"]),2,40,g.player_pos,g.facing)
	assert(float(g.enemies[0]["hp"])<100000 and float(g.enemies[0]["stun"])>0,"Attack/EMP fusion lost damage or control")
	g.enemies.clear()
	g.hero_race=2;g.cosmetic_hair=10;g.cosmetic_jewelry=10
	var saved:Dictionary=g.capture_save_data()
	var store=preload("res://components/server_save_store.gd").new()
	assert(store.valid_data(saved,g.player_uuid),"Generated fusion rejected by server save validation")
	g.apply_save_data(saved,true)
	assert(g.cosmetic_hair==10 and g.cosmetic_jewelry==10)
	assert(g.learned[id] and not g.learned[3] and not g.learned[35])
	assert(not g.VillageInteriors32.blocked(g.INTERIOR_CENTER+Vector2(0,300),g.INTERIOR_CENTER,3))
	assert(g.VillageInteriors32.exit_offset(3)==Vector2(0,340))
	for look in [Vector2.LEFT,Vector2.RIGHT]:
		for phase in [0.0,0.2,0.5,0.9]:
			var motion:Dictionary=g.cloak_motion_profile(2,look,true,true,true,false,phase)
			var points:PackedVector2Array=g.cloak_local_points(motion)
			assert((points[3].x+points[4].x)*look.x<0,"Cloak trails on wrong side")
	# Walkability uses actual body collision, not merely painted terrain cells.
	g.player_pos=Vector2(825,1020)
	for gate in g.VILLAGE_GATES:g.opened_village_gates[gate]=true
	var queue:Array[Vector2i]=[Vector2i(51,64)]
	var reached:Dictionary={queue[0]:true};var cursor:=0
	while cursor<queue.size():
		var cell:=queue[cursor];cursor+=1
		for step in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
			var next:Vector2i=cell+step
			var point:=Vector2(next)*16.0
			if next.x<2 or next.y<2 or point.x>1744 or point.y>2576 or reached.has(next):continue
			if g.is_blocked(point,Vector2(cell)*16.0):continue
			reached[next]=true;queue.append(next)
	for shop in g.VillageLayout.SHOPS:
		var door:Vector2=g.village_house_door(shop)
		assert(not g.is_blocked(door,door),"Blocked door: "+str(shop["name"]))
		# Scaled artwork can put a door between grid samples. The rounded sample
		# may lie inside the facade even when the real door is reachable from below.
		var reachable:=false
		var cell:Vector2i=Vector2i((door/16.0).floor())
		for offset in [Vector2i.ZERO,Vector2i.RIGHT,Vector2i.DOWN,Vector2i(1,1)]:
			var candidate:Vector2i=cell+offset
			if not reached.has(candidate):continue
			var origin:=Vector2(candidate)*16.0
			var clear:=true
			for step in 4:
				if g.is_blocked(origin.lerp(door,(step+1)/4.0),origin):clear=false;break
			if clear:reachable=true;break
		assert(reachable,"Unreachable door: "+str(shop["name"]))
	assert(reached.has(Vector2i(55,160)),"South exit disconnected")
	for name in ["smith","chapel","tavern","arena","arena_interior","atelier","skillhaus","ratshalle"]:
		var texture:Texture2D=load("res://art/village/%s.png" % name)
		var im:=texture.get_image()
		assert(not im.is_empty() and im.get_pixel(0,0).a==0)
	print("VILLAGE_FUSION_UPGRADE_OK 528 unique playable pairs; costs/requirements; sacrifice/reload; support effects; network identity; cloak directions; every door and south exit reachable; transparent art")
	g.queue_free()
	quit()
