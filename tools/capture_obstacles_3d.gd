extends SceneTree
## Tatsächliche Spielkarten mit laufenden 3D-Meshes, Figuren und Tiefensortierung.
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass

func _initialize()->void:call_deferred("capture")

func capture()->void:
	var args:=OS.get_cmdline_user_args()
	var out:=args[0] if not args.is_empty() else "res://docs/design/obstacles-live-3d"
	DirAccess.make_dir_recursive_absolute(out)
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var g:=Game.new();vp.add_child(g)
	for i in 8:await process_frame
	g.set_process(false);g.performance_cache_enabled=false;g.panel="";g.character_created=true
	g.hero_name="Angelo";g.hero_race=2;g.level=40;g.enemies.clear();g.world_fog.bytes.fill(255);g.world_fog.mark_changed()
	for zone in range(13):
		var rect:Rect2=g.region_rect(zone)
		var point:Vector2=rect.position+Vector2(rect.size.x*.45,rect.size.y*.4)
		if zone==0:point=Vector2(875,1000)
		if zone==1:point=Vector2(3650,2650)
		g.player_pos=point;g.camera_pos=(point-g.VIEW*.5).clamp(Vector2.ZERO,g.WORLD-g.VIEW)
		g.scale=Vector2.ONE;g.world_obstacles_3d.signature=""
		for i in 12:
			g.world_obstacles_3d.update(g,1.0/60);g.queue_redraw();await process_frame
		await RenderingServer.frame_post_draw
		var path:=out.path_join("map%02d.png"%zone)
		assert(vp.get_texture().get_image().save_png(path)==OK)
		print("CAPTURED ",zone," objects=",g.world_obstacles_3d.rows.size()," ",path)
	for view in [["mauer-tor",Vector2(5000,1250),1.0],["mauer-ecke",Vector2(5000,4200),1.0],["zoom-70",Vector2(12600,2200),.7],["held-hinter-baum",Vector2(3575,3075),1.0],["held-vor-baum",Vector2(3575,3135),1.0]]:
		g.player_pos=view[1];g.camera_zoom=float(view[2]);g.scale=Vector2.ONE*g.camera_zoom
		g.camera_pos=g.player_pos-g.camera_view_size()*.5;g.world_obstacles_3d.signature=""
		for i in 12:
			g.world_obstacles_3d.update(g,1.0/60);g.queue_redraw();await process_frame
		await RenderingServer.frame_post_draw
		assert(vp.get_texture().get_image().save_png(out.path_join(str(view[0])+".png"))==OK)
		print("CAPTURED ",view[0]," objects=",g.world_obstacles_3d.rows.size()," atlas=",g.world_obstacles_3d.viewport.size)
	quit()
