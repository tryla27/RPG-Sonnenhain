extends SceneTree
class Board extends "res://main.gd":
	const Design=preload("res://components/monster_design_32.gd")
	var page=0
	func _ready()->void:
		font=ThemeDB.fallback_font
	func _process(_delta:float)->void:pass
	func _draw()->void:
		draw_rect(Rect2(0,0,1450,1200),Color("101e2d"))
		draw_string(font,Vector2(25,35),"MONSTER-UPDATE · GODOT-ENTWURF · ACHT RICHTUNGEN · %d/3"%(page+1),HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color("d9b964"))
		for col in 8:
			draw_string(font,Vector2(270+col*145,75),["N","NO","O","SO","S","SW","W","NW"][col],HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("d9b964"))
		for row in 9:
			var t=page*9+row
			var y=100+row*120
			var lv=enemy_level(t)
			draw_string(font,Vector2(20,y+35),ENEMY_TYPES[t]["name"],HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("eee4cd"))
			draw_string(font,Vector2(20,y+58),"Map %d · Lv %d"%[ENEMY_TYPES[t]["region"],lv],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("a9bac5"))
			for col in 8:
				var foot=Vector2(280+col*145,y+80)
				draw_rect(Rect2(foot-Vector2(48,64),Vector2(96,96)),Color("293f33"))
				var a=[4,3,2,1,0,7,6,5][col]*PI/4.0
				Design.paint(self,foot,t,lv,Vector2(sin(a),cos(a)),ENEMY_TYPES[t]["color"],.7)
func _initialize()->void:call_deferred("capture")
func capture()->void:
	for page in 3:
		var vp=SubViewport.new()
		vp.size=Vector2i(1450,1200)
		vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
		root.add_child(vp)
		var board=Board.new()
		board.page=page
		vp.add_child(board)
		await process_frame
		await RenderingServer.frame_post_draw
		await process_frame
		await RenderingServer.frame_post_draw
		var err=vp.get_texture().get_image().save_png("D:/SonnenhainRPG-Audio/monster-update-%d.png"%(page+1))
		if err!=OK:quit(err);return
		vp.queue_free()
	quit()
