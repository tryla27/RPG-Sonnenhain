extends SceneTree
# Jeder gezeichnete Busch raschelt: Dorfbüsche, Blütenbüsche, Kräuter- und
# Beerensträucher, Büsche an Hindernissen und Streubüsche auf dem Boden.

const Foliage=preload("res://components/foliage.gd")

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		if failures<=20:push_error("BUSH_RUSTLE_FAIL "+label)

func _initialize()->void:call_deferred("run")

func run()->void:
	var g=load("res://main.gd").new()
	for p in g.VillageLayout.BUSHES:check(g.foliage_at(p),"Dorfbusch %s" % p)
	for p in g.VillageLayout.FLOWER_BUSHES:check(g.foliage_at(p),"Blütenbusch %s" % p)
	for plant in g.food_system.plants:
		if str(plant.get("kind",""))=="herb" or (str(plant.get("kind",""))=="fruit" and not bool(plant.get("tree",false))):
			check(g.foliage_at(plant["point"]),"Strauch %s" % plant["point"])
	# Büsche an Hindernissen in allen Gebieten, die welche zeichnen.
	var obstacle_bushes:={}
	for cx in range(0,48):
		for cy in range(0,36):
			var obstacle:Dictionary=g.obstacle_in_cell(cx,cy)
			if obstacle.is_empty():continue
			var bush:=Foliage.obstacle_bush_point(int(obstacle["zone"]),obstacle["pos"],float(obstacle["radius"]))
			if bush==Vector2.INF:continue
			obstacle_bushes[int(obstacle["zone"])]=int(obstacle_bushes.get(int(obstacle["zone"]),0))+1
			check(g.foliage_at(bush),"Hindernisbusch Gebiet %d bei %s" % [obstacle["zone"],bush])
	for zone in [1,2,3]:check(int(obstacle_bushes.get(zone,0))>0,"Gebiet %d hat Hindernisbüsche" % zone)
	# Streubüsche: mindestens einige pro Gebiet werden erkannt.
	var scatter:={}
	for tx in range(0,180):
		for ty in range(0,130):
			var key:int=g.hash_cell(tx,ty)
			var origin:=Vector2(tx*64,ty*64)
			var zone:int=g.visual_region_at(origin+Vector2(32,32))
			if not Foliage.scatter_is_bush(zone,key):continue
			var p:=Vector2(tx*64+(key%23),ty*64+((key/23)%25))
			if g.foliage_at(Foliage.cluster_center(p)):scatter[zone]=int(scatter.get(zone,0))+1
	for zone in [1,2,3,4]:check(int(scatter.get(zone,0))>20,"Streubüsche in Gebiet %d rascheln (%d)" % [zone,int(scatter.get(zone,0))])
	# Kein Rascheln auf freiem Pflaster und am Wegstein.
	check(not g.foliage_at(g.WAYSTONES[0]),"Wegstein ist kein Busch")
	g.free()
	if failures>0:
		print("BUSH_RUSTLE_FAILED ",failures)
		quit(1)
		return
	print("BUSH_RUSTLE_OK village, flower, herb, obstacle and scatter bushes rustle")
	quit()
