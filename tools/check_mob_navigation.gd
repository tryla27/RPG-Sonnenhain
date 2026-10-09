extends SceneTree
const Nav=preload("res://components/mob_navigation.gd")
const Combat=preload("res://components/mob_combat.gd")
class World extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
class Game extends "res://main.gd":
	var blocks:Array=[]
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
	func region_at(_point:Vector2)->int:return 1
	func blocked_by_region_wall(_point:Vector2)->bool:return false
	func waystone_safe_at(point:Vector2)->bool:return point.x>=700
	func terrain_blocked(point:Vector2,radius:float=-1.0)->bool:
		for block in blocks:
			if block.grow(maxf(0.0,radius)).has_point(point):return true
		return false
	func projectile_collision(a:Vector2,b:Vector2,_server:bool,_context:String="",_room:int=-1,_height:float=0)->Dictionary:
		return {"hit":not Nav.clear_segment(a,b,func(p:Vector2)->bool:return not terrain_blocked(p,0)),"pos":b}
var failures:=0
func check(value:bool,label:String)->void:
	if not value:failures+=1;print("FAIL ",label)
func _initialize()->void:call_deferred("run")
func mob(type:int=3)->Dictionary:
	return {"uid":17,"type":type,"pos":Vector2.ZERO,"home":Vector2.ZERO,"hp":1000.0,"max_hp":1000.0,"stun":0.0,"seed":0.0,"attack_wait":0.0}
func travel(label:String,blocks:Array,origin:Vector2,target:Vector2,radius:float)->void:
	var walkable:=func(point:Vector2)->bool:
		for block in blocks:
			if block.grow(radius).has_point(point):return false
		return point.x<700
	var actor:Dictionary={"pos":origin,"uid":17}
	var collision:=false
	for frame in 1200:
		var previous:Vector2=actor["pos"]
		var direction:=Nav.direction(actor,target,1.0/60,walkable)
		var path:Array=actor.get("nav_path",[])
		var distance:=2.5
		if not path.is_empty():distance=minf(distance,previous.distance_to(path[0]))
		actor["pos"]=previous+direction*distance
		if not Nav.clear_segment(previous,actor["pos"],walkable):collision=true;break
		if Vector2(actor["pos"]).distance_to(target)<8:break
	if collision or Vector2(actor["pos"]).distance_to(target)>=8:print("ROUTE_RESULT ",label," pos=",actor["pos"]," collision=",collision," path=",actor.get("nav_path",[]))
	check(not collision and Vector2(actor["pos"]).distance_to(target)<8,label)
