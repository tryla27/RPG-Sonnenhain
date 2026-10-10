extends SceneTree
# Torbogen oben rechts in den Aschebergen führt in die Nebelheide und zurück
# (Angelo 10.10.2026). Server erlaubt den Sprung online.

class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_d:float)->void:pass
	func save_game()->void:pass
	func play_sound(_n:String)->void:pass

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("ASCHEBERGE_PORTAL_FAIL "+label)

func _initialize()->void:
	var g:=Game.new()
	g.reset_class_skills();g.character_created=true;g.level=30
	for i in g.QUESTS.size():g.quests.append({"state":0,"progress":0})
	for i in g.BORIN_QUESTS.size():g.borin_quests.append({"state":0,"progress":0})
	for i in g.WORLD_EVENTS.size():
		g.event_states.append(0);g.event_progress.append(0)
	var portal:Array=[]
	for p in g.PORTALS:
		if g.region_at(p[0])==5:portal=p
	check(not portal.is_empty(),"Torbogen in den Aschebergen vorhanden")
	if portal.is_empty():
		quit(1);return
	var start:Vector2=portal[0]
	check(start.x>10000.0 and start.y<1200.0,"oben rechts in den Aschebergen (%s)" % start)
	check(int(portal[2])==8 and g.region_at(portal[1])==8,"führt in die Nebelheide")
	check(not g.is_blocked(start+Vector2(0,60),start+Vector2(0,60)),"vor dem Torbogen begehbar")
	g.player_pos=start+Vector2(0,40)
	g.interact()
	check(g.region_at(g.player_pos)==8,"E: in der Nebelheide (Region %d)" % g.region_at(g.player_pos))
	check(not g.is_blocked(g.player_pos,g.player_pos),"Ankunft begehbar")
	var arrival:=g.player_pos
	check(g.valid_network_teleport(start+Vector2(0,40),arrival,{"hp":100},"world"),"Server erlaubt den Sprung")
	# Rückweg nur, wenn die Ascheberge offen sind (Boss-Siegel wie beim Laufen).
	g.bosses_defeated[1]=false
	g.player_pos=Vector2(portal[1])+Vector2(0,40)
	g.interact()
	check(g.region_at(g.player_pos)==8,"Siegel: kein Rückweg in versiegelte Ascheberge")
	g.bosses_defeated[1]=true
	g.player_pos=Vector2(portal[1])+Vector2(0,40)
	g.interact()
	check(g.region_at(g.player_pos)==5,"zurück in die Ascheberge")
	g.free()
	if failures>0:
		push_error("ASCHEBERGE_PORTAL_FAILED %d" % failures);quit(1);return
	print("ASCHEBERGE_PORTAL_OK")
	quit()
