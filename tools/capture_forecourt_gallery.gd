extends SceneTree
const Props=preload("res://components/village_forecourts.gd")
const OWNERS:={"style":"Atelier","smith":"Schmiede","healer":"Kirche","borin":"Borin","elder":"Rathaus","innkeeper":"Taverne","arena":"Arena"}
const LABELS:={"mannequin":"Kleiderpuppe","cloth":"Stofftisch","anvil":"Amboss","logs":"Holzlager","herbs":"Kräuterkasten","offering":"Opferstein","books":"Bücherpult","scrolls":"Schriftrollen","notices":"Aushang","bench":"Sitzbank","barrels":"Fässer","dummy":"Trainingspuppe","weapons":"Waffenständer"}
class Gallery extends Node2D:
	func _draw()->void:
		var font:=ThemeDB.fallback_font
		draw_rect(Rect2(0,0,960,736),Color("182a2c"))
		for i in Props.ITEMS.size():
			var item:Dictionary=Props.ITEMS[i]
			var origin:=Vector2((i%4)*240,floori(i/4.0)*184)
			draw_rect(Rect2(origin+Vector2(8,8),Vector2(224,168)),Color("314638"))
			Props.paint(self,origin+Vector2(120,140),item["item"])
			draw_string(font,origin+Vector2(18,166),OWNERS[item["owner"]]+" / "+LABELS[item["item"]],HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e7d3a4"))
func _initialize()->void:call_deferred("capture")
func capture()->void:
	var viewport:=SubViewport.new()
	viewport.size=Vector2i(960,736)
	viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var gallery:=Gallery.new()
	gallery.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	viewport.add_child(gallery)
	await process_frame
	await RenderingServer.frame_post_draw
	await process_frame
	await RenderingServer.frame_post_draw
	assert(viewport.get_texture().get_image().save_png("res://docs/hausgegenstaende-v2.png")==OK)
	print("FORECOURT_GALLERY_OK")
	quit()
