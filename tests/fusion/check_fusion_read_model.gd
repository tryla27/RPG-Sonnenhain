extends SceneTree

const FusionReadModel=preload("res://components/fusion_read_model.gd")

func _initialize()->void:
	var fusions:Array=[
		{"id":40,"a":0,"b":16,"gold":1200},
		{"id":43,"a":17,"b":18,"gold":1800}
	]
	var indexes:=FusionReadModel.build_indexes(fusions)
	assert(int(FusionReadModel.definition_by_id(indexes,43)["a"])==17)
	assert(int(FusionReadModel.definition_by_key(indexes,"0:16")["id"])==40)
	assert(FusionReadModel.definition_by_key(indexes,"16:0").is_empty())
	var profiles:Dictionary={
		40:{"spawn":"DAMAGE_IMPACT_POSITION"},
		41:{"spawn":"IMPULSE_IMPACT_POSITION"}
	}
	assert(FusionReadModel.spawn_rule(profiles,40)=="DAMAGE_IMPACT_POSITION")
	assert(FusionReadModel.spawn_rule(profiles,41)=="IMPULSE_IMPACT_POSITION")
	var abilities:Array=[{"name":"Wirbelhieb"},{"name":"Schildwall"}]
	var learned:Array=[true,false]
	var missing:=FusionReadModel.missing_sources({"a":0,"b":1},learned,abilities)
	assert(missing==["Schildwall"])
	assert(FusionReadModel.offer_index(fusions,43)==1)
	assert(FusionReadModel.offer_index(fusions,99)==-1)
	print("FUSION_READ_MODEL_OK indexes, profiles, missing sources and offer lookup")
	quit()
