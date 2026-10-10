extends SceneTree
const Bodies=preload("res://components/world_obstacle_models_3d.gd")
const World=preload("res://components/world_obstacles_3d.gd")
class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
class Ground extends RefCounted:
	var calls:Array=[]
	func draw_flower(_p:Vector2,_key:int)->void:calls.append("flower")
	func draw_grass(_p:Vector2)->void:calls.append("grass")
	func draw_pebbles(_p:Vector2)->void:calls.append("pebbles")
	func draw_wave(_p:Vector2,_key:int)->void:calls.append("wave")

var failures:=0
func check(ok:bool,message:String="3D-Landschaftsprüfung fehlgeschlagen")->void:
	if not ok:
		failures+=1;push_error(message);quit(1)

func _initialize()->void:call_deferred("run")

func meshes(node:Node)->int:
	var count:=0
	if node is MeshInstance3D:
		check(node.mesh is ArrayMesh and node.mesh.get_surface_count()>0)
		var box:AABB=node.mesh.get_aabb();check(box.size.length()>0 and box.position.is_finite())
		for surface in node.mesh.get_surface_count():
			var material=node.mesh.surface_get_material(surface)
			check(material is StandardMaterial3D)
			check(material.albedo_texture.get_size()==Vector2(64,64))
		count+=1
	for child in node.get_children():count+=meshes(child)
	return count

func run()->void:
	var ground:=Ground.new()
	World.paint_ground(ground,0,3,Vector2.ZERO,false);check(ground.calls.is_empty())
	World.paint_ground(ground,6,2,Vector2.ZERO,true);check(ground.calls==["wave"])
	ground.calls.clear();World.paint_ground(ground,1,3,Vector2.ZERO,false);check(ground.calls==["flower"])
	ground.calls.clear();World.paint_ground(ground,4,8,Vector2.ZERO,false);check(ground.calls==["grass"])
	var catalog:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://components/world_obstacles_3d.json"))
	check(catalog["map0_excluded"] and catalog["objects"].size()==72 and catalog["common_objects"].size()==6)
	var mesh_count:=0;var animated:=0
	for spec in catalog["objects"]+catalog["common_objects"]:
		var body:Node3D=Bodies.new().build(spec)
		mesh_count+=meshes(body)
		check(body.get_node_or_null("SolidFoot")==null) # Die verbindlichen 2D-Collider bleiben zuständig.
		var player:=body.get_node_or_null("AnimationPlayer") as AnimationPlayer
		if player!=null:
			animated+=1;check(player.has_animation("rare_event"));check(player.get_animation("rare_event").loop_mode==Animation.LOOP_NONE)
		body.free()
	check(mesh_count>=78 and mesh_count<=300 and animated==58)
	check(not World.replaces_static(0) and not World.replaces_static(-1) and not World.replaces_static(13))
	check(not World.replaces_wall(Vector2(1780,0),Vector2(1780,2600)))
	check(not World.replaces_wall(Vector2(0,2600),Vector2(1780,2600)))
	check(World.outside_village(Rect2(10,10,100,100)).is_empty())
	for rect in [Rect2(1740,2500,150,200),Rect2(1600,2600,100,80),Rect2(1780,100,200,100),Rect2(-20,-20,1850,2700)]:
		var covered:=0.0
		for part in World.outside_village(rect):
			check(rect.encloses(part) and not part.intersects(World.Geometry.region_rect(0)))
			covered+=part.get_area()
		check(is_equal_approx(covered,rect.get_area()-rect.intersection(World.Geometry.region_rect(0)).get_area()))
	var g:=Game.new();root.add_child(g)
	var renderer:=World.new()
	check(renderer.collect(g,g.region_rect(0)).is_empty())
	g.character_created=true;renderer.update(g,.1);check(renderer.viewport==null) # Server/Headless ohne Grafik.
	for zone in range(1,13):
		var seen:Dictionary={}
		var rows:Array=renderer.collect(g,g.region_rect(zone))
		check(not rows.is_empty())
		for row in rows:
			if str(row["model"]).begins_with("common-wall-"):continue
			check(int(row["map"])==zone and g.region_at(row["point"])==zone)
			check(g.class_boss_arena_index_at(row["point"],55)<0 and not g.near_waystone_shrine(row["point"],55))
			seen[int(row["motif"])]=true
		for motif in range(1,7):check(seen.has(motif),"Motiv fehlt auf Map %d: %d"%[zone,motif])
	g.free()
	if failures>0:
		quit(1);return
	print("OBSTACLES_3D_OK 78 echte Mesh-Körper, 58 kurze Animationen, alle 72 Motive in Außenmaps, Map 0 unverändert, Server ohne Grafik")
	quit()
