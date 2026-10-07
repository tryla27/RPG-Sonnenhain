extends SceneTree
const Map0=preload("res://components/start_tilemap_32.gd")
const Plan=preload("res://components/map0_ground_plan_32.gd")
const Catalog=preload("res://components/terrain/terrain_catalog_32.gd")
const Rules=preload("res://components/terrain/gba_transition_rules_32.gd")

class TestGame extends "res://main.gd":
	func _ready()->void:pass
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass

func _initialize()->void:call_deferred("run")

func run()->void:
	assert(Rules.all_masks().size()==47,"every valid eight-neighbor blob mask must be covered")
	for mask in 256:assert(Rules.normalize(Rules.normalize(mask))==Rules.normalize(mask))
	assert(Rules.foreground_pixel(255,Vector2i(0,0),Vector2i.ZERO))
	assert(not Rules.foreground_pixel(15,Vector2i(31,0),Vector2i.ZERO),"concave NE corner cannot stay square")
	assert(not Rules.foreground_pixel(0,Vector2i(0,0),Vector2i.ZERO))
	assert(Rules.foreground_pixel(0,Vector2i(16,16),Vector2i.ZERO),"isolated patch must retain its center")
	assert(not Rules.foreground_pixel(Rules.normalize(254),Vector2i(16,0),Vector2i.ZERO))
	assert(not Rules.foreground_pixel(Rules.normalize(253),Vector2i(31,16),Vector2i.ZERO))
	var texture:Texture2D=load(Catalog.GROUND_ATLAS)
	var image:=texture.get_image()
	if image.is_compressed():image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	assert(image.get_size()==Vector2i(512,416))
	for row in 13:
		var patch:=Image.create(128,128,false,Image.FORMAT_RGBA8)
		var colors:Dictionary={}
		for v in 16:patch.blit_rect(image,Rect2i(v*32,row*32,32,32),Vector2i(v%4*32,floori(v/4.0)*32))
		for y in 128:
			assert(patch.get_pixel(0,y)==patch.get_pixel(127,y),"horizontal material seam: "+str(row))
			for x in 128:
				var color:=patch.get_pixel(x,y)
				assert(color.a==1.0)
				colors[color.to_rgba32()]=true
		for x in 128:assert(patch.get_pixel(x,0)==patch.get_pixel(x,127),"vertical material seam: "+str(row))
		assert(colors.size()<=(6 if row in [0,1,2,3,4,11] else 8))
	# Arena rim must be the same cobbles, not purple wall blocks.
	assert(image.get_region(Rect2i(0,5*32,512,32)).get_data()==image.get_region(Rect2i(0,10*32,512,32)).get_data())
	for row in [8,9]:assert(image.get_region(Rect2i(0,5*32,512,32)).get_data()==image.get_region(Rect2i(0,row*32,512,32)).get_data(),"entrances must use matching cobbles")
	Map0.prepare(Callable())
	assert(Map0.gba_enabled and Map0.used_baked_chunks,"production must use the current pre-baked chunks")
	assert(Map0.cell_ground_sources.size()==4592)
	for family in Map0.visual_cells.values():assert(family not in ["village_path","garden_path","arena_ground"],"yellow soil must not return")
	var flower_count:=0
	for coord:Vector2i in Map0.overlay_cells.values():
		if coord.y==1:flower_count+=1
	assert(flower_count>400,"meadow needs substantially more flowers")
	var paths=preload("res://components/village_paths.gd")
	for x in [1616,1648,1680]:assert(Map0.visual_family_at(Vector2(x,1936))=="village_stone","east arena lane must be three complete tiles wide")
	for x in [528,560,592]:assert(Map0.visual_family_at(Vector2(x,1936))=="village_stone","west arena lane must match the east lane width")
	for lamp:Vector2 in preload("res://components/village_fixtures.gd").LAMPS:
		assert(paths.distance(lamp)<=66.0,"lantern must sit beside the road")
		assert(Map0.visual_family_at(paths.closest(lamp)) in ["village_stone","plaza_stone","spawn_crossing","building_apron","arena_entry_stone","arena_border"],"lantern light must land on paving")
	var sources:Dictionary={}
	for source_id in Map0.cell_ground_sources.values():sources[source_id]=true
	assert(sources.size()==6)
	for source_id in sources:
		var source:=Map0.shared_tileset.get_source(source_id) as TileSetAtlasSource
		assert(source.texture.get_width()<=896 and source.texture.get_height()<=896)
	for tree:Vector2 in preload("res://components/village_layout.gd").TREES:
		assert(Map0.visual_family_at(tree) not in ["forest_ground","plaza_stone","arena_border"],"tree must stand on natural grass, not a foreign floor carpet")
	var full:=Map0.complete_floor_image()
	assert(full.get_size()==Vector2i(1792,2624))
	var bytes:=full.get_data()
	for i in range(3,bytes.size(),4):assert(bytes[i]==255)
	var game:=TestGame.new()
	game.hero_race=1 # Largest existing character collision radius.
	game.level=50
	for gate:Vector2 in game.VILLAGE_GATES:game.opened_village_gates[gate]=true
	game.player_pos=game.waystone_arrival(0)
	var elevations=preload("res://components/village_elevation.gd")
	elevations.prepare()
	assert(elevations.entries.size()==1)
	for entry in elevations.entries:
		var door:Vector2=entry["door"]
		assert(elevations.height_at(door)==32)
		assert(elevations.height_at(door+Vector2(0,20))==16)
		assert(elevations.height_at(door+Vector2(0,120))==0)
		assert(is_equal_approx(elevations.height_at(door+Vector2(0,8)),24))
		assert(is_equal_approx(elevations.height_at(door+Vector2(0,32)),8))
		var cliff:=Vector2(Rect2(entry["upper"]).position.x+1,door.y+4)
		assert(elevations.blocked(cliff,cliff-Vector2(4,0),18),"side cliff must not be walk-through")
		game.player_pos=door+Vector2(0,120)
		game.move_with_collision(Vector2(0,-120))
		assert(game.player_pos.distance_to(door)<1,"both stone stair flights must be traversable")
	game.player_pos=game.waystone_arrival(0)
	assert("spawn_crossing" in Map0.visual_cells.values(),"mixed paving junction must be present")
	var start:=Vector2i(floori(game.player_pos.x/32.0),floori(game.player_pos.y/32.0))
	var queue:Array[Vector2i]=[start]
	var reached:Dictionary={start:true}
	var free_cells:Dictionary={}
	for x in Plan.GRID.x:
		for y in Plan.GRID.y:
			var cell:=Vector2i(x,y)
			free_cells[cell]=not game.is_blocked(Plan.center(cell),Plan.center(cell))
	var cursor:=0
	while cursor<queue.size():
		var current:=queue[cursor];cursor+=1
		for direction in [Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT]:
			var next:Vector2i=current+direction
			if reached.has(next) or not bool(free_cells.get(next,false)):continue
			var origin:=Plan.center(current)
			var destination:=Plan.center(next)
			var clear:=true
			for step in 4:
				if game.is_blocked(origin.lerp(destination,(step+1)/4.0),origin):clear=false;break
			if clear:reached[next]=true;queue.append(next)
	var targets:Array[Vector2]=[]
	for shop in game.VillageLayout.SHOPS:
		if not shop.has("shared_with"):targets.append(game.village_house_door(shop))
	for gate:Vector2 in game.VILLAGE_GATES:targets.append(gate-Vector2(32,0) if gate.x==1780 else gate-Vector2(0,32))
	for target in targets:
		var found:=false
		for cell:Vector2i in reached:
			if Plan.center(cell).distance_to(target)<=48.0:found=true;break
		assert(found,"no physically walkable route from spawn to "+str(target))
	# The visible paving itself must form a physically traversable connected network.
	queue=[start];reached={start:true};cursor=0
	while cursor<queue.size():
		var current:=queue[cursor];cursor+=1
		for direction in [Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT]:
			var next:Vector2i=current+direction
			if reached.has(next) or not bool(free_cells.get(next,false)):continue
			if str(Map0.visual_cells.get(next,"")) not in ["village_stone","plaza_stone","spawn_crossing","building_apron","arena_entry_stone","arena_border"]:continue
			var origin:=Plan.center(current)
			var destination:=Plan.center(next)
			var clear:=true
			for step in 4:
				if game.is_blocked(origin.lerp(destination,(step+1)/4.0),origin):clear=false;break
			if clear:reached[next]=true;queue.append(next)
	for target in targets:
		var found:=false
		for cell:Vector2i in reached:
			if Plan.center(cell).distance_to(target)<=48.0:found=true;break
		assert(found,"entrance or gate lacks a connected walkable COBBLE path: "+str(target))
	game.free()
	print("GBA_GROUND_QA_OK 47 masks, opaque limited palettes, paired material seams, six valid baked chunks, corrected arena/tree floors, all seven doors and two gates physically reachable")
	quit()
