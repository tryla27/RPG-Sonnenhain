extends SceneTree
## Isolierte Sichtprüfung. Keine Kontoverbindung, Käufe oder Live-Spielstände.
class Game extends "res://main.gd":
	func save_game()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func announce_multiplayer_context()->void:pass
	func _process(_delta:float)->void:queue_redraw()

const VIEWS := [
	["sonnenhain",Vector2(825,1136)],
	["ratshalle",Vector2(1312,1424)],
	["osttor",Vector2(1790,1120)],
	["bluetenwiesen",Vector2(3150,2350)],
	["pilzwald",Vector2(3150,4780)],
]
func _initialize()->void:call_deferred("run")
func run()->void:
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var screen:=TextureRect.new();screen.texture=vp.get_texture()
	screen.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;screen.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	root.add_child(screen);screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var g:=Game.new();vp.add_child(g)
	for i in 8:await process_frame
	g.creation_name="Sichtprüfung";g.pending_class=0;g.pending_race=0;g.pending_gender=0
	g.start_new_game();g.finish_intro();g.enemies.clear();g.camera_zoom=1.0;g.scale=Vector2.ONE
	var args:=OS.get_cmdline_user_args()
	var browser:=OS.get_name()=="Web"
	var out:=args[0] if not browser and not args.is_empty() else "user://start-area"
	if not browser:DirAccess.make_dir_recursive_absolute(out)
	var selection:=clampi(int(args[0]),0,VIEWS.size()-1) if browser and not args.is_empty() else -1
	for index in VIEWS.size():
		if selection>=0 and index!=selection:continue
		var view:Array=VIEWS[index]
		g.player_pos=view[1];g.camera_pos=g.player_pos-g.VIEW*.5;g.camera_smooth=g.camera_pos
		var zone:int=g.region_at(g.player_pos);g.world_fog.update_from_game(g)
		g.world_obstacles_3d.signature="";g.enemies.clear()
		if zone in [1,2]:
			for mob in [0,1] if zone==1 else [2,3]:
				g.enemies.append(g.make_enemy(mob,g.player_pos+Vector2(150+(mob%2)*120,45)))
		for i in 70:
			g.world_obstacles_3d.update(g,1.0/60.0);g.queue_redraw();await process_frame
		await RenderingServer.frame_post_draw
		var pixels:=g.world_obstacles_3d.visible_pixels(g.world_obstacles_3d.viewport.get_texture().get_image()) if is_instance_valid(g.world_obstacles_3d.viewport) else 0
		print("START_AREA_VIEW ",view[0]," ",JSON.stringify({"rows":g.world_obstacles_3d.rows.size(),"pixels":pixels,"active_3d":g.world_obstacles_3d.active,"region":zone}))
		if not browser:vp.get_texture().get_image().save_png(out.path_join(str(view[0])+".png"))
	if browser:return
	quit()
