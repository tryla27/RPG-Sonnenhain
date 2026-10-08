extends SceneTree
const Plan=preload("res://components/map0_ground_plan_32.gd")
class Board extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func camera_world_rect()->Rect2:return Plan.BOUNDS
	func visible_world(_p:Vector2,_margin:float=160.0)->bool:return true
	func _draw()->void:
		font=ThemeDB.fallback_font
		draw_set_transform(Vector2.ZERO)
		StartTileMap32.paint(self,Plan.BOUNDS,Callable())
		SpawnPlatform32.platform(self,WAYSTONES[0])
		var props:=village_props()
		props.append({"kind":"qa_spawn","point":WAYSTONES[0],"depth":WAYSTONES[0].y})
		props.sort_custom(func(a,b):return float(a["depth"])<float(b["depth"]))
		for prop in props:
			if prop["kind"]=="qa_spawn":draw_waystone(prop["point"])
			else:paint_village_prop(prop)
		draw_fusion_crystal()
		draw_day_night_overlay()
func _initialize()->void:call_deferred("capture")
func capture()->void:
	for variant in [{"name":"tag","time":360.0},{"name":"nacht","time":0.0}]:
		var viewport:=SubViewport.new()
		viewport.size=Vector2i(1780,2600)
		viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var board:=Board.new()
		board.world_time=variant["time"]
		board.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		viewport.add_child(board)
		await process_frame
		await RenderingServer.frame_post_draw
		await process_frame
		await RenderingServer.frame_post_draw
		assert(viewport.get_texture().get_image().save_png("res://docs/dorf-lichtfix-"+variant["name"]+"-2026-10-08.png")==OK)
		viewport.queue_free()
		await process_frame
	print("VILLAGE_DAY_NIGHT_RENDER_OK")
	quit()
