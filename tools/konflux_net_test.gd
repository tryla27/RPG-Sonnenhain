extends "res://main.gd"
var elapsed:=0.0
var joined:=false
var sent:=false
var saw_damage:=false
var entered_at:=0.0
var saw_peer:=false
var returned := false
func _ready() -> void:
	super._ready()
	creative_mode=true
	hero_name=command_arg_value("--test-name=","A")
	character_created=true
	level=40
	class_id=2
	player_pos=KonfluxMap.ENTRANCE
	panel=""
	var peer:=WebSocketMultiplayerPeer.new()
	peer.create_client(command_arg_value("--test-url=","ws://127.0.0.1:27845"))
	multiplayer.multiplayer_peer=peer
	network_mode="client"
func _process(delta: float) -> void:
	elapsed+=delta
	if remote_players.size()>0: saw_peer=true
	if not joined and elapsed>1 and multiplayer.multiplayer_peer.get_connection_status()==MultiplayerPeer.CONNECTION_CONNECTED:
		push_player_state()
		rpc_konflux_room.rpc_id(1,true,-1)
		joined=true
	if konflux.active:
		if entered_at==0:
			entered_at=elapsed
			print("KONFLUX_NET_ENTER ",hero_name)
		if elapsed-entered_at<6.7:
			move_with_collision(Vector2(205,0)*delta)
		elif elapsed-entered_at>9.5 and elapsed-entered_at<16.3:
			move_with_collision(Vector2(-205,0)*delta)
		elif elapsed-entered_at>16.5 and not returned:
			returned = true
			rpc_konflux_room.rpc_id(1,false,-1,true)
		elif hero_name=="A" and not sent:
			sent=true
			rpc_konflux_attack.rpc_id(1,0,[1.0,0.0]) # wrong class: must be denied
			rpc_konflux_attack.rpc_id(1,17,[1.0,0.0]) # wrong class: must be denied
			rpc_konflux_attack.rpc_id(1,31,[1.0,0.0])
			rpc_konflux_attack.rpc_id(1,-1,[0.0,1.0])
		if hp<max_hp() and elapsed-entered_at>7.0:
			saw_damage=true
			print("KONFLUX_NET_DAMAGE ",hero_name," hp=",hp)
		if elapsed>entered_at+6.8 and elapsed<entered_at+9.4 and hero_name=="A":
			attack_timer=maxf(0,attack_timer-delta)
			if attack_timer<=0:
				attack_timer=0.6
				rpc_konflux_attack.rpc_id(1,25,[0.0,1.0])
		if hero_name=="B" and elapsed-entered_at>6.7 and elapsed-entered_at<7.2:
			move_with_collision(Vector2(0,100)*delta)
		konflux.update(self,delta)
	else:
		push_player_state()
	if elapsed>20:
		var ok: bool=returned and not konflux.active and player_pos.distance_to(WAYSTONES[0]+Vector2(0,105))<10 and saw_peer and (hero_name=="A" or saw_damage)
		print("KONFLUX_NET_RESULT ",hero_name," peers=",remote_players.size()," active=",konflux.active," damaged=",saw_damage," ok=",ok)
		get_tree().quit(0 if ok else 1)
