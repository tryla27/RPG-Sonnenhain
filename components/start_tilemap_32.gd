extends Node2D
## Map 0 runtime floor: logical 32px plan + new visual terrain families.
const Plan=preload("res://components/map0_ground_plan_32.gd")
const Catalog=preload("res://components/terrain/terrain_catalog_32.gd")
const Offer=preload("res://components/terrain/terrain_offer_32.gd")
const Selector=preload("res://components/terrain/terrain_selector_32.gd")
const TransitionRules=preload("res://components/terrain/terrain_transition_rules_32.gd")
const LegacyOffer=preload("res://components/terrain/legacy_terrain_offer_32.gd")
const GbaCompositor=preload("res://components/terrain/gba_ground_compositor_32.gd")
const GbaBake=preload("res://components/terrain/gba_bake_manifest.gd")
const GbaRules=preload("res://components/terrain/gba_transition_rules_32.gd")
const BAKED_PATH:="res://art/terrain/gba_v1/chunks/"
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
static var source_ids:Dictionary={}
static var material_cells:Dictionary={}
static var visual_cells:Dictionary={}
static var visual_coords:Dictionary={}
static var transition_cells:Dictionary={}
static var overlay_cells:Dictionary={}
static var terrain:Dictionary={}
static var floor_image:Image
static var gba_enabled:=true
static var cell_ground_sources:Dictionary={}
static var bake_signature:=""
static var used_baked_chunks:=false
var world_bounds:=BOUNDS
var road_distance:Callable
var ground:TileMapLayer
var paths:TileMapLayer
var decoration:TileMapLayer

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
	gba_enabled=bool(ProjectSettings.get_setting("sonnenhain/terrain/gba_enabled",true))
	Offer.prepare()
	shared_tileset=TileSet.new();shared_tileset.tile_size=Vector2i(TILE,TILE)
	ground_source_id=make_source(Catalog.GROUND_ATLAS if gba_enabled else Catalog.LEGACY_GROUND_ATLAS,16,Catalog.FAMILY_ORDER.size() if gba_enabled else 12)
	overlay_source_id=make_source(Catalog.GBA_OVERLAY_ATLAS if gba_enabled else Catalog.OVERLAY_ATLAS,16,8)
	transition_source_id=make_source(Catalog.TRANSITION_ATLAS,16,16)
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

	for x in Plan.GRID.x:
		for y in Plan.GRID.y:
			var cell:=Vector2i(x,y)
			var route_d:=preload("res://components/village_paths.gd").distance(Plan.center(cell)) if gba_enabled else route_distance(Plan.center(cell),routes)
			var legacy:String=Plan.material_for(cell,route_d)
			var visual:String=Offer.resolve(legacy,cell,route_d) if gba_enabled else LegacyOffer.resolve(legacy,cell,route_d)
			material_cells[cell]=legacy
			visual_cells[cell]=visual
			visual_coords[cell]=Catalog.atlas_coord(visual,Catalog.coherent_variant(cell) if gba_enabled else Selector.variant_index(visual,cell,16))
			terrain[cell]=0 if legacy in NATURAL_MATERIALS else (1 if legacy=="earth_path" else 2)

	var dirs:Array[Vector2i]=[Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT]
	for cell:Vector2i in visual_cells:
		var current:String=str(visual_cells[cell])
		for di in 4:
			var other:Vector2i=cell+dirs[di]
			if not Plan.in_bounds(other):continue
			var coord:Vector2i=TransitionRules.coord(current,str(visual_cells.get(other,current)),di,cell)
			if coord.x>=0:
				transition_cells[cell]=coord
				break

	for cell:Vector2i in visual_cells:
		var family:String=str(visual_cells[cell]);var legacy:String=str(material_cells[cell])
		var near_tree:=false
		if gba_enabled:
			for tree:Vector2 in preload("res://components/village_layout.gd").TREES:
				if Plan.center(cell).distance_to(tree)<80 and tree.x>160:near_tree=true
		if not gba_enabled and legacy=="arcane_floor":overlay_cells[cell]=Vector2i(Selector.variant_index("arcane",cell,16),6)
		elif gba_enabled and near_tree and family in ["village_grass","moss_grass"] and Selector.chance("leaves",cell,3):overlay_cells[cell]=Vector2i(Selector.variant_index("leaves",cell,16),0)
		elif gba_enabled and family=="village_grass" and Selector.chance("flower_meadow",cell,2 if preload("res://components/village_paths.gd").flower_corner(Plan.center(cell)) else 4):overlay_cells[cell]=Vector2i(Selector.variant_index("flowers",cell,16),1)
		elif not gba_enabled and family in ["village_grass","moss_grass","forest_ground"] and Selector.chance("flora",cell,9):overlay_cells[cell]=Vector2i(Selector.variant_index("flowers",cell,16),0)
		elif not gba_enabled and family in ["village_path","garden_path","arena_ground"] and Selector.chance("tracks",cell,11):overlay_cells[cell]=Vector2i(Selector.variant_index("tracks",cell,16),4)
		elif not gba_enabled and family in ["village_stone","plaza_stone","old_cobble_rework","building_apron","arena_entry_stone","arena_border"] and Selector.chance("wear",cell,10):overlay_cells[cell]=Vector2i(Selector.variant_index("wear",cell,16),5)
	if gba_enabled:prepare_gba_floor()

