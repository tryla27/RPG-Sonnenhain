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
		for x in [0,48,96,144,192]:
			for y in [0,40,80,120,160]: check(g.distance_to_trail(h+Vector2(x,y))>65,"House on road: %s"%h)
		check(g.is_blocked(h+Vector2(96,110),h+Vector2(96,190)),"House collider missing")
		check(not g.is_blocked(h+Vector2(96,180),h+Vector2(96,190)),"Door approach obstructed: %s"%h)
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
	check(g.is_blocked(Vector2(875,2600),Vector2(875,2500)),"South level gate bypassed")
	g.level=5
	check(not g.is_blocked(Vector2(875,2600),Vector2(875,2500)),"Unlocked south gate obstructed")
	for i in g.WAYSTONES.size():
		var stone: Vector2 = g.WAYSTONES[i]
		var arrival: Vector2 = g.waystone_arrival(i)
		check(g.is_blocked(stone,stone),"Waystone core has no collider")
		check(g.region_at(arrival)==g.region_at(stone),"Waystone arrival left its region: %d" % i)
		check(not g.is_blocked(arrival,arrival),"Waystone arrival obstructed: %d at %s" % [i,arrival])
	for role in 3:
		g.class_id=role
		g.arcane_step_learned=true
		g.facing=Vector2.RIGHT
		g.dodge()
		check(g.dash_timer>0 and g.dodge_duration>0,"Dodge did not start")
		check(g.dash_dir.is_normalized(),"Dodge direction invalid")
	for look in [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]: check(absf(g.weapon_hand_offset(look).x)>=22,"Weapon hand overlaps face")
	g.free()
	print("MAP_LOGIC_RESULT failures=",failures)
	quit(0 if failures==0 else 1)
