extends SceneTree
class Board extends Node2D:
	const Design=preload("res://components/monster_design_32.gd")
	const Combat=preload("res://components/mob_combat.gd")
	const Wolf=preload("res://components/wolf_animation.gd")
	var tick:=0
	var font:Font=ThemeDB.fallback_font
	func _draw()->void:
		var time:=tick/15.0
		draw_rect(Rect2(0,0,1280,710),Color("192b26"))
		draw_string(font,Vector2(22,34),"SONNENHAIN · MOOSWOLF · ECHTE POSE-ANIMATIONEN",HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color("edd4a0"))
		var config:=Combat.profile(3,{"region":2,"speed":132},8,14)
		for column in 8:
			draw_string(font,Vector2(250+column*128,68),["S","SW","W","NW","N","NO","O","SO"][column],HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("cfdbc4"))
		for row in 4:
			var y:=170.0+row*150
			draw_string(font,Vector2(20,y-25),["RUHE","LAUFEN","BISS","SPRUNG"][row],HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("edd4a0"))
			for direction in 8:
				var foot:=Vector2(260+direction*128,y)
				draw_rect(Rect2(foot-Vector2(57,94),Vector2(114,122)),Color("536b3e"))
				var angle:=-direction*PI/4.0
				var look:=Vector2(sin(angle),cos(angle))
				var phase:=fposmod(time*132.0/Wolf.STRIDE_LENGTH*TAU,TAU) if row==1 else 0.0
				var attack:float=-1.0
				var ability_id:=""
				if row>=2:
					var ability:Dictionary=config["abilities"][row-2]
					var timing:=Combat.attack_timing(config,ability)
					var age:=fposmod(time,float(timing["attack_cycle"]))
					if age<float(timing["windup"])+float(timing["active_time"])+float(timing["recovery"]):attack=Combat.visual_progress({"age":age,"ability":ability},config)
					ability_id=ability["id"]
				Design.paint(self,foot,3,8,look,Color("789983"),phase,attack,1.0,Vector2.ONE,ability_id,{"walking":row==1,"clock":time,"seed":direction*.07})
func _initialize()->void:call_deferred("capture")
func capture()->void:
	DirAccess.make_dir_recursive_absolute("res://docs/mob-erneuerung/wolf-frames")
	var viewport:=SubViewport.new()
	viewport.size=Vector2i(1280,710)
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var board:=Board.new()
	viewport.add_child(board)
	for tick in 48:
		board.tick=tick
		board.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var error:=viewport.get_texture().get_image().save_png("res://docs/mob-erneuerung/wolf-frames/frame-%02d.png"%tick)
		if error!=OK:quit(error);return
	print("WOLF_ANIMATION_RENDER_OK 8 directions, idle, distance-driven gait, bite and grounded leap poses")
	viewport.queue_free()
	await process_frame
	quit()
