extends SceneTree
const Codec=preload("res://components/network_codec.gd")
const Snap=preload("res://components/world_snapshot.gd")
class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_d:float)->void:pass
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;push_error("COMPACT_UPDATES_FAIL "+label)
func _initialize()->void:
	var g:=Game.new()
	var codec:=Codec.new()
	var full:Dictionary=g.local_player_state()
	var initial:=codec.motion_packet(full,0)
	check(initial["_full"],"initial vollständiges Profil")
	var moved:=full.duplicate(true);moved["pos"]=[15000.0,8650.0]
	var small:=codec.motion_packet(moved,50)
	check(not small["_full"] and not small.has("active_quests"),"Bewegung ohne unveränderte Quests")
	check(Codec.merge_player_state(full,small)==moved,"Profil bleibt bei Bewegung vollständig")
	var refresh:=codec.motion_packet(moved,1000)
	check(refresh["_full"] and refresh.has("active_quests"),"verlorene Änderung nach einer Sekunde geheilt")
	var base:Dictionary={"protocol":g.NETWORK_PROTOCOL_VERSION,"context":"world","instance_id":"world","enemies":[],"shots":[],"drops":[],"golem":g.golem_world.snapshot(0.0)}
	for i in 100:
		base["enemies"].append({"uid":i,"type":27 if i==0 else 25,"pos":[14900.0+i,8650.0],"hp":100.0,"max_hp":100.0,"facing":[0.0,1.0],"walking":true,"attack_state":{},"golem":{"state":"walk","timer":.1} if i==0 else {}})
	var started:=Time.get_ticks_usec()
	var packet:=Snap.encode(base)
	var encode_us:=Time.get_ticks_usec()-started
	var decoded:=Snap.decode(packet)
	check(decoded==base,"Weltpaket verlustfrei einschließlich Golem")
	var old_bytes:=var_to_bytes(base).size();var new_bytes:=var_to_bytes(packet).size()
	check(new_bytes<old_bytes*.4,"große Pakete deutlich kleiner")
	check(var_to_bytes(small).size()<var_to_bytes(full).size()*.4,"Bewegung deutlich kleiner")
	check(Snap.decode({"_wire":PackedByteArray(),"_size":Snap.MAX_WIRE_BYTES+1}).is_empty(),"begrenzte Dekompression")
	print("NETWORK_BENCHMARK full_player=",var_to_bytes(full).size()," motion=",var_to_bytes(small).size()," world_before=",old_bytes," world_after=",new_bytes," encode_us=",encode_us)
	g.free();print("COMPACT_UPDATES failures=",failures);quit(1 if failures else 0)
