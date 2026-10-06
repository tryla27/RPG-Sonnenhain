extends RefCounted
## Visual-only elevation pass for Map 0. No collision/pathfinding changes are introduced here.
const Plan=preload("res://components/map0_ground_plan_32.gd")

static func coord(cell:Vector2i,route_distance:float)->Vector2i:
	var p:=Plan.center(cell)
	var below:=Plan.center(cell+Vector2i.DOWN) if Plan.in_bounds(cell+Vector2i.DOWN) else p+Vector2(0,32)
	if Plan.PLAZA.has_point(p) and not Plan.PLAZA.has_point(below):
		return Vector2i(posmod(cell.x*3+cell.y*5,8),1 if route_distance<96.0 else 0)
	if Plan.ARENA_YARD.has_point(p) and not Plan.ARENA_YARD.has_point(below):
		return Vector2i(posmod(cell.x*5+cell.y*3,8),3 if route_distance<128.0 else 2)
	return Vector2i(-1,-1)
