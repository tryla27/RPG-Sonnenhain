extends SceneTree
# Vorschau: Torbogen oben rechts in den Aschebergen (zur Nebelheide) und seine
# Ankunft in der Nebelheide, im echten Spielbild.
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_portal_ascheberge.gd -- <datei.png>
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass

func _initialize()->void:call_deferred("capture")

func shot(g,vp:SubViewport,pos:Vector2)->Image:
	g.player_pos=pos;g.enemies.clear()
	for i in 25:await process_frame
	await RenderingServer.frame_post_draw
	return vp.get_texture().get_image()

func capture()->void:
	var out:String=OS.get_cmdline_user_args()[0]
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	var g:=Game.new();vp.add_child(g)
	for i in 8:await process_frame
	g.character_created=true;g.level=30;g.panel="";g.hp=g.max_hp()
	var portal:Array=g.PORTALS[g.PORTALS.size()-1]
	var a:Image=await shot(g,vp,Vector2(portal[0])+Vector2(0,90))
	var b:Image=await shot(g,vp,Vector2(portal[1])+Vector2(0,110))
	var sheet:=Image.create(1152,1296,false,Image.FORMAT_RGBA8)
	sheet.blit_rect(a,Rect2i(0,0,1152,648),Vector2i(0,0))
	sheet.blit_rect(b,Rect2i(0,0,1152,648),Vector2i(0,648))
	sheet.save_png(out)
	print("CAPTURED ",out)
	quit()
