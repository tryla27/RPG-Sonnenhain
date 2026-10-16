extends SceneTree
const Geometry=preload("res://components/world_geometry.gd")
const Content=preload("res://components/game_content.gd")
func _initialize()->void:
	var regions:Array=[];var trails:Array=[];var stones:Array=[]
	for i in 13:
		var r:=Geometry.region_rect(i);regions.append([r.position.x,r.position.y,r.size.x,r.size.y])
	for trail in Content.TRAILS:
		var points:Array=[]
		for p in trail:points.append([p.x,p.y])
		trails.append(points)
	for p in Geometry.WAYSTONES:stones.append([p.x,p.y])
	DirAccess.make_dir_recursive_absolute("res://art/source/inkscape")
	var file:=FileAccess.open("res://art/source/inkscape/map_geometry.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"regions":regions,"trails":trails,"waystones":stones},"\t"));file.close();quit()
