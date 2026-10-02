extends Node2D
## Real TileMapLayers, matching the existing world coordinates and navigation.
const TILE := 32
const BOUNDS := Rect2(0,0,1780,2600)
const PLAZA := Rect2(384,640,992,1024)
const GARDENS := [Rect2(416,672,192,224),Rect2(1152,672,192,224),Rect2(416,1344,224,288),Rect2(1152,1344,192,256)]
# Exact live exits: east -> meadow, south -> coast. Do not snap gate coordinates.
const EAST_EXIT := Vector2(1780,1120)
const SOUTH_EXIT := Vector2(875,2600)
const ATLAS_PATH := "res://art/start32/terrain_32.webp"
static var shared_tileset: TileSet
static var cells: Dictionary = {}
static var terrain: Dictionary = {}
static var flower_cells: Dictionary = {}
static var ground_cells: Dictionary = {}
static var ground_sources: Dictionary = {}
static var cell_sources: Dictionary = {}
static var grass_tones := [Color(1.0,1.0,1.0),Color(1.08,1.06,0.92),Color(0.94,0.98,0.94),Color(1.02,1.02,0.98),Color(1.04,1.03,0.95)]
var world_bounds := BOUNDS
var road_distance: Callable
var ground: TileMapLayer
var paths: TileMapLayer
var decoration: TileMapLayer

static func seed_at(cell: Vector2i) -> int:
	return posmod(cell.x*97+cell.y*173+cell.x*cell.y*13,8191)

static func prepare(_distance: Callable) -> void:
	if shared_tileset != null: return
	shared_tileset=TileSet.new();shared_tileset.tile_size=Vector2i(TILE,TILE)
	var texture:Texture2D=load(ATLAS_PATH)
	for source_id in grass_tones.size():
		var atlas:=TileSetAtlasSource.new()
		atlas.texture=texture;atlas.texture_region_size=Vector2i(TILE,TILE)
		for y in 12:
			for x in 24:
				atlas.create_tile(Vector2i(x,y))
				atlas.get_tile_data(Vector2i(x,y),0).modulate=grass_tones[source_id]
		shared_tileset.add_source(atlas,source_id)
	var noise:=FastNoiseLite.new();noise.seed=7041;noise.frequency=0.008;noise.fractal_octaves=2
	var routes:Array=[PackedVector2Array([Vector2(900,1050),Vector2(1270,1110),Vector2(1460,1210),Vector2(1680,1210),EAST_EXIT]),PackedVector2Array([Vector2(900,1300),Vector2(875,1760),Vector2(850,1920),Vector2(920,2176),Vector2(875,2368),SOUTH_EXIT])]
	# All live houses and NPCs retain their interaction/collision coordinates.
	var homes:Array=[]
	for shop in preload("res://components/village_layout.gd").SHOPS:
		if shop.has("shared_with"): continue
		homes.append({"pos":shop["house"],"kind":str(shop["kind"])})
	for home_info:Dictionary in homes:
		var home:Vector2=home_info["pos"]
		var kind:String=home_info["kind"]
		var door:=home+Vector2(96,180)
		if kind=="borin":door=home+Vector2(128,240)
		elif kind=="arena":door=home+Vector2(192,260)
		var entry:=Vector2(clampf(door.x,448,1312),clampf(door.y,704,1600))
		# Southern homes connect to the nearby main footpath rather than long diagonal tracks.
		if door.y>1664:entry=Vector2(875,door.y)
		var bend:=door.lerp(entry,0.5)+Vector2(0,16)
		routes.append(PackedVector2Array([door,bend,entry]))
	for x in 56:
		for y in 82:
			var cell:=Vector2i(x,y);var center:=Vector2(cell*TILE)+Vector2.ONE*16
			var garden:=false
			for r in GARDENS:
				if ((center-r.get_center())/(r.size*0.5)).length_squared()<=1.0:garden=true
			var near:=Vector2(clampf(center.x,PLAZA.position.x+96,PLAZA.end.x-96),clampf(center.y,PLAZA.position.y+96,PLAZA.end.y-96))
			var paved:=PLAZA.has_point(center) and center.distance_to(near)<=96 and not garden
			var route_d:=route_distance(center,routes)
			var block_center:=Vector2(floori(x/4.0)*128+64,floori(y/4.0)*128+64)
			var flowers:=noise.get_noise_2dv(block_center)>0.28 and route_d>96 and not PLAZA.grow(64).has_point(center)
			var tone:=noise.get_noise_2dv(center)
			ground_cells[cell]=Vector2i(posmod(x,4)+(4 if flowers else 0),posmod(y,4))
			ground_sources[cell]=2 if tone< -0.12 else (3 if tone>0.12 else 0)
			terrain[cell]=2 if paved else (1 if route_d<64 else 0)
			cell_sources[cell]=0 if paved else (1 if route_d<36 else 4)
	for cell:Vector2i in terrain:
		cells[cell]=Vector2i(posmod(cell.x,4),posmod(cell.y,4))
		if terrain[cell]==2:
			var mask:=0;var neighbors:=[Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT]
			for n in 4:
				if int(terrain.get(cell+neighbors[n],0))==2:mask|=1<<n
			cells[cell]=Vector2i(mask,8+posmod(floori(cell.x/3.0)*7+floori(cell.y/3.0)*13,4))

