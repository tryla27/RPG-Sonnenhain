extends SceneTree
## Sichtbeleg (mit Gebietshinweis rechts): Gebietsbanner beim ersten Betreten (Alte Ruinen und Mondküste).
## Aufruf: godot --path . -s tools/capture_region_banner.gd -- <Ausgabeordner>
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func _process(_delta:float)->void:pass
	func spawn_enemy()->void:pass
func _initialize()->void:call_deferred("run")
func run()->void:
	var args:=OS.get_cmdline_user_args()
	var out:String=args[0] if not args.is_empty() else "res://docs/design/region-banner"
	DirAccess.make_dir_recursive_absolute(out)
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var g:=Game.new();vp.add_child(g)
	for frame in 8:await process_frame
	g.set_process(false);g.panel="";g.character_created=true;g.hero_name="Vorschau";g.level=16;g.hp=100
	g.world_fog.bytes.fill(255);g.world_fog.mark_changed()
	for spot in [["ruinen",Vector2(6300,1700)],["mondkueste",Vector2(800,5200)]]:
		g.previous_region=0
		g.player_pos=spot[1];g.camera_pos=g.player_pos-g.VIEW*.5;g.camera_smooth=g.camera_pos
		g.update_player(1.0/60.0)
		for i in 40:g.region_banner.tick(1.0/60.0);g.region_finds.tick(1.0/60.0)
		for frame in 20:
			g.world_obstacles_3d.update(g,1.0/60.0);g.update_static_cache();g.queue_redraw()
			await process_frame
		RenderingServer.force_draw(false)
		vp.get_texture().get_image().save_png(out.path_join(str(spot[0])+".png"))
	print("REGION_BANNER_CAPTURE_OK");quit()
