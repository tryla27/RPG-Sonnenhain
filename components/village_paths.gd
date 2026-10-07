extends RefCounted
const WIDTH:=96.0
const HALF_WIDTH:=WIDTH*0.5
static var ROUTES:=[
	PackedVector2Array([Vector2(544,608),Vector2(544,1408),Vector2(544,2544),Vector2(875,2544),Vector2(875,2600)]),
	PackedVector2Array([Vector2(544,608),Vector2(1536,608)]),
	PackedVector2Array([Vector2(310,589),Vector2(310,688),Vector2(544,688)]),
	PackedVector2Array([Vector2(1472,510),Vector2(1472,624),Vector2(1536,624)]),
	PackedVector2Array([Vector2(320,1054),Vector2(320,1104),Vector2(544,1104)]),
	PackedVector2Array([Vector2(316,1569),Vector2(316,1664),Vector2(544,1664)]),
	PackedVector2Array([Vector2(321,2282),Vector2(321,2368),Vector2(544,2368)]),
	PackedVector2Array([Vector2(825,1136),Vector2(825,1408),Vector2(544,1408)]),
	PackedVector2Array([Vector2(825,1408),Vector2(1648,1408),Vector2(1648,1184),Vector2(1780,1120)]),
	PackedVector2Array([Vector2(1312,1374),Vector2(1312,1408)]),
	PackedVector2Array([Vector2(1648,1408),Vector2(1648,2544),Vector2(544,2544)]),
	PackedVector2Array([Vector2(1081,2420),Vector2(1081,2544)])
]
static func closest(p:Vector2)->Vector2:
	var best:=Vector2.ZERO
	var d:=INF
	for route in ROUTES:
		for i in range(route.size()-1):
			# Center axes on tile centers so a 96px lane is actually three tiles,
			# rather than two tiles when its axis falls on a grid boundary.
			var a:Vector2=(route[i]/32.0).floor()*32.0+Vector2(16,16)
			var b:Vector2=(route[i+1]/32.0).floor()*32.0+Vector2(16,16)
			var q:=Geometry2D.get_closest_point_to_segment(p,a,b)
			if p.distance_squared_to(q)<d:d=p.distance_squared_to(q);best=q
	return best
static func distance(p:Vector2)->float:return p.distance_to(closest(p))
static func flower_corner(p:Vector2)->bool:
	return (p.x<480 and (p.y<160 or p.y>2380 or (p.y>1632 and p.y<1832))) or (p.x>1290 and p.y<620)
