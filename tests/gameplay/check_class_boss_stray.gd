extends SceneTree
# Ein Klassenboss außerhalb seines Felds (alter Platz, festgefahren) darf den
# Spawn im eigenen Feld nicht blockieren. Gemeldet von Angelo: Dunkler
# Arkanhüter fehlte nach dem Versetzen ins Kristallmoor, nur das Feld war da.

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("CLASS_BOSS_STRAY_FAIL "+label)

func _initialize()->void:call_deferred("run")

func boss_positions(g,type:int)->Array:
	var out:=[]
	for e in g.enemies:
		if int(e["type"])==type:out.append(Vector2(e["pos"]))
	return out

func run()->void:
	var g=load("res://main.gd").new()
	g.dedicated_server_mode=true
	g.network_mode="host"
	var site:Vector2=g.CLASS_BOSS_SITES[1]
	g.remote_players={7:{"context":"world","instance_id":"world","pos":[site.x,site.y+250],"level":40,"hp":500,"class":0}}
	# Streuner vom alten Platz (Sternenbruchtor) mit vollem Leben.
	var stray:Dictionary=g.make_enemy(13,Vector2(9700,6500))
	stray["hp"]=999.0;stray["context"]="world"
	g.enemies.append(stray)
	g.spawn_dedicated_bosses()
	var at:=boss_positions(g,13)
	check(at.size()==1,"genau ein Arkanhüter (%d)" % at.size())
	check(at.size()==1 and at[0].distance_to(site)<1.0,"Arkanhüter steht im eigenen Feld")
	# Boss im eigenen Feld bleibt, es kommt kein zweiter.
	g.spawn_dedicated_bosses()
	check(boss_positions(g,13).size()==1,"kein zweiter Boss")
	g.free()

	# Allein (ohne Server) dasselbe.
	var o=load("res://main.gd").new()
	o.player_pos=site+Vector2(0,250)
	var stray2:Dictionary=o.make_enemy(13,Vector2(9700,6500))
	stray2["hp"]=999.0
	o.enemies.append(stray2)
	o.spawn_nearby_boss()
	var off:=boss_positions(o,13)
	check(off.size()==1 and off[0].distance_to(site)<1.0,"allein: Arkanhüter im eigenen Feld")
	o.free()
	if failures>0:
		print("CLASS_BOSS_STRAY_FAILED ",failures)
		quit(1)
		return
	print("CLASS_BOSS_STRAY_OK stray class bosses no longer block the arena spawn")
	quit()
