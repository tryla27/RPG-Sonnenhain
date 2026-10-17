extends SceneTree
## Belastungsmessung Dunkler Golem auf dem Server: ein dedizierter Server und
## vier Spieler über echte WebSocket-Verbindungen kämpfen bis zum Sieg (oder
## Zeitlimit). Gemessen wird die Serverzeit je Schritt (Gegner, Golem, Welt)
## und je Weltpaket, dazu Paketgrößen und die Zahl der Gegner/Brocken.
## Kein Konto, keine Live-Spielstände (Speicherort user://golem_bench).
## Aufruf: godot --headless --path . -s tools/benchmark_golem_server.gd [-- <ausgabe.json>]

const GolemBoss=preload("res://components/golem_boss.gd")
const MasterArmor=preload("res://components/master_armor.gd")

class TestGame:
	extends "res://main.gd"
	var hits_taken:=0
	var pushed:=false
	func _ready() -> void: pass
	func _process(_delta: float) -> void: pass
	func _draw() -> void: pass
	func save_game() -> void: pass
	func apply_player_damage(raw:int) -> void:
		hits_taken+=1
		super.apply_player_damage(raw)
		hp=max_hp()
	func rpc_golem_push(x: float, y: float) -> void:
		pushed=true
		super.rpc_golem_push(x,y)

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("GOLEM_BENCH_FAIL "+label)

func _initialize() -> void:
	call_deferred("run")

func session(label: String, peer: MultiplayerPeer):
	var branch := Node.new()
	branch.name = label
	root.add_child(branch)
	var api := SceneMultiplayer.new()
	api.root_path = branch.get_path()
	set_multiplayer(api,branch.get_path())
	api.multiplayer_peer = peer
	var game = TestGame.new()
	game.name = "Sonnenhain"
	game.konflux_preview_mode = true
	branch.add_child(game)
	game.set_process(false)
	game.set_process_input(false)
	return game


func food(g,name:String,count:int)->Dictionary:
	var item:Dictionary=g.make_item(name,"food",0,0,10,"",1)
	item["count"]=count
	return item

func percentile(values:Array,part:float)->float:
	if values.is_empty():return 0.0
	var ordered:=values.duplicate();ordered.sort()
	return float(ordered[mini(ordered.size()-1,ceili(ordered.size()*part)-1)])

func stats(values:Array)->Dictionary:
	return {"count":values.size(),"p50":percentile(values,.5),"p95":percentile(values,.95),"p99":percentile(values,.99),"max":percentile(values,1.0)}

func golem_on(g)->Array:
	var out:Array=[]
	for e in g.enemies:
		if GolemBoss.is_golem(e):out.append(e)
	return out

func armor_count(g)->int:
	var n:=0
	for item in g.inventory:
		if MasterArmor.index(item)==MasterArmor.GOLEM:n+=1
	return n

var update_ms:Array=[]
var snapshot_ms:Array=[]
var mobs:Array=[]
var boulders:Array=[]
var shots:Array=[]
var drops:Array=[]

func tick(server,players:Array,frame:int,dt:float)->void:
	for p in players:
		p.invulnerable=maxf(0.0,p.invulnerable-dt)
		p.update_golem_client(dt)
		server.remote_players[p.local_peer_id].merge({"pos":[p.player_pos.x,p.player_pos.y],"hp":p.hp,"max_hp":p.max_hp()},true)
	var started:=Time.get_ticks_usec()
	server.update_dedicated_enemies(dt)
	update_ms.append(float(Time.get_ticks_usec()-started)/1000.0)
	mobs.append(server.enemies.size());boulders.append(server.golem_world.boulders.size());shots.append(server.enemy_projectiles.size());drops.append(server.drops.size())
	if frame%3==0:
		started=Time.get_ticks_usec()
		server.push_world_snapshot()
		snapshot_ms.append(float(Time.get_ticks_usec()-started)/1000.0)

