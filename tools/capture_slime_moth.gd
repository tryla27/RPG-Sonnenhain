extends SceneTree
# Bewegte Vorschau: Waldschleim (Hüpfen, Stehen) und Himmelsfalter (Schweben,
# Fliegen, Angriff, Niederlage, Sternenstaub-Schuss). Speichert Einzelbilder
# <ordner>/frame_000.png …; tools/make_gif.py baut daraus eine GIF.
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_slime_moth.gd -- <ordner> [bilder]
const Mob=preload("res://components/monster_design_32.gd")
const Moth=preload("res://components/himmelsfalter_art.gd")
const Slime=preload("res://components/woodland_mob_art.gd")
const Pose=preload("res://components/woodland_pose_animation.gd")

class Board extends Node2D:
	var t:=0.0
	var font:Font
	func label(p:Vector2,s:String)->void:
		draw_string(font,p,s,HORIZONTAL_ALIGNMENT_CENTER,180,14,Color("fff3cf"))
	func _draw()->void:
		draw_rect(Rect2(0,0,1100,560),Color("7f9f6c"))
		draw_rect(Rect2(0,280,1100,280),Color("b9b0cf"))
		# Waldschleim: hüpfend in vier Richtungen, stehend.
		var looks:=[Vector2.DOWN,Vector2.RIGHT,Vector2.UP,Vector2(-1,1).normalized()]
		for i in 4:
			var foot:=Vector2(110+i*190,220)
			var phase:=fposmod(t*TAU*1.6+i*0.4,TAU)
			Mob.paint(self,foot,0,1,looks[i],Color("73cb88"),phase,-1.0,1.0,Vector2.ONE,"",{"walking":true,"clock":t,"seed":float(i)})
			label(foot+Vector2(-90,46),["Hüpfen vorn","Hüpfen seitlich","Hüpfen hinten","Hüpfen schräg"][i])
		var idle:=Vector2(900,220)
		Mob.paint(self,idle,0,1,Vector2.DOWN,Color("73cb88"),0.0,-1.0,1.0,Vector2.ONE,"",{"walking":false,"clock":t,"seed":2.0})
		label(idle+Vector2(-90,46),"Stehen: Atmen, Blatt")
		# Himmelsfalter.
		var states:=[{"look":Vector2.DOWN,"walking":false,"attack":-1.0,"death":-1.0,"name":"Schweben"},
			{"look":Vector2.RIGHT,"walking":true,"attack":-1.0,"death":-1.0,"name":"Fliegen"},
			{"look":Vector2.DOWN,"walking":false,"attack":fposmod(t*0.8,1.0),"death":-1.0,"name":"Sternenstaub"},
			{"look":Vector2.UP,"walking":false,"attack":-1.0,"death":-1.0,"name":"von hinten"},
			{"look":Vector2.DOWN,"walking":false,"attack":-1.0,"death":fposmod(t*0.5,1.0),"name":"Niederlage"}]
		for i in states.size():
			var st:Dictionary=states[i]
			var foot:=Vector2(110+i*210,520)
			Mob.paint(self,foot,25,40,st["look"],Color("d9c6e8"),1.0 if st["walking"] else 0.0,float(st["attack"]),1.0,Vector2.ONE,"",{"walking":st["walking"],"clock":t,"seed":float(i)*0.7,"death":st["death"]})
			label(foot+Vector2(-90,30),str(st["name"]))
		var shot:=Vector2(560+fposmod(t*220.0,200.0),400)
		Moth.draw_shot(self,shot,Vector2.RIGHT,t)

func _initialize()->void:call_deferred("capture")

func capture()->void:
	var args:=OS.get_cmdline_user_args()
	var out:String=args[0]
	var count:=int(args[1]) if args.size()>1 else 30
	DirAccess.make_dir_recursive_absolute(out)
	var vp:=SubViewport.new();vp.size=Vector2i(1100,560);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var b:=Board.new();b.font=ThemeDB.fallback_font;vp.add_child(b)
	for i in count:
		b.t=i/30.0
		b.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		vp.get_texture().get_image().save_png(out.path_join("frame_%03d.png" % i))
	print("CAPTURED ",count," ",out)
	quit()
