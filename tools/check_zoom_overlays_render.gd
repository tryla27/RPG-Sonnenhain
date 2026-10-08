extends SceneTree
class Board extends "res://main.gd":
	var mode:="pause"
	func _ready()->void:
		font=ThemeDB.fallback_font;reset_class_skills();texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	func _process(_delta:float)->void:pass
	func _draw()->void:
		drawing_ui=false;character_canvas_offset=Vector2.ZERO
		if mode=="pause":
			apply_ui_transform();panel="pause";draw_panel()
		else:
			camera_pos=region_rect(3).get_center()-camera_view_size()*0.5
			player_pos=camera_world_rect().get_center();character_canvas_offset=-camera_pos
			draw_set_transform(-camera_pos)
			draw_rect(camera_world_rect(),Color("adb69b"))
			if mode=="fog":draw_overworld_atmosphere()
			else:dungeon_id=0;draw_dungeon_atmosphere()
func _initialize()->void:call_deferred("run")
func render(mode:String,index:int)->Image:
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var board:=Board.new();board.mode=mode;board.camera_zoom_index=index;board.camera_zoom=float(board.CAMERA_ZOOM_LEVELS[index]);board.scale=Vector2.ONE*board.camera_zoom
	vp.add_child(board);await process_frame;await RenderingServer.frame_post_draw;await process_frame;await RenderingServer.frame_post_draw
	var im:=vp.get_texture().get_image();vp.queue_free();await process_frame
	return im
func run()->void:
	if DisplayServer.get_name()=="headless":
		print("ZOOM_OVERLAYS_RENDER_SKIPPED graphical renderer required");quit();return
	DirAccess.make_dir_recursive_absolute("res://docs/zoom-fixes")
	var base:Image=await render("pause",0)
	base.save_png("res://docs/zoom-fixes/pause-100.png")
	for i in [1,2]:
		var menu:Image=await render("pause",i)
		# Button panel follows the character preview, so it catches transform leakage.
		menu.save_png("res://docs/zoom-fixes/pause-"+str(i)+".png")
		var mismatch:=0
		for y in range(145,405):
			for x in range(525,960):
				if menu.get_pixel(x,y)!=base.get_pixel(x,y):mismatch+=1
		assert(mismatch==0,"ESC buttons must stay pixel-identical at every zoom")
		if i==2:menu.save_png("res://docs/zoom-fixes/pause-70.png")
	for mode in ["fog","dungeon"]:
		for i in 3:
			var im:Image=await render(mode,i)
			# The old 1152x648-only layer left these far-right/bottom pixels uncovered at 70%.
			for p in [Vector2i(1100,600),Vector2i(1100,100),Vector2i(600,620)]:
				assert(im.get_pixelv(p).r<0.60,"atmosphere must cover the expanded view")
			if i==2:im.save_png("res://docs/zoom-fixes/"+mode+"-70.png")
	print("ZOOM_OVERLAYS_RENDER_OK ESC buttons fixed at 100/85/70%; overworld and dungeon atmosphere covers far edges at every zoom")
	quit()
