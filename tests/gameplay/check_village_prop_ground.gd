extends SceneTree
# Laternen und Büsche stehen im Dorf auf Gras: nie auf Pflaster, Platten oder Mauern.

const T=preload("res://components/start_tilemap_32.gd")
const F=preload("res://components/village_fixtures.gd")
const L=preload("res://components/village_layout.gd")
const GRASS:=["village_grass","moss_grass"]

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("VILLAGE_PROP_GROUND_FAIL "+label)

func footprint_on_grass(p:Vector2,r:float)->bool:
	for dx in [-r,0.0,r]:
		for dy in [-r*0.5,0.0,r*0.5]:
			if T.visual_family_at(p+Vector2(dx,dy)) not in GRASS:return false
	return true

func _initialize()->void:
	var groups:={"Laterne":[F.LAMPS,8.0],"Busch":[L.BUSHES,24.0],"Blumenbusch":[L.FLOWER_BUSHES,24.0]}
	for label in groups:
		for p in groups[label][0]:
			check(footprint_on_grass(p,groups[label][1]),"%s bei %s steht nicht auf Gras" % [label,p])
			check(p.x<=1713.0 and p.y<=2533.0,"%s bei %s steht auf oder an der Mauer" % [label,p])
	if failures>0:
		print("VILLAGE_PROP_GROUND_FAILED ",failures)
		quit(1)
		return
	print("VILLAGE_PROP_GROUND_OK lanterns and bushes stand on grass, clear of walls")
	quit()
