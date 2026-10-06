extends Node2D
## Map 0 runtime floor: logical 32px plan + new visual terrain families.
const Plan=preload("res://components/map0_ground_plan_32.gd")
const Catalog=preload("res://components/terrain/terrain_catalog_32.gd")
const Offer=preload("res://components/terrain/terrain_offer_32.gd")
const Selector=preload("res://components/terrain/terrain_selector_32.gd")
const TransitionRules=preload("res://components/terrain/terrain_transition_rules_32.gd")
const HeightRules=preload("res://components/terrain/terrain_height_rules_32.gd")
const TILE:=32
const BOUNDS:=Plan.BOUNDS
const EAST_EXIT:=Plan.EAST_GATE
const SOUTH_EXIT:=Plan.SOUTH_GATE
const MATERIAL_IDS:=["grass_meadow","grass_moss","forest_floor","earth_path","village_stone","old_cobble","arcane_floor"]
const NATURAL_MATERIALS:=["grass_meadow","grass_moss","forest_floor"]
const MATERIAL_TINTS:={"grass_meadow":Color.WHITE,"grass_moss":Color.WHITE,"forest_floor":Color.WHITE,"earth_path":Color.WHITE,"village_stone":Color.WHITE,"old_cobble":Color.WHITE,"arcane_floor":Color.WHITE}

static var shared_tileset:TileSet
static var ground_source_id:=-1
static var overlay_source_id:=-1
static var transition_source_id:=-1
static var height_source_id:=-1
static var source_ids:Dictionary={}
static var material_cells:Dictionary={}
static var visual_cells:Dictionary={}
static var visual_coords:Dictionary={}
static var transition_cells:Dictionary={}
static var overlay_cells:Dictionary={}
static var height_cells:Dictionary={}
static var terrain:Dictionary={}
var world_bounds:=BOUNDS
var road_distance:Callable
var ground:TileMapLayer
var paths:TileMapLayer
var decoration:TileMapLayer
var heights:TileMapLayer

static func seed_at(cell:Vector2i)->int:return Plan.seed_at(cell)

static func make_source(texture_path:String,columns:int,rows:int)->int:
	var atlas:=TileSetAtlasSource.new()
	atlas.texture=load(texture_path)
	atlas.texture_region_size=Vector2i(TILE,TILE)
	for y in rows:
		for x in columns:atlas.create_tile(Vector2i(x,y))
	var id:int=shared_tileset.get_next_source_id()
	shared_tileset.add_source(atlas,id)
	return id

static func prepare(_distance:Callable)->void:
	if shared_tileset!=null:return
	Offer.prepare()
	shared_tileset=TileSet.new();shared_tileset.tile_size=Vector2i(TILE,TILE)
	ground_source_id=make_source(Catalog.GROUND_ATLAS,4,12)
	overlay_source_id=make_source(Catalog.OVERLAY_ATLAS,8,2)
	transition_source_id=make_source(Catalog.TRANSITION_ATLAS,8,8)
	height_source_id=make_source(Catalog.HEIGHT_ATLAS,4,4)
	for id in Catalog.FAMILY_ORDER:source_ids[id]=ground_source_id
	for id in MATERIAL_IDS:source_ids[id]=ground_source_id

	var routes:Array=[
		PackedVector2Array([Vector2(832,960),Vector2(1120,960),Vector2(1456,960),Vector2(1664,1024),EAST_EXIT]),
		PackedVector2Array([Vector2(832,1184),Vector2(656,1456),Vector2(656,2440),Vector2(875,2440),SOUTH_EXIT]),
		PackedVector2Array([Vector2(384,1024),Vector2(832,1024),Vector2(1280,1024)]),
		PackedVector2Array([Vector2(832,608),Vector2(832,1024),Vector2(832,1440)])
	]
	for shop in preload("res://components/village_layout.gd").SHOPS:
		if shop.has("shared_with"):continue
		var home:Vector2=shop["house"]
		var kind:String=str(shop["kind"])
		var door:=preload("res://components/village_buildings.gd").door(home,kind)
		var entry:=Vector2(clampf(door.x,416,1248),clampf(door.y,640,1408))
		if door.y>1500:entry=Vector2(864,door.y)
		elif door.x<480:entry=Vector2(416,clampf(door.y,704,2208))
		elif door.x>1184:entry=Vector2(1248,clampf(door.y,640,2208))
		routes.append(PackedVector2Array([door,door.lerp(entry,0.5)+Vector2(0,16),entry]))

	var route_by_cell:Dictionary={}
	for x in Plan.GRID.x:
		for y in Plan.GRID.y:
			var cell:=Vector2i(x,y)
			var route_d:=route_distance(Plan.center(cell),routes)
			route_by_cell[cell]=route_d
			var legacy:String=Plan.material_for(cell,route_d)
			var visual:String=Offer.resolve(legacy,cell,route_d)
			material_cells[cell]=legacy
			visual_cells[cell]=visual
			visual_coords[cell]=Catalog.atlas_coord(visual,Selector.variant_index(visual,cell,4))
			terrain[cell]=0 if legacy in NATURAL_MATERIALS else (1 if legacy=="earth_path" else 2)

	var dirs:Array[Vector2i]=[Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT]
	for cell:Vector2i in visual_cells:
		var current:String=str(visual_cells[cell])
		for di in 4:
			var other:Vector2i=cell+dirs[di]
			if not Plan.in_bounds(other):continue
			var coord:Vector2i=TransitionRules.coord(current,str(visual_cells.get(other,current)),di)
			if coord.x>=0:
				transition_cells[cell]=coord
				break

	for cell:Vector2i in visual_cells:
		var family:String=str(visual_cells[cell]);var legacy:String=str(material_cells[cell])
		if legacy=="arcane_floor":overlay_cells[cell]=Vector2i(4+Selector.variant_index("arcane",cell,2),1)
		elif family in ["village_grass","moss_grass","forest_ground"] and Selector.chance("flora",cell,11):overlay_cells[cell]=Vector2i(Selector.variant_index("flowers",cell,4),0)
		elif family in ["village_path","garden_path","arena_ground"] and Selector.chance("tracks",cell,13):overlay_cells[cell]=Vector2i(Selector.variant_index("tracks",cell,2),1)
		elif family in ["village_stone","plaza_stone","old_cobble_rework","building_apron","arena_entry_stone","arena_border"] and Selector.chance("wear",cell,15):overlay_cells[cell]=Vector2i(4+Selector.variant_index("wear",cell,4),0)
		var hc:=HeightRules.coord(cell,float(route_by_cell[cell]))
		if hc.x>=0:height_cells[cell]=hc

