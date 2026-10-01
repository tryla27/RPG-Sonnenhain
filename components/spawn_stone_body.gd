extends RefCounted
const TILE:int=32
const FOOTPRINT:Vector2i=Vector2i(16,16)
const STAIR_WIDTH:int=4
static func attach(parent:Node2D,variant:int)->StaticBody2D:
	var body:=StaticBody2D.new();body.name="SpawnsteinKollision";body.collision_layer=1;body.collision_mask=0
	var polygon:=CollisionPolygon2D.new();polygon.name="FesterSteinkern"
	var half_width:float=64.0 if variant==3 else 48.0
	polygon.polygon=PackedVector2Array([Vector2(-half_width,-32),Vector2(half_width,-32),Vector2(half_width,32),Vector2(-half_width,32)])
	body.add_child(polygon)
	for side in [-1,1]:
		var pillar:=CollisionShape2D.new();var shape:=RectangleShape2D.new();shape.size=Vector2(36,24);pillar.shape=shape;pillar.position=Vector2(side*96,12);body.add_child(pillar)
	parent.add_child(body)
	return body
static func blocks(local_position:Vector2,variant:int,margin:float=0)->bool:
	var half_width:float=64.0 if variant==3 else 48.0
	if Rect2(-half_width,-32,half_width*2,64).grow(margin).has_point(local_position):return true
	for side in [-1,1]:
		if Rect2(Vector2(side*96-18,0),Vector2(36,24)).grow(margin).has_point(local_position):return true
	return false
