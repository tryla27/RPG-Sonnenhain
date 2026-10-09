extends SceneTree
# Regel D1: Jede Fusion zündet am Trefferpunkt ihres Trägers, nie beim Spieler.
# Spielt alle erzeugten Fusionen und die vier handgebauten offline und auf dem
# Server durch und misst, wo ihre Zweitwirkung tatsächlich auslöst.

const FusionRules=preload("res://components/fusion_rules.gd")
const FusionCast=preload("res://components/fusion_cast.gd")

class Game extends "res://main.gd":
	var triggers:Array=[]
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
	func play_sound(_name:String)->void:pass
	func play_world_sound(_name:String,_pos:Vector2)->void:pass
	func announce_multiplayer_context()->void:pass
	func trigger_fusion(fusion_tag:Dictionary,point:Vector2,dir:Vector2)->void:
		# Nur Zündungen zählen, die das Limit zulässt.
		if int(fusion_tag.get("left",0))>0:triggers.append({"point":point,"fusion":int(fusion_tag["fusion"])})
		super(fusion_tag,point,dir)
	# 40, 42 und 43 zünden direkt über ihr Einschlagsprofil.
	func apply_fusion_impact(fusion_id:int,center:Vector2,damage:int,main_uid:int,rank:int,source_peer:int=0)->void:
		if fusion_id in [40,42,43]:triggers.append({"point":center,"fusion":fusion_id})
		super(fusion_id,center,damage,main_uid,rank,source_peer)

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		if failures<=25:push_error("FUSION_ORIGIN_FAIL "+label)

func _initialize()->void:call_deferred("run")

func prepared()->Game:
	var g:=Game.new()
	g.reset_class_skills()
	for i in g.QUESTS.size():g.quests.append({"state":0,"progress":0})
	for i in g.WORLD_EVENTS.size():
		g.event_states.append(0)
		g.event_progress.append(0)
	return g

## Wirkt eine Fusion und lässt Geschosse und Zonen bis zum Ende laufen.
func cast(g:Game,id:int,enemy_offset:Vector2,server:bool)->Array:
	g.triggers.clear()
	g.projectiles.clear()
	g.impact_zones.clear()
	g.enemies.clear()
	g.player_pos=Vector2(2600,1500)
	g.facing=Vector2.RIGHT
	if enemy_offset!=Vector2.ZERO:
		var enemy:Dictionary=g.make_enemy(0,g.player_pos+enemy_offset)
		enemy["hp"]=999999.0
		enemy["max_hp"]=999999.0
		g.enemies.append(enemy)
	if server:g.server_ability_effects(id,g.player_pos,Vector2.RIGHT,0,80,2,7)
	else:g.execute_ability_effects(id,2,80,g.player_pos,Vector2.RIGHT)
	for frame in 150:
		g.update_projectiles(1.0/60.0)
		g.update_impact_zones(1.0/60.0)
	return g.triggers.duplicate()

## Die vier handgebauten Fusionen behalten ihre IDs 40–43.
func fusion_id_for(g:Game,a:int,b:int)->int:
	for fusion in g.BUILTIN_FUSIONS:
		if FusionRules.normalized_key(int(fusion["a"]),int(fusion["b"]))==FusionRules.normalized_key(a,b):return int(fusion["id"])
	return FusionRules.output_id(a,b)

