extends SceneTree
## Messwerkzeug: Kosten von Gegner-KI und Gegnerzeichnen mit vielen Gegnern
## (Blütenwiese, standardmäßig 25 Gegner der Arten 0–5). Gibt Mikrosekunden je
## Bild aus, dazu Abschnittszeiten des Zeichnens, den mittleren Abstand der
## Gegner zum Helden und eine Prüfsumme der Endpositionen (TRACE), mit der sich
## Umbauten auf gleiches Verhalten prüfen lassen (feste Saat).
## Aufruf: godot --path . -s tools/profile_enemies.gd [-- <anzahl> [<arten,…>]]
## Ohne Fenster nicht aussagekräftig fürs Zeichnen: mit xvfb-run starten.
class Game extends "res://main.gd":
	var t_enemy:=0;var t_level:=0;var n_enemy:=0
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func _process(_delta:float)->void:pass
	var sec:={}
	func timed(k:String,s:int)->void:sec[k]=int(sec.get(k,0))+Time.get_ticks_usec()-s
	func draw_world()->void:
		var s:=Time.get_ticks_usec();super();timed("draw_world",s)
	func draw_sorted_world_objects()->void:
		var s:=Time.get_ticks_usec();super();timed("draw_sorted_world_objects",s)
	func draw_hud()->void:
		var s:=Time.get_ticks_usec();super();timed("draw_hud",s)
	func draw_day_night_overlay()->void:
		var s:=Time.get_ticks_usec();super();timed("draw_day_night_overlay",s)
	func draw_golem_world_fx()->void:
		var s:=Time.get_ticks_usec();super();timed("draw_golem_world_fx",s)
	func draw_chat_overlay()->void:
		var s:=Time.get_ticks_usec();super();timed("draw_chat_overlay",s)
	func draw_party_widget()->void:
		var s:=Time.get_ticks_usec();super();timed("draw_party_widget",s)
	func draw_enemy(enemy:Dictionary)->void:
		var s:=Time.get_ticks_usec();super(enemy);t_enemy+=Time.get_ticks_usec()-s;n_enemy+=1
	func draw_enemy_level(p:Vector2,type:int,boss:bool,elite_kind:int=0)->void:
		var s:=Time.get_ticks_usec();super(p,type,boss,elite_kind);t_level+=Time.get_ticks_usec()-s
func _initialize()->void:call_deferred("run")
func run()->void:
	var args:=OS.get_cmdline_user_args()
	var count:=int(args[0]) if not args.is_empty() else 25
	var types:Array=[0,1,2,3,4,5]
	if args.size()>1:types=Array(args[1].split(",")).map(func(v):return int(v))
	var vp:=SubViewport.new();vp.size=Vector2i(1152,648);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
	var g:=Game.new();vp.add_child(g)
	for frame in 8:await process_frame
	g.panel="";g.character_created=true;g.hero_name="Mess";g.level=12;g.hp=100000
	g.player_pos=Vector2(3650,2650);g.camera_pos=g.player_pos-g.VIEW*.5;g.camera_smooth=g.camera_pos
	g.world_fog.bytes.fill(255);g.world_fog.mark_changed()
	seed(7);g.enemies.clear()
	for i in count:
		var e:Dictionary=g.make_enemy(types[i%types.size()],g.player_pos+Vector2(randf_range(-420,420),randf_range(-260,260)))
		g.enemies.append(e)
	g.spawn_timer=-1000.0;g.rescue_state=3
	var ai:=[];var draw:=[];var total:=[]
	for frame in 180:
		g.t_enemy=0;g.t_level=0;g.n_enemy=0;if frame==30:g.sec={}
		var s:=Time.get_ticks_usec()
		g.update_enemies(1.0/60.0)
		var a:=Time.get_ticks_usec()-s
		g.hp=100000;g.world_time+=1.0/60.0
		g.world_obstacles_3d.update(g,1.0/60.0);g.update_static_cache()
		g.queue_redraw()
		await process_frame
		if frame>=30:ai.append(a);draw.append(g.t_enemy);total.append(g.performance_draw_us)
		if frame==179:print("level_us=",g.t_level," enemies_drawn=",g.n_enemy)
	var trace:=""
	for e in g.enemies:trace+="%.3f,%.3f,%s;"%[e["pos"].x,e["pos"].y,str(e.get("attack_state",{}).get("id",-1))]
	var dist:=0.0
	for e in g.enemies:dist+=Vector2(e["pos"]).distance_to(g.player_pos)
	print("MEAN_DIST ",dist/maxf(1,g.enemies.size()))
	print("TRACE ",trace.md5_text()," hp=",g.hp)
	ai.sort();draw.sort();total.sort()
	print("PROFILE mobs=%d ai_p50=%d ai_p95=%d enemydraw_p50=%d enemydraw_p95=%d draw_total_p50=%d"%[g.enemies.size(),ai[ai.size()/2],ai[int(ai.size()*.95)],draw[draw.size()/2],draw[int(draw.size()*.95)],total[total.size()/2]])
	for k in g.sec:print("  ",k," avg_us=",int(g.sec[k])/150)
	quit()
