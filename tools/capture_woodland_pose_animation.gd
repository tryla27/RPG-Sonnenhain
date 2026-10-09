extends SceneTree
class Board extends Node2D:
	const Design=preload("res://components/monster_design_32.gd")
	const Combat=preload("res://components/mob_combat.gd")
	const Pose=preload("res://components/woodland_pose_animation.gd")
	const PALETTES=[Color("73cb88"),Color("e998b6"),Color("e3ad77")]
	var tick:=0
	var overview:=false
	var font:Font=ThemeDB.fallback_font
	func _draw()->void:
		var time:=tick/15.0
		draw_rect(Rect2(0,0,1280,670),Color("192b26"))
		draw_string(font,Vector2(22,34),"SONNENHAIN · SCHLEIM, KÄFER UND PILZLING · POSE-ANIMATIONEN",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("edd4a0"))
		var headers: Array=["S","SW","W","NW","N","NO","O","SO"] if overview else ["RUHE","LAUFEN","ANGRIFF","TREFFER","TOD"]
		for column in headers.size():draw_string(font,Vector2(250+column*(128 if overview else 200),72),headers[column],HORIZONTAL_ALIGNMENT_LEFT,-1,17,Color("cfdbc4"))
		for type in 3:
			var y:=190.0+type*185
			draw_string(font,Vector2(20,y-30),["Waldschleim","Blütenkäfer","Pilzling"][type],HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("edd4a0"))
			for column in headers.size():
				var foot:=Vector2(275+column*(128 if overview else 200),y)
				draw_rect(Rect2(foot-Vector2(60,98),Vector2(120,124)),Color("536b3e"))
				var angle:=-column*PI/4.0 if overview else PI*.5
				var look:=Vector2(sin(angle),cos(angle))
				var phase:=0.0
				var attack:float=-1.0
				var visual:Dictionary={"walking":not overview and column==1,"clock":time,"seed":type*.47}
				if not overview and column==1:phase=fposmod(time*[78,113,65][type]/Pose.STRIDES[type]*TAU,TAU)
				if not overview and column==2:
					var config:=Combat.profile(type,{"region":1 if type<2 else 2,"speed":[78,113,65][type]},8,11)
					var ability:Dictionary=config["abilities"][0]
					var age:=fposmod(time,float(config["attack_cycle"]))
					if age<float(config["windup"])+float(config["active_time"])+float(config["recovery"]):attack=Combat.visual_progress({"age":age,"ability":ability},config)
				if not overview and column==3:visual["hurt"]=maxf(0.0,.18-fposmod(time,.85))
				if not overview and column==4:visual["death"]=fposmod(time,1.4)
				Design.paint(self,foot,type,8,look,PALETTES[type],phase,attack,1.0,Vector2.ONE,"",visual)
func _initialize()->void:call_deferred("capture")
func capture()->void:
	DirAccess.make_dir_recursive_absolute("res://docs/mob-erneuerung/woodland-frames")
	var viewport:=SubViewport.new()
	viewport.size=Vector2i(1280,670)
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var board:=Board.new()
	viewport.add_child(board)
	for tick in 56:
		board.tick=tick;board.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		var error:=viewport.get_texture().get_image().save_png("res://docs/mob-erneuerung/woodland-frames/frame-%02d.png"%tick)
		if error!=OK:quit(error);return
	board.overview=true;board.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	viewport.get_texture().get_image().save_png("res://docs/mob-erneuerung/woodland-richtungen.png")
	print("WOODLAND_POSE_RENDER_OK idle / move / release / hurt / death plus all eight direction views")
	viewport.queue_free();await process_frame;quit()