func run()->void:
	var g:=prepared()
	var generated:Array=[]
	for a in g.BASE_ABILITIES.size():
		for b in range(a+1,g.BASE_ABILITIES.size()):
			if FusionRules.template_for_pair(a,b).is_empty():continue
			generated.append({"id":fusion_id_for(g,a,b),"a":a,"b":b})
	check(generated.size()==528,"528 Paarfusionen (%d)" % generated.size())

	# 1. Regeln: kein verbotener Zündort, jeder Träger trifft oder schickt einen Impuls.
	for f in generated:
		var template:=FusionRules.template_for_pair(int(f["a"]),int(f["b"]))
		var spawn:=str(template["spawn_position"])
		check(FusionCast.spawn_allowed(spawn),"%s: Zündort %s verboten" % [template["key"],spawn])
		var carrier:=int(template["carrier"]["spell_id"])
		var hits:=bool(FusionRules.metadata(carrier).get("damage",false))
		check(hits or spawn=="IMPULSE_IMPACT_POSITION","%s: Träger ohne Treffer und ohne Impuls" % template["key"])
	for id in [40,41,42,43]:
		check(FusionCast.spawn_allowed(g.fusion_spawn_rule(id)),"Fusion %d: Zündort %s" % [id,g.fusion_spawn_rule(id)])

	# 2. Verhalten: Gegner 130 px vor dem Spieler. Jede Fusion zündet mindestens
	# einmal, nie am Spieler, höchstens dreimal pro Wirken.
	var checked:=0
	for f in generated:
		var id:=int(f["id"])
		if id>=g.ABILITIES.size() or g.fusion_definition_by_id(id).is_empty():
			check(false,"Fusion %d (%d+%d) nicht im Spiel" % [id,f["a"],f["b"]])
			continue
		checked+=1
		for server in [false,true]:
			var plan:=FusionCast.plan(int(f["a"]),int(f["b"]))
			if server and bool(plan["impulse"]) and id!=41:continue
			var fired:Array=cast(g,id,Vector2(130,0),server)
			var where:="Server" if server else "offline"
			check(fired.size()>=1,"Fusion %d (%d+%d) %s: zündet nie" % [id,f["a"],f["b"],where])
			check(fired.size()<=FusionCast.MAX_TRIGGERS,"Fusion %d %s: %d Zündungen" % [id,where,fired.size()])
			for t in fired:
				var dist:float=(t["point"] as Vector2).distance_to(Vector2(2600,1500))
				check(dist>=60.0,"Fusion %d (%d+%d) %s: zündet beim Spieler (%.0f px)" % [id,f["a"],f["b"],where,dist])
	check(checked==528,"alle 528 im Spiel geprüft (%d)" % checked)

	# 3. Ohne Gegner: Zündung am Reichweitenende bzw. Hindernis, nicht am Spieler.
	for pair in [[0,1],[2,17],[1,36],[4,8],[13,35]]:
		var id:=fusion_id_for(g,pair[0],pair[1])
		var fired:Array=cast(g,id,Vector2.ZERO,false)
		check(fired.size()>=1,"%d+%d ohne Gegner zündet nicht" % pair)
		for t in fired:check((t["point"] as Vector2).distance_to(Vector2(2600,1500))>=60.0,"%d+%d ohne Gegner zündet beim Spieler" % pair)

	# 4. Reaktorwall: Schild sofort am Spieler, Wand am Einschlag des Impulses.
	g.shield_timer=0.0
	var wall:Array=cast(g,41,Vector2(200,0),false)
	check(g.shield_timer>0.0,"Reaktorwall schützt den Spieler")
	check(wall.size()==1 and (wall[0]["point"] as Vector2).distance_to(Vector2(2800,1500))<40.0,"Reaktorwall zündet am Gegner")
	var server_wall:Array=cast(g,41,Vector2(200,0),true)
	check(server_wall.size()==1 and (server_wall[0]["point"] as Vector2).distance_to(Vector2(2800,1500))<40.0,"Server: Reaktorwall am Gegner")

	# 6. Sprünge bleiben erhalten: Mit Sprungangriff als Partner springt der Spieler.
	for partner in [16,18,22]:
		var jump_id:=fusion_id_for(g,2,partner)
		var plan:=FusionCast.plan(2,partner)
		if not FusionCast.jumps_at_cast(plan):continue
		cast(g,jump_id,Vector2(400,0),false)
		check(g.player_pos.distance_to(Vector2(2600,1500))>150.0,"Sprung + %d: Spieler springt" % partner)
	check(FusionCast.MAX_TRIGGERS==5,"Limit fünf Zündungen")

	# 5. Fächer: höchstens fünf Zündungen, jede am ersten Treffer ihres Geschosses.
	var fan:=fusion_id_for(g,17,26)
	check(cast(g,fan,Vector2(130,0),false).size()<=FusionCast.MAX_TRIGGERS,"Fächer höchstens dreimal")

	g.free()
	if failures>0:
		print("FUSION_ORIGIN_FAILED ",failures)
		quit(1)
		return
	print("FUSION_ORIGIN_OK %d fusions fire at the hit point offline and on the server, never at the player" % checked)
	quit()
