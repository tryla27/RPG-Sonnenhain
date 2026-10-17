extends SceneTree
## Ein gemeinsamer Modellbaumeister (geteilte Materialien) liefert dieselbe
## Geometrie wie ein frischer Baumeister je Modell.
const Models=preload("res://components/world_obstacle_models_3d.gd")
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:failures+=1;push_error(message)

func fingerprint(node:Node)->Array:
	var parts:Array=[]
	if node is MeshInstance3D and node.mesh!=null:
		for surface in node.mesh.get_surface_count():
			var arrays:Array=node.mesh.surface_get_arrays(surface)
			parts.append([str(node.name),hash(arrays[Mesh.ARRAY_VERTEX]),hash(arrays[Mesh.ARRAY_TEX_UV]),node.mesh.surface_get_material(surface).resource_name])
	for child in node.get_children():parts.append_array(fingerprint(child))
	return parts

func _initialize()->void:
	var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://components/world_obstacles_3d.json"))
	var shared:=Models.new();var shared_materials:=0
	for spec in data["objects"]+data["common_objects"]:
		var fresh:Node3D=Models.new().build(spec);var reused:Node3D=shared.build(spec)
		check(fingerprint(fresh)==fingerprint(reused),"Gleiche Geometrie für %s"%spec["id"])
		fresh.free();reused.free()
	shared_materials=shared.materials.size()
	check(shared_materials>0,"Materialien werden zwischen Modellen geteilt")
	if failures>0:quit(1);return
	print("OBSTACLE_MODEL_BUILDER_OK %d gemeinsame Materialien"%shared_materials)
	quit()
