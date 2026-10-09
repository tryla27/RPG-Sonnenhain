extends SceneTree
# Viele Gegner und Beute in der ganzen Welt dürfen das Weltpaket nicht so groß
# machen, dass es verloren geht (Gegner frieren ein, Bosse fehlen). Echter
# WebSocket: Server + Spiel.

const WorldSnapshot=preload("res://components/world_snapshot.gd")

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("WORLD_SNAPSHOT_FAIL "+label)

func _initialize():call_deferred("run")
func session(label:String,peer:MultiplayerPeer):
	var branch:=Node.new();branch.name=label;root.add_child(branch)
	var api:=SceneMultiplayer.new();api.root_path=branch.get_path();set_multiplayer(api,branch.get_path());api.multiplayer_peer=peer
	var game=load("res://main.gd").new();game.name="Sonnenhain";game.konflux_preview_mode=true;branch.add_child(game);game.set_process(false);game.set_process_input(false)
	game.character_created=true;game.panel="";game.reset_class_skills()
	return game
func settle():
	for frame in 10:await process_frame
func run():
	var host:=WebSocketMultiplayerPeer.new();WorldSnapshot.widen(host);assert(host.create_server(31958)==OK)
	var server=session("Authority",host);server.network_mode="host";server.dedicated_server_mode=true
	var cp:=WebSocketMultiplayerPeer.new();WorldSnapshot.widen(cp);assert(cp.create_client("ws://127.0.0.1:31958")==OK)
	var c=session("Client",cp);c.network_mode="client"
	while server.multiplayer.get_peers().size()<1: await process_frame
	var site:Vector2=server.CLASS_BOSS_SITES[1]
	c.player_pos=site+Vector2(0,250)
	c.rpc_player_presence.rpc_id(1,c.local_player_state());await settle()
	server.remote_players[cp.get_unique_id()]["pos"]=[c.player_pos.x,c.player_pos.y]
	# Volle Welt: 400 Gegner überall, 120 Beutestücke, dazu der Boss im Feld.
	var rng:=RandomNumberGenerator.new();rng.seed=7
	for i in 400:
		var e:Dictionary=server.make_enemy(i%12,Vector2(rng.randf_range(200,15800),rng.randf_range(200,8400)))
		e["uid"]=1000+i
		server.enemies.append(e)
	for i in 120:
		server.drops.append({"drop_uid":5000+i,"pos":Vector2(rng.randf_range(200,15800),rng.randf_range(200,8400)),"item":server.make_item("Schatzklinge %d" % i,"sword",3,40,500,"feuer",30),"life":120.0})
	server.spawn_dedicated_bosses()
	var full:={"enemies":[],"drops":[]}
	server.push_world_snapshot()
	await settle()
	var boss_seen:=false
	for e in c.enemies:
		if int(e["type"])==13:boss_seen=true
	check(boss_seen,"Spiel sieht den Boss trotz voller Welt")
	check(c.enemies.size()>0 and c.enemies.size()<400,"Spiel bekommt nur nahe Gegner (%d)" % c.enemies.size())
	for e in c.enemies:
		check(Vector2(e["pos"]).distance_to(c.player_pos)<=WorldSnapshot.INTEREST_RANGE+1.0,"nur Gegner in der Nähe")
	# Bewegung kommt an: Boss verschieben, neues Paket.
	for e in server.enemies:
		if int(e["type"])==13:e["pos"]=e["pos"]+Vector2(60,0)
	server.push_world_snapshot();await settle()
	var moved:=false
	for e in c.enemies:
		if int(e["type"])==13 and Vector2(e["net_target_pos"]).distance_to(site+Vector2(60,0))<1.0:moved=true
	check(moved,"Bewegung des Bosses kommt an")
	host.close();cp.close()
	if failures>0:
		print("WORLD_SNAPSHOT_FAILED ",failures)
		quit(1)
		return
	print("WORLD_SNAPSHOT_OK full world stays deliverable: nearby filter and wide buffers")
	quit()
