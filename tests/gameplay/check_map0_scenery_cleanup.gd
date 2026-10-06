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
	assert(g.REFERENCE_TREES.size()==5,"Only the five approved replacement trees belong in Map 0")
	var kinds:Array=[]
	for prop in g.village_props():kinds.append(str(prop.get("kind","")))
	assert(kinds.count("tree")==5,"Map 0 must use the new authored tree sites")
	assert("barrel" not in kinds,"Map 0 must not spawn barrels")
	assert("magic_tree" in kinds,"Borin's authored magic tree stays")
	for name in g.StartScenery32.SCENERY:
		assert(ResourceLoader.exists("res://art/village/objects/%s.png" % name),"Missing approved scenery sprite")
	print("MAP0_SCENERY_CLEANUP_OK replacement_trees=5 barrels=0 magic_tree=replaced")
	g.queue_free()
	quit()
