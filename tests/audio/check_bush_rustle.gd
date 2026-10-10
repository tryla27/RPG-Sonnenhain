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
	# Die neuen 3D-Körper bestimmen die tatsächlichen Busch-/Farnstellen.
	var leafy:=0
	for zone in range(1,13):
		var samples:=0
		var rows:Array=g.world_obstacles_3d.collect(g,g.region_rect(zone))
		for row in rows:
			if str(row["model"]).begins_with("common-wall-"):continue
			var family:String=g.WorldObstacles3D.Models.FAMILIES[zone-1][int(row["motif"])-1]
			if family not in ["bush","fern","fern_roots"]:continue
			check(g.foliage_at(row["point"]),"3D-Strauch/Farn auf Map %d bei %s"%[zone,row["point"]])
			samples+=1;leafy+=1
			if samples>=20:break
	check(leafy>=100,"Genügend echte Strauchstellen über die Außenkarten")
	# Kein Rascheln auf freiem Pflaster und am Wegstein.
	check(not g.foliage_at(g.WAYSTONES[0]),"Wegstein ist kein Busch")
	g.free()
	if failures>0:
		print("BUSH_RUSTLE_FAILED ",failures)
		quit(1)
		return
	print("BUSH_RUSTLE_OK village, flower, herb and actual 3D foliage locations rustle")
	quit()
