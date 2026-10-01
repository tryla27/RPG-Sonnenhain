extends SceneTree

const Models = preload("res://components/animation_lab_models.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	assert(ResourceLoader.exists("res://tools/local_animation_lab_v2.tscn"))
	assert(Models.direction_index(Vector2.DOWN)==0)
	assert(Models.direction_index(Vector2.RIGHT)==2)
	assert(Models.direction_index(Vector2.UP)==4)
	assert(Models.direction_index(Vector2.LEFT)==6)
	var scene: PackedScene = load("res://tools/local_animation_lab_v2.tscn")
	assert(scene != null)
	var node := scene.instantiate()
	assert(node != null)
	root.add_child(node)
	await process_frame
	assert(node.has_method("dir_name"))
	print("ANIMATION_LAB_V2_OK")
	node.queue_free()
	quit()
