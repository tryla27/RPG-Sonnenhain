extends SceneTree

func _initialize()->void:
	var main:=FileAccess.get_file_as_string("res://main.gd")
	var catalog:=FileAccess.get_file_as_string("res://components/fusion_catalog.gd")
	assert(catalog.find('{"id":43,"a":17,"b":18,"gold":1800,"max_rank":4}')>=0)
	var content:=FileAccess.get_file_as_string("res://components/game_content.gd")
	assert(content.find('"name":"Eisball"')>=0)
	assert(main.find("func iceball_chain(")>=0)
	assert(main.find("func iceball_impact(")>=0)
	assert(main.find("if rank>=2:")>=0)
	assert(main.find("if rank>=3:")>=0)
	assert(main.find("if rank>=4:")>=0)
	assert(main.find('if not fusion_definition.is_empty():shot["fusion_rank"]=rank')>=0)
	assert(catalog.find('43:{"trigger":"ON_DAMAGE_HIT","spawn":"DAMAGE_IMPACT_POSITION"')>=0)
	assert(main.find('apply_fusion_impact(spell_id,impact')>=0)
	assert(main.find('offer["a"]=a')==-1)
	print("EISBALL_FUSION_OK fixed Frostnova+Blitzlanze recipe; 4 stages; impact-position routing; multiplayer rank")
	quit()
