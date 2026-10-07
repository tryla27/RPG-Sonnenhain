extends RefCounted
## Maps the existing logical Map-0 material to a coherent visual family without changing collision/path geometry.
const Plan=preload("res://components/map0_ground_plan_32.gd")
const VillageLayout=preload("res://components/village_layout.gd")
const VillageBuildings=preload("res://components/village_buildings.gd")

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

static func near_normal_door(p:Vector2)->bool:
	prepare()
	for row in door_points:
		if str(row["kind"])=="arena":continue
		var door:Vector2=row["door"]
		if absf(p.x-door.x)<=112.0 and p.y>=door.y-26.0 and p.y<=door.y+112.0:return true
	return false

static func arena_edge_distance(p:Vector2)->float:
	var r:Rect2=Plan.ARENA_YARD
	return minf(minf(p.x-r.position.x,r.end.x-p.x),minf(p.y-r.position.y,r.end.y-p.y))

static func resolve(legacy_id:String,cell:Vector2i,route_distance:float)->String:
	prepare()
	var p:=Plan.center(cell)

	# Arena: actual ground in the yard, border only at the perimeter.
	if Plan.ARENA_YARD.has_point(p):
		if arena_door!=Vector2.ZERO and absf(p.x-arena_door.x)<=192.0 and p.y>=arena_door.y-48.0 and p.y<=arena_door.y+224.0:
			return "arena_entry_stone"
		if arena_edge_distance(p)<48.0:
			return "arena_border"
		return "arena_ground"

	if near_normal_door(p):return "building_apron"

	# Plaza stays visually coherent. Legacy cobble speckles no longer create dark single-cell noise.
	if Plan.PLAZA.has_point(p) and not Plan.is_garden(cell):
		return "plaza_stone"

	if Plan.is_garden(cell):
		return "garden_path" if route_distance<104.0 else "village_grass"

	# Property pads are warm paths/aprons rather than random dark cobble cells.
	if Plan.is_property(cell):
		if route_distance<76.0:return "building_apron"
		return "village_path"

	match legacy_id:
		"grass_meadow":return "village_grass"
		"grass_moss":return "moss_grass"
		"forest_floor":return "forest_ground"
		"earth_path":return "village_path"
		"village_stone":return "village_stone"
		"old_cobble":return "village_stone"
		"arcane_floor":return "plaza_stone"
	return "village_grass"