func run() -> void:
	var args:=OS.get_cmdline_user_args()
	var out_path:String=args[0] if not args.is_empty() else ""
	var save_root:="user://golem_bench"
	DirAccess.make_dir_recursive_absolute(save_root)
	if FileAccess.file_exists(save_root.path_join("golem_world.json")):DirAccess.remove_absolute(save_root.path_join("golem_world.json"))
	var host := WebSocketMultiplayerPeer.new()
	if host.create_server(31912) != OK: quit(1); return
	var server = session("Server",host)
	server.network_mode = "host"
	server.dedicated_server_mode = true
	server.golem_world_path = save_root.path_join("golem_world.json")
	server.reset_class_skills()
	while server.skill_levels.size()<64:server.skill_levels.append(0)
	var players:=[]
	var peers:=[]
	for index in 4:
		var peer:=WebSocketMultiplayerPeer.new();peer.create_client("ws://127.0.0.1:31912");peers.append(peer)
		var p=session("P%d"%index,peer)
		p.network_mode="client";p.character_created=true;p.level=40;p.class_id=index%3
		p.reset_class_skills()
		while p.skill_levels.size()<64:p.skill_levels.append(0)
		p.hp=p.max_hp();p.inventory.clear()
		players.append(p)
	var deadline := Time.get_ticks_msec()+15000
	while server.multiplayer.get_peers().size() < 4:
		if Time.get_ticks_msec() > deadline: quit(2); return
		await process_frame
	server.remote_players={}
	for index in players.size():
		var p=players[index]
		p.local_peer_id=peers[index].get_unique_id()
		p.player_pos=GolemBoss.ALTAR+[Vector2(0,80),Vector2(70,150),Vector2(-80,140),Vector2(150,90)][index]
		server.remote_players[p.local_peer_id]={"level":40,"uuid":"golem-bench-%d" % p.local_peer_id,"class":p.class_id,"context":"world","instance_id":"world","pos":[p.player_pos.x,p.player_pos.y],"hp":p.hp,"max_hp":p.max_hp()}
	var summoner=players[0]
	summoner.inventory.append(food(summoner,"Steinbeeren",31))
	summoner.interact()
	deadline=Time.get_ticks_msec()+10000
	while summoner.golem_summon_pending:
		if Time.get_ticks_msec()>deadline:break
		await process_frame
	check(golem_on(server).size()==1,"Server hat den Golem")
	var frame:=0;var sim_time:=0.0;var victory:=false
	var armor_before:=armor_count(summoner)
	deadline=Time.get_ticks_msec()+240000
	while Time.get_ticks_msec()<deadline:
		for sub in 2:
			tick(server,players,frame,1.0/30.0);frame+=1;sim_time+=1.0/30.0
		var targets:=golem_on(server)
		if targets.is_empty():
			# Nach dem Zerfall: übrige Gegner (Hälften, Falter) angreifen.
			for e in server.enemies:targets.append(e)
		if not targets.is_empty() and sim_time>2.0:
			for p in players:
				var t:Vector2=targets[0]["pos"]
				var dir:Vector2=(t-p.player_pos).normalized()
				p.rpc_client_normal_attack.rpc_id(1,[p.player_pos.x,p.player_pos.y],[dir.x,dir.y],0,0,880,"")
				if p.player_pos.distance_to(t)>200.0:p.player_pos+=dir*6.0
		if armor_count(summoner)>armor_before:victory=true;break
		await process_frame
	var report:={"players":players.size(),"sim_seconds":sim_time,"frames":frame,"victory":victory,
		"server_update_ms":stats(update_ms),"snapshot_ms":stats(snapshot_ms),
		"mobs_max":percentile(mobs,1.0),"boulders_max":percentile(boulders,1.0),"shots_max":percentile(shots,1.0),"shots_p50":percentile(shots,.5),"drops_max":percentile(drops,1.0),
		"update_over_16ms":update_ms.filter(func(v):return float(v)>16.0).size(),
		"update_over_50ms":update_ms.filter(func(v):return float(v)>50.0).size()}
	print("GOLEM_BENCH ",JSON.stringify(report))
	if out_path!="":
		var file:=FileAccess.open(out_path,FileAccess.WRITE)
		if file:file.store_string(JSON.stringify(report,"  "))
	check(victory,"Sieg innerhalb des Zeitlimits")
	for p in players:p.queue_free()
	server.queue_free()
	if failures>0:quit(1);return
	quit()
