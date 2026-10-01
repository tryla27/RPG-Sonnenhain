extends SceneTree
func _initialize():call_deferred("run")
func session(label:String,peer:MultiplayerPeer):
	var branch:=Node.new();branch.name=label;root.add_child(branch)
	var api:=SceneMultiplayer.new();api.root_path=branch.get_path();set_multiplayer(api,branch.get_path());api.multiplayer_peer=peer
	var game=load("res://main.gd").new();game.name="Sonnenhain";game.konflux_preview_mode=true;branch.add_child(game);game.set_process(false);game.set_process_input(false)
	game.character_created=true;game.panel="";game.reset_class_skills()
	return game
func settle():
	for frame in 12:await process_frame
func run():
	var host:=WebSocketMultiplayerPeer.new();assert(host.create_server(31928)==OK)
	var server=session("Authority",host);server.network_mode="host";server.dedicated_server_mode=true
	var left_peer:=WebSocketMultiplayerPeer.new();assert(left_peer.create_client("ws://127.0.0.1:31928")==OK)
	var right_peer:=WebSocketMultiplayerPeer.new();assert(right_peer.create_client("ws://127.0.0.1:31928")==OK)
	var left=session("Left",left_peer);left.network_mode="client"
	var right=session("Right",right_peer);right.network_mode="client"
	var deadline:int=Time.get_ticks_msec()+10000
	while server.multiplayer.get_peers().size()<2:
		if Time.get_ticks_msec()>deadline:quit(2);return
		await process_frame
	var a:int=left_peer.get_unique_id();var b:int=right_peer.get_unique_id()
	var center:Vector2=server.WAYSTONES[0]
	left.player_pos=center+Vector2(0,80);right.player_pos=center+Vector2(160,80)
	left.rpc_player_presence.rpc_id(1,left.local_player_state());right.rpc_player_presence.rpc_id(1,right.local_player_state());await settle()
	left.player_pos=center+Vector2(0,-10);left.push_vital_state()
	right.player_pos=center+Vector2(160,-10);right.push_vital_state();await settle()
	var accepted:Vector2=server.network_player_position(a)
	assert(accepted.y>=center.y+47 and not server.SpawnStoneBody.blocks(accepted-center,0,15))
	var observer:Array=right.remote_players[a]["pos"]
	assert(Vector2(observer[0],observer[1]).distance_to(accepted)<.01)
	assert(server.network_player_position(b).distance_to(right.player_pos)<.01)
	assert(left.SpawnPlatform32.height_at(accepted,center)==right.SpawnPlatform32.height_at(accepted,center))
	left.player_pos=server.WAYSTONES[1]+Vector2(0,180);left.mark_network_teleport();await settle()
	assert(server.network_player_position(a).distance_to(left.player_pos)<.01)
	assert(right.network_player_position(a).distance_to(left.player_pos)<.01)
	print("SPAWN_NETWORK_OK real WebSocket: server blocks core, observer agrees, side passage stays open, shared height and waystone travel preserved")
	host.close();left_peer.close();right_peer.close()
	for game in [server,left,right]:game.sound_streams.clear();game.get_parent().queue_free()
	await settle();quit()