static func route_distance(p:Vector2,routes:Array)->float:
	var nearest:=100000.0
	for route in routes:
		for i in range(route.size()-1):nearest=minf(nearest,p.distance_to(Geometry2D.get_closest_point_to_segment(p,route[i],route[i+1])))
	return nearest

static func grass_coord(cell:Vector2i)->Vector2i:
	return ground_cells.get(cell,Vector2i(posmod(cell.x,4),posmod(cell.y,4)))
static func kind_at(point:Vector2)->int:
	if not BOUNDS.has_point(point):return 0
	prepare(Callable())
	return int(terrain.get(Vector2i(floori(point.x/TILE),floori(point.y/TILE)),0))

static func paint(c: CanvasItem,bounds: Rect2,distance: Callable) -> void:
	prepare(distance)
	var area := bounds.intersection(BOUNDS)
	if not area.has_area(): return
	var texture: Texture2D = (shared_tileset.get_source(0) as TileSetAtlasSource).texture
	for x in range(maxi(0,floori(area.position.x/TILE)),mini(56,ceili(area.end.x/TILE))):
		for y in range(maxi(0,floori(area.position.y/TILE)),mini(82,ceili(area.end.y/TILE))):
			var cell := Vector2i(x,y)
			var position := Vector2(cell*TILE)
			var target := Rect2(position,Vector2.ONE*TILE).intersection(BOUNDS)
			var source := Rect2(Vector2(grass_coord(cell)*TILE),target.size)
			c.draw_texture_rect_region(texture,target,source,grass_tones[int(ground_sources.get(cell,0))])
			var atlas: Vector2i = cells[cell]
			if terrain[cell]>0: c.draw_texture_rect_region(texture,target,Rect2(Vector2(atlas*TILE),target.size),grass_tones[int(cell_sources.get(cell,0))])
			if flower_cells.has(cell): c.draw_texture_rect_region(texture,target,Rect2(Vector2(Vector2i(flower_cells[cell])*TILE),target.size))

func _ready() -> void:
	prepare(road_distance)
	var clip := Control.new()
	clip.name = "Map0Boundary"
	clip.size = BOUNDS.size
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(clip)
	ground = make_layer(clip,"Grass32")
	paths = make_layer(clip,"PathsAndPlaza32")
	decoration = make_layer(clip,"Flowers32")
	var area := world_bounds.intersection(BOUNDS)
	for x in range(maxi(0,floori(area.position.x/TILE)),mini(56,ceili(area.end.x/TILE))):
		for y in range(maxi(0,floori(area.position.y/TILE)),mini(82,ceili(area.end.y/TILE))):
			var cell := Vector2i(x,y)
			ground.set_cell(cell,int(ground_sources.get(cell,0)),grass_coord(cell))
			var atlas: Vector2i = cells[cell]
			if terrain[cell]>0: paths.set_cell(cell,int(cell_sources.get(cell,0)),atlas)
			if flower_cells.has(cell): decoration.set_cell(cell,0,flower_cells[cell])
	ground.update_internals()
	paths.update_internals()
	decoration.update_internals()

func make_layer(parent: Node,title: String) -> TileMapLayer:
	var layer := TileMapLayer.new()
	layer.name = title
	layer.tile_set = shared_tileset
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	layer.collision_enabled = false
	layer.navigation_enabled = false
	parent.add_child(layer)
	return layer
