extends Node
## Prüfszene für Web-Release-Templates, die --script nicht ausführen.
## Wiederverwendet die isolierte Spielklasse der nativen Bildprüfung.
const Capture=preload("res://tools/capture_start_area.gd")
func _ready()->void:call_deferred("run")
func run()->void:
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648)
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	add_child(vp)
	var screen:=TextureRect.new();screen.texture=vp.get_texture()
	screen.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	screen.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(screen);screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var g:=Capture.Game.new();vp.add_child(g)
	for frame in 8:await get_tree().process_frame
	g.creation_name="Web-Sichtprüfung";g.pending_class=0;g.pending_race=0;g.pending_gender=0
	g.start_new_game();g.finish_intro();g.enemies.clear();g.camera_zoom=1.0;g.scale=Vector2.ONE
	var args:=OS.get_cmdline_user_args()
	var index:=clampi(int(args[0]),0,Capture.VIEWS.size()-1) if not args.is_empty() else 0
	var view:Array=Capture.VIEWS[index]
	g.player_pos=view[1];g.camera_pos=g.player_pos-g.VIEW*.5;g.camera_smooth=g.camera_pos
	var zone:int=g.region_at(g.player_pos);g.world_fog.update_from_game(g)
	g.world_obstacles_3d.signature="";g.enemies.clear()
	if zone in [1,2]:
		for mob in [0,1] if zone==1 else [2,3]:
			g.enemies.append(g.make_enemy(mob,g.player_pos+Vector2(150+(mob%2)*120,45)))
	for frame in 70:
		g.world_obstacles_3d.update(g,1.0/60.0);g.queue_redraw();await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var pixels:=g.world_obstacles_3d.visible_pixels(g.world_obstacles_3d.viewport.get_texture().get_image()) if is_instance_valid(g.world_obstacles_3d.viewport) else 0
	print("START_AREA_WEB ",view[0]," ",JSON.stringify({"rows":g.world_obstacles_3d.rows.size(),"pixels":pixels,"active_3d":g.world_obstacles_3d.active,"region":zone}))
