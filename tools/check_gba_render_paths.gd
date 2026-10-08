extends SceneTree
const Map0=preload("res://components/start_tilemap_32.gd")
class Painted extends Node2D:
	func _draw()->void:
		preload("res://components/start_tilemap_32.gd").paint(self,Rect2(0,0,1780,2600),Callable())
func _initialize()->void:call_deferred("run")
func run()->void:
	if DisplayServer.get_name()=="headless":
		print("GBA_RENDER_PATHS_SKIPPED graphical renderer required; run without --headless for pixel comparison")
		quit()
		return
	var viewports:Array[SubViewport]=[]
	for mode in 2:
		var vp:=SubViewport.new()
		vp.size=Vector2i(1780,2600)
		vp.transparent_bg=true
		vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
		root.add_child(vp)
		var node:Node2D=Map0.new() if mode==0 else Painted.new()
		node.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		vp.add_child(node)
		viewports.append(vp)
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	var tiled:=viewports[0].get_texture().get_image()
	var cached:=viewports[1].get_texture().get_image()
	assert(tiled.get_data()==cached.get_data(),"live TileMap and cached painter must be pixel-identical, including corners and clipped boundaries")
	print("GBA_RENDER_PATHS_OK pixel-identical TileMap/cached painter across the complete 1780x2600 map")
	quit()
