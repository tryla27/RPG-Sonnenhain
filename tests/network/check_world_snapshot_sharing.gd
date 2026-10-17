extends SceneTree
## Weltpaket: Spieler mit demselben Ausschnitt bekommen ein gemeinsam kodiertes
## Paket (einmal packen statt je Spieler), verschiedene Ausschnitte eigene
## Pakete. Der interne Schlüssel wird nicht mitgesendet.
const WorldSnapshot=preload("res://components/world_snapshot.gd")
class Perf extends RefCounted:
	var skipped:=0;var count:=0;var encode_calls:=0
	func record_snapshot(_bytes:int,encode_us:int)->void:
		count+=1
		if encode_us>0:encode_calls+=1
class Sender extends RefCounted:
	var sent:Array=[]
	func rpc_id(peer:int,packet:Dictionary)->void:sent.append([peer,packet])
class Net extends RefCounted:
	var multiplayer_peer:MultiplayerPeer=null
class FakeGame extends RefCounted:
	var multiplayer:=Net.new()
	var server_performance:=Perf.new()
	var rpc_world_snapshot:=Sender.new()
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;push_error("WORLD_SNAPSHOT_SHARING_FAIL "+label)
func _initialize()->void:
	var enemies:Array=[]
	for i in 40:enemies.append({"uid":i,"type":1,"pos":[1000.0+i*20.0,1000.0],"hp":50.0,"max_hp":50.0})
	enemies.append({"uid":99,"type":1,"pos":[9000.0,9000.0],"hp":5.0,"max_hp":5.0})
	var base:={"protocol":1,"context":"world","enemies":enemies,"shots":[],"drops":[],"golem":{}}
	var near_a:=WorldSnapshot.for_peer(base,Vector2(1100,1000))
	var near_b:=WorldSnapshot.for_peer(base,Vector2(1150,1040))
	var far:=WorldSnapshot.for_peer(base,Vector2(9000,9000))
	check(near_a["_share_key"]==near_b["_share_key"],"gleicher Ausschnitt, gleicher Schlüssel")
	check(near_a["_share_key"]!=far["_share_key"],"anderer Ausschnitt, anderer Schlüssel")
	check(near_a["enemies"].size()==40 and far["enemies"].size()==1,"Nähefilter unverändert")
	check(WorldSnapshot.near(enemies,Vector2(9000,9000))==far["enemies"],"near() liefert dieselben Zeilen")
	var g:=FakeGame.new();var shared:={}
	for snap in [near_a,near_b,far]:WorldSnapshot.transmit(g,g.rpc_world_snapshot.sent.size()+2,snap,shared)
	var sent:Array=g.rpc_world_snapshot.sent
	check(sent.size()==3 and g.server_performance.count==3,"drei Pakete gesendet und gezählt")
	check(g.server_performance.encode_calls==2,"nur zweimal gepackt (%d)"%g.server_performance.encode_calls)
	check(is_same(sent[0][1],sent[1][1]),"gleiches Paket für gleichen Ausschnitt")
	for row in sent:
		var decoded:=WorldSnapshot.decode(row[1])
		check(not decoded.has("_share_key") and not row[1].has("_share_key"),"Schlüssel wird nicht gesendet")
	var first:=WorldSnapshot.decode(sent[0][1]);var last:=WorldSnapshot.decode(sent[2][1])
	check(first.get("enemies",[]).size()==40 and last.get("enemies",[]).size()==1,"Inhalt kommt vollständig an")
	# Ohne Zwischenspeicher (z. B. andere Aufrufer) bleibt das alte Verhalten.
	var plain:=FakeGame.new()
	WorldSnapshot.transmit(plain,7,base)
	check(plain.rpc_world_snapshot.sent.size()==1 and WorldSnapshot.decode(plain.rpc_world_snapshot.sent[0][1]).get("enemies",[]).size()==41,"Einzelsendung ohne Schlüssel")
	if failures>0:quit(1);return
	print("WORLD_SNAPSHOT_SHARING_OK")
	quit()
