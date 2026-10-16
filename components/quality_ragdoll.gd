extends RefCounted
## Clientseitiger Physik-Prototyp im Grafiklabor, ohne Netzwerk-/Kampfzustand.
static func find_skeleton(node:Node)->Skeleton3D:
	if node is Skeleton3D:return node
	for child in node.get_children():
		var found:=find_skeleton(child)
		if found!=null:return found
	return null
static func attach(skeleton:Skeleton3D)->PhysicalBoneSimulator3D:
	var simulator:=PhysicalBoneSimulator3D.new();simulator.name="QualityRagdoll";skeleton.add_child(simulator)
	for index in range(1,skeleton.get_bone_count()):
		var name:=str(skeleton.get_bone_name(index))
		var length:=.4
		if name=="hips":length=.25
		elif name.begins_with("leg"):length=.65
		var body:=PhysicalBone3D.new();body.name="Physical_"+name
		simulator.add_child(body);body.set("bone_name",name)
		body.mass=4.0 if name in ["hips","torso"] else 1.0
		body.linear_damp=.6;body.angular_damp=2.0
		body.joint_type=PhysicalBone3D.JOINT_TYPE_NONE if name=="hips" else PhysicalBone3D.JOINT_TYPE_CONE
		body.body_offset=Transform3D(Basis.IDENTITY,Vector3(0,length*.5,0))
		body.joint_offset=Transform3D(Basis.IDENTITY,Vector3(0,-length*.5,0))
		var collider:=CollisionShape3D.new();var shape:=CapsuleShape3D.new()
		shape.radius=.09;shape.height=maxf(.2,length);collider.shape=shape;body.add_child(collider)
	return simulator
