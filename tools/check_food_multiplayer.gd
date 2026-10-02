extends SceneTree

class TestGame:
	extends "res://main.gd"
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func _draw()->void:pass
	func save_game()->void:pass

func _initialize()->void:call_deferred("run")
func session(label:String,peer:MultiplayerPeer):
	var branch:=Node.new();branch.name=label;root.add_child(branch)
	var api:=SceneMultiplayer.new();api.root_path=branch.get_path();set_multiplayer(api,branch.get_path());api.multiplayer_peer=peer
	var game=TestGame.new();game.name="Sonnenhain";game.konflux_preview_mode=true;branch.add_child(game)
	game.network_mode="client";game.character_created=true;game.panel="";game.reset_class_skills()
	return game
func settle(count:int=12)->void:
	for frame in count:await process_frame
func run()->void:
	var host:=WebSocketMultiplayerPeer.new();assert(host.create_server(31939)==OK)
	var server=session("Authority",host);server.network_mode="host";server.dedicated_server_mode=true
	var left_peer:=WebSocketMultiplayerPeer.new();assert(left_peer.create_client("ws://127.0.0.1:31939")==OK)
	var right_peer:=WebSocketMultiplayerPeer.new();assert(right_peer.create_client("ws://127.0.0.1:31939")==OK)
	var left=session("Left",left_peer);var right=session("Right",right_peer)
	var deadline:=Time.get_ticks_msec()+10000
	while server.multiplayer.get_peers().size()<2:
		if Time.get_ticks_msec()>deadline:quit(2);return
		await process_frame
	var a:=left_peer.get_unique_id();var b:=right_peer.get_unique_id()
	server.food_system.configure(server);left.food_system.configure(left);right.food_system.configure(right)
	assert(server.food_system.plants.size()==36 and left.food_system.regional_props(left).size()==36)
	for region in range(1,13):
		var candidates:Array=server.food_system.plants.filter(func(row):return server.region_at(row["point"])==region)
		assert(candidates.size()==3)
		var first:Dictionary=candidates[0];var second:Dictionary=candidates[1]
		var point:Vector2=first["point"];var point2:Vector2=second["point"]
		left.player_pos=point+Vector2(0,70);right.player_pos=left.player_pos
		server.remote_players[a]={"pos":[left.player_pos.x,left.player_pos.y],"context":"world","instance_id":"world"}
		server.remote_players[b]={"pos":[right.player_pos.x,right.player_pos.y],"context":"world","instance_id":"world"}
		var accepted:Vector2=server.food_system.accepted_move(server,left.player_pos,point,15)
		assert(accepted.distance_to(point+Vector2(0,8))>=server.FoodSystem.BODY_RADIUS+15-.1)
		left.player_pos=point+Vector2(0,20);right.player_pos=left.player_pos
		server.remote_players[a]["pos"]=[left.player_pos.x,left.player_pos.y];server.remote_players[b]["pos"]=[right.player_pos.x,right.player_pos.y]
		var before:int=left.inventory.size();left.request_server_food_harvest(server.FoodSystem.key(point));await settle()
		assert(left.inventory.size()==before+1 and int(left.inventory.back()["count"])==3)
		assert(not left.food_system.ready_at(point,Time.get_unix_time_from_system()))
		assert(not right.food_system.ready_at(point,Time.get_unix_time_from_system()))
		var right_before:int=right.inventory.size();right.request_server_food_harvest(server.FoodSystem.key(point));await settle()
		assert(right.inventory.size()==right_before)
		server.remote_players[b]["pos"]=[point2.x,point2.y+20];right.player_pos=point2+Vector2(0,20)
		right.request_server_food_harvest(server.FoodSystem.key(point2));await settle()
		assert(right.inventory.size()==right_before+1)
	server.food_system.harvested.clear();left.food_system.harvested.clear()
	var protected:Dictionary=server.food_system.plants[0]
	server.remote_players[a]["pos"]=[protected["point"].x+500,protected["point"].y+500]
	var count_before:int=left.inventory.size();left.request_server_food_harvest(server.FoodSystem.key(protected["point"]));await settle()
	assert(left.inventory.size()==count_before and server.food_system.ready_at(protected["point"],Time.get_unix_time_from_system()))
	print("FOOD_MULTIPLAYER_OK maps1-12 visible bodies, authoritative distance, shared cooldown, race-safe harvest and rewards over real WebSocket")
	host.close();left_peer.close();right_peer.close()
	for game in [server,left,right]:game.sound_streams.clear();game.get_parent().queue_free()
	await settle(2);quit()

