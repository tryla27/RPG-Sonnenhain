extends SceneTree
## Sichtbeleg: Almas Hauptseite „Kochen“ (Rezeptwahl, Lernen, Zutaten, Kochen).
## Aufruf: godot --path . -s tools/capture_alma_cooking.gd -- <ordner>
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func _process(_delta:float)->void:pass
func _initialize()->void:call_deferred("run")
func run()->void:
	var args:=OS.get_cmdline_user_args()
	var out:String=args[0] if not args.is_empty() else "res://docs/design/alma-cooking"
	DirAccess.make_dir_recursive_absolute(out)
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var g:=Game.new();vp.add_child(g)
	for frame in 8:await process_frame
	g.set_process(false);g.character_created=true;g.hero_name="Vorschau";g.level=12;g.gold=40
	g.steinrose.learned[1]=true;g.steinrose.learned[2]=true
	for shot in [["kochen_gelernt",0],["kochen_lernen",3]]:
		g.steinrose.open(g);g.steinrose.selected=shot[1]
		for frame in 6:
			g.queue_redraw();await process_frame
		RenderingServer.force_draw(false)
		vp.get_texture().get_image().save_jpg(out.path_join(str(shot[0])+".jpg"),.9)
	print("ALMA_CAPTURE_OK ",out);quit()
