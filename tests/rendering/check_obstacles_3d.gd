extends SceneTree
const Bodies=preload("res://components/world_obstacle_models_3d.gd")
const World=preload("res://components/world_obstacles_3d.gd")
class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass

func _initialize()->void:call_deferred("check")

func meshes(node:Node)->int:
	var count:=0
	if node is MeshInstance3D:
		assert(node.mesh is ArrayMesh and node.mesh.get_surface_count()>0)
		var box:AABB=node.mesh.get_aabb();assert(box.size.length()>0 and box.position.is_finite())
		for surface in node.mesh.get_surface_count():
			var material=node.mesh.surface_get_material(surface)
			assert(material is StandardMaterial3D)
			assert(material.albedo_texture.get_size()==Vector2(64,64))
		count+=1
	for child in node.get_children():count+=meshes(child)
	return count

func check()->void:
	var catalog:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://components/world_obstacles_3d.json"))
	assert(catalog["map0_excluded"] and catalog["objects"].size()==72 and catalog["common_objects"].size()==6)
	var mesh_count:=0;var animated:=0
	for spec in catalog["objects"]+catalog["common_objects"]:
		var body:Node3D=Bodies.new().build(spec)
		mesh_count+=meshes(body)
		assert(body.get_node_or_null("SolidFoot")==null) # Die verbindlichen 2D-Collider bleiben zuständig.
		var player:=body.get_node_or_null("AnimationPlayer") as AnimationPlayer
		if player!=null:
			animated+=1;assert(player.has_animation("rare_event"));assert(player.get_animation("rare_event").loop_mode==Animation.LOOP_NONE)
		body.free()
	assert(mesh_count>=78 and mesh_count<=300 and animated==58)
	assert(not World.replaces_static(0) and not World.replaces_static(-1) and not World.replaces_static(13))
	assert(not World.replaces_wall(Vector2(1780,0),Vector2(1780,2600)))
	assert(not World.replaces_wall(Vector2(0,2600),Vector2(1780,2600)))
	var g:=Game.new();root.add_child(g)
	var renderer:=World.new()
	assert(renderer.collect(g,g.region_rect(0)).is_empty())
	g.character_created=true;renderer.update(g,.1);assert(renderer.viewport==null) # Server/Headless ohne Grafik.
	for zone in range(1,13):
		var seen:Dictionary={}
		var rows:Array=renderer.collect(g,g.region_rect(zone))
		assert(not rows.is_empty())
		for row in rows:
			if str(row["model"]).begins_with("common-wall-"):continue
			assert(int(row["map"])==zone and g.region_at(row["point"])==zone)
			assert(g.class_boss_arena_index_at(row["point"],55)<0 and not g.near_waystone_shrine(row["point"],55))
			seen[int(row["motif"])]=true
		for motif in range(1,7):assert(seen.has(motif),"Motiv fehlt auf Map %d: %d"%[zone,motif])
	g.free()
	print("OBSTACLES_3D_OK 78 echte Mesh-Körper, 58 kurze Animationen, alle 72 Motive in Außenmaps, Map 0 unverändert, Server ohne Grafik")
	quit()
