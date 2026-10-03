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

	print("MAP0_GROUND_PASS_OK 4592 native 32px cells, six chunks, no legacy overlays, gates clear")
	quit()
