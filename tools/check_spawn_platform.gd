extends SceneTree
class TestGame:
	extends "res://main.gd"
	func _ready():pass
	func _process(_dt):pass
	func _draw():pass
func _initialize():
	var g:=TestGame.new();root.add_child(g);g.reset_class_skills();g.player_pos=Vector2(825,1095)
	var center:Vector2=g.WAYSTONES[0]
	assert(g.is_blocked(center))
	assert(g.projectile_world_blocked(center))
	for side in [-1,1]:assert(g.projectile_world_blocked(center+Vector2(side*152,8)))
	assert(not g.projectile_world_blocked(center+Vector2(0,180)))
	for side in [-1,1]:assert(g.is_blocked(center+Vector2(side*152,8)))
	for x in [center.x-40,center.x,center.x+40]:
		for y in range(80,260,10):assert(not g.is_blocked(center+Vector2(x-center.x,y)))
	for side in [-1,1]:
		for y in range(-56,140,16):assert(not g.is_blocked(center+Vector2(side*104,y)))
	for rect in g.SpawnStoneBody.solids():assert(g.is_blocked(center+rect.get_center()))
	var render=preload("res://components/spawn_platform_32.gd")
	assert(render.height_at(center,center)==16)
	assert(render.height_at(center+Vector2(0,500),center)==0)
	assert(g.REFERENCE_WELL.x>center.x+256+44)
	assert(g.SpawnStoneBody.accepted_move(Vector2(0,70),Vector2(0,-70),15).y>=47)
	assert(g.SpawnStoneBody.accepted_move(Vector2(104,70),Vector2(104,-56),15)==Vector2(104,-56))
	assert(g.SpawnStoneBody.accepted_move(Vector2.ZERO,Vector2(0,80),15)==Vector2(0,80))
	var body=g.SpawnStoneBody.attach(g,0);assert(body is StaticBody2D and body.get_child_count()==g.SpawnStoneBody.solids().size())
	print("SPAWN_PLATFORM_CHECK passed core and pillar collision, 4-tile stairs, both walk-around routes, height and well clearance")
	g.queue_free();quit()
