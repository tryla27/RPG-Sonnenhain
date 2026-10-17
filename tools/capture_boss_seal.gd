extends SceneTree
## Sichtbeleg: Siegeltor an bossgesperrten Gebietstoren (senkrecht und waagerecht).
## Aufruf: godot --path . -s tools/capture_boss_seal.gd -- <Ausgabeordner>
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func _process(_delta:float)->void:pass
func _initialize()->void:call_deferred("run")
func run()->void:
	var args:=OS.get_cmdline_user_args()
	var out:String=args[0] if not args.is_empty() else "res://docs/design/boss-seal"
	DirAccess.make_dir_recursive_absolute(out)
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var g:=Game.new();vp.add_child(g)
	for frame in 8:await process_frame
	g.set_process(false);g.panel="";g.character_created=true;g.hero_name="Vorschau";g.level=24;g.hp=100
	g.enemies.clear();g.world_fog.bytes.fill(255);g.world_fog.mark_changed()
	for spot in [["senkrecht",Vector2(4850,6200)],["waagerecht",Vector2(6600,4050)]]:
		g.player_pos=spot[1];g.camera_pos=g.player_pos-g.VIEW*.5;g.camera_smooth=g.camera_pos
		for frame in 24:
			g.world_obstacles_3d.update(g,1.0/60.0);g.update_static_cache();g.queue_redraw()
			await process_frame
		RenderingServer.force_draw(false)
		vp.get_texture().get_image().save_png(out.path_join(str(spot[0])+".png"))
	print("BOSS_SEAL_CAPTURE_OK");quit()
