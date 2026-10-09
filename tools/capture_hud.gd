extends SceneTree
# Vorschaubilder für HUD und Patch Notes aus dem echten Spiel.
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_hud.gd -- <ausgabeordner> [praefix]

class Game extends "res://main.gd":
	var fake_mouse:=Vector2(-100,-100)
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass

func _initialize()->void:call_deferred("capture")

func shot(viewport:SubViewport,path:String)->void:
	for i in 4:
		await process_frame
		await RenderingServer.frame_post_draw
	assert(viewport.get_texture().get_image().save_png(path)==OK)
	print("CAPTURED ",path)

func capture()->void:
	var args:=OS.get_cmdline_user_args()
	var out:String=args[0] if args.size()>0 else "user://"
	var prefix:String=args[1] if args.size()>1 else "hud"
	DirAccess.make_dir_recursive_absolute(out)
	var viewport:=SubViewport.new()
	viewport.size=Vector2i(1152,648)
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var g:=Game.new()
	viewport.add_child(g)
	# Statische Bodenstücke brauchen einige Frames.
	for i in 45:
		await process_frame
	g.panel=""
	g.character_created=true
	g.hero_name="Angelo"
	g.player_pos=g.WAYSTONES[0]+Vector2(90,140)
	g.level=7
	g.xp=60
	g.hp=g.max_hp()*0.62
	for i in 30:
		await process_frame
	for zoom in g.CAMERA_ZOOM_LEVELS.size():
		g.set_camera_zoom_index(zoom,false)
		await shot(viewport,out.path_join("%s-zoom%d.png" % [prefix,roundi(float(g.CAMERA_ZOOM_LEVELS[zoom])*100)]))
	g.set_camera_zoom_index(0,false)
	for hover in [["status",Vector2(120,40)],["quest",Vector2(200,570)],["xp",Vector2(500,642)]]:
		var motion:=InputEventMouseMotion.new()
		motion.position=hover[1]
		motion.global_position=hover[1]
		viewport.push_input(motion)
		await shot(viewport,out.path_join("%s-hover-%s.png" % [prefix,hover[0]]))
	if "patch_view" in g:
		var away:=InputEventMouseMotion.new()
		away.position=Vector2(5,5)
		viewport.push_input(away)
		g.panel="patches"
		g.patch_view=g.PatchNotes.new_view()
		await shot(viewport,out.path_join("patchnotes-liste.png"))
		g.patch_view["open"]=1
		await shot(viewport,out.path_join("patchnotes-detail.png"))
	if "menu_feedback" in g:
		g.panel="settings"
		g.menu_feedback.ask_exit("settings")
		await shot(viewport,out.path_join("verlassen-rueckfrage.png"))
	quit()
