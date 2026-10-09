extends SceneTree
class Game extends "res://main.gd":
	var dust_calls:=0
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
	func play_sound(name:String)->void:
		if name=="mushroom_poison":dust_calls+=1
func _initialize()->void:call_deferred("run")
func run()->void:
	var game:=Game.new();root.add_child(game)
	game.network_mode="client";game.panel="";game.player_pos=Vector2(2300,800);game.interior_id=-1
	var enemy={"uid":19,"type":2,"pos":[2300.0,800.0],"facing":[1.0,0.0],"attack_state":{"id":2,"fired":true,"age":.86,"dir":[1.0,0.0],"ability":{"id":"giftstaub","shape":"cloud","range":84.0}}}
	var snapshot={"protocol":game.NETWORK_PROTOCOL_VERSION,"context":"world","enemies":[enemy],"shots":[]}
	game.rpc_world_snapshot(snapshot.duplicate(true));game.rpc_world_snapshot(snapshot.duplicate(true))
	assert(game.dust_calls==1,"repeated snapshots cannot replay poison hiss")
	enemy["attack_state"]["id"]=3;enemy["attack_state"]["fired"]=false
	game.rpc_world_snapshot(snapshot.duplicate(true));assert(game.dust_calls==1)
	enemy["attack_state"]["fired"]=true
	game.rpc_world_snapshot(snapshot.duplicate(true));assert(game.dust_calls==2)
	game.dedicated_server_mode=true;game.play_mushroom_poison(game.player_pos)
	assert(game.dust_calls==2,"dedicated server stays silent")
	game.dedicated_server_mode=false;game.play_mushroom_poison(game.player_pos+Vector2(700,0))
	assert(game.dust_calls==2,"distant mushroom stays silent")
	var hiss:=load("res://audio/sfx/mushroom_spores_clean.wav") as AudioStreamWAV
	assert(hiss!=null and hiss.get_length()>1.18 and hiss.get_length()<1.22)
	game.queue_free();await process_frame
	print("MUSHROOM_SOUND_OK actual poison release / repeated snapshots once / no windup sound / distance limit / dedicated server silent / 1.2s hiss")
	quit()
