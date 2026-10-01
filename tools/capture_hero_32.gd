extends SceneTree
class Board extends Node2D:
	const Hero=preload("res://components/rpg_hero.gd")
	func _draw()->void:
		draw_rect(Rect2(0,0,1280,1120),Color("101e2d"))
		var font=ThemeDB.fallback_font
		draw_string(font,Vector2(28,38),"AKTUELLE GODOT-FIGUREN · 32-PIXEL-TILES · ACHT RICHTUNGEN",HORIZONTAL_ALIGNMENT_LEFT,-1,23,Color("d9b964"))
		var headings=["N","NO","O","SO","S","SW","W","NW"]
		var indices=[4,3,2,1,0,7,6,5]
		for col in 8:
			draw_string(font,Vector2(236+col*128,78),headings[col],HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("d9b964"))
		for race in 3:
			for role in 3:
				var row=race*3+role
				var y=100+row*110
				draw_string(font,Vector2(20,y+45),["Mensch","Ork","Roboter"][race],HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("eee4cd"))
				draw_string(font,Vector2(20,y+67),["Krieger","Magier","Bogenschuetze"][role],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("a9bac5"))
				for col in 8:
					var foot=Vector2(240+col*128,y+82)
					for tx in 3:
						for ty in 3:
							draw_rect(Rect2(foot+Vector2(-48+tx*32,-64+ty*32),Vector2(32,32)),Color("23372e") if (tx+ty)%2==0 else Color("293f33"))
					var a=indices[col]*PI/4.0
					Hero.paint(self,foot,role,race,0,Vector2(sin(a),cos(a)),0.7,1.0,Vector2.ZERO)
func _initialize()->void:
	call_deferred("capture")
func capture()->void:
	var vp=SubViewport.new()
	vp.size=Vector2i(1280,1120)
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	vp.add_child(Board.new())
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	var err=vp.get_texture().get_image().save_png("D:/SonnenhainRPG-Audio/figuren-32tiles-aktuell.png")
	quit(err)
