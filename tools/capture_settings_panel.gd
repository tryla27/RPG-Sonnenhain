extends SceneTree
# Vorschau: Einstellungsfenster (Esc → Einstellungen) im normalen Spiel.
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_settings_panel.gd -- <datei.png>
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
	g.character_created=true;g.level=42;g.gold=16087
	g.music_volume=0.6;g.effects_volume=0.25
	g.pause_status="Server gespeichert"
	g.panel="settings"
	g.queue_redraw()
	for i in 6:await process_frame
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(out)
	print("CAPTURED ",out)
	quit()
