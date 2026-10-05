# Production deploy marker: save repair + HUD + 32px village pass.
extends SceneTree
var failures := 0
func check(ok: bool,label: String) -> void:
	if not ok:
		failures += 1
		push_error(label)

func _initialize() -> void:
	var g = load("res://main.gd").new()
	for h in g.house_positions():
		check(g.region_rect(0).grow(-45).encloses(Rect2(h,Vector2(192,160))),"House outside village: %s"%h)
		var house_info:Dictionary={}
		for candidate in g.VillageLayout.SHOPS:
			if candidate["house"]==h and not candidate.has("shared_with"):
				house_info=candidate
				break
		check(not house_info.is_empty(),"House metadata missing: %s"%h)
		if not house_info.is_empty():
			check(g.region_rect(0).encloses(g.VillageBuildings.bounds(h,str(house_info["kind"]))),"Building art outside village")
			var door:Vector2=g.village_house_door(house_info)
			check(g.is_blocked(door-Vector2(0,70),door),"House collider missing: %s"%h)
			check(not g.is_blocked(door,door+Vector2(0,10)),"Door approach obstructed: %s"%h)
	for n in g.NPCS:
		check(not g.is_blocked(n["pos"],n["pos"]),"NPC inside collision: %s"%n["name"])
		check(n["pos"].y>g.npc_position(n["name"]).y-1,"NPC lookup mismatch")
	for p in [Vector2(825,1020),Vector2(900,1300),Vector2(875,1750)]: check(not g.is_blocked(p,p),"Spawn or main path blocked")
	for p in [Vector2(1779,1120),Vector2(1781,1120),Vector2(874,2599),Vector2(874,2601),Vector2(4999,3000),Vector2(5001,3000)]: check(g.visual_region_at(p)==g.region_at(p),"Art crosses region border")
	g.player_pos=Vector2(1680,1120)
	g.move_with_collision(Vector2(240,0))
	check(g.player_pos.x<1729,"Roll crossed closed gate")
	g.opened_village_gates[g.VILLAGE_GATES[0]]=true
	g.move_with_collision(Vector2(240,0))
	check(g.player_pos.x>1780,"Opened gate cannot be crossed")
	g.level=1
	g.opened_village_gates[g.VILLAGE_GATES[1]]=true
	check(not g.is_blocked(Vector2(875,2600),Vector2(875,2500)),"Ordinary gate still blocked by level")
	check(g.region_available(2),"Low-level player cannot access ordinary region")
	g.bosses_defeated=[false,false,false]
	check(g.is_blocked(Vector2(5000,6200),Vector2(4900,6200)),"Kriegsherr boss gate not sealed")
	check(g.boss_gate_name(0)=="Kriegsherr","Boss gate 0 label names wrong boss")
	check(g.boss_gate_name(1)=="Arkanhüter","Boss gate 1 label names wrong boss")
	check(not g.region_available(4),"Boss-locked region opened before Kriegsherr")
	g.bosses_defeated[0]=true
	check(not g.is_blocked(Vector2(5000,6200),Vector2(4900,6200)),"Kriegsherr victory did not open gate")
	check(g.region_available(4),"Kriegsherr victory did not unlock existing boss-gated region")
	g.level=1
	check(g.region_available(12),"High recommended level still blocks an ungated region")
	for i in g.WAYSTONES.size():
		var stone: Vector2 = g.WAYSTONES[i]
		var arrival: Vector2 = g.waystone_arrival(i)
		check(g.is_blocked(stone,stone),"Waystone core has no collider")
		check(g.region_at(arrival)==g.region_at(stone),"Waystone arrival left its region: %d" % i)
		check(not g.is_blocked(arrival,arrival),"Waystone arrival obstructed: %d at %s" % [i,arrival])
	for role in 3:
		g.class_id=role
		g.class_mastery_unlocked=role!=1
		g.arcane_step_learned=false
		g.facing=Vector2.RIGHT
		g.dash_cooldown=0.0
		g.dodge()
		check(g.dash_timer>0 and g.dodge_duration>0,"Normal dodge did not start")
		check(g.dash_dir.is_normalized(),"Dodge direction invalid")
	g.class_id=1
	g.class_mastery_unlocked=true
	g.arcane_step_learned=true
	var blink_ok:=false
	for base in [Vector2(2250,1280),Vector2(2600,1740),g.region_rect(1).get_center(),g.region_rect(3).get_center()]:
		var expected_region:int=g.region_at(base)
		var safe_origin:Vector2=g.safe_world_teleport_destination(base,expected_region)
		for direction in [Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP]:
			g.player_pos=safe_origin
			g.facing=direction
			g.energy=100.0
			g.dash_timer=0.0
			g.dash_cooldown=0.0
			var blink_origin:Vector2=g.player_pos
			g.dodge()
			if g.player_pos.distance_to(blink_origin)>40.0 and g.dash_timer==0.0:
				blink_ok=true
				break
		if blink_ok:break
	check(blink_ok,"Mage rift blink did not teleport from any safe test point")
	for look in [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]: check(absf(g.weapon_hand_offset(look).x)>=22,"Weapon hand overlaps face")
	g.free()
	print("MAP_LOGIC_RESULT failures=",failures," · levels advisory, boss seals named and authoritative")
	quit(0 if failures==0 else 1)
