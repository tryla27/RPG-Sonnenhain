extends SceneTree
# Rezeptbuch im echten Spielmenü, ohne Verbindung zum Live-Server.
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func _process(_d:float)->void:queue_redraw()
func _initialize()->void:call_deferred("capture")
func capture()->void:
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648)
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var g:=Game.new();vp.add_child(g)
	for i in 8:await process_frame
	g.character_created=true;g.panel="journal";g.recipe_journal.tab=1
	g.steinrose.learned[3]=true;g.steinrose.learned[11]=true
	g.recipe_journal.selected=3
	g.inventory=[{"name":"Kristallbeeren","count":1}]
	for i in 10:await process_frame
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0])
	print("RECIPE_JOURNAL_CAPTURED")
	quit()
