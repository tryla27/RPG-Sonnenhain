extends Node2D
## Map 0 runtime floor is fully authored as native 32px tiles.
const Palette=preload("res://components/world_material_palette_32.gd")
const Plan=preload("res://components/map0_ground_plan_32.gd")
const TILE:=32
const BOUNDS:=Plan.BOUNDS
const EAST_EXIT:=Plan.EAST_GATE
const SOUTH_EXIT:=Plan.SOUTH_GATE
const ATLAS_PATH:="res://art/start32/terrain_32.webp"
const MATERIAL_IDS:=["grass_meadow","grass_moss","forest_floor","earth_path","village_stone","old_cobble","arcane_floor"]
# Map 0 uses a real autumnized natural-ground texture plus warm per-material
# modulation. This avoids the old green highlights that survived a plain tint.
# Roads, stone plazas and arcane accents keep their original palette.
const NATURAL_MATERIALS:=["grass_meadow","grass_moss","forest_floor"]
const MATERIAL_TINTS:={
	"grass_meadow":Color(1.00,0.93,0.74),
	"grass_moss":Color(0.93,0.68,0.43),
	"forest_floor":Color(0.86,0.58,0.34),
	"earth_path":Color(0.86,0.72,0.58),
	"village_stone":Color(0.84,0.86,0.82),
	"old_cobble":Color(0.70,0.74,0.70),
	"arcane_floor":Color(0.70,0.86,0.96),
}
static var shared_tileset:TileSet
static var source_ids:Dictionary={}
static var cells:Dictionary={}
static var terrain:Dictionary={}
static var material_cells:Dictionary={}
static var flower_cells:Dictionary={}
static var ground_cells:Dictionary={}
static var ground_sources:Dictionary={}
static var ground_materials:Dictionary={}
static var cell_sources:Dictionary={}
var world_bounds:=BOUNDS
var road_distance:Callable
var ground:TileMapLayer
var paths:TileMapLayer
var decoration:TileMapLayer

static func seed_at(cell:Vector2i)->int:
	return Plan.seed_at(cell)

static func autumnize_natural_texture(source:Texture2D)->Texture2D:
	var image:=source.get_image()
	image.convert(Image.FORMAT_RGBA8)
	for y in image.get_height():
		for x in image.get_width():
			var col:=image.get_pixel(x,y)
			if col.a<=0.01:continue
			# Replace green-dominant vegetation pixels instead of merely tinting
			# them. Neutral stone/soil pixels remain untouched.
			if col.g>0.20 and col.g>col.b*1.05 and col.g>col.r*0.92:
				var light:=clampf(maxf(col.r,maxf(col.g,col.b)),0.0,1.0)
				col=Color(
					0.36+0.42*light,
					0.16+0.34*light,
					0.055+0.13*light,
					col.a
				)
				image.set_pixel(x,y,col)
	return ImageTexture.create_from_image(image)

static func prepare(_distance:Callable)->void:
	if shared_tileset!=null:return
	shared_tileset=TileSet.new()
	shared_tileset.tile_size=Vector2i(TILE,TILE)
	var texture:Texture2D=load(ATLAS_PATH)
	var autumn_texture:=autumnize_natural_texture(texture)
	for material_id in MATERIAL_IDS:
		var atlas:=TileSetAtlasSource.new()
		atlas.texture=autumn_texture if material_id in NATURAL_MATERIALS else texture
		atlas.texture_region_size=Vector2i(TILE,TILE)
		for y in 12:
			for x in 24:
				atlas.create_tile(Vector2i(x,y))
				atlas.get_tile_data(Vector2i(x,y),0).modulate=MATERIAL_TINTS[material_id]
		var source_id:int=shared_tileset.get_next_source_id()
		shared_tileset.add_source(atlas,source_id)
		source_ids[material_id]=source_id
	var noise:=FastNoiseLite.new()
	noise.seed=7041
	noise.frequency=0.008
	noise.fractal_octaves=2
	var routes:Array=[
		PackedVector2Array([Vector2(832,960),Vector2(1120,960),Vector2(1456,960),Vector2(1664,1024),EAST_EXIT]),
		PackedVector2Array([Vector2(832,1184),Vector2(864,1568),Vector2(864,1984),Vector2(896,2304),SOUTH_EXIT]),
		PackedVector2Array([Vector2(384,1024),Vector2(832,1024),Vector2(1280,1024)]),
		PackedVector2Array([Vector2(832,608),Vector2(832,1024),Vector2(832,1440)])
	]
	for shop in preload("res://components/village_layout.gd").SHOPS:
		if shop.has("shared_with"):continue
		var home:Vector2=shop["house"]
		var kind:String=str(shop["kind"])
		var door:=home+Vector2(96,180)
		if kind=="borin":door=home+Vector2(128,240)
		elif kind=="arena":door=home+Vector2(192,260)
		var entry:=Vector2(clampf(door.x,416,1248),clampf(door.y,640,1408))
		if door.y>1500:entry=Vector2(864,door.y)
		elif door.x<480:entry=Vector2(416,clampf(door.y,704,2208))
		elif door.x>1184:entry=Vector2(1248,clampf(door.y,640,2208))
		routes.append(PackedVector2Array([door,door.lerp(entry,0.5)+Vector2(0,16),entry]))
	for x in Plan.GRID.x:
		for y in Plan.GRID.y:
			var cell:=Vector2i(x,y)
			var center:=Plan.center(cell)
			var route_d:=route_distance(center,routes)
			var material:String=Plan.material_for(cell,route_d)
			material_cells[cell]=material
			var tone:=noise.get_noise_2dv(center)
			var base_material:String="grass_meadow"
			if material in ["grass_meadow","grass_moss","forest_floor"]:base_material=material
			elif tone< -0.18:base_material="grass_moss"
			ground_cells[cell]=Vector2i(posmod(x,4),posmod(y,4))
			ground_sources[cell]=source_ids[base_material]
			ground_materials[cell]=base_material
			if material in ["grass_meadow","grass_moss","forest_floor"]:
				terrain[cell]=0
				cell_sources[cell]=source_ids[material]
			elif material=="earth_path":
				terrain[cell]=1
				cell_sources[cell]=source_ids[material]
			else:
				terrain[cell]=2
				cell_sources[cell]=source_ids[material]
	for cell:Vector2i in terrain:
		cells[cell]=Vector2i(posmod(cell.x,4),posmod(cell.y,4))
		if int(terrain[cell])==2:
			var mask:=0
			var neighbors:=[Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT]
			for n in 4:
				var other:Vector2i=cell+neighbors[n]
				if int(terrain.get(other,0))==2:mask|=1<<n
			cells[cell]=Vector2i(mask,8+posmod(floori(cell.x/3.0)*7+floori(cell.y/3.0)*13,4))

