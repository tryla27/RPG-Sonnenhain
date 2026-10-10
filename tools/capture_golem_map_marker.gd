extends SceneTree
# Vorschau: Weltkarte mit dem Golem-Altar (lila Symbol im Himmelsgarten).
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_golem_map_marker.gd -- <datei.png>
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass

func _initialize()->void:call_deferred("capture")

func capture()->void:
	var out:String=OS.get_cmdline_user_args()[0]
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var g:=Game.new();vp.add_child(g)
	for i in 8:await process_frame
	g.set_process(false)
	g.character_created=true;g.creative_mode=true;g.level=40;g.player_pos=Vector2(13500,8730)
	g.world_fog.bytes.fill(255);g.world_fog.mark_changed()
	g.panel="map";g.queue_redraw()
	for i in 6:await process_frame
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(out)
	print("CAPTURED ",out)
	quit()
