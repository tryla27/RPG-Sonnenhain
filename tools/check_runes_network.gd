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
	assert(host.create_server(31925)==OK)
	var server=session("RuneAuthority",host);server.network_mode="host";server.dedicated_server_mode=true
	var actor_peer:=WebSocketMultiplayerPeer.new();actor_peer.create_client("ws://127.0.0.1:31925")
	var observer_peer:=WebSocketMultiplayerPeer.new();observer_peer.create_client("ws://127.0.0.1:31925")
	var actor=session("RuneActor",actor_peer);actor.network_mode="client";actor.level=40
	var observer=session("RuneObserver",observer_peer);observer.network_mode="client";observer.level=40
	actor.player_pos=Vector2(2500,900);observer.player_pos=actor.player_pos+Vector2(10,0)
	var deadline:=Time.get_ticks_msec()+10000
	while server.multiplayer.get_peers().size()<2:
		if Time.get_ticks_msec()>deadline:quit(2);return
		await process_frame
	var actor_id:=actor_peer.get_unique_id()
	observer.rpc_player_state.rpc_id(1,observer.local_player_state())
	await wait_frames(8)
	for hero_class in 3:
		for race in 3:
			for gender in 2:
				actor.class_id=hero_class;actor.hero_race=race;actor.hero_gender=gender
				actor.essence.reset()
				for tree in actor.EssenceSystem.TREE_COUNT:assert(actor.essence.invest(40,tree,0))
				assert(actor.essence.invest(40,2,1))
				actor.rpc_player_state.rpc_id(1,actor.local_player_state())
				await wait_frames(12)
				assert(server.remote_players[actor_id]["rune_ranks"]==actor.essence.ranks)
				assert(observer.remote_players[actor_id]["rune_ranks"]==actor.essence.ranks)
				assert(server.remote_players[actor_id]["class"]==hero_class)
				assert(server.remote_players[actor_id]["essence_magic_element"]==1)
	var invalid=actor.essence.ranks.duplicate(true)
	invalid[0][0]=99
	assert(actor.EssenceSystem.network_ranks(invalid,40).is_empty())
	assert(actor.EssenceSystem.network_ranks(actor.essence.ranks,1).is_empty())
	print("RUNES_NETWORK_OK all five rune trees: 18 class/race/gender combinations, real WebSocket authority and observer; bounded ranks and level budget")
	host.close();actor_peer.close();observer_peer.close()
	for game in [server,actor,observer]:
		game.sound_streams.clear();game.get_parent().queue_free()
	await wait_frames(2)
	quit()
