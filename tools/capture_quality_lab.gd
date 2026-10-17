extends SceneTree
const Lab=preload("res://components/quality_art_lab.gd")
func _initialize()->void:call_deferred("run")
func run()->void:
	var args:=OS.get_cmdline_user_args();var out:=args[0] if not args.is_empty() else "res://docs/design/quality-v1"
	DirAccess.make_dir_recursive_absolute(out)
	var vp:=SubViewport.new();vp.size=Vector2i(1280,760);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var lab:=Lab.new();vp.add_child(lab)
	for asset_name in ["wall_horizontal","gate_closed","building_smithy","sword_tier3","warrior_gold"]:
		for index in lab.manifest.size():
			if lab.manifest[index]["id"]==asset_name:
				lab.asset_picker.select(index);lab.select_model(index);break
		for i in 12:await process_frame
		await RenderingServer.frame_post_draw
		vp.get_texture().get_image().save_png(out.path_join(asset_name+".png"))
		print("QUALITY_CAPTURE ",asset_name)
	lab.test_ragdoll()
	for i in 90:await process_frame
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(out.path_join("warrior_ragdoll.png"))
	lab.count_picker.select(1);lab.select_model(lab.asset_picker.selected)
	for i in 30:await process_frame
	var samples:Array=[];var previous:=Time.get_ticks_usec()
	for i in 120:
		await process_frame
		var now:=Time.get_ticks_usec();samples.append(float(now-previous)/1000.0);previous=now
	samples.sort();await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(out.path_join("warriors_20.png"))
	var report:={"scope":"Isoliertes natives Grafiklabor, 20 animierte Krieger; kein Browser-/Koopnachweis","p50_ms":samples[59],"p95_ms":samples[113],"p99_ms":samples[118],"frames":120}
	var file:=FileAccess.open(out.path_join("warriors_20.json"),FileAccess.WRITE);file.store_string(JSON.stringify(report,"\t"));file.close()
	print("QUALITY_20_MODELS ",JSON.stringify(report))
	lab.free();vp.free();quit()
