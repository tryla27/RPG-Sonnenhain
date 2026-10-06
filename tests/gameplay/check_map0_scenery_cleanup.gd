extends SceneTree

class TestGame extends "res://main.gd":
	func _ready()->void:pass
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass

func _initialize()->void:
	call_deferred("run")

func run()->void:
	var g:=TestGame.new()
	root.add_child(g)
	assert(g.REFERENCE_TREES.is_empty(),"Map 0 reference trees must stay removed until replacement art is ready")
	var kinds:Array=[]
	for prop in g.village_props():kinds.append(str(prop.get("kind","")))
	assert("tree" not in kinds,"Map 0 must not spawn normal trees")
	assert("barrel" not in kinds,"Map 0 must not spawn barrels")
	assert("magic_tree" in kinds,"Borin's authored magic tree stays")
	print("MAP0_SCENERY_CLEANUP_OK trees=0 barrels=0 magic_tree=kept")
	g.queue_free()
	quit()
