extends SceneTree
# Vorschau: goldener Ritter (menschlicher Krieger) in 8 Richtungen und allen
# Zuständen, gezeichnet über Hero.paint mit Welt-Verschiebung wie im Spiel
# (prüft auch, dass nichts doppelt verschoben wird). Daneben ein Magier als
# Größenvergleich.
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_golden_knight.gd -- <datei.png>

const Hero=preload("res://components/rpg_hero.gd")
const OFF:=Vector2(37,-23)

class Board extends Node2D:
	var font:Font
	func hero(screen:Vector2,role:int,look:Vector2,phase:float,running:bool=false,roll:float=-1.0,death:float=-1.0,hurt:float=0.0,jump:float=-1.0,attack:float=-1.0)->void:
		draw_set_transform(OFF)
		Hero.knight_attack=attack
		Hero.paint(self,screen-OFF,role,0,0,look,phase,1.6,OFF,roll,Vector2.RIGHT,-1,death,hurt,-1,0,running,jump)
		Hero.knight_attack=-1.0
		draw_set_transform(Vector2.ZERO)
	func _draw()->void:
		draw_rect(Rect2(0,0,1500,980),Color("7f9f6c"))
		var looks:=[Vector2.DOWN,Vector2(-1,1).normalized(),Vector2.LEFT,Vector2(-1,-1).normalized(),Vector2.UP,Vector2(1,-1).normalized(),Vector2.RIGHT,Vector2(1,1).normalized()]
		var names:=["S","SW","W","NW","N","NO","O","SO"]
		var rows:=[["Stehen",0.0,false,-1.0,-1.0,0.0,-1.0,-1.0],["Gehen",1.3,false,-1.0,-1.0,0.0,-1.0,-1.0],["Laufen",2.4,true,-1.0,-1.0,0.0,-1.0,-1.0],["Angriff",0.0,false,-1.0,-1.0,0.0,-1.0,0.6],["Sprung",0.0,false,-1.0,-1.0,0.0,0.45,-1.0],["Rolle",0.0,false,0.3,-1.0,0.0,-1.0,-1.0],["Treffer",0.0,false,-1.0,-1.0,0.8,-1.0,-1.0],["Sturz",0.0,false,-1.0,0.8,0.0,-1.0,-1.0]]
		for c in 8:
			draw_string(font,Vector2(200+c*150,30),names[c],HORIZONTAL_ALIGNMENT_CENTER,60,18,Color("fff3cf"))
		for r in rows.size():
			var row:Array=rows[r]
			var y:=150+r*112
			draw_string(font,Vector2(14,y-30),str(row[0]),HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("fff3cf"))
			for c in 8:
				var foot:=Vector2(230+c*150,y)
				draw_line(foot+Vector2(-30,0),foot+Vector2(30,0),Color(0,0,0,0.25),2.0)
				hero(foot,0,looks[c],float(row[1]),bool(row[2]),float(row[3]),float(row[4]),float(row[5]),float(row[6]),float(row[7]))
		hero(Vector2(1440,150),1,Vector2.DOWN,0.0)
		draw_string(font,Vector2(1400,175),"Magier",HORIZONTAL_ALIGNMENT_CENTER,80,14,Color("fff3cf"))

func _initialize()->void:call_deferred("capture")

func capture()->void:
	var out:String=OS.get_cmdline_user_args()[0]
	var vp:=SubViewport.new();vp.size=Vector2i(1500,980);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var b:=Board.new();b.font=ThemeDB.fallback_font;vp.add_child(b)
	for i in 4:await process_frame
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(out)
	print("CAPTURED ",out)
	quit()
