extends RefCounted
const TILE:int=32
const FOOTPRINT:Vector2i=Vector2i(16,16)
const STAIR_WIDTH:int=4

static func solids(variant:int=0)->Array[Rect2]:
	var half_width:float=64.0 if variant==3 else 48.0
	return [Rect2(-half_width,-32,half_width*2,64),Rect2(-168,-8,32,32),Rect2(136,-8,32,32),Rect2(-256,-104,32,300),Rect2(224,-104,32,300),Rect2(-224,-104,448,24),Rect2(-224,166,144,30),Rect2(80,166,144,30)]

static func attach(parent:Node2D,variant:int)->StaticBody2D:
	var body:=StaticBody2D.new()
	body.name="SpawnsteinKollision";body.collision_layer=1;body.collision_mask=0
	for rect in solids(variant):
		var collider:=CollisionShape2D.new()
		var shape:=RectangleShape2D.new()
		shape.size=rect.size;collider.shape=shape;collider.position=rect.get_center()
		body.add_child(collider)
	parent.add_child(body)
	return body

static func blocks(local_position:Vector2,variant:int,margin:float=0)->bool:
	for rect in solids(variant):
		if rect.grow(margin).has_point(local_position):return true
	return false

static func accepted_move(origin:Vector2,target:Vector2,margin:float)->Vector2:
	# Existing saves inside an edited solid may leave it without getting trapped.
	if blocks(origin,0,margin) and not blocks(target,0,margin):return target
	var steps:int=maxi(1,ceili(origin.distance_to(target)/8.0))
	var accepted:=origin
	for step in range(1,steps+1):
		var point:=origin.lerp(target,float(step)/steps)
		if blocks(point,0,margin):break
		accepted=point
	return accepted
