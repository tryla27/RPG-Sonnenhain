extends SceneTree
## Ruinenhof (Spielpilot): liegt in den Alten Ruinen um Serins Ereignis, ist
## frei begehbar (keine Bäume, Felsen oder Deko darin), vom Hauptweg durch den
## Eingang erreichbar, und der Abschluss des Ereignisses wird sichtbar.
const Courtyard=preload("res://components/ruin_courtyard.gd")
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func _process(_delta:float)->void:pass
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;push_error("RUIN_COURTYARD_FAIL "+label)
func _initialize()->void:call_deferred("run")
func run()->void:
	var g:=Game.new();root.add_child(g)
	for i in 6:await process_frame
	g.character_created=true;g.level=20
	var event:Dictionary=g.WORLD_EVENTS[Courtyard.EVENT_INDEX]
	check(str(event["name"])=="Serin" and Courtyard.RECT.has_point(event["pos"]),"Serins Ereignis liegt im Hof")
	for corner in [Courtyard.RECT.position,Courtyard.RECT.end,Vector2(Courtyard.RECT.end.x,Courtyard.RECT.position.y),Vector2(Courtyard.RECT.position.x,Courtyard.RECT.end.y)]:
		check(g.region_at(corner)==3,"Hof ganz in den Alten Ruinen: %s"%corner)
	# Begehbar: kein Baum, Fels oder Ruinenstein im Hof.
	var blocked:=0
	for x in range(int(Courtyard.RECT.position.x)+10,int(Courtyard.RECT.end.x)-9,20):
		for y in range(int(Courtyard.RECT.position.y)+10,int(Courtyard.RECT.end.y)-9,20):
			if g.terrain_blocked(Vector2(x,y),18.0) or g.blocked_by_region_wall(Vector2(x,y)):blocked+=1
	check(blocked==0,"Hof frei begehbar (%d gesperrte Punkte)"%blocked)
	# Vom Hauptweg durch den Eingang bis zum Siegel ohne Hindernis.
	var trail_point:=Vector2(Courtyard.GATE_X,1530)
	check(g.distance_to_trail(trail_point)<60.0,"Startpunkt liegt auf dem Hauptweg")
	for step in 41:
		var p:=trail_point.lerp(Courtyard.SEAL,step/40.0)
		check(not g.terrain_blocked(p,18.0),"Eingang frei bei %s"%p)
	# Landschaftskörper (Bäume, Deko, Felsen) halten Abstand.
	var rows:Array=g.world_obstacles_3d.collect(g,Courtyard.RECT.grow(300))
	var inside:=0
	for row in rows:
		if Courtyard.RECT.has_point(row["point"]) and not str(row["model"]).begins_with("common-wall-"):inside+=1
	check(inside==0,"keine Landschaftskörper im Hof (%d)"%inside)
	check(Courtyard.clears(Courtyard.SEAL) and not Courtyard.clears(trail_point),"clears() trennt Hof und Weg")
	# Ereignis: annehmen, vier Streuner im Hof besiegen, sichtbarer Abschluss.
	g.player_pos=event["pos"]+Vector2(0,60)
	g.interact_world_event(Courtyard.EVENT_INDEX)
	check(int(g.event_states[Courtyard.EVENT_INDEX])==1,"Ereignis läuft")
	g.effects.clear()
	for kill in int(event["goal"]):
		var enemy:Dictionary=g.make_enemy(9,Courtyard.SEAL+Vector2(kill*30-45,40))
		enemy["hp"]=0.0
		g.enemies.append(enemy)
		g.defeat_enemy(g.enemies.size()-1)
	check(int(g.event_states[Courtyard.EVENT_INDEX])==2,"Hof gesäubert nach %d Siegen"%int(event["goal"]))
	var shown:=false
	for fx in g.effects:
		if str(fx["text"])=="HOF GESÄUBERT":shown=true
	check(shown,"Abschluss wird im Hof angezeigt")
	g.free()
	if failures>0:quit(1);return
	print("RUIN_COURTYARD_OK")
	quit()
