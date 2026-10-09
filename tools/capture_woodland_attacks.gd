extends SceneTree
class Board extends "res://main.gd":
	var tick:=0
	func _ready()->void:
		font=ThemeDB.fallback_font
		character_canvas_offset=Vector2.ZERO
	func _process(_delta:float)->void:pass
	func mob_visual_scale(_enemy:Dictionary)->float:return 1.0
	func _draw()->void:
		draw_rect(Rect2(0,0,1152,640),Color("203329"))
		draw_string(font,Vector2(24,34),"SONNENHAIN · NEUE MOB-ANGRIFFE",HORIZONTAL_ALIGNMENT_LEFT,-1,24,Color("edd4a0"))
		for column in 3:
			draw_string(font,Vector2(240+column*300,74),["BEREIT","WARNUNG","ANGRIFF"][column],HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("cddbb7"))
		for row in 3:
			var type:=row+1
			var y:=180.0+row*160
			draw_string(font,Vector2(20,y-8),["Drüsensekret","Giftstaub","Sprungbiss"][row],HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("edd4a0"))
			for column in 3:
				var pos:=Vector2(275+column*300,y)
				draw_rect(Rect2(pos-Vector2(110,86),Vector2(240,138)),Color("536b3e"))
				var enemy:Dictionary=make_enemy(type,pos)
				enemy["uid"]=row*3+column
				enemy["target_peer"]=0
				player_pos=pos+Vector2(150,0)
				enemy["facing"]=Vector2.RIGHT
				var profile:=mob_profile(enemy)
				var ability:Dictionary=profile["abilities"][-1]
				var timing:=MobCombat.attack_timing(profile,ability)
				var age:=float(timing["windup"])*.6
				if column==2:age=float(timing["windup"])+float(timing["active_time"])*.5
				if column>0:enemy["attack_state"]={"id":1,"age":age,"dir":Vector2.RIGHT,"ability":ability,"fired":column==2}
				if column==2 and type==2:
					WoodlandAttackVFX.cloud(self,pos,84.0,float(tick)*.05,2.0)
				elif column==2 and type==1:
					WoodlandAttackVFX.secretion(self,pos+Vector2(82,-8),Vector2.RIGHT)
				draw_enemy(enemy)
func _initialize()->void:call_deferred("capture")
func capture()->void:
	var viewport:=SubViewport.new()
	viewport.size=Vector2i(1152,640)
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var board:=Board.new()
	viewport.add_child(board)
	await process_frame
	await RenderingServer.frame_post_draw
	var error:=viewport.get_texture().get_image().save_png("res://docs/mob-erneuerung/angriffe.png")
	if error!=OK:quit(error);return
	print("WOODLAND_ATTACKS_RENDER_OK real enemy renderer / glands / area warning and dust / leap warning and airborne sprite")
	viewport.queue_free()
	await process_frame
	quit()
