extends SceneTree
# Vorschau: die 7 legendären Rüstungen an allen drei Klassen (vorn, Seite, hinten).
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_master_armor.gd -- <datei.png>

const Hero=preload("res://components/rpg_hero.gd")
const MasterArmor=preload("res://components/master_armor.gd")

class Sheet extends Node2D:
	var font:Font
	func _draw()->void:
		draw_rect(Rect2(0,0,1400,880),Color("6f9a63"))
		for id in 7:
			var y:=110+id*112
			draw_string(font,Vector2(20,y-30),str(MasterArmor.ARMORS[id]["name"]),HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("fff3cf"))
			draw_string(font,Vector2(20,y-10),"Schutz %d" % int(MasterArmor.ARMORS[id]["power"]),HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e8f2de"))
			for cls in 3:
				for view in 3:
					var look:Vector2=[Vector2.DOWN,Vector2.RIGHT,Vector2.UP][view]
					Hero.paint(self,Vector2(250+cls*360+view*105,y-40),cls,cls%3,(cls+id)%2,look,0.0,1.25,Vector2.ZERO,-1.0,Vector2.RIGHT,MasterArmor.design(id))
		for cls in 3:
			draw_string(font,Vector2(290+cls*360,870),["Krieger","Magier","Schütze"][cls],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("fff3cf"))

func _initialize()->void:call_deferred("capture")

func capture()->void:
	var out:String=OS.get_cmdline_user_args()[0]
	var vp:=SubViewport.new();vp.size=Vector2i(1400,880);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var sheet:=Sheet.new();sheet.font=ThemeDB.fallback_font;vp.add_child(sheet)
	for i in 6:await process_frame
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(out)
	print("CAPTURED ",out)
	quit()
