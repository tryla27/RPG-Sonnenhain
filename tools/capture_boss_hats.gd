extends SceneTree
# Vorschau: die drei Bosshüte an allen drei Klassen, von vorn und von der Seite.
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_boss_hats.gd -- <datei.png>

const Hero=preload("res://components/rpg_hero.gd")

class Sheet extends Node2D:
	var font:Font
	func _draw()->void:
		draw_rect(Rect2(0,0,1152,700),Color("6f9a63"))
		var names:=["Helm des Kriegsherrn","Hut des Dunklen Arkanhüters","Hut des Jagdmeisters"]
		var classes:=["Krieger","Magier","Schütze"]
		for hat in 3:
			draw_string(font,Vector2(30,150+hat*205),names[hat],HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("fff3cf"))
			for cls in 3:
				for view in 2:
					var p:=Vector2(330+cls*270+view*120,150+hat*205)
					Hero.paint(self,p,cls,cls%3,(cls+view)%2,Vector2.DOWN if view==0 else Vector2.RIGHT,0.0,1.6,Vector2.ZERO,-1.0,Vector2.RIGHT,-1,-1.0,0.0,3+hat)
		for cls in 3:
			draw_string(font,Vector2(350+cls*270,690),classes[cls],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("fff3cf"))

func _initialize()->void:call_deferred("capture")

func capture()->void:
	var out:String=OS.get_cmdline_user_args()[0]
	var vp:=SubViewport.new();vp.size=Vector2i(1152,700);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var sheet:=Sheet.new();sheet.font=ThemeDB.fallback_font;vp.add_child(sheet)
	for i in 6:await process_frame
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(out)
	print("CAPTURED ",out)
	quit()