func run()->void:
	travel("tree detour",[Rect2(70,-30,60,60)],Vector2.ZERO,Vector2(220,0),14)
	travel("large body detour",[Rect2(70,-30,60,60)],Vector2.ZERO,Vector2(220,0),30)
	travel("U trap exit requires initial movement away",[Rect2(70,-110,30,220),Rect2(-100,-110,200,30),Rect2(-100,80,200,30)],Vector2.ZERO,Vector2(220,0),14)
	travel("multiple obstacles",[Rect2(60,-90,40,120),Rect2(130,-10,40,120)],Vector2.ZERO,Vector2(260,0),14)
	check(not Nav.clear_segment(Vector2.ZERO,Vector2(200,0),func(p:Vector2)->bool:return not Rect2(70,-20,2,40).grow(14).has_point(p)),"swept movement catches thin obstacle including body radius")
	var blocked:Dictionary={"pos":Vector2.ZERO,"uid":1}
	var safe:=func(point:Vector2)->bool:return point.x<80
	for frame in 180:
		var dir:=Nav.direction(blocked,Vector2(150,0),1.0/60,safe)
		var next:Vector2=blocked["pos"]+dir*2
		if Nav.clear_segment(blocked["pos"],next,safe):blocked["pos"]=next
	check(Vector2(blocked["pos"]).x<80,"unreachable protected zone stays protected")
	var game:=Game.new()
	for type in range(27):
		if type in [12,13,14]:continue
		var actor:=mob(type)
		var config:=Combat.profile(type,game.ENEMY_TYPES[type],10,10)
		Combat.step(actor,config,[{"id":2,"pos":Vector2(100,0)}],.01)
		actor["attack_state"]={};actor["pos"]=Vector2(950,0);actor["attack_wait"]=1.0
		var action:=Combat.step(actor,config,[{"id":2,"pos":Vector2(2000,0)}],.1)
		check(action["move"].x>0 and not actor["returning"],"persistent pursuit "+str(type))
		actor["pos"]=Vector2.ZERO
		action=Combat.step(actor,config,[{"id":2,"pos":Vector2(60,0)}],.1)
		check(action["move"].x>0,"no close-range retreat "+str(type))
		actor["attack_wait"]=0.0
		action=Combat.step(actor,config,[{"id":2,"pos":Vector2(60,0),"attack_clear":false}],.1)
		check(actor["attack_state"].is_empty() and action["move"].x>0,"blocked attack approaches instead "+str(type))
	var wolf:=mob()
	var profile:=Combat.profile(3,game.ENEMY_TYPES[3],10,10)
	Combat.step(wolf,profile,[{"id":2,"pos":Vector2(150,0)}],.01)
	check(is_equal_approx(float(wolf["attack_state"]["ability"]["windup"]),.4),"half wolf jump cast")
	Combat.step(wolf,profile,[{"id":2,"pos":Vector2(220,0)}],.8)
	var action:=Combat.step(wolf,profile,[{"id":2,"pos":Vector2(220,0)}],.01)
	check(action["move"].x>0,"forward pursuit during recovery")
	# Exercise the actual shared movement driver, including blocked attack sight.
	game.skill_levels.resize(16);game.skill_levels.fill(0)
	game.player_pos=Vector2(260,0);game.hp=100;game.death_timer=0
	game.blocks=[Rect2(70,-50,40,100)]
	var beetle:=mob(1);game.enemies=[beetle]
	var touched:=false
	for frame in 900:
		game.advance_mob(beetle,1.0/60,false)
		if game.terrain_blocked(beetle["pos"],game.mob_hit_radius(beetle)):touched=true;break
		if Vector2(beetle["pos"]).distance_to(game.player_pos)<45:break
	check(not touched and Vector2(beetle["pos"]).distance_to(game.player_pos)<45,"actual ranged mob routes around blocking tree and closes distance")
	var dedicated:=Game.new()
	dedicated.skill_levels.resize(16);dedicated.skill_levels.fill(0)
	dedicated.blocks=game.blocks
	dedicated.remote_players[101]={"pos":[260.0,0.0],"hp":100.0,"context":"world"}
	var server_beetle:=mob(1);dedicated.enemies=[server_beetle]
	beetle=mob(1);game.enemies=[beetle]
	for frame in 600:
		game.advance_mob(beetle,1.0/60,false)
		dedicated.advance_mob(server_beetle,1.0/60,true)
		check(Vector2(beetle["pos"]).distance_to(server_beetle["pos"])<.001,"shared offline/server route")
	dedicated.free()
	# Real generated geometry, including deterministic cached tree roots.
	var world:=World.new()
	var tested:=false
	var started:=Time.get_ticks_usec()
	for x in range(35,65):
		for y in range(8,28):
			var tree:Dictionary=world.decorative_tree_in_cell(x,y)
			if tree.is_empty():continue
			var center:Vector2=tree["point"]
			var from:=center-Vector2(100,0)
			var to:=center+Vector2(100,0)
			var walker:=mob();walker["pos"]=from
			var clear:=func(point:Vector2)->bool:return world.mob_walkable(point,from,walker,true)
			if not clear.call(from) or not clear.call(to):continue
			var path:=Nav.route(from,to,clear)
			if path.is_empty() or Vector2(path[-1]).distance_to(to)>1:continue
			var previous:=from
			for waypoint in path:
				check(Nav.clear_segment(previous,waypoint,clear),"real tree path clears body and region boundary")
				previous=waypoint
			tested=true;break
		if tested:break
	check(tested,"route found around a real generated tree")
	print("REAL_TREE_ROUTE_MS ",float(Time.get_ticks_usec()-started)/1000.0)
	world.free()
	game.free()
	print("MOB_NAVIGATION_CHECK failures=",failures," detours / U trap / body clearance / protected zones / persistent chase / recovery / blocked attacks")
	quit(1 if failures else 0)
