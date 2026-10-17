extends SceneTree
## Geländekollision: die beschleunigte terrain_blocked() liefert an Häusern der
## Klassenbosse, am Rettungslager und auf freier Wiese dasselbe wie die frühere
## Fassung (Rechtecke je Aufruf neu gebaut). Prüft auch Randpunkte.
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func _process(_delta:float)->void:pass
	## Frühere Fassung als Vergleich.
	func reference_blocked(p:Vector2,radius:float)->bool:
		for house_index in CLASS_BOSS_HOUSE_POS.size():
			if class_boss_house_rect(house_index).grow(radius).has_point(p):return true
		if region_at(p) == 1:
			for offset in [Vector2(-360, -160), Vector2(260, -190), Vector2(-330, 220), Vector2(280, 240)]:
				if Rect2(RESCUE_POS + offset - Vector2(73, 54), Vector2(146, 108)).grow(16).has_point(p): return true
		for circle in terrain_circles(int(floorf(p.x/64.0)),int(floorf(p.y/64.0))):
			if p.distance_to(Vector2(circle.x,circle.y)) < circle.z+radius: return true
		return false
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;push_error("TERRAIN_BLOCKED_FAIL "+label)
func _initialize()->void:call_deferred("run")
func run()->void:
	var g:=Game.new();root.add_child(g)
	for i in 4:await process_frame
	seed(11)
	var centers:Array=[g.RESCUE_POS,Vector2(3650,2650)]
	for house in g.CLASS_BOSS_HOUSE_POS:centers.append(house)
	var mismatches:=0;var blocked:=0;var total:=0
	for center in centers:
		for i in 20000:
			var p:Vector2=center+Vector2(randf_range(-560,560),randf_range(-420,420))
			if i%4==0:p=p.round()
			var radius:float=[0.0,8.0,13.44,18.0,36.4,60.0][i%6]
			var fast:bool=g.terrain_blocked(p,radius)
			total+=1
			if fast:blocked+=1
			if fast!=g.reference_blocked(p,radius):
				mismatches+=1
				if mismatches<5:push_error("abweichend bei %s r=%s"%[p,radius])
	# Exakte Ränder eines Hauses (ganzzahlig, also ohne Rundungsfehler).
	var size:Vector2=g.WorldGeometry.CLASS_BOSS_HOUSE_SIZE
	for house in g.CLASS_BOSS_HOUSE_POS:
		for radius in [0.0,10.0]:
			for p in [house+Vector2(-size.x*.5-radius,-size.y-radius),house+Vector2(size.x*.5+radius,0),house+Vector2(0,radius),house+Vector2(size.x*.5+radius-1,radius-1)]:
				check(g.terrain_blocked(p,radius)==g.reference_blocked(p,radius),"Rand %s r=%s"%[p,radius])
	check(mismatches==0,"gleiche Ergebnisse (%d Abweichungen)"%mismatches)
	check(blocked>total/50 and blocked<total,"Stichprobe enthält blockierte und freie Punkte (%d/%d)"%[blocked,total])
	g.free()
	if failures>0:quit(1);return
	print("TERRAIN_BLOCKED_OK ",blocked,"/",total)
	quit()
