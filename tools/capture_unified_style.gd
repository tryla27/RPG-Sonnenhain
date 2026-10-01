extends SceneTree
class Board extends "res://main.gd":
	const Hero=preload("res://components/rpg_hero.gd")
	func _ready()->void:
		font=ThemeDB.fallback_font
		weapon_sprites=null
	func _process(_delta:float)->void:pass
	func _draw()->void:
		draw_rect(Rect2(0,0,1200,1050),Color("101e2d"))
		draw_string(font,Vector2(25,38),"GEMEINSAMER GODOT-STIL · FIGUREN, RUeSTUNGEN, WAFFEN, ITEMS",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color("d9b964"))
		for race in 3:
			for role in 3:
				var p=Vector2(95+role*130,160+race*135)
				Hero.paint(self,p,role,race,0,Vector2.DOWN,0,1,Vector2.ZERO)
				draw_string(font,p+Vector2(-50,45),["Mensch","Ork","Roboter"][race]+" "+["Krieger","Magier","Bogen"][role],HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("eee4cd"))
		draw_string(font,Vector2(470,80),"ALLE SECHS RUeSTUNGEN",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("d9b964"))
		for armor in 6:
			var p=Vector2(540+(armor%3)*190,180+(armor/3)*180)
			Hero.paint(self,p,0,0,0,Vector2.DOWN,0,1,Vector2.ZERO,-1,Vector2.RIGHT,armor)
			draw_string(font,p+Vector2(-55,45),["Reisendenleder","Wachtpanzer","Arkanrobe","Waldlaeufer","Sonnenruestung","Kristallharnisch"][armor],HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("eee4cd"))
		draw_string(font,Vector2(25,545),"WAFFEN UND ITEMS · NATIV GERENDERT",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("d9b964"))
		var kinds=["sword","staff","bow","armor","ring","potion","gem","herb","essence"]
		for kind in kinds.size():
			for design in 4:
				draw_item_icon(Vector2(35+kind*127,585+design*55),kinds[kind],Color("85cdd8"),1.0,design,design)
			draw_string(font,Vector2(35+kind*127,820),kinds[kind],HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("eee4cd"))
		draw_string(font,Vector2(25,868),"ALLE 31 ESSBAREN ITEMS",HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("d9b964"))
		for food in 31:
			FoodSystem.icon(self,Vector2(35+(food%16)*72,900+(food/16)*62),food,1.0)
func _initialize()->void:call_deferred("capture")
func capture()->void:
	var vp=SubViewport.new()
	vp.size=Vector2i(1200,1050)
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	vp.add_child(Board.new())
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	quit(vp.get_texture().get_image().save_png("D:/SonnenhainRPG-Audio/gemeinsamer-godot-stil.png"))
