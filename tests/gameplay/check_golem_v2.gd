extends SceneTree
# Golem v2 (10.10.2026): Trefferzonen, Wegsuche im Himmelsgarten, 15 Minuten
# Pause (nicht im Testmodus), Brocken zerbröseln, Rücksetzen ohne Spieler,
# schmales Weltpaket außerhalb, gezieltes Neuzeichnen umgeworfener Bäume und
# Rechenzeit der Wegsuche.

const GolemBoss=preload("res://components/golem_boss.gd")

class Game extends "res://main.gd":
	var sounds:Array=[]
	func _ready()->void:pass
	func _process(_d:float)->void:pass
	func save_game()->void:pass
	func play_sound(n:String)->void:sounds.append(n)
	func play_world_sound(n:String,_p:Vector2)->void:sounds.append(n)

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("GOLEM_V2_FAIL "+label)

func _initialize()->void:call_deferred("run")

func the_golem(g)->Dictionary:
	for e in g.enemies:
		if GolemBoss.is_golem(e):return e
	return {}

func run()->void:
	var g:=Game.new()
	# Magier: keine zufälligen Krieger-Krits, damit die Zonen-Schäden fest sind.
	g.class_id=1
	g.reset_class_skills();g.character_created=true;g.level=40
	g.hp=g.max_hp()
	for i in g.QUESTS.size():g.quests.append({"state":0,"progress":0})
	for i in g.BORIN_QUESTS.size():g.borin_quests.append({"state":0,"progress":0})
	for i in g.WORLD_EVENTS.size():
		g.event_states.append(0);g.event_progress.append(0)

	# --- Trefferzonen ------------------------------------------------------
	var gp:=GolemBoss.ALTAR
	var u:=GolemBoss.visual_scale(GolemBoss.TYPE_BIG)
	var head_y:=gp.y+GolemBoss.HEAD_CENTER.y*u
	check(GolemBoss.shot_zone(gp,27,Vector2(gp.x-600,head_y),Vector2(gp.x-100,head_y))=="head","Schuss von der Seite in Kopfhöhe: Kopf")
	check(GolemBoss.shot_zone(gp,27,Vector2(gp.x-600,gp.y-40*u),Vector2(gp.x-100,gp.y-40*u))=="torso","Schuss in Rumpfhöhe: Rumpf")
	check(GolemBoss.shot_zone(gp,27,Vector2(gp.x-600,gp.y-6*u),Vector2(gp.x-100,gp.y-6*u))=="legs","Schuss in Fußhöhe: Beine")
	check(GolemBoss.shot_zone(gp,27,Vector2(gp.x-600,gp.y-300),Vector2(gp.x-450,gp.y-300))=="","noch nicht da: kein Treffer")
	check(GolemBoss.shot_zone(gp,27,Vector2(gp.x-600,gp.y-500),Vector2(gp.x+600,gp.y-500))=="","über dem Kopf vorbei: kein Treffer")
	check(GolemBoss.shot_zone(gp,27,Vector2(gp.x,gp.y+500),Vector2(gp.x,gp.y+20))=="head","von unten mittig auf den Kopf gezielt: Kopf")
	check(GolemBoss.zone_mult("head")>1.5 and GolemBoss.zone_mult("legs")<1.0 and is_equal_approx(GolemBoss.zone_mult("torso"),1.0),"Kopf ×1,6, Rumpf ×1, Beine ×0,75")
	# Echter Pfeil: Kopftreffer macht 1,6-fachen Schaden und zeigt "KOPF!".
	g.player_pos=gp+Vector2(-700,200)
	g.enemies.clear()
	var golem:Dictionary=g.golem_world.summon(g,1)
	golem["pos"]=gp;golem["golem"]["state"]="walk"
	g.enemies.append(golem)
	var hp0:float=float(golem["hp"])
	g.projectiles.append({"pos":Vector2(gp.x-170,head_y),"dir":Vector2.RIGHT,"speed":650.0,"life":2.0,"damage":100,"kind":3,"element":"","hits":[]})
	for i in 40:
		g.update_projectiles(1.0/60.0)
		if g.projectiles.is_empty():break
	var dealt:=hp0-float(golem["hp"])
	check(dealt>=150.0 and dealt<=170.0,"Kopftreffer ×1,6 (%s)" % dealt)
	var kopf:=false
	for e in g.effects:
		if str(e.get("text",""))=="KOPF!":kopf=true
	check(kopf,"KOPF! erscheint")
	hp0=float(golem["hp"])
	g.projectiles.append({"pos":Vector2(gp.x-420,gp.y-6*u),"dir":Vector2.RIGHT,"speed":650.0,"life":2.0,"damage":100,"kind":3,"element":"","hits":[]})
	for i in 40:
		g.update_projectiles(1.0/60.0)
		if g.projectiles.is_empty():break
	dealt=hp0-float(golem["hp"])
	check(dealt>=70.0 and dealt<=80.0,"Beintreffer ×0,75 (%s)" % dealt)

	# --- Wegsuche: Wand aus Brocken zwischen Golem und Spieler ----------------
	var start:=gp+Vector2(-900,0)
	var goal:=gp+Vector2(-200,0)
	golem["pos"]=start;golem["golem"]={"state":"walk","timer":0.0,"shield_cd":999.0,"throw_cd":999.0,"melee_cd":999.0,"screamed":true,"players":1}
	g.golem_world.boulders.clear()
	for k in range(-3,4):g.golem_world.boulders.append([start.x+300,start.y+k*70.0])
	g.player_pos=goal
	check(not g.golem_world.line_open(g,start,goal,GolemBoss.body_radius(27)),"Brockenwand versperrt den geraden Weg")
	var t0:=Time.get_ticks_usec()
	var path:Array=g.golem_world.find_path(g,start,goal,GolemBoss.body_radius(27))
	var path_ms:=(Time.get_ticks_usec()-t0)/1000.0
	check(not path.is_empty(),"Weg um die Wand gefunden (%d Punkte)" % path.size())
	print("GOLEM_V2_INFO find_path %.2f ms, nav_cells %d" % [path_ms,g.golem_world.nav_cells.size()])
	check(path_ms<120.0,"Wegsuche bleibt im Rechenbudget (%.1f ms)" % path_ms)
	var closest:=INF
	for i in 600:
		g.golem_world.update_golem(g,golem,[{"id":0,"pos":goal,"max_hp":100.0}],0.05)
		closest=minf(closest,Vector2(golem["pos"]).distance_to(goal))
	check(closest<200.0,"Golem kommt um die Wand herum zum Spieler (%.0f px)" % closest)
	for b in g.golem_world.boulders:
		check(Vector2(golem["pos"]).distance_to(Vector2(b[0],b[1]))>GolemBoss.BOULDER_RADIUS or g.golem_world.boulders.size()<7,"läuft nicht durch Brocken")

	# Völlig eingesperrt: nach dem Ausweichen bricht er durch.
	g.golem_world.boulders.clear()
	for k in 16:
		var a:=k*TAU/16.0
		g.golem_world.boulders.append([start.x+cos(a)*130.0,start.y+sin(a)*130.0])
	golem["pos"]=start;golem["golem"]={"state":"walk","timer":0.0,"shield_cd":999.0,"throw_cd":999.0,"melee_cd":999.0,"screamed":true,"players":1}
	var before:int=g.golem_world.boulders.size()
	for i in 400:g.golem_world.update_golem(g,golem,[{"id":0,"pos":goal,"max_hp":100.0}],0.05)
	check(g.golem_world.boulders.size()<before,"eingesperrt: zerschlägt Brocken (%d → %d)" % [before,g.golem_world.boulders.size()])
	check(Vector2(golem["pos"]).distance_to(start)>150.0,"eingesperrt: kommt frei")
	check(not golem["golem"].has("path") or GolemBoss.net_info(golem["golem"]).has("path")==false,"Wegdaten gehen nicht ins Weltpaket")
	# Nie aus dem Himmelsgarten heraus.
	check(g.region_at(Vector2(golem["pos"]))==12,"bleibt im Himmelsgarten")

	# --- Sieg: Brocken zerbröseln, 15 Minuten Pause, Testmodus darf ---------
	g.golem_world.boulders=[[gp.x+300,gp.y],[gp.x+400,gp.y]]
	g.golem_world.end_fight(true,1000.0)
	check(is_equal_approx(g.golem_world.cooldown_until,1900.0),"15 Minuten Pause nach dem Sieg")
	check(g.golem_world.crumble>0.0,"Brocken zerbröseln")
	g.enemies.clear()
	check(g.golem_world.summon_blocked(g.enemies,false,1000.0+60.0).contains("14:00"),"Altar nennt die Restzeit (%s)" % g.golem_world.summon_blocked(g.enemies,false,1060.0))
	check(g.golem_world.summon_blocked(g.enemies,true,1060.0)=="","Testmodus: keine Pause")
	check(g.golem_world.summon_blocked(g.enemies,false,1901.0)=="","nach 15 Minuten wieder frei")
	for i in 70:g.golem_world.update_world(g,0.05,true)
	check(g.golem_world.boulders.is_empty(),"nach 3 s sind die Brocken weg")
	var stored:=GolemBoss.new()
	stored.load_state(JSON.parse_string(JSON.stringify(g.golem_world.save_state())))
	check(is_equal_approx(stored.cooldown_until,1900.0),"Pause übersteht Neustart")
	# Neustart mit liegengebliebenen Brocken: sie zerbröseln auch dann.
	var leftover:=GolemBoss.new()
	leftover.load_state({"boulders":[[gp.x+200,gp.y],[gp.x+260,gp.y]],"trees":{}})
	check(leftover.crumble>0.0 and not leftover.fight_active,"Neustart: alte Brocken zerbröseln")
	for i in 70:leftover.update_world(g,0.05,true)
	check(leftover.boulders.is_empty(),"Neustart: Brocken nach 3 s weg")
	# Allein: Pause blockiert die Beschwörung am Altar, Testmodus nicht.
	g.golem_world.cooldown_until=Time.get_unix_time_from_system()+600.0
	g.player_pos=GolemBoss.ALTAR+Vector2(0,60)
	g.creative_mode=false
	g.try_golem_summon()
	check(the_golem(g).is_empty(),"Pause: kein Golem")
	g.creative_mode=true
	g.try_golem_summon()
	check(not the_golem(g).is_empty(),"Testmodus: Golem trotz Pause")
	g.creative_mode=false

	# --- Niemand im Himmelsgarten: nach 5 Minuten verschwindet er ------------
	g.player_pos=Vector2(2600,1500)
	check(g.golem_targets().is_empty(),"Spieler außerhalb")
	g.golem_world.boulders=[[gp.x+300,gp.y]]
	var wait_before:float=g.golem_world.cooldown_until
	for i in 310:g.golem_world.update_world(g,1.0,true)
	check(the_golem(g).is_empty() and not g.golem_world.fight_active,"Golem verschwindet ohne Spieler")
	check(is_equal_approx(g.golem_world.cooldown_until,wait_before),"ohne Sieg keine neue Pause")
	check(g.golem_world.boulders.is_empty(),"Brocken zerbröseln auch dann")

	# --- Schmales Weltpaket außerhalb des Himmelsgartens ---------------------
	check(GolemBoss.needs_full(GolemBoss.ALTAR) and not GolemBoss.needs_full(Vector2(2600,1500)),"volles Paket nur am Himmelsgarten")
	g.golem_world.fields=[{"pos":[1,2],"life":3.0,"next":0.1,"mult":1.0}]
	g.golem_world.cooldown_until=Time.get_unix_time_from_system()+300.0
	var lite:=g.golem_world.lite_snapshot()
	check(JSON.stringify(lite).length()<120,"schmal (%d Zeichen)" % JSON.stringify(lite).length())
	var client:=GolemBoss.new()
	client.fields=[{"pos":[0,0],"life":5.0}]
	client.apply_snapshot(JSON.parse_string(JSON.stringify(lite)),0.0)
	check(client.fields.is_empty() and client.cooldown_left()>290.0,"schmales Paket: Pause kommt an, alte Felder weg")
	var full:=g.golem_world.snapshot(0.0)
	full["trees"]={"5:6":99999999999.0}
	var changed:Array=client.apply_snapshot(JSON.parse_string(JSON.stringify(full)),0.0)
	check(changed==["5:6"],"geänderte Bäume einzeln gemeldet (%s)" % [changed])

	# --- Umgefallener Baum: nur seine Zelle wird neu berechnet ---------------
	g.decorative_tree_cache.clear()
	for tx in range(200,210):g.decorative_tree_in_cell(tx,130)
	var cached:=g.decorative_tree_cache.size()
	g.golem_trees_changed("203:130")
	check(g.decorative_tree_cache.size()==cached-1,"nur eine Zelle verworfen")

	g.free()
	if failures>0:
		push_error("GOLEM_V2_FAILURES %d" % failures)
		quit(1)
		return
	print("GOLEM_V2_OK")
	quit(0)
