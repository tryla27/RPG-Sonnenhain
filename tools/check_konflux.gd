extends SceneTree
const K=preload("res://components/konflux_map.gd")
var failures:=0
var checks:=0
func check(ok: bool,label: String) -> void:
	checks+=1
	if not ok:
		failures+=1
		push_error(label)
func _initialize() -> void:
	check(K.SIZE==Vector2(80000,80000),"Map dimensions")
	check(K.SIZE.x/32*K.SIZE.y/32==6250000,"Tile extent")
	check(K.safe(K.CENTER) and not K.safe(K.CENTER+Vector2(1300,0)),"Protection boundary")
	check(not K.blocked(K.CENTER,K.CENTER),"Spawn walkable")
	for x in K.BRIDGE_X:
		for y in range(int(K.river_y(x)-6800),int(K.river_y(x)+6800),12):
			var p:=Vector2(x,y)
			check(not K.blocked(p,p-Vector2(0,12)),"Bridge traversal %s"%p)
	check(K.water(Vector2(16000,K.river_y(16000)))==2,"Deep water")
	check(K.blocked(Vector2(16000,K.river_y(16000)),Vector2(16000,K.river_y(16000)+12)),"Deep water blocks")
	for r in K.PLATEAUS:
		var start:=Vector2(r.get_center().x,r.end.y+780)
		for step in 70:
			var target:=start-Vector2(0,12)
			check(not K.blocked(target,start),"Ramp smooth %s"%target)
			start=target
		check(K.height_at(start)>0,"Ramp reaches plateau")
		var edge:=Vector2(r.position.x-1,r.get_center().y)
		check(K.blocked(edge+Vector2(4,0),edge),"Cliff cannot be climbed")
	for id in K.BUILDING_IDS:
		var p: Vector2=K.LOCATIONS[id]
		check(K.blocked(p-Vector2(0,40),p),"Building body")
		check(not K.blocked(p+Vector2(0,100),p+Vector2(0,110)),"Building door reachable")
	for room in 4:
		check(not K.blocked(K.CENTER+Vector2(0,190),K.CENTER,room),"Interior spawn")
		check(K.blocked(K.CENTER+Vector2(300,0),K.CENTER,room),"Interior walls")
	check(not K.line_clear(K.CENTER+Vector2(-1500,0),K.CENTER+Vector2(1500,0)),"Safe zone blocks crossfire")
	var g=load("res://main.gd").new()
	g.reset_class_skills()
	g.creative_mode=false
	g.player_pos=Vector2(43000,45000)
	var a=g.konflux
	a.register_fighter(1,true,-1)
	a.register_fighter(2,true,-1)
	g.remote_players[2]={"pos":[43000.0,44920.0]}
	check(a.server_attack(g,2,-1,Vector2.DOWN,2),"PvP shot accepted")
	a.authority_update(g,0.15)
	check(float(a.fighter_stats[1]["hp"])<100,"PvP projectile deals damage")
	check(not a.server_attack(g,2,-1,Vector2.DOWN,2),"Server cooldown enforced")
	g.konflux.active=true
	var old_gold: int=g.gold
	a.hurt(g,1,1000,2)
	check(g.death_timer>0 and g.panel=="death","PvP death animation begins")
	g.respawn()
	check(g.player_pos==K.CENTER and g.hp==g.max_hp() and g.gold==old_gold,"PvP respawn without PvE penalty")
	g.player_pos=K.CENTER
	a.hurt(g,1,1000,2)
	check(float(a.fighter_stats[1]["hp"])>0,"Spawn damage denied")
	for r in K.PLATEAUS:
		g.player_pos=Vector2(r.position.x-40,r.get_center().y)
		g.move_with_collision(Vector2(400,0))
		check(g.player_pos.x<r.position.x,"Swept dodge cannot cross cliff")
	for path in ["buildings","events","props"]:
		var img:=Image.load_from_file("res://art/konflux/"+path+".webp")
		if img == null:
			check(false,"Cannot decode asset "+path)
			quit(1)
			return
		check(not img.is_empty() and img.get_pixel(0,0).a<0.01,"Transparent asset "+path)
	a.load_art()
	for x in 100: a.make_chunk(Vector2i(x,0))
	check(a.chunks.size()<=K.MAX_CHUNKS,"Bounded streaming cache")
	g.free()
	print("KONFLUX_CHECK: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)