static func prepare_gba_floor()->void:
	var ground_source:=shared_tileset.get_source(ground_source_id) as TileSetAtlasSource
	var source_image:=ground_source.texture.get_image()
	if source_image.is_compressed():source_image.decompress()
	source_image.convert(Image.FORMAT_RGBA8)
	var overlay_source:=shared_tileset.get_source(overlay_source_id) as TileSetAtlasSource
	var overlay_image:=overlay_source.texture.get_image()
	if overlay_image.is_compressed():overlay_image.decompress()
	overlay_image.convert(Image.FORMAT_RGBA8)
	bake_signature=input_signature(source_image,overlay_image)
	used_baked_chunks=bake_signature==GbaBake.SIGNATURE and not bool(ProjectSettings.get_setting("sonnenhain/terrain/force_rebake",false))
	for id in Plan.CHUNK_ORDER:
		used_baked_chunks=used_baked_chunks and ResourceLoader.exists(BAKED_PATH+str(id)+".png")
	if used_baked_chunks:
		transition_cells.clear()
		for cell:Vector2i in visual_cells:
			var mask:=GbaRules.mask_for(str(visual_cells[cell]),cell,visual_cells)
			if mask!=255:transition_cells[cell]=mask
		install_chunk_sources()
		return
	var result:=GbaCompositor.compose(source_image,visual_cells)
	floor_image=result["image"]
	transition_cells=result["transitions"]
	# Bake the static detail layer too, so cached paint and live TileMap agree.
	for cell:Vector2i in overlay_cells:
		floor_image.blend_rect(overlay_image,Rect2i(Vector2i(overlay_cells[cell])*32,Vector2i(32,32)),cell*32)
	install_chunk_sources()

static func input_signature(source:Image,overlays:Image)->String:
	var hash_context:=HashingContext.new()
	hash_context.start(HashingContext.HASH_SHA256)
	hash_context.update(source.get_data())
	hash_context.update(overlays.get_data())
	# Ordered layout, ordered details, and mask revision invalidate stale exports.
	var layout:=PackedStringArray([str(GbaCompositor.REVISION)])
	for y in Plan.GRID.y:
		for x in Plan.GRID.x:
			var cell:=Vector2i(x,y)
			layout.append(str(visual_cells[cell])+":"+str(overlay_cells.get(cell,Vector2i(-1,-1))))
	hash_context.update("|".join(layout).to_utf8_buffer())
	return hash_context.finish().hex_encode()

static func install_chunk_sources()->void:
	# Six <=896px textures work on small WebGL devices and match existing world chunks.
	for id in Plan.CHUNK_ORDER:
		var region:Rect2i=Plan.CHUNKS[id]["cells"]
		var texture:Texture2D=load(BAKED_PATH+str(id)+".png") if used_baked_chunks else ImageTexture.create_from_image(floor_image.get_region(Rect2i(region.position*32,region.size*32)))
		var atlas:=TileSetAtlasSource.new()
		atlas.texture=texture;atlas.texture_region_size=Vector2i(32,32)
		var source_id:int=shared_tileset.get_next_source_id()
		for x in range(region.position.x,region.end.x):
			for y in range(region.position.y,region.end.y):
				var cell:=Vector2i(x,y)
				var local:=cell-region.position
				atlas.create_tile(local)
				visual_coords[cell]=local
				cell_ground_sources[cell]=source_id
		shared_tileset.add_source(atlas,source_id)

static func complete_floor_image()->Image:
	if floor_image!=null:return floor_image
	floor_image=Image.create(Plan.GRID.x*32,Plan.GRID.y*32,false,Image.FORMAT_RGBA8)
	for id in Plan.CHUNK_ORDER:
		var region:Rect2i=Plan.CHUNKS[id]["cells"]
		var chunk:Texture2D=load(BAKED_PATH+str(id)+".png")
		var image:=chunk.get_image()
		if image.is_compressed():image.decompress()
		image.convert(Image.FORMAT_RGBA8)
		floor_image.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),region.position*32)
	return floor_image

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
	for x in range(maxi(0,floori(area.position.x/TILE)),mini(Plan.GRID.x,ceili(area.end.x/TILE))):
		for y in range(maxi(0,floori(area.position.y/TILE)),mini(Plan.GRID.y,ceili(area.end.y/TILE))):
			var cell:=Vector2i(x,y);var target:=Rect2(Vector2(cell*TILE),Vector2.ONE*TILE).intersection(BOUNDS)
			var source:=shared_tileset.get_source(int(cell_ground_sources.get(cell,ground_source_id))) as TileSetAtlasSource
			var coord:Vector2i=visual_coords[cell]
			c.draw_texture_rect_region(source.texture,target,Rect2(Vector2(coord*TILE),target.size))

func _ready()->void:
	prepare(road_distance)
	var clip:=Control.new();clip.name="Map0Boundary";clip.size=BOUNDS.size;clip.clip_contents=true;clip.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(clip)
	ground=make_layer(clip,"Ground32")
	paths=make_layer(clip,"Transitions32")
	decoration=make_layer(clip,"Details32")
	var area:=world_bounds.intersection(BOUNDS)
	for x in range(maxi(0,floori(area.position.x/TILE)),mini(Plan.GRID.x,ceili(area.end.x/TILE))):
		for y in range(maxi(0,floori(area.position.y/TILE)),mini(Plan.GRID.y,ceili(area.end.y/TILE))):
			var cell:=Vector2i(x,y)
			ground.set_cell(cell,int(cell_ground_sources.get(cell,ground_source_id)),visual_coords[cell])
			if not gba_enabled and transition_cells.has(cell):paths.set_cell(cell,transition_source_id,transition_cells[cell])
			if not gba_enabled and overlay_cells.has(cell):decoration.set_cell(cell,overlay_source_id,overlay_cells[cell])
	ground.update_internals();paths.update_internals();decoration.update_internals()

func make_layer(parent:Node,title:String)->TileMapLayer:
	var layer:=TileMapLayer.new();layer.name=title;layer.tile_set=shared_tileset;layer.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;layer.collision_enabled=false;layer.navigation_enabled=false;parent.add_child(layer);return layer
