extends SceneTree
# Nahrungsbüsche: 8–12 Fruchtbüsche und 3 Kräuter je Gebiet, verteilt, frei, gleich auf jedem Gerät.
const FoodSystem=preload("res://components/food_system.gd")
class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_d:float)->void:pass

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("FOOD_BUSHES_FAIL "+label)

func _initialize()->void:call_deferred("run")

func run()->void:
	var g:=Game.new()
	g.food_system.configure(g)
	var again:=FoodSystem.new();again.configure(g)
	check(again.plants.size()==g.food_system.plants.size(),"gleiche Anzahl bei jedem Aufbau")
	for i in mini(again.plants.size(),g.food_system.plants.size()):
		if Vector2(again.plants[i]["point"])!=Vector2(g.food_system.plants[i]["point"]):
			check(false,"gleiche Plätze bei jedem Aufbau");break
	for region in range(1,13):
		var fruits:=0;var herbs:=0;var pts:Array=[]
		for plant in g.food_system.plants:
			if int(plant["region"])!=region:continue
			if str(plant["kind"])=="herb":herbs+=1
			else:fruits+=1
			pts.append(Vector2(plant["point"]))
			check(FoodSystem.bush_spot_ok(g,plant["point"],region),"freier Platz in Gebiet %d" % region)
		check(fruits>=8 and fruits<=12,"Gebiet %d: %d Fruchtbüsche" % [region,fruits])
		check(herbs==3,"Gebiet %d: %d Kräuter" % [region,herbs])
		var closest:=INF
		for a in pts.size():
			for b in range(a+1,pts.size()):closest=minf(closest,pts[a].distance_to(pts[b]))
		check(closest>=300.0,"Gebiet %d verteilt (nächster Abstand %d)" % [region,int(closest)])
	g.free()
	if failures>0:
		push_error("FOOD_BUSHES_FAILED %d" % failures);quit(1);return
	print("FOOD_BUSHES_OK")
	quit()
