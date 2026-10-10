extends SceneTree
# Vorschau: Weltkarte mit allen Nahrungsbüschen (gelb) und Kräutern (grün).
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_food_bushes.gd -- <datei.png>
class Game extends "res://main.gd":
	var show:=false
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func _draw()->void:
		if not show:return
		draw_rect(Rect2(0,0,1152,648),Color("17202a"))
		var rect:=Rect2(20,34,1112,600)
		draw_world_atlas(rect)
		var inset:=rect.grow(-7)
		var map_scale:=inset.size/WORLD
		for plant in food_system.plants:
			var p:Vector2=inset.position+Vector2(plant["point"])*map_scale
			var herb:=str(plant.get("kind","fruit"))=="herb"
			draw_circle(p,6,Color("1a1a1a"))
			draw_circle(p,4.5,Color("7fd37a") if herb else Color("f2c94c"))
		text_at(Vector2(20,24),"Nahrungsbüsche: 8–12 Fruchtbüsche (gelb) + 3 Kräuter (grün) pro Gebiet",15,Color("ffe9b8"))

func _initialize()->void:call_deferred("capture")

func capture()->void:
	var out:String=OS.get_cmdline_user_args()[0]
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var g:=Game.new();vp.add_child(g)
	for i in 8:await process_frame
	g.set_process(false)
	g.character_created=true;g.creative_mode=true;g.level=40
	g.world_fog.bytes.fill(255);g.world_fog.mark_changed()
	g.food_system.configure(g)
	g.panel="";g.show=true;g.queue_redraw()
	for i in 6:await process_frame
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(out)
	print("CAPTURED ",out)
	quit()
