extends SceneTree

class TestGame:
	extends "res://main.gd"
	func _ready()->void: pass
	func _process(_delta:float)->void: pass
	func save_game()->void: pass

func _initialize()->void:
	call_deferred("run")

func run()->void:
	var g:=TestGame.new()
	g.reset_class_skills()
	var ids:=g.fusion_catalog_skills()
	var pairs:=g.fusion_codex_pairs()
	assert(ids.size()>2)
	assert(pairs.size()==int(ids.size()*(ids.size()-1)/2),"codex must contain every unique skill pair")
	assert(pairs.size()>g.FUSIONS.size(),"codex must be broader than the curated playable recipes")

	var found_eisball:=false
	var found_preview_only:=false
	for pair in pairs:
		var key:=g.fusion_key(int(pair["a"]),int(pair["b"]))
		var definition:Dictionary=pair.get("definition",{})
		if key=="17:18":
			assert(not definition.is_empty() and int(definition["id"])==43)
			found_eisball=true
		elif definition.is_empty():
			found_preview_only=true
	assert(found_eisball)
	assert(found_preview_only)
	print("FUSION_CODEX_OK all unique active-skill pairs listed; curated recipes remain playable")
	g.free()
	quit()
