extends RefCounted

# Reines Lesemodell fuer Fusionen.
# Keine Mutation, keine Saves, keine Netzwerk- oder Kampfeffekte.

static func build_indexes(fusions:Array)->Dictionary:
	var by_id:Dictionary={}
	var by_key:Dictionary={}
	for fusion in fusions:
		var id:=int(fusion["id"])
		var a:=int(fusion["a"])
		var b:=int(fusion["b"])
		var low:=mini(a,b)
		var high:=maxi(a,b)
		by_id[id]=fusion
		by_key["%d:%d" % [low,high]]=fusion
	return {"by_id":by_id,"by_key":by_key}

static func definition_by_id(indexes:Dictionary,fusion_id:int)->Dictionary:
	var raw:Variant=indexes.get("by_id",{}).get(fusion_id,{})
	return raw.duplicate(true) if raw is Dictionary else {}

static func definition_by_key(indexes:Dictionary,key:String)->Dictionary:
	var raw:Variant=indexes.get("by_key",{}).get(key,{})
	return raw.duplicate(true) if raw is Dictionary else {}

static func impact_profile(profiles:Dictionary,fusion_id:int)->Dictionary:
	var raw:Variant=profiles.get(fusion_id,{})
	return raw.duplicate(true) if raw is Dictionary else {}

static func spawn_rule(profiles:Dictionary,fusion_id:int)->String:
	return str(impact_profile(profiles,fusion_id).get("spawn",""))

static func missing_sources(fusion:Dictionary,learned:Array,abilities:Array)->Array[String]:
	var missing:Array[String]=[]
	for source_id in [int(fusion["a"]),int(fusion["b"])]:
		if source_id<0 or source_id>=learned.size() or not learned[source_id]:
			var name:=""
			if source_id>=0 and source_id<abilities.size():
				name=str(abilities[source_id].get("name",""))
			missing.append(name)
	return missing

static func offer_index(offers:Array,fusion_id:int)->int:
	for i in offers.size():
		if int(offers[i]["id"])==fusion_id:return i
	return -1
