extends SceneTree

const FusionRules=preload("res://components/fusion_rules.gd")
const BuildInfo=preload("res://components/build_info.gd")

func _initialize()->void:
	var fusible:Array=[]
	for id in range(40):
		if FusionRules.is_fusible(id):fusible.append(id)
	assert(fusible.size()==33)
	for excluded in [9,10,11,15,24,27,33]:
		assert(not FusionRules.is_fusible(excluded))
	for output in [40,41,42,43]:
		assert(not FusionRules.is_fusible(output))

	assert(FusionRules.normalized_key(16,0)=="0:16")
	assert(FusionRules.normalized_key(18,17)=="17:18")

	var fire_whirl:=FusionRules.template_for_pair(0,16)
	assert(int(fire_whirl["carrier"]["spell_id"])==16)
	assert(str(fire_whirl["trigger"])=="ON_HIT")
	assert(str(fire_whirl["spawn_position"])=="DAMAGE_IMPACT_POSITION")
	assert(str(fire_whirl["fusion_reaction"])!="")

	# Regel D1: Ohne angreifenden Träger fliegt ein Impuls; sonst zündet der Treffer.
	var reactor:=FusionRules.template_for_pair(1,36)
	assert(str(reactor["trigger"])=="ON_IMPULSE_HIT")
	assert(str(reactor["spawn_position"])=="IMPULSE_IMPACT_POSITION")

	var jump_frost:=FusionRules.template_for_pair(2,21)
	assert(int(jump_frost["carrier"]["spell_id"])==2)
	assert(str(jump_frost["spawn_position"])=="DAMAGE_IMPACT_POSITION")

	var mark_guard:=FusionRules.template_for_pair(32,36)
	assert(str(mark_guard["spawn_position"])=="IMPULSE_IMPACT_POSITION")

	for a in range(40):
		for b in range(a+1,40):
			var template:=FusionRules.template_for_pair(a,b)
			if template.is_empty():continue
			assert(str(template["spawn_position"]) not in ["PLAYER_POSITION","LANDING_POSITION"])

	var ice_lightning:=FusionRules.template_for_pair(17,18)
	assert(str(ice_lightning["fusion_reaction"])=="CONDUCTIVE_FREEZE")
	assert((ice_lightning["ranks"] as Dictionary).size()==4)

	var invalid:=FusionRules.template_for_pair(9,16)
	assert(invalid.is_empty())
	assert(str(BuildInfo.SHORT)!="")

	print("FUSION_RULES_OK 33 fusible sources; deterministic carrier/trigger/spawn at the hit point; four ranks; exclusions")
	quit()