static func route_distance(p:Vector2,routes:Array)->float:
	var nearest:=100000.0
	for route in routes:
		for i in range(route.size()-1):nearest=minf(nearest,p.distance_to(Geometry2D.get_closest_point_to_segment(p,route[i],route[i+1])))
	return nearest

static func kind_at(point:Vector2)->int:
	if not BOUNDS.has_point(point):return 0
	prepare(Callable())
	return int(terrain.get(Vector2i(floori(point.x/TILE),floori(point.y/TILE)),0))

static func material_at(point:Vector2)->String:
	if not BOUNDS.has_point(point):return ""
	prepare(Callable())
	return str(material_cells.get(Vector2i(floori(point.x/TILE),floori(point.y/TILE)),""))

static func visual_family_at(point:Vector2)->String:
	if not BOUNDS.has_point(point):return ""
	prepare(Callable())
	return str(visual_cells.get(Vector2i(floori(point.x/TILE),floori(point.y/TILE)),""))

static func legacy_overlay_count()->int:return Plan.legacy_overlay_expected()

static func paint(c:CanvasItem,bounds:Rect2,distance:Callable)->void:
	prepare(distance)
	var area:=bounds.intersection(BOUNDS)
	if not area.has_area():return
	var source:=shared_tileset.get_source(ground_source_id) as TileSetAtlasSource
	for x in range(maxi(0,floori(area.position.x/TILE)),mini(Plan.GRID.x,ceili(area.end.x/TILE))):
		for y in range(maxi(0,floori(area.position.y/TILE)),mini(Plan.GRID.y,ceili(area.end.y/TILE))):
			var cell:=Vector2i(x,y);var target:=Rect2(Vector2(cell*TILE),Vector2.ONE*TILE).intersection(BOUNDS)
			var coord:Vector2i=visual_coords[cell]
			c.draw_texture_rect_region(source.texture,target,Rect2(Vector2(coord*TILE),target.size))

func _ready()->void:
	prepare(road_distance)
	var clip:=Control.new();clip.name="Map0Boundary";clip.size=BOUNDS.size;clip.clip_contents=true;clip.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(clip)
	ground=make_layer(clip,"Ground32")
	paths=make_layer(clip,"Transitions32")
	decoration=make_layer(clip,"Details32")
	heights=make_layer(clip,"VisualHeights32")
	var area:=world_bounds.intersection(BOUNDS)
	for x in range(maxi(0,floori(area.position.x/TILE)),mini(Plan.GRID.x,ceili(area.end.x/TILE))):
		for y in range(maxi(0,floori(area.position.y/TILE)),mini(Plan.GRID.y,ceili(area.end.y/TILE))):
			var cell:=Vector2i(x,y)
			ground.set_cell(cell,ground_source_id,visual_coords[cell])
			if transition_cells.has(cell):paths.set_cell(cell,transition_source_id,transition_cells[cell])
			if overlay_cells.has(cell):decoration.set_cell(cell,overlay_source_id,overlay_cells[cell])
			if height_cells.has(cell):heights.set_cell(cell,height_source_id,height_cells[cell])
	ground.update_internals();paths.update_internals();decoration.update_internals();heights.update_internals()

func make_layer(parent:Node,title:String)->TileMapLayer:
	var layer:=TileMapLayer.new();layer.name=title;layer.tile_set=shared_tileset;layer.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;layer.collision_enabled=false;layer.navigation_enabled=false;parent.add_child(layer);return layer
