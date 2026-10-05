extends SceneTree

class TestGame:
	extends "res://main.gd"
	func _ready() -> void: pass
	func _process(_delta: float) -> void: pass
	func _draw() -> void: pass
	func save_game() -> void: pass

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
	var game = load("res://main.gd").new()
	game.name = "Sonnenhain"
	game.konflux_preview_mode = true
	branch.add_child(game)
	game.set_process(false)
	game.set_process_input(false)
	return game


func wait_frames(count:int=8)->void:
	for n in count:await process_frame

func run()->void:
	var host:=WebSocketMultiplayerPeer.new()
	if host.create_server(31918)!=OK:quit(1);return
	var server=session("Authority",host);server.network_mode="host";server.dedicated_server_mode=true
	var left_peer:=WebSocketMultiplayerPeer.new();left_peer.create_client("ws://127.0.0.1:31918")
	var right_peer:=WebSocketMultiplayerPeer.new();right_peer.create_client("ws://127.0.0.1:31918")
	var left=session("Left",left_peer);left.network_mode="client";left.level=40;left.hp=left.max_hp()
	var right=session("Right",right_peer);right.network_mode="client";right.level=40;right.hp=right.max_hp()
	var deadline:=Time.get_ticks_msec()+10000
	while server.multiplayer.get_peers().size()<2:
		if Time.get_ticks_msec()>deadline:quit(2);return
		await process_frame
	var a:=left_peer.get_unique_id();var b:=right_peer.get_unique_id()
	for region in range(1,13):
		var center:Vector2=server.region_rect(region).get_center()
		left.player_pos=center;right.player_pos=center+Vector2(20,0)
		server.remote_players={a:{"pos":[center.x,center.y],"context":"world","instance_id":"world","hp":1000,"level":40,"uuid":"feedback-left","class":1},b:{"pos":[center.x+20,center.y],"context":"world","instance_id":"world","hp":1000,"level":40,"uuid":"feedback-right","class":1}}
		var type:=0
		for candidate in server.ENEMY_TYPES.size():
			if int(server.ENEMY_TYPES[candidate]["region"])==region and candidate not in [12,13,14]:type=candidate;break
		var mob:Dictionary=server.make_enemy(type,center+Vector2(70,70))
		mob["uid"]=8000+region;mob["hp"]=100;mob["max_hp"]=100
		server.enemies=[mob]
		server.push_world_snapshot()
		await wait_frames()
		assert(left.enemies.size()==1 and right.enemies.size()==1)
		assert(left.enemies[0]["uid"]==right.enemies[0]["uid"])
		server.damage_enemy(0,17,Vector2.ZERO,false,"",a)
		await wait_frames()
		assert(left.enemies[0]["hp"]==83 and right.enemies[0]["hp"]==83)
		assert(left.enemies[0]["flash"]>0 and right.enemies[0]["flash"]>0)
		server.damage_enemy(0,200,Vector2.ZERO,false,"",a)
		await wait_frames()
		assert(left.enemies.is_empty() and right.enemies.is_empty())
		assert(left.dead_mob_uids.has(8000+region) and right.dead_mob_uids.has(8000+region))
		assert(left.mob_deaths.back()["uid"]==right.mob_deaths.back()["uid"])
	print("FEEDBACK_MAPS_NETWORK_OK maps1-12 shared IDs, authoritative HP, hurt and death over real WebSocket")
	left.player_pos=Vector2(825,1095);right.player_pos=Vector2(825,1095)
	server.remote_players[a]["pos"]=[825.0,1095.0];server.remote_players[b]["pos"]=[825.0,1095.0]
	var home:Vector2=server.village_house("Fenna")["house"]
	var facade:Rect2=server.VillageBuildings.solid(home,"style")
	var shot_origin:=Vector2(facade.get_center().x,facade.end.y+40)
	for kind in [0,1,2,3]:
		var before_left:int=left.combat_feedback.breaks.size();var before_right:int=right.combat_feedback.breaks.size()
		server.projectiles=[{"pos":shot_origin,"dir":Vector2.UP,"speed":2000.0,"life":1.0,"damage":10,"kind":kind,"owner_peer":a,"hits":[]}]
		server.update_dedicated_player_projectiles(.08)
		await wait_frames()
		assert(server.projectiles.is_empty())
		assert(left.combat_feedback.breaks.size()==before_left+1 and right.combat_feedback.breaks.size()==before_right+1)
	print("IMPACT_NETWORK_OK all four projectile kinds: authoritative building collision and both clients receive identical burst")
	# Same-context travel must bypass the ordinary 95-pixel movement cap only for valid destinations.
	var origin:Vector2=server.WAYSTONES[0]+Vector2(0,120)
	var destination:Vector2=server.WAYSTONES[1]+Vector2(0,180)
	left.player_pos=origin;left.hp=left.max_hp()
	server.remote_players[a].merge({"pos":[origin.x,origin.y],"teleport_serial":0},true)
	right.remote_players.erase(a);right.remote_player_render_positions.erase(a)
	left.teleport_serial=0;left.player_pos=destination;left.mark_network_teleport()
	await wait_frames(12)
	assert(Vector2(server.remote_players[a]["pos"][0],server.remote_players[a]["pos"][1])==destination)
	assert(right.remote_player_render_positions[a]==destination)
	left.player_pos=destination+Vector2(12,0);left.push_vital_state()
	await wait_frames()
	right.update_network_interpolation(.03)
	assert(right.remote_player_render_positions[a].x>destination.x and right.remote_player_render_positions[a].x<destination.x+12)
	left.hp=20;left.apply_player_damage(500);left.push_vital_state()
	await wait_frames()
	assert(right.remote_players[a]["hp"]==0 and right.remote_players[a]["death_progress"]>=0)
	left.respawn();left.push_vital_state()
	await wait_frames(12)
	assert(right.remote_players[a]["hp"]==left.max_hp() and right.remote_players[a]["death_progress"]<0)
	assert(right.remote_player_render_positions[a]==left.player_pos)
	print("PLAYER_VITALS_TELEPORT_NETWORK_OK HP/death/respawn reliable; same-world waystone travel snaps immediately; normal walking still interpolates")
	var site:Vector2=server.CLASS_BOSS_SITES[0]
	left.player_pos=site+Vector2(0,300);right.player_pos=left.player_pos
	server.remote_players[a]["pos"]=[left.player_pos.x,left.player_pos.y];server.remote_players[b]["pos"]=[left.player_pos.x,left.player_pos.y]
	server.enemies.clear();server.spawn_dedicated_bosses();server.spawn_dedicated_bosses();server.push_world_snapshot()
	await wait_frames()
	assert(server.enemies.size()==3 and left.enemies.size()==3 and right.enemies.size()==3)
	for i in 3:assert(left.enemies[i]["uid"]==right.enemies[i]["uid"])
	assert(left.enemies[1]["guardian_of"]==left.enemies[0]["uid"] and right.enemies[2]["small_guardian"])
	print("CLASS_BOSS_NETWORK_OK Map06 Kriegsherr shared once + exactly two linked guards; no duplicate per client")
	
	print("REMOVED_PVP_WORLD_NETWORK_OK no legacy arena vitals test remains")
	host.close();left_peer.close();right_peer.close()
	for game in [server,left,right]:
		game.sound_streams.clear()
		game.get_parent().queue_free()
	await wait_frames(2)
	quit()
