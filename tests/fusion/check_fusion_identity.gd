extends SceneTree

class TestGame:
	extends "res://main.gd"
	func _ready()->void: pass
	func _process(_delta:float)->void: pass
	func save_game()->void: pass
	func announce_multiplayer_context()->void: pass

func _initialize()->void:
	call_deferred("run")

func run()->void:
	var g:=TestGame.new()
	g.reset_class_skills()

	# Reihenfolge der Eltern darf keine zweite Identität erzeugen.
	assert(g.fusion_key(0,16)=="0:16")
	assert(g.fusion_key(16,0)=="0:16")
	assert(int(g.fusion_definition_by_key("0:16")["id"])==40)
	assert(int(g.fusion_definition_by_id(43)["a"])==17)
	assert(int(g.fusion_definition_by_id(43)["b"])==18)

	# Neue Speicherung ist kompakt und serverlesbar.
	g.learned_fusions={"17:18":{"fusion_id":43,"rank":3}}
	var snapshot:=g.fusion_progress_snapshot()
	assert(snapshot.has("17:18"))
	assert(int(snapshot["17:18"]["fusion_id"])==43)
	assert(int(snapshot["17:18"]["rank"])==3)
	var rows:=g.fusion_progress_rows()
	assert(rows.size()==1)
	assert(rows[0][0]=="17:18" and int(rows[0][1])==43 and int(rows[0][2])==3)

	# Der Server akzeptiert nur exakt passende Key+ID-Paare.
	var remote_state:Dictionary={"fusions":[["17:18",43,3]]}
	assert(g.fusion_rank_from_network_state(remote_state,43)==3)
	assert(g.fusion_rank_from_network_state({"fusions":[["18:17",43,4]]},43)==0)
	assert(g.fusion_rank_from_network_state({"fusions":[["17:18",42,4]]},43)==0)
	assert(g.fusion_rank_from_network_state({},43)==0)
	var sanitized:=g.sanitize_fusion_rows([["18:17",43,4],["17:18",43,3],["17:18",42,4],["0:16",40,2]])
	assert(sanitized.size()==2)
	assert(sanitized[0][0]=="17:18" and int(sanitized[0][1])==43)
	assert(sanitized[1][0]=="0:16" and int(sanitized[1][1])==40)

	# Alte fusion_history-Saves werden automatisch auf das neue Format migriert.
	g.learned_fusions.clear()
	g.reset_class_skills()
	g.restore_fusion_progress({},[{"id":43,"a":18,"b":17,"rank":2,"gold":1800}])
	assert(g.learned_fusions.has("17:18"))
	assert(int(g.learned_fusions["17:18"]["rank"])==2)
	assert(g.learned[17] and g.learned[18] and g.learned[43])
	assert(int(g.skill_levels[43])==2)

	# Falsche oder unbekannte Kombinationen dürfen nicht aus Saves eingeschleust werden.
	g.restore_fusion_progress({"17:18":{"fusion_id":999,"rank":4}},[])
	assert(g.learned_fusions.is_empty())

	print("FUSION_IDENTITY_OK normalized key; save migration; multiplayer key/id/rank validation")
	g.free()
	quit()
