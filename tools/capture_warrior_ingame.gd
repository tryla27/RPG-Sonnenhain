extends SceneTree
# Vorschau: der Krieger im echten Spielbild (Stehen vorn, Stehen seitlich, Sprung), um
# Zeichenfehler mit der Welt-Verschiebung zu erkennen (10.10.2026: Sprung-Sprite
# war doppelt verschoben und unsichtbar).
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_warrior_ingame.gd -- <datei.png>
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass

func _initialize()->void:call_deferred("capture")

func shot(vp:SubViewport)->Image:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	return vp.get_texture().get_image().get_region(Rect2i(476,204,200,180))

func capture()->void:
	var out:String=OS.get_cmdline_user_args()[0]
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var g:=Game.new();vp.add_child(g)
	for i in 8:await process_frame
	g.character_created=true;g.level=42;g.panel="";g.class_id=0;g.hero_race=0;g.hero_gender=0
	g.hp=g.max_hp();g.death_timer=0.0
	g.player_pos=g.WAYSTONES[1]+Vector2(0,160)
	for i in 20:await process_frame
	g.enemies.clear()
	var sheet:=Image.create(600,180,false,Image.FORMAT_RGBA8)
	g.is_walking=false;g.facing=Vector2.DOWN;g.queue_redraw()
	sheet.blit_rect(await shot(vp),Rect2i(0,0,200,180),Vector2i(0,0))
	g.facing=Vector2.RIGHT;g.queue_redraw()
	sheet.blit_rect(await shot(vp),Rect2i(0,0,200,180),Vector2i(200,0))
	g.is_walking=false;g.warrior_jump_duration=10.0;g.warrior_jump_timer=5.0;g.warrior_jump_direction=Vector2.DOWN;g.queue_redraw()
	sheet.blit_rect(await shot(vp),Rect2i(0,0,200,180),Vector2i(400,0))
	sheet.resize(1200,360,Image.INTERPOLATE_NEAREST)
	sheet.save_png(out)
	print("CAPTURED ",out)
	quit()
