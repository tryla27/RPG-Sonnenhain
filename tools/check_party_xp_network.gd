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
	if host.create_server(31877) != OK: quit(1); return
	var server = session("Server",host)
	server.network_mode = "host"
	server.dedicated_server_mode = true
	var low_peer := WebSocketMultiplayerPeer.new()
	var high_peer := WebSocketMultiplayerPeer.new()
	low_peer.create_client("ws://127.0.0.1:31877")
	high_peer.create_client("ws://127.0.0.1:31877")
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
	server.remote_players = {low_id:{"level":7,"uuid":"low","class":0,"context":"world"},high_id:{"level":40,"uuid":"high","class":0,"context":"world"}}
	server.server_parties = {1:[low_id,high_id]}
	server.server_party_of_peer = {low_id:1,high_id:1}
	var reward: int = server.enemy_xp_reward(1,0,7)
	# Higher-level killer must not reduce the lower-level recipient's XP.
	server.send_server_enemy_reward(high_id,{"uid":901,"type":1,"elite":0,"pos":Vector2(2200,1000)})
	while low.xp < reward:
		if Time.get_ticks_msec() > deadline: quit(3); return
		await process_frame
	assert(low.xp == reward and high.xp == 0)
	# Reverse killer: XP goes directly with the low-level member's loot packet.
	server.send_server_enemy_reward(low_id,{"uid":902,"type":1,"elite":0,"pos":Vector2(2200,1000)})
	while low.xp < reward*2:
		if Time.get_ticks_msec() > deadline: quit(4); return
		await process_frame
	assert(low.xp == reward*2 and high.xp == 0)
	for i in 10: await process_frame
	assert(server.server_pending_transactions.is_empty())
	print("PARTY_XP_NETWORK_OK real WebSocket RPC: level7 +",reward," for level40 kill and own kill; acknowledgments received")
	host.close()
	low_peer.close()
	high_peer.close()
	server.get_parent().queue_free()
	low.get_parent().queue_free()
	high.get_parent().queue_free()
	await process_frame
	await process_frame
	quit()
