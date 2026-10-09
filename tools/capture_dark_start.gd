extends SceneTree
# Vorschaubilder für C1 „Start im Dunkeln“: frischer Charakter am Spawn
# (normal und weit herausgezoomt), nach einem kurzen Weg, und die große Karte.
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_dark_start.gd -- <ordner>

class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass

func _initialize()->void:call_deferred("capture")

func shot(viewport:SubViewport,path:String)->void:
	await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png(path)
	print("CAPTURED ",path)

func capture()->void:
	var out:String=OS.get_cmdline_user_args()[0]
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
	g.enemies.clear()
	g.world_fog.clear()
	g.player_pos=Vector2(825,1020)
	for i in 30:await process_frame
	await shot(viewport,out.path_join("1-start.png"))
	g.set_camera_zoom_index(2,false)
	for i in 20:await process_frame
	await shot(viewport,out.path_join("2-start-weit.png"))
	# Kurzer Weg nach Osten und zurück: der Pfad bleibt aufgedeckt.
	for step in 60:
		g.player_pos=Vector2(825+step*30,1020+sin(step*0.15)*120)
		await process_frame
	g.player_pos=Vector2(1700,1020)
	g.set_camera_zoom_index(2,false)
	for i in 20:await process_frame
	await shot(viewport,out.path_join("3-nach-weg.png"))
	g.panel="map"
	for i in 10:await process_frame
	await shot(viewport,out.path_join("4-karte.png"))
	quit()
