extends RefCounted
## Map 0 visual zoning. Changes only the rendered floor; logical materials, collision and navigation stay untouched.
const Plan=preload("res://components/map0_ground_plan_32.gd")
const Profile=preload("res://components/terrain/overworld_ground_profile_32.gd")
const VillageLayout=preload("res://components/village_layout.gd")
const VillageBuildings=preload("res://components/village_buildings.gd")

const SPAWN_CENTER:=Vector2(832,1024)
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

static func resolve(legacy_id:String,cell:Vector2i,route_distance:float)->String:
	prepare()
	var p:=Plan.center(cell)

	# Arena keeps its existing geometry, but only uses floor families.
	if Plan.ARENA_YARD.has_point(p):
		if arena_door!=Vector2.ZERO and absf(p.x-arena_door.x)<=192.0 and p.y>=arena_door.y-48.0 and p.y<=arena_door.y+224.0:
			return Profile.ARENA_ENTRY
		if arena_edge_distance(p)<42.0:
			return Profile.ARENA_BORDER
		return Profile.ARENA_GROUND

	# The spawn is a coherent large-stone courtyard, feathered into paths instead of a hard rectangle.
	if Profile.soft_radius(p,SPAWN_CENTER,SPAWN_STONE_RADIUS,cell,48.0):
		return Profile.PLAZA
	if Profile.soft_radius(p,SPAWN_CENTER,SPAWN_PATH_RADIUS,cell,42.0):
		return Profile.PATH

	# Each house receives a readable stone apron that naturally joins the path network.
	var door_d:=nearest_normal_door(p)
	if door_d<104.0:
		return Profile.APRON
	if door_d<154.0 and route_distance<118.0:
		return Profile.PATH

	# Gardens stay green; only their actual walking line becomes a soft garden path.
	if Plan.is_garden(cell):
		return Profile.GARDEN_PATH if route_distance<80.0+Profile.edge_noise(cell,4)*3.0 else Profile.GRASS

	# Main village circulation: a narrow stone backbone, then a broader warm dirt path.
	if route_distance<38.0+Profile.edge_noise(cell,3)*2.0:
		return Profile.STONE
	if route_distance<104.0+Profile.edge_noise(cell,4)*3.0:
		return Profile.PATH

	# Property pads no longer become rectangular dirt fields. Away from doors they blend back into grass.
	if Plan.is_property(cell):
		if route_distance<136.0:
			return Profile.PATH
		return Profile.GRASS

	# Outer village/nature bands.
	var edge:=Plan.edge_distance(p)
	if edge<76.0:return Profile.MOSS
	if edge<148.0 and Plan.seed_at(cell)%4!=0:return Profile.FOREST

	# Sparse calm variation only in natural ground; no random stone/cobble cells.
	if legacy_id=="grass_moss":return Profile.MOSS
	if legacy_id=="forest_floor" and Plan.seed_at(cell)%3==0:return Profile.FOREST
	return Profile.GRASS
