extends SceneTree
## Lokale Zwei-Spieler-Messung gegen einen echten dedizierten Server.
## Ein Prozess = ein Spieler. Misst, wie gleichmäßig die Bewegung des anderen
## Spielers und die Weltpakete ankommen. Optional simuliert --hitch-ms ein
## blockiertes Clientbild (z. B. Modellaufbau), um dessen Wirkung auf den
## anderen Spieler zu sehen. Kein Konto, keine Live-Spielstände.
##
## Aufruf (Server vorher starten, siehe docs/SERVER_LAGS_3D.md):
##   godot --headless --path . -s tools/benchmark_coop_network.gd -- \
##     --url=ws://127.0.0.1:31890 --name=A --seconds=40 [--hitch-ms=190 --hitch-every=2]

class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func _draw()->void:pass
	func save_game()->void:pass

func _initialize()->void:call_deferred("run")

func arg(prefix:String,fallback:String)->String:
	for raw in OS.get_cmdline_user_args():
		if raw.begins_with(prefix):return raw.substr(prefix.length())
	return fallback

func percentile(values:Array,part:float)->float:
	if values.is_empty():return 0.0
	var ordered:=values.duplicate();ordered.sort()
	return float(ordered[mini(ordered.size()-1,ceili(ordered.size()*part)-1)])

func summary(gaps:Array)->Dictionary:
	var over:=0
	for gap in gaps:
		if float(gap)>150.0:over+=1
	return {"count":gaps.size(),"p50_ms":percentile(gaps,.5),"p95_ms":percentile(gaps,.95),"p99_ms":percentile(gaps,.99),"max_ms":percentile(gaps,1.0),"over_150_ms":over}

func run()->void:
	var label:=arg("--name=","A")
	var seconds:=float(arg("--seconds=","40"))
	var hitch_ms:=int(arg("--hitch-ms=","0"))
	var hitch_every:=float(arg("--hitch-every=","2"))
	var peer:=WebSocketMultiplayerPeer.new()
	if peer.create_client(arg("--url=","ws://127.0.0.1:31890"))!=OK:quit(2);return
	var g:=Game.new();g.name="Sonnenhain";g.konflux_preview_mode=true
	root.add_child(g);g.set_process_input(false)
	g.multiplayer.multiplayer_peer=peer;g.network_mode="client"
	g.character_created=true;g.panel="";g.hero_name="Last"+label;g.player_uuid="coop-bench-"+label
	g.class_id=0 if label=="A" else 2;g.level=20
	var deadline:=Time.get_ticks_msec()+12000
	while peer.get_connection_status()!=MultiplayerPeer.CONNECTION_CONNECTED:
		if Time.get_ticks_msec()>deadline:printerr("COOP_BENCH keine Verbindung");quit(3);return
		await process_frame
	var base:=Vector2(3650,2650)+(Vector2.ZERO if label=="A" else Vector2(0,120))
	var started:=Time.get_ticks_msec();var last_frame:=started
	var sync_clock:=0.0;var hitch_clock:=0.0;var hitches:=0
	var other_ticks:Dictionary={};var other_gaps:Array=[];var other_last:Dictionary={}
	var reply_last:=0;var reply_gaps:Array=[];var frame_gaps:Array=[]
	while Time.get_ticks_msec()-started<seconds*1000.0:
		await process_frame
		var now:=Time.get_ticks_msec();var delta:=float(now-last_frame)/1000.0
		frame_gaps.append(now-last_frame);last_frame=now
		# Hin und her laufen: 6 s für 520 Welteinheiten, wie normales Laufen.
		var phase:=fmod(float(now-started)/6000.0,2.0)
		g.player_pos=base+Vector2(520.0*(phase if phase<1.0 else 2.0-phase),0)
		g.facing=Vector2.RIGHT if phase<1.0 else Vector2.LEFT
		g.world_time+=delta
		sync_clock-=delta
		if sync_clock<=0.0:sync_clock=0.05;g.push_player_state()
		# Ankunft neuer Zustände des anderen Spielers (state_tick vom Server).
		for other in g.remote_players:
			var tick:=int(g.remote_players[other].get("state_tick",0))
			if tick!=int(other_ticks.get(other,-1)):
				if other_last.has(other):other_gaps.append(now-int(other_last[other]))
				other_ticks[other]=tick;other_last[other]=now
		if g.server_last_reply_ms!=reply_last:
			if reply_last>0:reply_gaps.append(g.server_last_reply_ms-reply_last)
			reply_last=g.server_last_reply_ms
		if hitch_ms>0:
			hitch_clock+=delta
			if hitch_clock>=hitch_every:hitch_clock=0.0;hitches+=1;OS.delay_msec(hitch_ms)
	# Die ersten 2 s (Verbindungsaufbau) nicht werten.
	var report:={"name":label,"seconds":seconds,"hitch_ms":hitch_ms,"hitches":hitches,
		"other_player_updates":summary(other_gaps.slice(40)),
		"world_snapshots":summary(reply_gaps.slice(20)),
		"own_frames":summary(frame_gaps.slice(120)),
		"mobs_seen":g.enemies.size()}
	print("COOP_BENCH ",JSON.stringify(report))
	peer.close();g.queue_free();await process_frame;quit()
