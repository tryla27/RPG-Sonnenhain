extends RefCounted

# Reine Zustandsberechnungen fuer den Fusions-UI-/Kaufpfad.
# Keine Mutation, keine Saves und keine Kampfeffekte in diesem Modul.

static func available_fusions(fusions:Array,learned:Array,skill_levels:Array)->Array:
	var offers:Array=[]
	for fusion in fusions:
		var output:=int(fusion["id"])
		var source_a:=int(fusion["a"])
		var source_b:=int(fusion["b"])
		var max_rank:=clampi(int(fusion.get("max_rank",4)),1,4)
		if output>=learned.size() or source_a>=learned.size() or source_b>=learned.size():continue
		if not learned[source_a] or not learned[source_b]:continue
		if learned[output] and int(skill_levels[output])>=max_rank:continue
		offers.append(fusion.duplicate(true))
	return offers

static func can_fuse(fusion:Dictionary,learned:Array,skill_levels:Array,abilities:Array,level:int,gold:int)->bool:
	var a:=int(fusion["a"])
	var b:=int(fusion["b"])
	var id:=int(fusion["id"])
	if a<0 or b<0 or id<0:return false
	if a>=learned.size() or b>=learned.size() or id>=skill_levels.size():return false
	if a>=abilities.size() or b>=abilities.size():return false
	var max_rank:=clampi(int(fusion.get("max_rank",4)),1,4)
	return a!=b and learned[a] and learned[b] and int(skill_levels[id])<max_rank and level>=maxi(int(abilities[a]["req"]),int(abilities[b]["req"])) and gold>=int(fusion["gold"])

static func target_slot(slots:Array,source_a:int,source_b:int,fusion_id:int=-1)->int:
	for i in slots.size():
		if int(slots[i]) in [source_a,source_b,fusion_id]:return i
	for i in slots.size():
		if int(slots[i])<0:return i
	return 0
