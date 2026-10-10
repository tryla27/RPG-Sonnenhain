extends SceneTree
# Vorschau: Android-App-Steuerung im echten Spielbild (Touch-HUD, Menüleiste,
# Eingabeleiste über der Bildschirmtastatur).
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_app_touch.gd -- <ordner>
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass

func _initialize()->void:call_deferred("capture")

func shot(vp:SubViewport,path:String)->void:
	for i in 3:await process_frame
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(path)
	print("CAPTURED ",path)

func capture()->void:
	var out:String=OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(out)
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var g:=Game.new();vp.add_child(g)
	for i in 8:await process_frame
	g.character_created=true;g.level=24;g.panel="";g.class_id=0;g.hero_race=0;g.hero_gender=0
	g.hp=g.max_hp();g.death_timer=0.0;g.touch_enabled=true
	g.app_mode=true
	g.reset_touch_joystick();g.reset_touch_aim()
	var ids:Array=preload("res://components/class_spell_preview.gd").ids(0)
	for i in mini(3,ids.size()):g.slots[i]=int(ids[i])
	if ids.size()>0:g.cooldowns[int(ids[0])]=3.4
	g.player_pos=g.WAYSTONES[1]+Vector2(0,160)
	for i in 20:await process_frame
	g.enemies.clear()
	await shot(vp,out+"/hud.png")
	g.call("update_touch_joystick",g.touch_move_base+Vector2(60,-30))
	g.touch_move_id=0
	g.begin_touch_aim(1,Vector2(1032,526));g.update_touch_aim(Vector2(1090,480))
	g.queue_redraw()
	await shot(vp,out+"/hud_active.png")
	g.clear_touch_inputs()
	g.panel="app_menu";g.queue_redraw()
	await shot(vp,out+"/menu.png")
	g.panel=""
	if g.has_method("app_keyboard_preview"):
		g.panel="account_login";g.account_name="Wanderer";g.account_password="geheim12";g.account_focus=1
		g.app_keyboard_preview("account_1")
		await shot(vp,out+"/login_keyboard.png")
		g.panel="";g.chat_open=true;g.chat_input="Hallo Gruppe, wer kommt mit zum Golem?"
		g.app_keyboard_preview("chat")
		await shot(vp,out+"/chat_keyboard.png")
	quit()
