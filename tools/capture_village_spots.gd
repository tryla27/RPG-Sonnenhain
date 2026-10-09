extends SceneTree
# Bildschirmfotos an festen Dorfstellen aus dem echten Spiel (ohne HUD-Eingriffe).
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_village_spots.gd -- <ordner> x,y [x,y ...]

class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass

func _initialize()->void:call_deferred("capture")

func capture()->void:
	var args:=OS.get_cmdline_user_args()
	var out:String=args[0]
	DirAccess.make_dir_recursive_absolute(out)
	var viewport:=SubViewport.new()
	viewport.size=Vector2i(1152,648)
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var g:=Game.new()
	viewport.add_child(g)
	for i in 45:await process_frame
	g.panel=""
	g.character_created=true
	g.hero_name="Angelo"
	for n in range(1,args.size()):
		var parts:=str(args[n]).split(",")
		g.player_pos=Vector2(float(parts[0]),float(parts[1]))
		g.enemies.clear()
		for i in 40:await process_frame
		await RenderingServer.frame_post_draw
		viewport.get_texture().get_image().save_png(out.path_join("spot%d.png" % n))
		print("CAPTURED ",args[n]," camera ",g.camera_pos," zoom ",g.effective_camera_zoom())
	quit()
