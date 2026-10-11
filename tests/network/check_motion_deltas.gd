extends SceneTree
# Drei echte WebSocket-Sitzungen: vollständiges Profil, Bewegung und Golem-Musik.
const Snap=preload("res://components/world_snapshot.gd")
const Codec=preload("res://components/network_codec.gd")
const Boss=preload("res://components/golem_boss.gd")
class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_d:float)->void:pass
	func save_game()->void:pass
	func play_sound(_s:String)->void:pass
	func play_world_sound(_s:String,_p:Vector2)->void:pass
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;push_error("MOTION_DELTA_FAIL "+label)
func session(label:String,peer:MultiplayerPeer)->Game:
	var branch:=Node.new();branch.name=label;root.add_child(branch)
	var api:=SceneMultiplayer.new();api.root_path=branch.get_path()
	set_multiplayer(api,branch.get_path());api.multiplayer_peer=peer
	var game:=Game.new();game.name="Game";branch.add_child(game)
	game.character_created=true;game.panel="";game.reset_class_skills()
	game.player_pos=Boss.ALTAR
	return game
func settle()->void:
	for frame in 12:await process_frame
func _initialize()->void:call_deferred("run")
func run()->void:
	var host:=WebSocketMultiplayerPeer.new();Snap.widen(host)
	if host.create_server(31991)!=OK:check(false,"lokaler Server");quit(1);return
	var server:=session("Authority",host);server.network_mode="host";server.dedicated_server_mode=true
	var ap:=WebSocketMultiplayerPeer.new();Snap.widen(ap)
	var bp:=WebSocketMultiplayerPeer.new();Snap.widen(bp)
	check(ap.create_client("ws://127.0.0.1:31991")==OK,"Client A")
	check(bp.create_client("ws://127.0.0.1:31991")==OK,"Client B")
	var a:=session("A",ap);a.network_mode="client"
	var b:=session("B",bp);b.network_mode="client"
	var deadline:=Time.get_ticks_msec()+4000
	while server.multiplayer.get_peers().size()<2 and Time.get_ticks_msec()<deadline:await process_frame
	if server.multiplayer.get_peers().size()!=2:check(false,"Verbindungen");quit(1);return
	b.rpc_player_state.rpc_id(1,b.local_player_state());await settle()
	var codec:=Codec.new()
	var profile:Dictionary=a.local_player_state()
	profile["name"]="DeltaMage";profile["class"]=1;profile["head"]=2;profile["level"]=20
	profile["active_quests"]=[[0,1]]
	a.rpc_player_state.rpc_id(1,codec.motion_packet(profile,0));await settle()
	var id:=ap.get_unique_id()
	check(b.remote_players.has(id),"Profil beim anderen Spieler")
	profile["pos"]=[Boss.ALTAR.x+10,Boss.ALTAR.y]
	var delta:=codec.motion_packet(profile,50)
	check(not delta.has("head"),"nur Bewegung übertragen")
	a.rpc_player_state.rpc_id(1,delta);await settle()
	var received:Dictionary=b.remote_players.get(id,{})
	check(received.get("head",-1)==2 and received.get("name","")=="DeltaMage","Aussehen und Name bleiben nach Relay")
	check(received.get("active_quests",[])==[[0,1]],"Questdaten bleiben auf dem Server / Relay")
	check(absf(float(received.get("pos",[0,0])[0])-Boss.ALTAR.x-10)<1,"Bewegung kommt an")
	server.golem_world.fight_active=true
	for i in 50:
		var e:Dictionary=server.make_enemy(27 if i==0 else 25,Boss.ALTAR+Vector2(i*3,0))
		e["uid"]=100+i;server.enemies.append(e)
	server.push_world_snapshot();await settle()
	check(a.enemies.size()==50 and b.enemies.size()==50,"komprimiertes Weltpaket bei beiden")
	check(a.desired_music_theme()=="boss_golem" and b.desired_music_theme()=="boss_golem","Musikthema bei beiden Spielern ab Kampfzustand")
	host.close();ap.close();bp.close()
	print("MOTION_DELTA_NETWORK failures=",failures);quit(1 if failures else 0)
