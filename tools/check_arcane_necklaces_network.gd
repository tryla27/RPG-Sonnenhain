extends SceneTree
const Neck=preload("res://components/arcane_necklaces.gd")
func _initialize()->void:call_deferred("run")
func session(label:String,peer:MultiplayerPeer):
	var branch:=Node.new();branch.name=label;root.add_child(branch)
	var api:=SceneMultiplayer.new();api.root_path=branch.get_path();set_multiplayer(api,branch.get_path());api.multiplayer_peer=peer
	var game=load("res://main.gd").new();game.name="Sonnenhain";game.konflux_preview_mode=true;branch.add_child(game)
	game.set_process(false);game.set_process_input(false)
	return game
func settle(count:int=12)->void:
	for i in count:await process_frame
func run()->void:
	var host:=WebSocketMultiplayerPeer.new();assert(host.create_server(31936)==OK)
	var server=session("NeckServer",host);server.network_mode="host";server.dedicated_server_mode=true
	var pa:=WebSocketMultiplayerPeer.new();pa.create_client("ws://127.0.0.1:31936")
	var pb:=WebSocketMultiplayerPeer.new();pb.create_client("ws://127.0.0.1:31936")
	var actor=session("NeckActor",pa);actor.network_mode="client";actor.level=40;actor.player_pos=Vector2(2500,900)
	var other=session("NeckOther",pb);other.network_mode="client";other.level=40;other.player_pos=Vector2(2520,900)
	var until:=Time.get_ticks_msec()+10000
	while server.multiplayer.get_peers().size()<2:
		assert(Time.get_ticks_msec()<until);await process_frame
	actor.inventory.clear();actor.add_item(actor.make_item(Neck.NAMES[5],"necklace",3,0,10));actor.equipped_necklace_uid=int(actor.inventory[0]["uid"])
	other.inventory.clear();other.add_item(other.make_item(Neck.NAMES[0],"necklace",1,0,10));other.equipped_necklace_uid=int(other.inventory[0]["uid"])
	actor.rpc_player_presence.rpc_id(1,actor.local_player_state());other.rpc_player_presence.rpc_id(1,other.local_player_state());await settle()
	var aid:int=actor.multiplayer.get_unique_id();var bid:int=other.multiplayer.get_unique_id()
	assert(server.necklace_visual(aid)==5 and server.necklace_visual(bid)==0)
	assert(other.remote_players[aid]["necklace"]==5,"other players receive visible equipment")
	server.enemies=[server.make_enemy(0,Vector2(2520,1000))];server.enemies[0]["hp"]=10000.0
	server.damage_enemy(0,10,Vector2.ZERO,false,"",aid);server.damage_enemy(0,10,Vector2.ZERO,false,"",aid);await settle()
	assert(actor.necklaces.state(0,5,Time.get_ticks_msec())["hits"]==2,"server mirrors hunt progress to its owner")
	server.damage_enemy(0,10,Vector2.ZERO,false,"",bid)
	assert(server.enemies[0]["necklace_frost_mult"]==0.8)
	assert(server.necklaces.state(aid,5,Time.get_ticks_msec())["hits"]==2,"other player cannot advance the hunt")
	var before:float=server.enemies[0]["hp"]
	server.damage_enemy(0,10,Vector2.ZERO,false,"",aid);await settle()
	assert(server.enemies[0]["hp"]<before-10 and actor.necklaces.state(0,5,Time.get_ticks_msec())["hits"]==0)
	server.enemies=[server.make_enemy(13,Vector2(2520,1000))];server.drops.clear()
	server.send_server_enemy_reward(aid,server.enemies[0])
	var found:=0
	for drop in server.drops:
		if drop.has("item") and Neck.index(drop["item"])==4:
			found+=1;assert(int(drop["reserved_class"])==-1)
	assert(found==1,"server boss necklace is unrestricted")
	print("ARCANE_NECKLACES_NETWORK_OK authoritative effects, wearer progress, observer appearance, independent attackers, unrestricted server drops")
	pa.close();pb.close();host.close()
	for branch in root.get_children():
		if branch.name in ["NeckServer","NeckActor","NeckOther"]:branch.queue_free()
	await settle(2);quit()
