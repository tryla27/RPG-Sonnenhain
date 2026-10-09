extends SceneTree
const Mountain=preload("res://components/village_mountain.gd")
class TerrainCanvas extends Node2D:
	func _draw()->void:
		draw_set_transform(Vector2(0,64))
		Mountain.paint_generated(self)
func _initialize()->void:call_deferred("build")
func build()->void:
	var viewport:=SubViewport.new()
	viewport.size=Vector2i(600,432)
	viewport.transparent_bg=true
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var canvas:=TerrainCanvas.new()
	canvas.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	viewport.add_child(canvas)
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	assert(viewport.get_texture().get_image().save_png(Mountain.TEXTURE_PATH)==OK)
	print("MOUNTAIN_BAKE_OK six terraces cached in one native texture")
	quit()
