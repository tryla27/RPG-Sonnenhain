extends SceneTree

class TestGame:
	extends "res://main.gd"
	func _ready()->void: pass
	func _process(_delta:float)->void: pass
	func save_game()->void: pass
	func play_sound(_key)->void: pass
	func message(_text)->void: pass

func _initialize()->void:
	call_deferred("run")

func run()->void:
	var g:=TestGame.new()
	g.reset_class_skills()
	g.level=40
	g.gold=50000
	var sources:=g.fusion_candidate_skill_ids()
	var codex:=g.fusion_codex_entries()
	assert(sources.size()>4)
	assert(codex.size()==int(sources.size()*(sources.size()-1)/2),"codex must contain every unordered source pair")
	var keys:Dictionary={}
	var implemented:=0
	for entry in codex:
		var key:=str(entry["key"])
		assert(not keys.has(key),"duplicate fusion pair")
		keys[key]=true
		assert(int(entry["a"])<int(entry["b"]))
		assert(str(entry["name"])!="")
		if bool(entry["implemented"]):implemented+=1
	assert(implemented==g.FUSIONS.size())
	for fusion in g.FUSIONS:
		assert(keys.has(g.fusion_key(int(fusion["a"]),int(fusion["b"]))))
	g.learned[17]=true;g.skill_levels[17]=1
	g.learned[18]=true;g.skill_levels[18]=1
	var fixed:=g.fusion_definition_by_key("17:18")
	var cash:=g.gold
	assert(g.buy_fusion_definition(fixed))
	assert(g.learned[43] and g.skill_levels[43]==1 and g.gold==cash-int(fixed["gold"]))
	print("FUSION_CODEX_OK exhaustive source-pair list; fixed runtime fusions remain craftable and save-safe")
	g.free()
	quit()
