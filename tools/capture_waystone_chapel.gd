extends SceneTree
class Board extends "res://main.gd":
	var chapel:=false
	func _ready()->void:
		font=ThemeDB.fallback_font
		world_fog.configure(WORLD);world_fog.bytes.fill(255)
		for event in WORLD_EVENTS:event_states.append(0)
		for quest in QUESTS:quests.append({"state":0,"progress":0})
		for quest in BORIN_QUESTS:borin_quests.append({"state":0,"progress":0})
		waystone_unlocked.resize(WAYSTONES.size());waystone_unlocked.fill(true)
		bosses_defeated=[true,false,false];travel_map=true
		player_pos=WAYSTONES[0]+Vector2(100,0)
	func _process(_delta:float)->void:pass
	func _draw()->void:
		draw_rect(Rect2(0,0,1280,800),Color("141e23"))
		if chapel:
			VillageInteriors32.paint(self,Vector2(640,400),7,font,false,"E")
		else:
			ui_box(Rect2(140,80,880,550),Color("102431"))
			draw_map_panel()
func _initialize()->void:call_deferred("capture")
func capture()->void:
	DirAccess.make_dir_recursive_absolute("res://docs/review-20261009")
	for chapel in [false,true]:
		var viewport:=SubViewport.new();viewport.size=Vector2i(1280,800);viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var board:=Board.new();board.chapel=chapel;viewport.add_child(board)
		await process_frame;await RenderingServer.frame_post_draw
		var path:="res://docs/review-20261009/chapel.png" if chapel else "res://docs/review-20261009/waystone-map.png"
		assert(viewport.get_texture().get_image().save_png(path)==OK)
		viewport.queue_free();await process_frame
	print("WAYSTONE_CHAPEL_RENDER_OK actual map and interior renderers")
	quit()
