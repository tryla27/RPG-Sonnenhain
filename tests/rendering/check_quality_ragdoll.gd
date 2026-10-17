extends SceneTree
const Ragdoll=preload("res://components/quality_ragdoll.gd")
func _initialize()->void:call_deferred("run")
func run()->void:
	var model:Node3D=load("res://art/models/quality_v1/warrior_gold.glb").instantiate();root.add_child(model)
	var skeleton:=Ragdoll.find_skeleton(model)
	if skeleton==null:push_error("Ragdoll-Skelett fehlt");quit(1);return
	var simulator:=Ragdoll.attach(skeleton)
	for body in simulator.get_children():
		if body.get_bone_id()<0:push_error("Ragdoll-Knochen nicht zugeordnet: "+body.name);quit(1);return
	simulator.physical_bones_start_simulation()
	await physics_frame;await physics_frame
	if not simulator.is_simulating_physics():push_error("Ragdoll-Simulation startet nicht");quit(1);return
	simulator.physical_bones_stop_simulation();model.free()
	print("QUALITY_RAGDOLL_OK Knochenzuordnung, Physikstart und Stopp")
	quit()
