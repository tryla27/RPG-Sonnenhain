extends SceneTree
func _initialize(): call_deferred("run")
func run():
	var g = load("res://main.gd").new()
	g.name = "Sonnenhain"
	g.konflux_preview_mode = true
	root.add_child(g)
	g.set_process(false)
	g.set_process_input(false)
	g.character_created = true
	g.player_uuid = "network-save-test"
	g.hero_name = "Netztest"
	g.class_id = 1
	g.gold = 34567
	g.add_item(g.make_item("Netzring A","ring",1,11,10))
	g.add_item(g.make_item("Netzring B","ring",1,17,10))
	g.toggle_equipment_item(g.inventory.size()-2)
	g.toggle_equipment_item(g.inventory.size()-1)
	var peer := WebSocketMultiplayerPeer.new()
	assert(peer.create_client(g.command_arg_value("--save-test-url=","ws://127.0.0.1:31876")) == OK)
	g.multiplayer.multiplayer_peer = peer
	g.network_mode = "client"
	var deadline := Time.get_ticks_msec()+12000
	while peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		if Time.get_ticks_msec() > deadline: quit(2); return
		await process_frame
	g.server_save.uuid = g.player_uuid
	g.server_save.token = "b".repeat(64)
	g.server_save.latest = g.capture_save_data()
	g.server_save.dirty = true
	g.rpc_zz_save_open.rpc_id(1,g.server_save.token,g.player_uuid)
	while g.server_save.revision < 1 or not g.server_save.ready or g.server_save.dirty:
		g.server_save.update(g)
		if Time.get_ticks_msec() > deadline:
			push_error(g.server_save.status); quit(3); return
		await process_frame
	assert(g.gold in [34567,34568] and g.equipped_ring2_uid >= 0)
	var initial_revision: int = g.server_save.revision
	# Every run must also persist a fresh revision, even if a previous test snapshot exists.
	g.gold = 34568
	g.server_save.latest = g.capture_save_data()
	g.server_save.dirty = true
	while g.server_save.revision <= initial_revision or g.server_save.dirty:
		g.server_save.flush(g)
		if Time.get_ticks_msec() > deadline: quit(6); return
		await process_frame
	initial_revision = g.server_save.revision
	# Real connection loss; reopen against persisted snapshot and private capability.
	peer.close()
	g.server_save.disconnected()
	await create_timer(0.4).timeout
	peer = WebSocketMultiplayerPeer.new()
	peer.create_client(g.command_arg_value("--save-test-url=","ws://127.0.0.1:31876"))
	g.multiplayer.multiplayer_peer = peer
	g.network_mode = "client"
	while peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		if Time.get_ticks_msec() > deadline: quit(4); return
		await process_frame
	g.gold = 1
	g.equipped_ring2_uid = -1
	g.server_save.latest = g.capture_save_data()
	g.server_save.dirty = false
	g.rpc_zz_save_open.rpc_id(1,g.server_save.token,g.player_uuid)
	while not g.server_save.ready:
		if Time.get_ticks_msec() > deadline: quit(5); return
		await process_frame
	assert(g.gold == 34568 and g.equipped_ring2_uid >= 0 and g.server_save.revision == initial_revision)
	print("SERVER_SAVE_NETWORK_OK: real WebSocket upload/acknowledgment, reconnect, server download, two-ring restoration revision=",initial_revision)
	peer.close()
	g.queue_free()
	await process_frame
	await process_frame
	quit()
