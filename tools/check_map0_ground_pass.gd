extends SceneTree
const Map0=preload("res://components/start_tilemap_32.gd")
const Plan=preload("res://components/map0_ground_plan_32.gd")
const Catalog=preload("res://components/terrain/terrain_catalog_32.gd")
const Builder=preload("res://components/world_builder.gd")

func _initialize()->void:
	Map0.prepare(Callable())
	assert(Plan.TILE==32)
	assert(Plan.GRID==Vector2i(56,82))
	assert(Plan.CHUNK_ORDER==["NW","MW","MO","NO","SW","SO"])
	assert(Map0.legacy_overlay_count()==0)
	assert(Map0.NATURAL_MATERIALS==["grass_meadow","grass_moss","forest_floor"])
	assert(FileAccess.file_exists(Catalog.GROUND_ATLAS))
	assert(FileAccess.file_exists(Catalog.OVERLAY_ATLAS))
	assert(FileAccess.file_exists(Catalog.TRANSITION_ATLAS))
	assert(Catalog.VARIANTS==16)
	assert(Catalog.FAMILY_ORDER.size()==12)

	var total:=0
	var materials:Dictionary={}
	var families:Dictionary={}
	for x in Plan.GRID.x:
		for y in Plan.GRID.y:
			var cell:=Vector2i(x,y);var point:=Plan.center(cell)
			var material:=Map0.material_at(point);var family:=Map0.visual_family_at(point)
			assert(material!="","every Map 0 cell must retain a logical material")
			assert(Catalog.has(family),"unknown Map 0 visual family: "+family)
			materials[material]=int(materials.get(material,0))+1
			families[family]=int(families.get(family,0))+1
			total+=1
	assert(total==4592)
	for required in ["grass_meadow","grass_moss","forest_floor","earth_path","village_stone","old_cobble","arcane_floor"]:
		assert(materials.has(required),"missing logical Map 0 material: "+required)
	for required in ["village_grass","village_path","village_stone","plaza_stone","building_apron","garden_path","arena_entry_stone","arena_border","arena_ground"]:
		assert(families.has(required),"missing visual Map 0 family: "+required)

	for gate in [Plan.EAST_GATE,Plan.SOUTH_GATE]:
		var inside:Vector2=Vector2(gate)
		if gate==Plan.EAST_GATE:inside.x-=48
		else:inside.y-=48
		assert(Map0.material_at(inside) in ["village_stone","earth_path"])

	var builder=Builder.new()
	builder.seed_map0_ground()
	assert(builder.cells["ground"].size()==4592)
	for id in Plan.CHUNK_ORDER:
		var summary:=builder.chunk_completion(str(id))
		assert(bool(summary["complete"]))
		assert(int(summary["missing"])==0)
	assert(builder.validate_map0_ground().is_empty())
	assert(int(families.get("arena_ground",0))>int(families.get("arena_border",0))*2,"arena yard must be ground-dominant, not border-filled")
	assert(int(families.get("old_cobble_rework",0))==0,"dark cobble speckles must not leak into coherent Map 0 zones")
	assert(Map0.transition_cells.size()>0,"new Map 0 terrain needs transition cells")
	assert(Map0.overlay_cells.size()>0,"new Map 0 terrain needs detail overlays")
	assert(Map0.visual_family_at(Vector2(832,1024))=="plaza_stone","spawn center must use large plaza stones")
	assert(Map0.visual_family_at(Vector2(825,1020))=="plaza_stone","live spawn route sample must stay on plaza stone")
	print("MAP0_GROUND_PASS_OK floor-only Sonnenhain profile, coherent spawn plaza, house aprons and organic paths")
	quit()
