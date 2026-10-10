extends SceneTree
# Vorschau: kompakte Essensanzeige oben links (Mahlzeit + Snack), mit Info beim Darüberfahren.
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_food_chips.gd -- <datei.png>
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
	g.character_created=true;g.level=40;g.hp=g.max_hp();g.panel="";g.player_pos=Vector2(3300,2150)
	g.world_fog.bytes.fill(255);g.world_fog.mark_changed()
	var now:=Time.get_unix_time_from_system()
	g.food_system.active_food_name="Steinbeeren-Riegel";g.food_system.meal_until=now+250;g.food_system.meal_hp_regen=2.0
	g.food_system.buff_kind="armor";g.food_system.buff_value=0.05;g.food_system.buff_until=now+250
	g.food_system.regen_rate=1.5;g.food_system.regen_until=now+12
	var motion:=InputEventMouseMotion.new();motion.position=Vector2(50,82)
	vp.push_input(motion)
	g.queue_redraw()
	for i in 6:await process_frame
	await RenderingServer.frame_post_draw
	var img:=vp.get_texture().get_image()
	img.crop(520,220)
	img.resize(1040,440,Image.INTERPOLATE_NEAREST)
	img.save_png(out)
	print("CAPTURED ",out)
	quit()
