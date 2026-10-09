extends SceneTree
const Neck=preload("res://components/arcane_necklaces.gd")
class Preview extends "res://main.gd":
	func _ready()->void:
		font=ThemeDB.fallback_font;texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;panel="inventory"
		class_id=1;hero_race=0;hero_gender=1;level=40;gold=500;reset_class_skills()
		for i in 6:inventory.append(make_item(Neck.NAMES[i],"necklace",3 if i>=3 else 1,0,100))
		equipped_necklace_uid=int(inventory[4]["uid"]);selected_item=4
	func _process(_delta:float)->void:pass
	func _draw()->void:
		draw_rect(Rect2(0,0,1152,648),Color("102531"))
		draw_inventory_panel()

func _initialize()->void:call_deferred("run")
func run()->void:
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	vp.add_child(Preview.new());await process_frame;await RenderingServer.frame_post_draw;await process_frame;await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://docs/arcane-necklaces")
	assert(vp.get_texture().get_image().save_png("res://docs/arcane-necklaces/inventory-preview.png")==OK)
	print("ARCANE_NECKLACES_PREVIEW_OK actual inventory, necklace slot, effect description and character pendant")
	quit()
