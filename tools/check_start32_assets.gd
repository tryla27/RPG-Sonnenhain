extends SceneTree
func _initialize()->void:
	var g=load("res://main.gd").new()
	var map=load("res://components/start_tilemap_32.gd")
	map.prepare(Callable(g,"distance_to_trail"))
	assert(map.shared_tileset.tile_size==Vector2i(32,32))
	assert(map.terrain.size()==4592)
	assert(ResourceSaver.save(map.shared_tileset,"res://art/start32/start_tileset_32.tres")==OK)
	for file in ["objects-faithful.png","props-faithful.png"]:
		var im=Image.load_from_file("res://art/start32/"+file)
		assert(im.get_pixel(0,0).a<0.01,"Non-transparent sprite background")
		assert(im.get_pixel(1535,1023).a<0.01,"Non-transparent sprite corner")
	assert(not g.is_blocked(g.TAVERN_HOUSE+Vector2(126,180),g.TAVERN_HOUSE+Vector2(126,205)))
	print("FAITHFUL_START32_OK native32px TileSet, 4592 cells, transparent sprite corners, tavern approach")
	g.free()
	quit()
