extends SceneTree
## Sichtbeleg: Fusionsvorschau am Kristall (Liste mit VORSCHAU-Knopf und
## laufende Übungswelt). Aufruf: godot --path . -s tools/capture_fusion_preview.gd -- <ordner>
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func _process(_delta:float)->void:pass
func _initialize()->void:call_deferred("run")
func run()->void:
	var args:=OS.get_cmdline_user_args()
	var out:String=args[0] if not args.is_empty() else "res://docs/design/fusion-preview"
	DirAccess.make_dir_recursive_absolute(out)
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var g:=Game.new();vp.add_child(g)
	for frame in 8:await process_frame
	g.character_created=true;g.hero_name="Vorschau";g.level=30;g.class_id=0;g.gold=900;g.panel="fusion";g.fusion_page=0
	g.ensure_skill_state_size()
	for frame in 6:
		g.queue_redraw();await process_frame
	RenderingServer.force_draw(false)
	vp.get_texture().get_image().save_jpg(out.path_join("kristall_liste.jpg"),.9)
	var target:="Wirbelhieb · Klingenwelle"
	for i in g.FUSIONS.size():
		if str(g.ABILITIES[int(g.FUSIONS[i]["id"])]["name"])==target:
			g.fusion_page=int(i/4);g.click_fusion(Vector2(660,215+(i%4)*86))
	for shots in [["vorschau_wirken",.18],["vorschau_ergebnis",3.2]]:
		while g.fusion_preview.since_cast<float(shots[1]):
			g.fusion_preview.tick(g,1.0/60.0);g.queue_redraw();await process_frame
		RenderingServer.force_draw(false)
		vp.get_texture().get_image().save_jpg(out.path_join(str(shots[0])+".jpg"),.9)
	print("FUSION_PREVIEW_CAPTURE_OK ",out);quit()
