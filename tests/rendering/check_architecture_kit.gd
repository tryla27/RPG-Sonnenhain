extends SceneTree
## Architektur-Set v2: jedes Blender-Bauteil lädt, ersetzt nur seine ID und hat
## genau die Begrenzung des alten Modells (sonst verschieben sich Atlasplatz,
## Projektion und Sortierung).
const Kit=preload("res://components/architecture_kit.gd")
const Models=preload("res://components/world_obstacle_models_3d.gd")
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:failures+=1;push_error(message)

func bounds(node:Node,xf:Transform3D,acc:Array)->void:
	var t:Transform3D=xf*(node.transform if node is Node3D else Transform3D())
	if node is MeshInstance3D and node.mesh!=null:
		var box:AABB=t*node.mesh.get_aabb()
		acc[0]=box if acc[0]==null else acc[0].merge(box)
	for child in node.get_children():bounds(child,t,acc)

func _initialize()->void:
	var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://components/world_obstacles_3d.json"))
	var specs:Dictionary={}
	for spec in data["objects"]+data["common_objects"]:specs[str(spec["id"])]=spec
	var builder:=Models.new()
	for id in Kit.IDS:
		check(Kit.replaces(id),"Bauteil vorhanden: "+id)
		var scene:=Kit.scene_for(id)
		if scene==null:continue
		var fresh:Node3D=scene.instantiate();var acc:=[null];bounds(fresh,Transform3D(),acc)
		var old:Node3D=builder.build(specs[id]);var old_acc:=[null];bounds(old,Transform3D(),old_acc)
		var a:AABB=acc[0];var b:AABB=old_acc[0]
		check(a.position.distance_to(b.position)<.03 and a.size.distance_to(b.size)<.03,"Begrenzung wie bisher: %s neu=%s alt=%s"%[id,a,b])
		fresh.free();old.free()
	check(not Kit.replaces("map01-obj01"),"Bäume bleiben unverändert")
	Kit.enabled=false
	check(not Kit.replaces("common-wall-01"),"Abschaltbar für Vergleiche")
	Kit.enabled=true
	if failures>0:quit(1);return
	print("ARCHITECTURE_KIT_OK %d Bauteile"%Kit.IDS.size())
	quit()
