extends SceneTree
# Vorschau: Inventar, Maus über der getragenen Rüstung am Charakter → Item-Infos.
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_worn_tooltip.gd -- <datei.png>
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
	g.character_created=true;g.level=40;g.class_id=0
	g.inventory.clear()
	var armor:Dictionary=g.master_armor_item(3)
	g.inventory.append(armor);g.equipped_armor_uid=int(armor["uid"])
	var sword:Dictionary=g.make_item("Klinge des Ostens","sword",3,84,400)
	g.inventory.append(sword);g.equipped_uid=int(sword["uid"])
	g.inventory.append(g.make_item("Heiltrank","potion",1,0,18))
	g.panel="inventory"
	var motion:=InputEventMouseMotion.new();motion.position=Vector2(545,270)
	vp.push_input(motion)
	g.queue_redraw()
	for i in 6:await process_frame
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(out)
	print("CAPTURED ",out)
	quit()
