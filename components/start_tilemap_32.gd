extends Node2D
## Real TileMapLayers, matching the existing world coordinates and navigation.
const TILE := 32
const BOUNDS := Rect2(0,0,1780,2600)
const PLAZA := Rect2(480,680,690,650)
const ATLAS_PATH := "res://art/start32/terrain_32.webp"
static var shared_tileset: TileSet
static var cells: Dictionary = {}
static var terrain: Dictionary = {}
static var flower_cells: Dictionary = {}
var world_bounds := BOUNDS
var road_distance: Callable
var ground: TileMapLayer
var paths: TileMapLayer
var decoration: TileMapLayer

static func seed_at(cell: Vector2i) -> int:
	return posmod(cell.x*97+cell.y*173+cell.x*cell.y*13,8191)

static func prepare(distance: Callable) -> void:
	if shared_tileset != null: return
	shared_tileset = TileSet.new()
	shared_tileset.tile_size = Vector2i(TILE,TILE)
	var source := TileSetAtlasSource.new()
	source.texture = load(ATLAS_PATH)
	source.texture_region_size = Vector2i(TILE,TILE)
	for y in 12:
		for x in 24: source.create_tile(Vector2i(x,y))
	shared_tileset.add_source(source,0)
	for x in 56:
		for y in 82:
			var cell := Vector2i(x,y)
			var center := Vector2(cell*TILE)+Vector2.ONE*16
			var d: float = distance.call(center)
			terrain[cell] = 2 if PLAZA.has_point(center) else (1 if d<58.0 else 0)
	for cell: Vector2i in terrain:
		var kind: int = terrain[cell]
		cells[cell] = grass_coord(cell)
		if kind>0:
			var mask := 0
			var neighbors := [Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT]
			for n in 4:
				if int(terrain.get(cell+neighbors[n],0))>0: mask |= 1<<n
			cells[cell] = Vector2i(mask,(4 if kind==1 else 8)+seed_at(cell)%4)


static func grass_coord(cell:Vector2i)->Vector2i:
	var block:=Vector2i(floori(cell.x/4.0),floori(cell.y/4.0))
	var flowers:bool=seed_at(block)%5==0
	return Vector2i(posmod(cell.x,4)+(4 if flowers else 0),posmod(cell.y,4))
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
			c.draw_texture_rect_region(texture,target,source)
			var atlas: Vector2i = cells[cell]
			if terrain[cell]>0: c.draw_texture_rect_region(texture,target,Rect2(Vector2(atlas*TILE),target.size))
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
			ground.set_cell(cell,0,grass_coord(cell))
			var atlas: Vector2i = cells[cell]
			if terrain[cell]>0: paths.set_cell(cell,0,atlas)
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