static func route_distance(p:Vector2,routes:Array)->float:
	var nearest:=100000.0
	for route in routes:
		for i in range(route.size()-1):
			nearest=minf(nearest,p.distance_to(Geometry2D.get_closest_point_to_segment(p,route[i],route[i+1])))
	return nearest

static func grass_coord(cell:Vector2i)->Vector2i:
	return ground_cells.get(cell,Vector2i(posmod(cell.x,4),posmod(cell.y,4)))

static func kind_at(point:Vector2)->int:
	if not BOUNDS.has_point(point):return 0
	prepare(Callable())
	return int(terrain.get(Vector2i(floori(point.x/TILE),floori(point.y/TILE)),0))

static func material_at(point:Vector2)->String:
	if not BOUNDS.has_point(point):return ""
	prepare(Callable())
	return str(material_cells.get(Vector2i(floori(point.x/TILE),floori(point.y/TILE)),""))

static func legacy_overlay_count()->int:
	return Plan.legacy_overlay_expected()

static func paint(c:CanvasItem,bounds:Rect2,distance:Callable)->void:
	prepare(distance)
	var area:=bounds.intersection(BOUNDS)
	if not area.has_area():return
	var texture:Texture2D=(shared_tileset.get_source(0) as TileSetAtlasSource).texture
	for x in range(maxi(0,floori(area.position.x/TILE)),mini(Plan.GRID.x,ceili(area.end.x/TILE))):
		for y in range(maxi(0,floori(area.position.y/TILE)),mini(Plan.GRID.y,ceili(area.end.y/TILE))):
			var cell:=Vector2i(x,y)
			var position:=Vector2(cell*TILE)
			var target:=Rect2(position,Vector2.ONE*TILE).intersection(BOUNDS)
			var base_id:int=int(ground_sources.get(cell,0))
			var base_source:=shared_tileset.get_source(base_id) as TileSetAtlasSource
			var base_material:=str(ground_materials.get(cell,"grass_meadow"))
			var source:=Rect2(Vector2(grass_coord(cell)*TILE),target.size)
			c.draw_texture_rect_region(base_source.texture,target,source,MATERIAL_TINTS.get(base_material,Color.WHITE))
			if int(terrain[cell])>0:
				var atlas:Vector2i=cells[cell]
				var mat:String=str(material_cells[cell])
				c.draw_texture_rect_region(texture,target,Rect2(Vector2(atlas*TILE),target.size),MATERIAL_TINTS.get(mat,Color.WHITE))

func _ready()->void:
	prepare(road_distance)
	var clip:=Control.new()
	clip.name="Map0Boundary"
	clip.size=BOUNDS.size
	clip.clip_contents=true
	clip.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(clip)
	ground=make_layer(clip,"Ground32")
	paths=make_layer(clip,"PathsAndPlaza32")
	decoration=make_layer(clip,"Details32")
	var area:=world_bounds.intersection(BOUNDS)
	for x in range(maxi(0,floori(area.position.x/TILE)),mini(Plan.GRID.x,ceili(area.end.x/TILE))):
		for y in range(maxi(0,floori(area.position.y/TILE)),mini(Plan.GRID.y,ceili(area.end.y/TILE))):
			var cell:=Vector2i(x,y)
			ground.set_cell(cell,int(ground_sources.get(cell,0)),grass_coord(cell))
			if int(terrain[cell])>0:
				paths.set_cell(cell,int(cell_sources.get(cell,0)),cells[cell])
			if flower_cells.has(cell):decoration.set_cell(cell,int(source_ids["grass_meadow"]),flower_cells[cell])
	ground.update_internals()
	paths.update_internals()
	decoration.update_internals()

func make_layer(parent:Node,title:String)->TileMapLayer:
	var layer:=TileMapLayer.new()
	layer.name=title
	layer.tile_set=shared_tileset
	layer.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	layer.collision_enabled=false
	layer.navigation_enabled=false
	parent.add_child(layer)
	return layer
