extends SceneTree
# Vorschau: Kauf- und Verkaufsfenster mit Mengenauswahl und Gesamtwert.
# Aufruf: xvfb-run -a godot --path . --rendering-driver opengl3 --script tools/capture_shop_trade.gd -- <ordner>

class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass

func _initialize()->void:call_deferred("capture")

func shot(vp:SubViewport,path:String)->void:
	for i in 8:await process_frame
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(path)
	print("CAPTURED ",path)

func capture()->void:
	var out:String=OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(out)
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var g:=Game.new();vp.add_child(g)
	for i in 40:await process_frame
	g.character_created=true;g.hero_name="Angelo";g.level=20;g.gold=640
	g.merchant_kind="alchemy";g.shop_page=0;g.panel="shop"
	g.add_item(g.make_item("Heiltrank","potion",1,0,18))
	for k in 6:g.add_item(g.make_item("Heiltrank","potion",1,0,18))
	g.pending_purchase=0;g.pending_purchase_item=g.shop_stock["alchemy"][0].duplicate(true);g.trade_quantity=3
	await shot(vp,out.path_join("1-kaufen-menge.png"))
	g.pending_purchase=-1;g.pending_sale=0;g.trade_quantity=4
	await shot(vp,out.path_join("2-verkaufen-menge.png"))
	g.pending_sale=-1;g.selected_item=0;g.sell_all_confirm=true
	await shot(vp,out.path_join("3-alles-verkaufen.png"))
	quit()
