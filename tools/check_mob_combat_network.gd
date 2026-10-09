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

func run() -> void:
	var host := WebSocketMultiplayerPeer.new()
	if host.create_server(31888) != OK: quit(1); return
	var server = session("Server",host)
	server.network_mode = "host"
	server.dedicated_server_mode = true
	var low_peer := WebSocketMultiplayerPeer.new()
	var high_peer := WebSocketMultiplayerPeer.new()
	low_peer.create_client("ws://127.0.0.1:31888")
	high_peer.create_client("ws://127.0.0.1:31888")
	var low = session("Low",low_peer)
	var high = session("High",high_peer)
	low.network_mode = "client"
	high.network_mode = "client"
	low.level = 7
	high.level = 40
	low.xp = 0
	high.xp = 0
	var deadline := Time.get_ticks_msec()+10000
	while server.multiplayer.get_peers().size() < 2:
		if Time.get_ticks_msec() > deadline: quit(2); return
		await process_frame
	var low_id := low_peer.get_unique_id()
	var high_id := high_peer.get_unique_id()
	server.remote_players = {low_id:{"level":7,"uuid":"low","class":0,"context":"world","instance_id":"world","pos":[2200.0,1000.0]},high_id:{"level":40,"uuid":"high","class":0,"context":"world","instance_id":"world","pos":[2220.0,1000.0]}}
	server.server_parties = {1:[low_id,high_id]}
	server.server_party_of_peer = {low_id:1,high_id:1}
	var reward: int = server.enemy_xp_reward(1,0,7)
	var shared_reward: int = roundi(float(reward)*1.02)
	# Higher-level killer must not reduce the lower-level recipient's XP.
	server.send_server_enemy_reward(high_id,{"uid":901,"type":1,"elite":0,"pos":Vector2(2200,1000)})
	while low.xp < shared_reward:
		if Time.get_ticks_msec() > deadline: quit(3); return
		await process_frame
	assert(low.xp == shared_reward and high.xp == 0)
	# Reverse killer: XP goes directly with the low-level member's loot packet.
	server.send_server_enemy_reward(low_id,{"uid":902,"type":1,"elite":0,"pos":Vector2(2200,1000)})
	while low.xp < shared_reward*2:
		if Time.get_ticks_msec() > deadline: quit(4); return
		await process_frame
	assert(low.xp == shared_reward*2 and high.xp == 0)
	for i in 10: await process_frame
	assert(server.server_pending_transactions.is_empty())
	print("PARTY_XP_NETWORK_OK local-range group XP +2% bonus=",shared_reward," acknowledgments received")
	low.hp=1000.0;high.hp=1000.0
	low.invulnerable=0.0;high.invulnerable=0.0
	low.player_pos=Vector2(6000,1035);high.player_pos=Vector2(6000,1045)
	server.remote_players[low_id].merge({"pos":[6000.0,1035.0],"hp":1000.0},true)
	server.remote_players[high_id].merge({"pos":[6000.0,1045.0],"hp":1000.0},true)
	var mob:Dictionary=server.make_enemy(4,Vector2(6000,1000))
	mob["uid"]=818;mob["attack_wait"]=0.0
	server.enemies=[mob]
	low.enemies.clear();high.enemies.clear()
	server.update_dedicated_enemies(.01)
	server.push_world_snapshot()
	deadline=Time.get_ticks_msec()+10000
	while low.enemies.is_empty() or high.enemies.is_empty() or int(low.enemies[0].get("uid",0))!=818 or int(high.enemies[0].get("uid",0))!=818:
		if Time.get_ticks_msec()>deadline:quit(5);return
		await process_frame
	if low.enemies[0].get("attack_state",{}).is_empty():
		print("EMPTY_ATTACK server=",mob," targets=",server.mob_targets(mob,true)," low=",low.enemies[0]);quit(8);return
	assert(low.enemies[0]["attack_state"]["dir"] is Vector2)
	assert(low.enemies[0]["facing"] is Vector2)
	var damage:int=server.mob_profile(mob)["damage"]
	for frame in 70:
		server.update_dedicated_enemies(1.0/60.0)
		await process_frame
	while low.hp==1000 or high.hp==1000:
		if Time.get_ticks_msec()>deadline:quit(6);return
		await process_frame
	assert(low.hp==1000-damage and high.hp==1000-damage)
	mob["stun"]=1.0
	for frame in 90:
		server.update_dedicated_enemies(1.0/60.0)
		await process_frame
	assert(low.hp==1000-damage and high.hp==1000-damage)
	# New woodland attacks use the same authoritative snapshots and damage RPCs.
	# The legacy golem test point is inside terrain; find a real unobstructed
	# strip for attacks that now correctly respect walls.
	var woodland_site:=Vector2(6000,1000)
	var found_site:=false
	for y in range(-320,321,32):
		for x in range(-320,321,32):
			var candidate:=Vector2(6000+x,1000+y)
			var clear:bool=server.region_at(candidate)!=0
			for distance in [0,30,60,100,150,200]:
				var probe:=candidate+Vector2(distance,0)
				clear=clear and not server.terrain_blocked(probe,30) and not server.waystone_safe_at(probe) and server.region_at(probe)==server.region_at(candidate)
			if clear and not server.projectile_collision(candidate,candidate+Vector2(200,10),true)["hit"]:
				woodland_site=candidate;found_site=true;break
		if found_site:break
	assert(found_site,"Need an unobstructed multiplayer combat test site")
	low.hp=1000;high.hp=1000;low.invulnerable=0;high.invulnerable=0
	low.player_pos=woodland_site+Vector2(25,10);high.player_pos=woodland_site+Vector2(35,10)
	server.remote_players[low_id].merge({"pos":[low.player_pos.x,low.player_pos.y],"hp":1000.0},true)
	server.remote_players[high_id].merge({"pos":[high.player_pos.x,high.player_pos.y],"hp":1000.0},true)
	var mushroom:Dictionary=server.make_enemy(2,woodland_site)
	mushroom["uid"]=819;mushroom["attack_wait"]=0.0
	server.enemies=[mushroom];server.enemy_projectiles.clear()
	server.update_dedicated_enemies(.01);server.update_dedicated_enemies(.86)
	assert(server.enemy_projectiles.size()==1 and server.enemy_projectiles[0]["kind"]=="cloud")
	var poison_damage:=int(server.enemy_projectiles[0]["damage"])
	server.advance_mob_shots(.01,true);server.push_world_snapshot()
	deadline=Time.get_ticks_msec()+10000
	while low.hp==1000 or high.hp==1000 or low.enemy_projectiles.is_empty() or high.enemy_projectiles.is_empty():
		if Time.get_ticks_msec()>deadline:
			print("POISON_NETWORK_TIMEOUT hp=",low.hp,"/",high.hp," server_field=",server.enemy_projectiles," client_shots=",low.enemy_projectiles," site=",woodland_site)
			quit(9);return
		await process_frame
	assert(low.hp==1000-poison_damage and high.hp==1000-poison_damage)
	assert(low.enemy_projectiles[0]["kind"]=="cloud" and high.enemy_projectiles[0]["radius"]==84.0)
	assert(low.enemy_projectiles[0]["dir"] is Vector2 and low.enemies[0]["attack_state"]["ability"]["id"]=="giftstaub")
	server.advance_mob_shots(.1,true)
	for frame in 10:await process_frame
	assert(low.hp==1000-poison_damage and high.hp==1000-poison_damage)
	# Everyone outside the area is safe for the next pulse.
	server.remote_players[low_id]["pos"]=[woodland_site.x+250,woodland_site.y]
	server.remote_players[high_id]["pos"]=[woodland_site.x+250,woodland_site.y]
	server.advance_mob_shots(.65,true)
	for frame in 10:await process_frame
	assert(low.hp==1000-poison_damage and high.hp==1000-poison_damage)
	var wolf:Dictionary=server.make_enemy(3,woodland_site)
	wolf["uid"]=820;wolf["attack_wait"]=0
	server.enemies=[wolf];server.enemy_projectiles.clear()
	low.player_pos=woodland_site+Vector2(150,0);high.player_pos=woodland_site+Vector2(300,0)
	server.remote_players[low_id]["pos"]=[woodland_site.x+150,woodland_site.y]
	server.remote_players[high_id]["pos"]=[woodland_site.x+300,woodland_site.y]
	server.update_dedicated_enemies(.01);server.push_world_snapshot()
	while low.enemies.is_empty() or int(low.enemies[0].get("uid",0))!=820:
		if Time.get_ticks_msec()>deadline:quit(10);return
		await process_frame
	assert(low.enemies[0]["attack_state"]["ability"]["id"]=="sprungbiss")
	low.hp=1000;high.hp=1000;low.invulnerable=0;high.invulnerable=0
	server.update_dedicated_enemies(.8)
	assert(Vector2(wolf["pos"]).distance_to(woodland_site)<.01 and low.hp==1000)
	for frame in 20:
		server.update_dedicated_enemies(1.0/60)
		await process_frame
	while low.hp==1000:
		if Time.get_ticks_msec()>deadline:quit(11);return
		await process_frame
	assert(low.hp==1000-int(server.mob_profile(wolf)["damage"]) and high.hp==1000)
	assert(Vector2(wolf["pos"]).distance_to(woodland_site+Vector2(150,0))<1)
	var beetle:Dictionary=server.make_enemy(1,woodland_site)
	beetle["uid"]=821;beetle["attack_wait"]=0
	server.enemies=[beetle];server.enemy_projectiles.clear()
	low.hp=1000;low.invulnerable=0
	server.update_dedicated_enemies(.01);server.update_dedicated_enemies(.71);server.push_world_snapshot()
	while low.enemy_projectiles.is_empty() or str(low.enemy_projectiles[0].get("ability_id",""))!="druesensekret":
		if Time.get_ticks_msec()>deadline:quit(12);return
		await process_frame
	assert(Vector2(low.enemy_projectiles[0]["pos"]).distance_to(woodland_site+Vector2(16,-8))<.01)
	server.advance_mob_shots(.62,true)
	while low.hp==1000:
		if Time.get_ticks_msec()>deadline:quit(13);return
		await process_frame
	assert(low.hp==1000-int(server.mob_profile(beetle)["damage"]) and high.hp==1000)
	print("WOODLAND_ATTACKS_NETWORK_OK real WS: shared poison field / group pulse once / leaving area / swept leap landing / gland projectile")
	for index in 3:
		var now_ms := Time.get_ticks_msec()
		server.server_send_all_quest_progress(low_id,{"type":12+index,"uid":990+index,"pos":Vector2(6000,1000),"damage_by_peer":{low_id:100,high_id:80},"damage_at_by_peer":{low_id:now_ms,high_id:now_ms}})
	while not low.bosses_defeated[2] or not high.bosses_defeated[2]:
		if Time.get_ticks_msec()>deadline:quit(7);return
		await process_frame
	assert(low.bosses_defeated==[true,true,true] and high.bosses_defeated==[true,true,true])
	print("MOB_COMBAT_NETWORK_OK real WS: attack snapshots / Vector2 aim / two group hits exactly once / stun cancellation / all three boss credits")
	host.close()
	low_peer.close()
	high_peer.close()
	server.get_parent().queue_free()
	low.get_parent().queue_free()
	high.get_parent().queue_free()
	await process_frame
	await process_frame
	quit()
