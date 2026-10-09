extends SceneTree
class Board extends Node2D:
	const Design=preload("res://components/monster_design_32.gd")
	const Art=preload("res://components/woodland_mob_art.gd")
	const NAMES=["Waldschleim","Blütenkäfer","Pilzling","Mooswolf"]
	var tick:=0
	var font:Font=ThemeDB.fallback_font
	func _draw()->void:
		draw_rect(Rect2(0,0,1280,640),Color("192b26"))
		draw_string(font,Vector2(26,34),"SONNENHAIN · MOB-ERNEUERUNG · ACHT BLICKRICHTUNGEN",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("edd4a0"))
		for column in 8:
			draw_string(font,Vector2(250+column*128,66),["S","SW","W","NW","N","NO","O","SO"][column],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("cfdbc4"))
		for type in 4:
			var y:=170.0+type*130
			draw_string(font,Vector2(20,y-15),NAMES[type],HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("edd4a0"))
			for direction in 8:
				var foot:=Vector2(260+direction*128,y)
				draw_rect(Rect2(foot-Vector2(56,86),Vector2(112,108)),Color("536b3e"))
				var angle:=-direction*PI/4.0
				var look:=Vector2(sin(angle),cos(angle))
				var phase:=tick*.38 if tick<16 else 0.0
				var attack:float=(tick-16)/15.0 if tick>=16 else -1.0
				Design.paint(self,foot,type,1,look,Art.PALETTES[type],phase,attack)
func _initialize()->void:call_deferred("capture")
func capture()->void:
	var viewport:=SubViewport.new()
	viewport.size=Vector2i(1280,640)
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var board:=Board.new()
	viewport.add_child(board)
	for tick in 32:
		board.tick=tick
		board.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var image:=viewport.get_texture().get_image()
		var error:=image.save_png("res://docs/mob-erneuerung/frame-%02d.png"%tick)
		if error!=OK:quit(error);return
	print("WOODLAND_MOBS_RENDER_OK idle/walk/attack, all eight directions")
	quit()
