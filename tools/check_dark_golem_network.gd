extends SceneTree
# Dunkler Golem online: ein Server, zwei Spieler über echte WebSocket-Verbindung.
# Beschwören (Server prüft, Zutaten nur beim Beschwörer weg), Kampf mit echten
# Angriffen, Schaden/Stoß/Brocken/Schrei bei beiden, Zerfall, Sieg und
# Golem-Rüstung im Inventar beider Spieler, Brocken in golem_world.json.
# Aufruf: godot --headless --path . --script tools/check_dark_golem_network.gd

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
		push_error("GOLEM_NETWORK_FAIL "+label)
		printerr("GOLEM_NETWORK_FAIL "+label)

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

## Ein Spielschritt: Server rechnet, Spieler melden ihre Lage, Paket geht raus.
func tick(server,players:Array,frame:int,dt:float)->void:
	for p in players:
		p.invulnerable=maxf(0.0,p.invulnerable-dt)
		p.update_golem_client(dt)
		server.remote_players[p.local_peer_id].merge({"pos":[p.player_pos.x,p.player_pos.y],"hp":p.hp,"max_hp":p.max_hp()},true)
	server.update_dedicated_enemies(dt)
	if frame%3==0:server.push_world_snapshot()

func run() -> void:
	var save_root:="user://golem_network_test"
	DirAccess.make_dir_recursive_absolute(save_root)
	var host := WebSocketMultiplayerPeer.new()
	if host.create_server(31911) != OK: quit(1); return
	var server = session("Server",host)
	server.network_mode = "host"
	server.dedicated_server_mode = true
	server.golem_world_path = save_root.path_join("golem_world.json")
	server.reset_class_skills()
	while server.skill_levels.size()<64:server.skill_levels.append(0)
	var peer_a := WebSocketMultiplayerPeer.new()
	var peer_b := WebSocketMultiplayerPeer.new()
	var peer_c := WebSocketMultiplayerPeer.new()
	peer_a.create_client("ws://127.0.0.1:31911")
	peer_b.create_client("ws://127.0.0.1:31911")
	peer_c.create_client("ws://127.0.0.1:31911")
	var a = session("A",peer_a)
	var b = session("B",peer_b)
	var c = session("C",peer_c)
	var players:=[a,b,c]
	for p in players:
		p.network_mode="client";p.character_created=true;p.level=40;p.class_id=0
		p.reset_class_skills()
		while p.skill_levels.size()<64:p.skill_levels.append(0)
		p.hp=p.max_hp();p.inventory.clear()
	var deadline := Time.get_ticks_msec()+15000
	while server.multiplayer.get_peers().size() < 3:
		if Time.get_ticks_msec() > deadline: quit(2); return
		await process_frame
	a.local_peer_id=peer_a.get_unique_id();b.local_peer_id=peer_b.get_unique_id();c.local_peer_id=peer_c.get_unique_id()
	# C steht weit weg im Himmelsgarten und kämpft nicht mit.
	for far in [Vector2(0,-1100),Vector2(-1100,-600),Vector2(1200,-500),Vector2(-1500,0),Vector2(-1300,400)]:
		c.player_pos=GolemBoss.ALTAR+far
		if server.region_at(c.player_pos)==12 and not server.waystone_safe_at(c.player_pos) and not server.terrain_blocked(c.player_pos,20):break
	a.player_pos=GolemBoss.ALTAR+Vector2(0,80)
	b.player_pos=GolemBoss.ALTAR+Vector2(70,150)
	server.remote_players={}
	for p in players:
		server.remote_players[p.local_peer_id]={"level":40,"uuid":"golem-test-%d" % p.local_peer_id,"class":0,"context":"world","instance_id":"world","pos":[p.player_pos.x,p.player_pos.y],"hp":p.hp,"max_hp":p.max_hp()}
	check(a.uses_server_world() and b.uses_server_world(),"beide Spieler in der Serverwelt")

	# --- Beschwören -------------------------------------------------------
	# Vorerst ohne Opfergaben: E am Altar reicht.
	a.inventory.append(food(a,"Steinbeeren",31))
	a.interact()
	check(a.golem_summon_pending,"Anfrage gesendet")
	deadline=Time.get_ticks_msec()+10000
	while a.golem_summon_pending:
		if Time.get_ticks_msec()>deadline:check(false,"keine Antwort vom Server");break
		await process_frame
	check(golem_on(server).size()==1,"Server hat den Golem")
	check(a.steinrose.inventory_count(a,"Steinbeeren")==31,"keine Zutaten abgezogen (Opfergaben kommen später)")
	var big:Dictionary=golem_on(server)[0] if golem_on(server).size()>0 else {}
	var single_hp:float=float(server.make_enemy(27,Vector2.ZERO)["max_hp"])
	# A und B stehen am Altar, C ist weiter als 1600 px weg: zählt nicht.
	var near:=0
	for p in players:
		if p.player_pos.distance_to(GolemBoss.ALTAR)<1600.0:near+=1
	check(not big.is_empty() and is_equal_approx(float(big["max_hp"]),single_hp*(1.0+0.7*(near-1))),"Leben für %d Spieler: %s" % [near,big.get("max_hp",0)])
	# Zweite Beschwörung während er lebt: abgelehnt, nichts abgezogen.
	var frame:=0
	for i in 20:
		tick(server,players,frame,1.0/30.0);frame+=1
		await process_frame
	b.player_pos=GolemBoss.ALTAR+Vector2(40,90)
	b.interact()
	check(not b.golem_summon_pending,"zweiter Golem schon beim Spieler abgelehnt (lebt bereits)")
	b.player_pos=GolemBoss.ALTAR+Vector2(70,150)
	check(golem_on(a).size()==1 and golem_on(b).size()==1,"beide Spieler sehen den Golem")
	if golem_on(a).size()==1:
		check(str(golem_on(a)[0].get("golem",{}).get("state",""))!="","Golem-Zustand kommt beim Spieler an")

	# --- Kampf -------------------------------------------------------------
	var saw_shield:=false;var saw_field_a:=false;var saw_field_b:=false
	var saw_throw:=false;var saw_boulder_b:=false;var saw_scream_a:=false;var saw_scream_b:=false
	var saw_halves_a:=false;var saw_halves_b:=false;var saw_minions:=false;var saw_debris:=false
	var armor_before_a:=armor_count(a);var armor_before_b:=armor_count(b)
	deadline=Time.get_ticks_msec()+150000
	var sim_time:=0.0
	var victory:=false
	while Time.get_ticks_msec()<deadline:
		for sub in 2:
			tick(server,players,frame,1.0/30.0);frame+=1;sim_time+=1.0/30.0
		# Angriffe über die echte Netz-Anfrage (Nahkampf, Server prüft Abstand).
		var targets:=golem_on(server)
		if not targets.is_empty() and sim_time>3.0:
			for p in [a,b]:
				var t:Vector2=targets[0]["pos"]
				var dir:Vector2=(t-p.player_pos).normalized()
				p.rpc_client_normal_attack.rpc_id(1,[p.player_pos.x,p.player_pos.y],[dir.x,dir.y],0,0,880,"")
				# Hinterher laufen wie ein Spieler (höchstens 6 px pro Schritt).
				if p.player_pos.distance_to(t)>200.0:p.player_pos+=dir*6.0
		for g in golem_on(server):
			if str(g.get("golem",{}).get("state",""))=="shield":saw_shield=true
		saw_field_a=saw_field_a or not a.golem_world.fields.is_empty()
		saw_field_b=saw_field_b or not b.golem_world.fields.is_empty()
		saw_throw=saw_throw or not server.golem_world.throws.is_empty()
		saw_boulder_b=saw_boulder_b or not b.golem_world.boulders.is_empty()
		saw_scream_a=saw_scream_a or a.golem_world.scream_at>=0.0
		saw_scream_b=saw_scream_b or b.golem_world.scream_at>=0.0
		for p in players:
			for e in p.enemies:
				if int(e["type"])==28:
					if p==a:saw_halves_a=true
					else:saw_halves_b=true
				if int(e["type"])==25:saw_minions=true
		saw_debris=saw_debris or not a.golem_debris.is_empty()
		if armor_count(a)>armor_before_a and armor_count(b)>armor_before_b:
			victory=true;break
		await process_frame
	print("GOLEM_NETWORK_INFO sim=%.0fs frames=%d hits_a=%d hits_b=%d pushed=%s/%s boulders=%d" % [sim_time,frame,a.hits_taken,b.hits_taken,a.pushed,b.pushed,server.golem_world.boulders.size()])
	check(saw_shield,"Schild auf dem Server")
	check(saw_field_a and saw_field_b,"Steinhagel-Feld bei beiden Spielern")
	check(saw_throw and saw_boulder_b,"Brockenwurf, liegender Brocken beim Spieler")
	check(a.hits_taken>0 and b.hits_taken>0,"beide Spieler nehmen Schaden")
	check(a.pushed or b.pushed,"Brocken/Stampfer stößt Spieler weg")
	check(saw_scream_a and saw_scream_b,"Schrei bei beiden Spielern")
	check(saw_debris,"Zerfall in Einzelteile beim Spieler")
	check(saw_halves_a and saw_halves_b,"beide sehen die zwei Hälften")
	check(saw_minions,"Himmelsfalter-Wellen")
	check(victory,"Sieg: beide Spieler haben die Golem-Rüstung im Inventar")
	check(not server.golem_world.fight_active,"Kampf auf dem Server beendet")
	check(c.hits_taken>0,"Schrei trifft auch den Unbeteiligten weit weg (%d Treffer)" % c.hits_taken)
	check(armor_count(c)==0,"wer nicht mitkämpft, bekommt keine Rüstung")
	for i in 30:
		tick(server,players,frame,1.0/30.0);frame+=1
		await process_frame
	check(server.server_pending_transactions.is_empty(),"Belohnungen bestätigt")
	# Letzte Brocken landen, dann sichert der Server von selbst (höchstens 2 s).
	for i in 120:
		tick(server,players,frame,1.0/30.0);frame+=1
		await process_frame
	check(server.golem_world.boulders.is_empty() and a.golem_world.boulders.is_empty(),"Brocken nach dem Kampf zerbröselt (Server %d, Spieler %d)" % [server.golem_world.boulders.size(),a.golem_world.boulders.size()])
	check(a.golem_world.cooldown_left()>800.0,"15 Minuten Pause kommt beim Spieler an (%.0f s)" % a.golem_world.cooldown_left())
	# C geht weg aus dem Himmelsgarten: bekommt nur noch das schmale Paket.
	c.player_pos=Vector2(2600,1500)
	c.golem_world.fields=[{"pos":[0,0],"life":9.0}]
	for i in 12:
		tick(server,players,frame,1.0/30.0);frame+=1
		await process_frame
	check(c.golem_world.fields.is_empty() and c.golem_world.cooldown_left()>800.0,"außerhalb: schmales Paket mit Pause")
	# Pause: neuer Golem abgelehnt; im Testmodus erlaubt.
	a.player_pos=GolemBoss.ALTAR+Vector2(0,80)
	for i in 6:
		tick(server,players,frame,1.0/30.0);frame+=1
		await process_frame
	a.golem_world.cooldown_until=0.0
	a.interact()
	deadline=Time.get_ticks_msec()+10000
	while a.golem_summon_pending and Time.get_ticks_msec()<deadline:await process_frame
	check(golem_on(server).is_empty(),"Server lehnt während der Pause ab")
	# Der Server nimmt höchstens alle 2,5 s eine Anfrage pro Spieler an.
	await create_timer(2.7).timeout
	a.golem_summon_pending=false
	server.remote_players[a.local_peer_id]["test_mode"]=true
	a.creative_mode=true
	a.interact()
	deadline=Time.get_ticks_msec()+10000
	while a.golem_summon_pending and Time.get_ticks_msec()<deadline:await process_frame
	check(golem_on(server).size()==1,"Testmodus: Golem trotz Pause")
	a.creative_mode=false
	for i in 90:
		tick(server,players,frame,1.0/30.0);frame+=1
		await process_frame
	check(FileAccess.file_exists(server.golem_world_path),"golem_world.json gespeichert")
	var stored:Variant=JSON.parse_string(FileAccess.get_file_as_string(server.golem_world_path))
	check(stored is Dictionary and (stored["boulders"] as Array).size()==server.golem_world.boulders.size(),"Brocken in der Datei")
	var restarted:=GolemBoss.new();restarted.load_state(stored)
	check(restarted.boulders.size()==server.golem_world.boulders.size(),"Brocken nach Neustart wieder da")
	check(restarted.cooldown_left()>800.0,"Pause übersteht Neustart")

	host.close();peer_a.close();peer_b.close();peer_c.close()
	for g in [server,a,b,c]:g.get_parent().queue_free()
	await process_frame
	await process_frame
	if failures>0:
		printerr("GOLEM_NETWORK_FAILED %d" % failures)
		quit(1);return
	print("GOLEM_NETWORK_OK three players (two fighting): summon, fight, shield, hail, boulders, scream, split, minions, armor for both, persistence")
	quit()
