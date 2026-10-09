extends SceneTree
# Vorschaubilder für die neuen Wegstein-Plateaus: aktiv mit Held vor der Treppe,
# Held oben hinter dem Obelisk, und ein noch nicht aktivierter Wegstein.
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_waystone_plateau.gd -- <ordner>

class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass

func _initialize()->void:call_deferred("capture")

func shot(g,viewport:SubViewport,pos:Vector2,path:String)->void:
	g.player_pos=pos
	g.enemies.clear()
	for i in 30:await process_frame
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
	g.level=30
	for i in g.event_states.size():g.event_states[i]=3
	g.world_fog.bytes.fill(255)
	var a:Vector2=g.WAYSTONES[8]
	g.waystone_unlocked[8]=true
	await shot(g,viewport,a+Vector2(0,120),out.path_join("1-aktiv-vor-treppe.png"))
	await shot(g,viewport,a+Vector2(40,-80),out.path_join("2-oben-hinter-obelisk.png"))
	await shot(g,viewport,a+Vector2(0,64),out.path_join("3-auf-der-treppe.png"))
	var b:Vector2=g.WAYSTONES[5]
	g.waystone_unlocked[5]=false
	await shot(g,viewport,b+Vector2(-150,170),out.path_join("4-nicht-aktiviert.png"))
	quit()
