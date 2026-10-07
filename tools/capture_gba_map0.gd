extends SceneTree
const Map0=preload("res://components/start_tilemap_32.gd")

class Board extends "res://main.gd":
	var night_preview:=false
	func _ready()->void:
		font=ThemeDB.fallback_font
		static_draw_bounds=Rect2(0,0,1780,2600)
		texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	func camera_world_rect()->Rect2:return Rect2(0,0,1780,2600)
	func _process(_delta:float)->void:pass
	func _draw()->void:
		draw_set_transform(Vector2.ZERO)
		SpawnPlatform32.platform(self,WAYSTONES[0])
		var props:=village_props()
		props.append({"kind":"qa_spawn","point":WAYSTONES[0],"depth":WAYSTONES[0].y})
		props.sort_custom(func(a,b):return float(a["depth"])<float(b["depth"]))
		for prop in props:
			if prop["kind"]=="qa_spawn":draw_waystone(prop["point"])
			else:paint_village_prop(prop)
		draw_fusion_crystal()
		if night_preview:draw_day_night_overlay()

func _initialize()->void:call_deferred("capture")

func capture()->void:
	DirAccess.make_dir_recursive_absolute("res://docs/gba-map0")
	var vp:=SubViewport.new()
	vp.size=Vector2i(1780,2600)
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var map:=Map0.new()
	vp.add_child(map)
	var board:=Board.new()
	vp.add_child(board)
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	var picture:=vp.get_texture().get_image()
	assert(picture.save_png("res://docs/gba-map0/01-gesamte-dorfkarte.png")==OK)
	assert(picture.get_region(Rect2i(0,512,1780,1184)).save_png("res://docs/gba-map0/02-spawn-und-dorfmitte.png")==OK)
	for view in [["05-raised-forge",Rect2i(64,128,512,576)],["06-raised-borin",Rect2i(1216,32,544,624)],["07-raised-church",Rect2i(64,1088,512,608)],["08-mixed-stone-crossing",Rect2i(544,544,608,192)]]:
		assert(picture.get_region(view[1]).save_png("res://docs/gba-map0/%s.png"%view[0])==OK)
	var plan=load("res://components/map0_ground_plan_32.gd")
	for id in plan.CHUNK_ORDER:
		var region:Rect2i=Rect2i(plan.CHUNKS[id]["cells"])
		var pixels:Rect2i=Rect2i(region.position*32,region.size*32).intersection(Rect2i(0,0,1780,2600))
		assert(picture.get_region(pixels).save_png("res://docs/gba-map0/chunk-%s.png"%id)==OK)
	assert(Map0.complete_floor_image().save_png("res://docs/gba-map0/03-boden-ohne-objekte.png")==OK)
	board.night_preview=true
	board.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	assert(vp.get_texture().get_image().save_png("res://docs/gba-map0/04-lanterns-night.png")==OK)
	print("GBA_MAP0_RENDER_OK full map, spawn, six chunks, actual runtime TileMap and live village PNGs")
	quit()
