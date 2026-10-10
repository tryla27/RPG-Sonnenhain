extends SceneTree
# Vorschau Golem v2 (Kampf): Trefferzonen, größeres Feld und weiterer Wurf,
# Altar in der 15-Minuten-Pause mit grauem Kartensymbol, zerbröselnde Brocken
# und die F3-Leistungsanzeige.
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_golem_v2_combat.gd -- <datei.png>

const Hero=preload("res://components/rpg_hero.gd")
const GolemBoss=preload("res://components/golem_boss.gd")
const GolemDesign=preload("res://components/golem_design.gd")
const PerfOverlay=preload("res://components/perf_overlay.gd")

class Sheet extends Node2D:
	var font:Font
	var crumble:Array=[]
	func label(p:Vector2,text:String,size:int=15,w:int=300)->void:
		draw_string(font,p,text,HORIZONTAL_ALIGNMENT_CENTER,w,size,Color("fff3cf"))
	func _draw()->void:
		draw_rect(Rect2(0,0,2400,1100),Color("8fae7a"))
		# 1) Trefferzonen
		var gp:=Vector2(300,470)
		var u:=GolemBoss.visual_scale(GolemBoss.TYPE_BIG)
		GolemDesign.draw_golem(self,gp,GolemBoss.TYPE_BIG,{"state":"walk"},Vector2.DOWN,0.4,0.0)
		var torso:=Rect2(gp+GolemBoss.TORSO.position*u,GolemBoss.TORSO.size*u)
		var hull:=Rect2(gp+GolemBoss.HULL.position*u,GolemBoss.HULL.size*u)
		draw_rect(hull,Color("7fd0ff"),false,2.0)
		draw_rect(Rect2(hull.position.x,torso.end.y,hull.size.x,hull.end.y-torso.end.y),Color(0.4,0.8,1.0,0.18))
		draw_rect(torso,Color(1,0.85,0.3,0.22))
		draw_rect(torso,Color("ffd36f"),false,2.0)
		draw_circle(gp+GolemBoss.HEAD_CENTER*u,GolemBoss.HEAD_RADIUS*u,Color(1,0.3,0.3,0.30))
		draw_arc(gp+GolemBoss.HEAD_CENTER*u,GolemBoss.HEAD_RADIUS*u,0,TAU,32,Color("ff6b5e"),3.0)
		label(gp+Vector2(-200,GolemBoss.HEAD_CENTER.y*u-70),"Kopf ×1,6 · „KOPF!“",15,400)
		label(gp+Vector2(80,-170),"Rumpf ×1",15,140)
		label(gp+Vector2(80,-40),"Beine ×0,75",15,160)
		label(gp+Vector2(-200,80),"Trefferzonen (Geschosse)",15,400)
		# 2) Feld alt/neu und Wurf alt/neu
		var fc:=Vector2(1000,480)
		draw_arc(fc,320,0,TAU,72,Color(1,1,1,0.55),2.0)
		var world:=GolemBoss.new()
		world.fields.append({"pos":[fc.x,fc.y],"life":8.0,"next":0.2,"mult":1.0})
		GolemDesign.draw_world_fx(self,world,1.0)
		label(fc+Vector2(-250,-420),"Steinhagel-Feld: Radius 320 → 390 (+22 %)",16,500)
		label(fc+Vector2(-250,-400),"weiß = vorher",13,500)
		var tp:=Vector2(1500,920)
		GolemDesign.draw_scrape_warning(self,tp,{"state":"scrape","aim":[1,0],"timer":0.2})
		draw_line(tp+Vector2(0,-8),tp+Vector2(576,-8),Color(1,1,1,0.9),4.0)
		draw_line(tp+Vector2(0,8),tp+Vector2(703,8),Color("e3b8ff"),4.0)
		GolemDesign.draw_boulder(self,tp+Vector2(703,0))
		label(tp+Vector2(100,-70),"Brockenwurf: 576 → 703 px Reichweite (+22 %) · weiß = vorher",15,560)
		# 3) Altar in der Pause
		var ap:=Vector2(1900,420)
		GolemDesign.draw_altar(self,ap,false,0.3)
		label(ap+Vector2(-170,46),"Der Golem erwacht wieder in 14:32",15,340)
		GolemDesign.draw_map_marker(self,ap+Vector2(-60,-140),false,0.3,true)
		GolemDesign.draw_map_marker(self,ap+Vector2(60,-140),false,0.3,false)
		label(ap+Vector2(-200,-170),"Karte: Pause (grau) · bereit",14,400)
		label(ap+Vector2(-250,110),"15 Minuten Pause nach dem Sieg (nicht im Testmodus)",14,500)
		# 4) Brocken zerbröseln
		var keeps:=[1.0,0.65,0.3]
		for k in 3:
			GolemDesign.draw_boulder(self,Vector2(260+k*160,960),keeps[k])
		GolemDesign.draw_debris(self,crumble)
		label(Vector2(200,1040),"Nach dem Kampf: Brocken zerbröseln in 3 s",15,500)
		# 5) F3-Anzeige
		var o:=PerfOverlay.new();o.visible=true;o.fps=59.8;o.avg_ms=16.7;o.worst_ms=21.0
		draw_rect(Rect2(840,1000,320,22),Color(0,0,0,0.55))
		draw_string(font,Vector2(848,1016),o.text(14),HORIZONTAL_ALIGNMENT_CENTER,304,13,Color("9be59b"))
		label(Vector2(850,990),"F3: Leistungsanzeige",14)

func _initialize()->void:call_deferred("capture")

func capture()->void:
	var out:String=OS.get_cmdline_user_args()[0]
	var vp:=SubViewport.new();vp.size=Vector2i(2400,1100);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var sheet:=Sheet.new();sheet.font=ThemeDB.fallback_font
	seed(11)
	sheet.crumble=GolemDesign.make_crumble(Vector2(580,960))
	GolemDesign.update_debris(sheet.crumble,0.25)
	vp.add_child(sheet)
	for i in 6:await process_frame
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(out)
	print("CAPTURED ",out)
	quit()
