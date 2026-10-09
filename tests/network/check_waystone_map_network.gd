extends SceneTree
func _initialize()->void:call_deferred("run")
func session(label:String,peer:MultiplayerPeer):
	var branch:=Node.new();branch.name=label;root.add_child(branch)
	var api:=SceneMultiplayer.new();api.root_path=branch.get_path();set_multiplayer(api,branch.get_path());api.multiplayer_peer=peer
	var game=load("res://main.gd").new();game.name="Sonnenhain";game.konflux_preview_mode=true;branch.add_child(game)
	game.set_process(false);game.set_process_input(false)
	return game
func settle(count:int=16)->void:
	for i in count:await process_frame
func run()->void:
	var host:=WebSocketMultiplayerPeer.new();assert(host.create_server(31939)==OK)
	var server=session("MapServer",host);server.network_mode="host";server.dedicated_server_mode=true
	var pa:=WebSocketMultiplayerPeer.new();pa.create_client("ws://127.0.0.1:31939")
	var pb:=WebSocketMultiplayerPeer.new();pb.create_client("ws://127.0.0.1:31939")
	var actor=session("MapActor",pa);actor.network_mode="client";actor.level=40;actor.panel=""
	actor.player_pos=actor.WAYSTONES[0]+Vector2(0,140);actor.waystone_unlocked[1]=true
	var observer=session("MapObserver",pb);observer.network_mode="client"
	var deadline:=Time.get_ticks_msec()+10000
	while server.multiplayer.get_peers().size()<2:
		assert(Time.get_ticks_msec()<deadline);await process_frame
	actor.rpc_player_presence.rpc_id(1,actor.local_player_state());observer.rpc_player_presence.rpc_id(1,observer.local_player_state());await settle()
	var aid:int=actor.multiplayer.get_unique_id()
	actor.use_waystone();assert(actor.panel=="map")
	actor.click_map(actor.WaystoneMap.plaque(actor,1).get_center())
	var destination:Vector2=actor.waystone_arrival(1)
	await settle(30)
	assert(server.network_player_position(aid).distance_to(destination)<1,"server accepts destination without rubberband")
	var coords:Array=observer.remote_players[aid]["pos"]
	assert(Vector2(coords[0],coords[1]).distance_to(destination)<1,"observer sees teleport")
	actor.use_waystone();assert(actor.panel=="map")
	actor.click_map(actor.WaystoneMap.point(actor,0));await settle(30)
	assert(server.network_player_position(aid).distance_to(actor.waystone_arrival(0))<1,"return to village accepted")
	print("WAYSTONE_MAP_NETWORK_OK real WS map click / accepted travel / observer position / direct return to spawn")
	pa.close();pb.close();host.close()
	for branch in root.get_children():
		if branch.name in ["MapServer","MapActor","MapObserver"]:branch.queue_free()
	await settle(2);quit()
