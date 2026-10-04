extends SceneTree
const Map0=preload("res://components/start_tilemap_32.gd")
const Plan=preload("res://components/map0_ground_plan_32.gd")
const Builder=preload("res://components/world_builder.gd")

func _initialize()->void:
	Map0.prepare(Callable())
	assert(Plan.TILE==32)
	assert(Plan.GRID==Vector2i(56,82))
	assert(Plan.CHUNK_ORDER==["NW","MW","MO","NO","SW","SO"])
	assert(Map0.legacy_overlay_count()==0)
	# Map 0 natural floor must stay on the orange/rost autumn ambience palette.
	assert(Map0.NATURAL_MATERIALS==["grass_meadow","grass_moss","forest_floor"])
	assert(Map0.MATERIAL_TINTS["grass_meadow"]==Color(1.00,0.93,0.74))
	assert(Map0.MATERIAL_TINTS["grass_moss"]==Color(0.93,0.68,0.43))
	assert(Map0.MATERIAL_TINTS["forest_floor"]==Color(0.86,0.58,0.34))
	var natural_source:=Map0.shared_tileset.get_source(int(Map0.source_ids["grass_meadow"])) as TileSetAtlasSource
	var natural_image:=natural_source.texture.get_image()
	var residual_green:=0
	for y in range(0,natural_image.get_height(),4):
		for x in range(0,natural_image.get_width(),4):
			var col:=natural_image.get_pixel(x,y)
			if col.a>0.01 and col.g>0.20 and col.g>col.b*1.05 and col.g>col.r*0.92:
				residual_green+=1
	assert(residual_green==0,"Map 0 autumn texture still contains green-dominant natural pixels")
	var scenery_source:=FileAccess.get_file_as_string("res://components/reference_scenery.gd")
	for forbidden in ["659349","729f4f","587e40","88aa54","608947","456b36","709b47","96b956","b1c76b","789f4b"]:
		assert(scenery_source.find(forbidden)<0,"legacy bright-green low ambience remains: "+forbidden)
	var main_source:=FileAccess.get_file_as_string("res://main.gd")
	assert(main_source.find('draw_rect(pad,Color("6f7d57",0.18))')<0,"legacy green property-pad overlay remains")

	var total:=0
	var materials:Dictionary={}
	for x in Plan.GRID.x:
		for y in Plan.GRID.y:
			var cell:=Vector2i(x,y)
			var material:=Map0.material_at(Plan.center(cell))
			assert(material!="","every Map 0 cell must have a native 32px material")
			materials[material]=int(materials.get(material,0))+1
			total+=1
	assert(total==4592)
	for required in ["grass_meadow","grass_moss","forest_floor","earth_path","village_stone","old_cobble","arcane_floor"]:
		assert(materials.has(required),"missing Map 0 material: "+required)

	# Gate corridors must remain authored as road materials.
	for gate in [Plan.EAST_GATE,Plan.SOUTH_GATE]:
		var inside:Vector2=Vector2(gate)
		if gate==Plan.EAST_GATE:inside.x-=48
		else:inside.y-=48
		assert(Map0.material_at(inside) in ["village_stone","earth_path"])

	# The crystal yard is tile-authored and contains restrained arcane accents.
	var arcane_count:=0
	for x in range(floori(Plan.CRYSTAL_PLAZA.position.x/32.0),ceili(Plan.CRYSTAL_PLAZA.end.x/32.0)):
		for y in range(floori(Plan.CRYSTAL_PLAZA.position.y/32.0),ceili(Plan.CRYSTAL_PLAZA.end.y/32.0)):
			if Map0.material_at(Plan.center(Vector2i(x,y)))=="arcane_floor":arcane_count+=1
	assert(arcane_count>0)
	assert(arcane_count<80,"arcane floor must stay an accent, not become a full overlay")

	var builder=Builder.new()
	builder.seed_map0_ground()
	assert(builder.cells["ground"].size()==4592)
	for id in Plan.CHUNK_ORDER:
		var summary:=builder.chunk_completion(str(id))
		assert(bool(summary["complete"]))
		assert(int(summary["missing"])==0)
	assert(builder.validate_map0_ground().is_empty())

	print("MAP0_GROUND_PASS_OK 4592 native 32px cells, autumnized natural texture, low ambience warm, six chunks, gates clear")
	quit()
