extends SceneTree
class Board extends "res://main.gd":
	func _ready()->void:
		font=ThemeDB.fallback_font
		world_time=0.0
	func _process(_delta:float)->void:pass
	func _draw()->void:
		draw_rect(Rect2(0,0,1050,390),Color("101e2d"))
		draw_string(font,Vector2(25,38),"BESTEHENDE BOSSE · BISHERIGE GODOT-MODELLE",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("d9b964"))
		for index in 3:
			var t=12+index
			var p=Vector2(175+index*350,235)
			draw_rect(Rect2(p-Vector2(110,145),Vector2(220,190)),Color("293f33"))
			draw_boss_model(t,p,ENEMY_TYPES[t]["color"],0.0)
			draw_string(font,p+Vector2(-120,86),ENEMY_TYPES[t]["name"],HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("eee4cd"))
			draw_string(font,p+Vector2(-120,111),["Alte Ruinen · Map 3","Kristallmoor · Map 4","Sternenbruch · Map 7"][index],HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("a9bac5"))
func _initialize()->void:call_deferred("capture")
func capture()->void:
	var vp=SubViewport.new()
	vp.size=Vector2i(1050,390)
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	vp.add_child(Board.new())
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	quit(vp.get_texture().get_image().save_png("D:/SonnenhainRPG-Audio/bestehende-bosse.png"))
