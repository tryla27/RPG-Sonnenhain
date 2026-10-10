extends SceneTree
# Vorschau: Dunkler Golem (gehen, Schild, Schaben, Schrei), halber Golem, Altar,
# Steinhagel-Feld, Brockenwurf, liegende Brocken und Zerfall – neben einem Spieler.
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_dark_golem.gd -- <datei.png>

const Hero=preload("res://components/rpg_hero.gd")
const GolemBoss=preload("res://components/golem_boss.gd")
const GolemDesign=preload("res://components/golem_design.gd")

class Sheet extends Node2D:
	var font:Font
	var world:=GolemBoss.new()
	var debris:Array=[]
	func label(p:Vector2,text:String)->void:
		draw_string(font,p,text,HORIZONTAL_ALIGNMENT_CENTER,260,15,Color("fff3cf"))
	func _draw()->void:
		draw_rect(Rect2(0,0,2400,1050),Color("8fae7a"))
		draw_rect(Rect2(0,540,2400,510),Color("7f9f6c"))
		# Reihe 1: Golem neben Spieler in vier Zuständen.
		var states:=[{"state":"walk"},{"state":"shield"},{"state":"scrape","aim":[1,0],"timer":0.4},{"state":"stomp","timer":0.25,"stomp_at":[0,0]},{"state":"scream_pause"}]
		var names:=["Gehen (5× Spieler)","Schild: −99 % · 8 s","Schaben vor dem Wurf","Stampfer: Ring = Warnung","Schrei unter 40 %"]
		for i in 5:
			var p:=Vector2(260+i*470,460)
			if i==2:GolemDesign.draw_scrape_warning(self,p,states[i])
			if i==3:
				states[i]["stomp_at"]=[p.x,p.y+60]
				GolemDesign.draw_stomp_warning(self,states[i],GolemBoss.TYPE_BIG)
			GolemDesign.draw_golem(self,p,GolemBoss.TYPE_BIG,states[i],Vector2.DOWN if i!=2 else Vector2.RIGHT,0.6+i*0.4,0.0)
			Hero.paint(self,p+Vector2(140,-10),0,0,0,Vector2.LEFT,0.0,1.0,Vector2.ZERO,-1.0,Vector2.LEFT,0)
			label(p+Vector2(-130,40),names[i])
		# Reihe 2: Feld mit Hagel, Brocken im Flug, liegende Brocken, Altar, Hälften, Zerfall.
		GolemDesign.draw_world_fx(self,world,1.2)
		label(Vector2(170,1030),"Steinhagel-Feld 20 m · Brockenwurf 15 m")
		GolemDesign.draw_altar(self,Vector2(980,900),false,0.3)
		label(Vector2(850,960),"Altar: E drücken (Opfergaben später)")
		for side in [-1,1]:
			GolemDesign.draw_golem(self,Vector2(1380+side*100,930),GolemBoss.TYPE_HALF,{"state":"walk"},Vector2.DOWN,side*0.7,0.0)
		label(Vector2(1250,1030),"Zerfall: zwei Dunkle kleine Golems")
		GolemDesign.draw_debris(self,debris)
		label(Vector2(1660,620),"Zerfall in Einzelteile")

func _initialize()->void:call_deferred("capture")

func capture()->void:
	var out:String=OS.get_cmdline_user_args()[0]
	var vp:=SubViewport.new();vp.size=Vector2i(2400,1050);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var sheet:=Sheet.new();sheet.font=ThemeDB.fallback_font
	seed(7)
	sheet.world.fields.append({"pos":[340,800],"life":8.0,"next":0.2,"mult":1.0})
	for k in 7:
		var a:=k*0.9
		sheet.world.hail.append({"pos":[340+cos(a)*190*(0.3+0.1*k),800+sin(a)*190*(0.3+0.1*k)],"delay":0.15*k,"damage":45})
	sheet.world.throws.append({"from":[560,760],"dir":[1,0],"t":0.35,"hits":[],"mult":1.0})
	sheet.world.boulders.append([690,940]);sheet.world.boulders.append([760,880])
	sheet.debris=GolemDesign.make_debris(Vector2(1800,860),GolemBoss.TYPE_BIG)
	GolemDesign.update_debris(sheet.debris,0.35)
	vp.add_child(sheet)
	for i in 6:await process_frame
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(out)
	print("CAPTURED ",out)
	quit()
