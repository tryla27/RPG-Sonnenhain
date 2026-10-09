extends SceneTree
# Neue Wegstein-Plateaus: hinauf und hinunter nur über die Treppe, Obelisk ist
# fest, Ankunftspunkte und Deko liegen nicht auf dem Plateau.

const Shrine=preload("res://components/waystone_shrine_32.gd")

class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("WAYSTONE_PLATEAU_FAIL "+label)

func _initialize()->void:call_deferred("run")

func run()->void:
	var g:=Game.new()
	var stone:Vector2=g.WAYSTONES[8]
	# Treppe hinauf, Schritt für Schritt.
	var path:=[Vector2(0,130),Vector2(0,100),Vector2(0,80),Vector2(0,60),Vector2(0,36),Vector2(0,10),Vector2(80,0)]
	for i in range(1,path.size()):
		check(not g.is_blocked(stone+path[i],stone+path[i-1]),"Treppe hinauf: %s -> %s" % [path[i-1],path[i]])
	# Von der Seite in die Mauer: gesperrt.
	check(g.is_blocked(stone+Vector2(110,70),stone+Vector2(110,110)),"Mauer von unten gesperrt")
	check(g.is_blocked(stone+Vector2(-190+30,0),stone+Vector2(-190,0)),"Mauer von der Seite gesperrt")
	# Oben an der Kante: kein Sprung hinunter.
	check(g.is_blocked(stone+Vector2(110,60),stone+Vector2(110,30)),"vorne nicht hinunterspringen")
	check(g.is_blocked(stone+Vector2(0,-110),stone+Vector2(0,-90)),"hinten nicht hinunterspringen")
	# Treppe hinunter geht.
	check(not g.is_blocked(stone+Vector2(0,60),stone+Vector2(0,30)),"Treppe hinunter")
	check(not g.is_blocked(stone+Vector2(0,100),stone+Vector2(0,80)),"unten von der Treppe herunter")
	# Obelisk ist fest.
	check(g.is_blocked(stone+Vector2(0,-36),stone+Vector2(0,-10)),"Obelisk gesperrt")
	# Alter Spielstand in der Mauer: Herauslaufen erlaubt.
	check(not g.is_blocked(stone+Vector2(120,90),stone+Vector2(120,70)),"aus der Mauer heraus")
	# Schritte oben klingen nach Stein.
	check(g.ground_surface_at(stone+Vector2(60,-20))=="spawnstein","oben Steinschritte")

	for i in range(1,g.WAYSTONES.size()):
		var s:Vector2=g.WAYSTONES[i]
		var arrival:=g.waystone_arrival(i)
		check(not Shrine.occupied(arrival-s,4.0),"Ankunft %d nicht auf dem Plateau (%s)" % [i,arrival-s])
		check(arrival.distance_to(s)<300.0,"Ankunft %d nahe am Wegstein" % i)
		# Keine Hindernisse und Bäume auf dem Plateau.
		for cx in range(int(s.x/250)-2,int(s.x/250)+3):
			for cy in range(int(s.y/250)-2,int(s.y/250)+3):
				var o:Dictionary=g.obstacle_in_cell(cx,cy)
				if not o.is_empty():check(not Shrine.occupied(o["pos"]-s),"Hindernis auf Plateau %d" % i)
		for tx in range(int(s.x/64)-5,int(s.x/64)+6):
			for ty in range(int(s.y/64)-5,int(s.y/64)+6):
				var t:Dictionary=g.decorative_tree_in_cell(tx,ty)
				if not t.is_empty():check(not Shrine.occupied(t["point"]-s,30.0),"Baum auf Plateau %d" % i)
	g.free()
	if failures>0:
		print("WAYSTONE_PLATEAU_FAILED ",failures)
		quit(1)
		return
	print("WAYSTONE_PLATEAU_OK stairs only, solid obelisk, clear arrivals and decor")
	quit()
