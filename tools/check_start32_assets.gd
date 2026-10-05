extends SceneTree
func _initialize()->void:
	var g=load("res://main.gd").new()
	var map=load("res://components/start_tilemap_32.gd")
	map.prepare(Callable(g,"distance_to_trail"))
	assert(map.shared_tileset.tile_size==Vector2i(32,32))
	assert(map.terrain.size()==4592)
	assert(map.shared_tileset.get_source_count()==map.MATERIAL_IDS.size())
	for file in ["objects-faithful.webp","props-faithful.webp"]:
		var sprite:Texture2D=load("res://art/start32/"+file)
		assert(sprite!=null)
		var im=sprite.get_image()
		assert(im.get_pixel(0,0).a<0.01,"Non-transparent sprite background")
		assert(im.get_pixel(1535,1023).a<0.01,"Non-transparent sprite corner")
	assert(not g.is_blocked(g.village_house_door(g.village_house("Alma")),g.village_house_door(g.village_house("Alma"))+Vector2(0,25)))
	print("FAITHFUL_START32_OK native32px TileSet, all material sources, 4592 cells, transparent sprite corners, tavern approach")
	g.free()
	quit()
