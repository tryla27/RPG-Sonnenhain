extends SceneTree
func _initialize() -> void:
	var folder: String=OS.get_environment("KONFLUX_BOARDS")
	var ground:=Image.load_from_file(folder+"/01-boden-12.png")
	ground.convert(Image.FORMAT_RGBA8)
	var atlas:=Image.create(512,512,false,Image.FORMAT_RGBA8)
	for i in 12:
		var part:=ground.get_region(Rect2i(i%4*384+12,[8,342,674][i/4],350,296))
		part.resize(128,128,Image.INTERPOLATE_NEAREST)
		atlas.blit_rect(part,Rect2i(0,0,128,128),Vector2i(i%4*128,i/4*128))
	var water:=Image.load_from_file(folder+"/07-fluss-12.png")
	water.convert(Image.FORMAT_RGBA8)
	for i in 2:
		var part:=water.get_region(Rect2i(i*384+12,12,360,317))
		part.resize(128,128,Image.INTERPOLATE_NEAREST)
		atlas.blit_rect(part,Rect2i(0,0,128,128),Vector2i(i*128,384))
	atlas.save_webp("res://art/konflux/terrain.webp")
	var heights:=Image.load_from_file(folder+"/06-hoehen-12.png")
	heights.convert(Image.FORMAT_RGBA8)
	var cliffs:=Image.create(768,96,false,Image.FORMAT_RGBA8)
	var regions: Array[Rect2i]=[Rect2i(14,144,360,88),Rect2i(14,780,360,115),Rect2i(782,774,360,116)]
	for i in 3:
		var part:=heights.get_region(regions[i])
		part.resize(256,96,Image.INTERPOLATE_NEAREST)
		cliffs.blit_rect(part,Rect2i(0,0,256,96),Vector2i(i*256,0))
	cliffs.save_webp("res://art/konflux/cliffs.webp")
	var source:=Image.load_from_file(folder+"/07-fluss-12.png")
	var bridge:=source.get_region(Rect2i(14,747,360,160))
	bridge.resize(256,128,Image.INTERPOLATE_NEAREST)
	bridge.save_webp("res://art/konflux/bridge.webp")
	print("KONFLUX_ART: 14 materials, 3 cliff faces, bridge compiled")
	quit()
