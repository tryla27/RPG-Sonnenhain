extends RefCounted
## Map 0 visual zoning. Changes only the rendered floor; logical materials, collision and navigation stay untouched.
const Plan=preload("res://components/map0_ground_plan_32.gd")
const Profile=preload("res://components/terrain/overworld_ground_profile_32.gd")
const VillageLayout=preload("res://components/village_layout.gd")
const VillageBuildings=preload("res://components/village_buildings.gd")
const Paths=preload("res://components/village_paths.gd")
const Elevation=preload("res://components/village_elevation.gd")
const CROSSINGS:=[Rect2(576,576,544,96),Rect2(496,976,128,192),Rect2(752,1184,128,160)]

const SPAWN_CENTER:=Vector2(825,895)
const SPAWN_PLATFORM:=Rect2(569,655,512,480)
const SPAWN_STONE_RADIUS:=252.0
const SPAWN_PATH_RADIUS:=338.0

static var door_points:Array=[]
static var arena_door:=Vector2.ZERO

static func prepare()->void:
	if not door_points.is_empty():return
	for shop in VillageLayout.SHOPS:
		if shop.has("shared_with"):continue
		var home:Vector2=shop["house"]
		var kind:String=str(shop["kind"])
		var door:=VillageBuildings.door(home,kind)
		door_points.append({"door":door,"kind":kind})
		if kind=="arena":arena_door=door

static func nearest_normal_door(p:Vector2)->float:
	prepare()
	var nearest:=INF
	for row in door_points:
		if str(row["kind"])=="arena":continue
		nearest=minf(nearest,p.distance_to(Vector2(row["door"])))
	return nearest

static func arena_edge_distance(p:Vector2)->float:
	var r:Rect2=Plan.ARENA_YARD
	return minf(minf(p.x-r.position.x,r.end.x-p.x),minf(p.y-r.position.y,r.end.y-p.y))

static func rounded_distance(p:Vector2,rect:Rect2,radius:float)->float:
	var q:Vector2=(p-rect.get_center()).abs()-rect.size*0.5+Vector2.ONE*radius
	return Vector2(maxf(q.x,0),maxf(q.y,0)).length()+minf(maxf(q.x,q.y),0)-radius

static func contour(p:Vector2)->float:
	# Coherent low-frequency shapes; avoid random isolated tiles at the verge.
	return sin(p.x*0.009+p.y*0.003)*10.0+cos(p.y*0.011-p.x*0.004)*7.0

static func resolve(legacy_id:String,cell:Vector2i,route_distance:float)->String:
	prepare()
	var p:=Plan.center(cell)
	var path_distance:=Paths.distance(p)
	if path_distance<Paths.HALF_WIDTH:
		for crossing in CROSSINGS:
			if crossing.has_point(p):return "spawn_crossing"
	if Elevation.paved(p):return Profile.APRON

	# Arena keeps its existing geometry, but only uses floor families.
	if rounded_distance(p,Plan.ARENA_YARD,48)<contour(p)*0.4:
		if path_distance<Paths.HALF_WIDTH:return Profile.STONE
		if arena_door!=Vector2.ZERO and absf(p.x-arena_door.x)<=192.0 and p.y>=arena_door.y-48.0 and p.y<=arena_door.y+224.0:
			return Profile.ARENA_ENTRY
		if arena_edge_distance(p)<30.0:
			return Profile.ARENA_BORDER
		return Profile.GRASS

	# The spawn is a coherent large-stone courtyard, feathered into paths instead of a hard rectangle.
	if rounded_distance(p,SPAWN_PLATFORM.grow(72),64)<contour(p):
		return Profile.PLAZA
	if path_distance<Paths.HALF_WIDTH:return Profile.STONE
	if rounded_distance(p,SPAWN_PLATFORM.grow(152),96)<contour(p):
		return Profile.GRASS

	# Each house receives a readable stone apron that naturally joins the path network.
	var door_d:=nearest_normal_door(p)
	if door_d<88.0+contour(p)*0.3:
		return Profile.APRON
	if path_distance<Paths.HALF_WIDTH:return Profile.STONE
	if door_d<154.0 and route_distance<118.0:
		return Profile.GRASS

	# Gardens stay green; only their actual walking line becomes a soft garden path.
	if Plan.is_garden(cell):
		return Profile.GRASS

	# Main village circulation: a narrow stone backbone, then a broader warm dirt path.
	if route_distance<36.0+contour(p)*0.35:
		return Profile.STONE
	if route_distance<100.0+contour(p):
		return Profile.GRASS

	# Property pads no longer become rectangular dirt fields. Away from doors they blend back into grass.
	if Plan.is_property(cell):
		if route_distance<112.0+contour(p):
			return Profile.GRASS
		return Profile.GRASS

	# Outer village/nature bands.
	var edge:=Plan.edge_distance(p)
	if edge<44.0+contour(p)*0.4:return Profile.MOSS
	# Existing trees stand on the SAME grass. Fallen leaves are a transparent overlay,
	# not a brown forest-floor carpet clipped to the tile grid.

	# Sparse calm variation only in natural ground; no random stone/cobble cells.
	if legacy_id=="grass_moss" and sin(p.x*0.004)+cos(p.y*0.005)>1.2:return Profile.MOSS
	return Profile.GRASS
