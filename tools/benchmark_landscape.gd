extends SceneTree
## Reproduzierbare lokale Landschaftsroute, ohne Konto oder Live-Spielstände.
class Game extends "res://main.gd":
	var section_us:Dictionary={}
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func _process(_delta:float)->void:pass
	func draw_world()->void:
		var begin:=Time.get_ticks_usec();super.draw_world();section_us["ground"]=Time.get_ticks_usec()-begin
	func draw_sorted_world_objects()->void:
		var begin:=Time.get_ticks_usec();super.draw_sorted_world_objects();section_us["objects"]=Time.get_ticks_usec()-begin
	func draw_hud()->void:
		var begin:=Time.get_ticks_usec();super.draw_hud();section_us["hud"]=Time.get_ticks_usec()-begin
	func draw_overworld_atmosphere()->void:
		var begin:=Time.get_ticks_usec();super.draw_overworld_atmosphere();section_us["atmosphere"]=Time.get_ticks_usec()-begin

func _initialize()->void:call_deferred("run")

func percentile(values:Array,part:float)->float:
	var ordered:=values.duplicate();ordered.sort()
	return float(ordered[mini(ordered.size()-1,ceili(ordered.size()*part)-1)])

func run()->void:
	var args:=OS.get_cmdline_user_args()
	var out:=args[0] if not args.is_empty() else "res://build/landscape-benchmark"
	DirAccess.make_dir_recursive_absolute(out)
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648)
	vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var g:=Game.new();vp.add_child(g)
	for frame in 8:await process_frame
	g.set_process(false);g.panel="";g.character_created=true;g.hero_name="Prüfung"
	g.level=40;g.enemies.clear();g.world_fog.bytes.fill(255);g.world_fog.mark_changed()
	var results:Array=[]
	for test in [["wiese",Vector2(3650,2650)],["mauertor",Vector2(5000,1250)],["pilzwald",Vector2(3150,4780)]]:
		g.world_obstacles_3d.signature=""
		var times:Array=[];var update_times:Array=[];var draw_times:Array=[];var long_frames:=0
		var previous:=Time.get_ticks_usec()
		for frame in 240:
			# Erst stehen, dann dieselbe Strecke hin und zurück laufen.
			var offset:=0.0 if frame<60 else float(frame-60 if frame<150 else 240-frame)*5.0
			g.player_pos=test[1]+Vector2(offset,0)
			g.camera_pos=g.player_pos-g.VIEW*.5;g.camera_smooth=g.camera_pos
			var started:=Time.get_ticks_usec()
			g.world_obstacles_3d.update(g,1.0/60.0)
			g.update_static_cache()
			var update_ms:=float(Time.get_ticks_usec()-started)/1000.0
			g.queue_redraw();await process_frame
			var now:=Time.get_ticks_usec()
			if frame>=30:
				var ms:=float(now-previous)/1000.0;times.append(ms);update_times.append(update_ms)
				draw_times.append(float(g.performance_draw_us)/1000.0)
				if ms>50:long_frames+=1
			previous=now
		# Auch bei minimiertem Prüf-Fenster den Sichtbeleg abschließen.
		# Außerhalb der gewerteten Bildzeiten, danach erneut 30 Bilder Aufwärmen.
		RenderingServer.force_draw(false)
		vp.get_texture().get_image().save_png(out.path_join(str(test[0])+".png"))
		var entry:Dictionary={"scene":test[0],"frames":times.size(),"p50_ms":percentile(times,.5),"p95_ms":percentile(times,.95),"p99_ms":percentile(times,.99),"over_50_ms":long_frames,"collection_p95_ms":percentile(update_times,.95),"draw_cpu_p95_ms":percentile(draw_times,.95),"visible_objects":g.world_obstacles_3d.rows.size()}
		entry["last_draw_sections_us"]=g.section_us.duplicate()
		if g.world_obstacles_3d.has_method("metrics_snapshot"):entry["renderer"]=g.world_obstacles_3d.metrics_snapshot()
		results.append(entry);print("LANDSCAPE_BENCH ",JSON.stringify(entry))
	var report:Dictionary={"version":Engine.get_version_info()["string"],"adapter":RenderingServer.get_video_adapter_name(),"viewport":[1152,648],"zoom":1.0,"route":"60 stand + 90 hin + 90 zurück, 5 Welteinheiten/Bild; erste 30 Bilder nicht gewertet","scope":"Native lokale Darstellung ohne Netzwerk und KI; kein Live-Lag-Nachweis","results":results}
	var file:=FileAccess.open(out.path_join("report.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"));file.close();g.free();vp.free();quit()
