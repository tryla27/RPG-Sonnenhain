extends SceneTree
## Sichtbeleg der tatsächlichen Zeichenmodule, ohne Konto und Speicherzugriff.
class Preview extends Node2D:
	const Decor=preload("res://components/homecoming_decor.gd")
	const Telegraph=preload("res://components/attack_telegraph.gd")
	const Effects=preload("res://components/quality_effect_frames.gd")
	func _draw()->void:
		var font:=ThemeDB.fallback_font
		draw_rect(Rect2(0,0,1152,648),Color("102332"))
		draw_string(font,Vector2(30,44),"Sonnenhain · Grafikbausteine im Spiel",HORIZONTAL_ALIGNMENT_LEFT,-1,26,Color("ead9a9"))
		draw_string(font,Vector2(30,86),"Heimkehr: persönlicher Schmuck aus vorhandenem Storyfortschritt",HORIZONTAL_ALIGNMENT_LEFT,-1,18)
		for stage in 4:
			var p:=Vector2(140+stage*280,160)
			draw_circle(p,45,Color("355b64"))
			draw_set_transform(p,0,Vector2(.6,.6))
			Decor.paint(self,Vector2.ZERO,[3 if stage==1 else 0],3 if stage==2 else 0,stage==3)
			draw_set_transform(Vector2.ZERO)
			draw_string(font,p+Vector2(-65,133),["Beginn","Tessa geholfen","Dorf gerettet","Finale beendet"][stage],HORIZONTAL_ALIGNMENT_LEFT,-1,17)
		draw_string(font,Vector2(30,350),"Angriffsvorbereitung · gleiche Reichweite und Trefferregeln",HORIZONTAL_ALIGNMENT_LEFT,-1,18)
		for i in 3:
			var p:=Vector2(90+i*360,440)
			Telegraph.paint(self,p,Vector2.RIGHT,{"shape":["arc","line","cloud"][i],"range":80.0,"half_angle":.7},Color("e49b6c"),.65)
			draw_circle(p,7,Color("edd4a2"))
		draw_string(font,Vector2(30,560),"Effekte · acht Bilder pro Atlas · keine zusätzlichen Partikel",HORIZONTAL_ALIGNMENT_LEFT,-1,18)
		for i in 8:
			Effects.paint(self,Vector2(70+i*140,610),float(i)/8*.42,"feuer")
func _initialize()->void:call_deferred("run")
func run()->void:
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648)
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	vp.add_child(Preview.new())
	await process_frame
	RenderingServer.force_draw(false)
	vp.get_texture().get_image().save_png("res://docs/design/quality-v1/gameplay.png")
	print("QUALITY_GAMEPLAY_CAPTURE_OK");quit()
