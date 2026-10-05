extends RefCounted

# Autoritative Metadaten fuer die universelle Fusionsplanung.
# Passives, Ultimates, reine Bewegung und bereits erzeugte Fusionen sind keine Zutaten.
const EXCLUDED := {
	9:"PASSIVE",10:"PASSIVE",11:"PASSIVE",
	15:"ULTIMATE",24:"ULTIMATE",33:"ULTIMATE",
	27:"PURE_MOVEMENT",
	40:"FUSION_OUTPUT",41:"FUSION_OUTPUT",42:"FUSION_OUTPUT",43:"FUSION_OUTPUT"
}

const META := {
	0:{"element":"physisch","form":"melee_aoe","signature":"wirbel","damage":true,"role":"damage"},
	1:{"element":"neutral","form":"shield","signature":"block","damage":false,"role":"support"},
	2:{"element":"physisch","form":"jump","signature":"stun_landung","damage":true,"role":"control"},
	3:{"element":"physisch","form":"projectile","signature":"pierce","damage":true,"role":"damage"},
	4:{"element":"neutral","form":"self_buff","signature":"damage_buff","damage":false,"role":"support"},
	5:{"element":"physisch","form":"melee_impact","signature":"stun","damage":true,"role":"control"},
	6:{"element":"neutral","form":"self_buff","signature":"lifesteal","damage":false,"role":"support"},
	7:{"element":"physisch","form":"multi_projectile","signature":"triple_blade","damage":true,"role":"damage"},
	8:{"element":"neutral","form":"self_buff","signature":"heal_guard","damage":false,"role":"support"},
	12:{"element":"eis","form":"melee_impact","signature":"slow","damage":true,"role":"control"},
	13:{"element":"blitz","form":"chain","signature":"chain_3","damage":true,"role":"damage"},
	14:{"element":"gift","form":"self_buff","signature":"poison_weapon","damage":false,"role":"support"},
	16:{"element":"feuer","form":"projectile","signature":"explosion","damage":true,"role":"damage"},
	17:{"element":"eis","form":"zone","signature":"slow_nova","damage":true,"role":"control"},
	18:{"element":"blitz","form":"beam","signature":"pierce","damage":true,"role":"damage"},
	19:{"element":"arkan","form":"zone","signature":"pressure_wave","damage":true,"role":"damage"},
	20:{"element":"arkan","form":"multi_projectile","signature":"homing_triple","damage":true,"role":"damage"},
	21:{"element":"eis","form":"reactive_shield","signature":"freeze_attacker","damage":false,"role":"reactive"},
	22:{"element":"feuer","form":"targeted_zone","signature":"meteor_field","damage":true,"role":"damage"},
	23:{"element":"elementar","form":"zone","signature":"ice_lightning_fire","damage":true,"role":"damage"},
	25:{"element":"physisch","form":"projectile","signature":"precision_pierce","damage":true,"role":"damage"},
	26:{"element":"physisch","form":"multi_projectile","signature":"fan_3","damage":true,"role":"damage"},
	28:{"element":"gift","form":"projectile","signature":"poison_cloud","damage":true,"role":"damage"},
	29:{"element":"eis","form":"projectile","signature":"frost_burst","damage":true,"role":"control"},
	30:{"element":"blitz","form":"projectile","signature":"chain_hit","damage":true,"role":"damage"},
	31:{"element":"physisch","form":"targeted_zone","signature":"arrow_rain","damage":true,"role":"damage"},
	32:{"element":"neutral","form":"target","signature":"mark","damage":false,"role":"target"},
	34:{"element":"blitz","form":"projectile","signature":"energy_shot","damage":true,"role":"damage"},
	35:{"element":"neutral","form":"self_heal","signature":"repair","damage":false,"role":"support"},
	36:{"element":"neutral","form":"shield","signature":"energy_guard","damage":false,"role":"support"},
	37:{"element":"blitz","form":"zone","signature":"tesla_wave","damage":true,"role":"damage"},
	38:{"element":"neutral","form":"self_buff","signature":"overclock","damage":false,"role":"support"},
	39:{"element":"blitz","form":"zone","signature":"emp_stun","damage":true,"role":"control"}
}

const CARRIER_PRIORITY := {
	"beam":110,"projectile":105,"multi_projectile":100,"targeted_zone":95,
	"jump":90,"melee_impact":85,"melee_aoe":82,"chain":80,"zone":75,
	"target":55,"reactive_shield":35,"shield":25,"self_buff":20,"self_heal":20
}

static func is_fusible(id:int)->bool:
	return META.has(id) and not EXCLUDED.has(id)

static func normalized_key(a:int,b:int)->String:
	return "%d:%d" % [mini(a,b),maxi(a,b)]

# Pair IDs remain stable when additional spells are appended. Existing recipes
# retain their save IDs (40–43); generated outputs never become ingredients.
static func output_id(a:int,b:int)->int:
	var low:=mini(a,b)
	var high:=maxi(a,b)
	# Reserve 0–999 for authored spells so new source IDs cannot collide with outputs.
	return 1000+int(high*(high-1)/2)+low

static func registry_capacity()->int:
	var capacity:=44
	for a in META:
		for b in META:
			if int(a)<int(b):capacity=maxi(capacity,output_id(int(a),int(b))+1)
	return capacity

static func catalog(abilities:Array,existing:Array)->Array:
	var recipes:Array=[]
	var known:Dictionary={}
	for recipe in existing:
		known[normalized_key(int(recipe["a"]),int(recipe["b"]))]=recipe
	for a in abilities.size():
		if not is_fusible(a):continue
		for b in range(a+1,abilities.size()):
			var template:=template_for_pair(a,b)
			if template.is_empty():continue
			var key:=normalized_key(a,b)
			var recipe:Dictionary=known[key].duplicate(true) if known.has(key) else {
				"id":output_id(a,b),"a":a,"b":b,"max_rank":4,
				"gold":600+50*maxi(int(abilities[a]["req"]),int(abilities[b]["req"]))}
			recipe["template"]=template
			recipe["execution"]="CARRIER_IMPACT" if known.has(key) else "COMPOSITE_CAST"
			recipes.append(recipe)
	return recipes

static func abilities_with_fusions(base:Array,recipes:Array)->Array:
	var result:Array=base.duplicate(true)
	for recipe in recipes:
		var id:=int(recipe["id"])
		if id<base.size():continue
		while result.size()<=id:result.append({"name":"", "cd":0.0,"cost":0,"req":999999})
		var a:Dictionary=base[int(recipe["a"])]
		var b:Dictionary=base[int(recipe["b"])]
		result[id]={"name":"%s · %s" % [a["name"],b["name"]],"kind":id,
			"desc":"Vereint beide Ausgangsspells in einem gemeinsamen Einsatz.",
			"cd":maxf(float(a["cd"]),float(b["cd"]))*1.30,
			"cost":ceili((float(a["cost"])+float(b["cost"]))*0.675),
			"req":maxi(int(a["req"]),int(b["req"]))}
	return result

static func metadata(id:int)->Dictionary:
	var raw:Variant=META.get(id,{})
	return raw.duplicate(true) if raw is Dictionary else {}

static func carrier_score(id:int)->int:
	var meta:=metadata(id)
	if meta.is_empty():return -1
	var score:=int(CARRIER_PRIORITY.get(str(meta.get("form","")),0))
	if bool(meta.get("damage",false)):score+=200
	return score

static func choose_carrier(a:int,b:int)->int:
	var score_a:=carrier_score(a)
	var score_b:=carrier_score(b)
	if score_a==score_b:return mini(a,b)
	return a if score_a>score_b else b

static func trigger_for_carrier(id:int)->String:
	var meta:=metadata(id)
	var form:=str(meta.get("form",""))
	if form=="jump":return "ON_LAND"
	if bool(meta.get("damage",false)):return "ON_HIT"
	if str(meta.get("role",""))=="target":return "ON_TARGET"
	if str(meta.get("role",""))=="reactive":return "ON_BLOCK"
	return "ON_CAST"

static func spawn_for_carrier(id:int)->String:
	var meta:=metadata(id)
	var form:=str(meta.get("form",""))
	if form=="jump":return "LANDING_POSITION"
	if bool(meta.get("damage",false)):return "DAMAGE_IMPACT_POSITION"
	if str(meta.get("role",""))=="target":return "TARGET_POSITION"
	if str(meta.get("role",""))=="reactive":return "ATTACKER_POSITION"
	return "PLAYER_POSITION"

static func reaction_for_pair(a:int,b:int)->String:
	var ma:=metadata(a);var mb:=metadata(b)
	var ea:=str(ma.get("element","neutral"));var eb:=str(mb.get("element","neutral"))
	var pair:=[ea,eb];pair.sort()
	var key:="%s:%s" % [pair[0],pair[1]]
	match key:
		"eis:feuer":return "THERMAL_SHOCK"
		"blitz:eis":return "CONDUCTIVE_FREEZE"
		"feuer:gift":return "TOXIC_COMBUSTION"
		"blitz:gift":return "CHARGED_TOXIN"
		"arkan:blitz":return "ARCANE_OVERLOAD"
		"arkan:eis":return "RIFT_FREEZE"
		"arkan:feuer":return "RIFT_IGNITION"
	if ea!="neutral" and eb=="neutral" or eb!="neutral" and ea=="neutral":return "SIGNATURE_INFUSION"
	return "SIGNATURE_ECHO"

static func template_for_pair(a:int,b:int)->Dictionary:
	if a==b or not is_fusible(a) or not is_fusible(b):return {}
	var carrier:=choose_carrier(a,b)
	var secondary:=b if carrier==a else a
	var ma:=metadata(a);var mb:=metadata(b)
	return {
		"key":normalized_key(a,b),
		"source_a":mini(a,b),
		"source_b":maxi(a,b),
		"carrier":{"spell_id":carrier,"form":str(metadata(carrier).get("form",""))},
		"secondary":{"spell_id":secondary,"signature":str(metadata(secondary).get("signature",""))},
		"trigger":trigger_for_carrier(carrier),
		"spawn_position":spawn_for_carrier(carrier),
		"inherits":{
			"a_element":str(ma.get("element","neutral")),
			"a_signature":str(ma.get("signature","")),
			"b_element":str(mb.get("element","neutral")),
			"b_signature":str(mb.get("signature",""))
		},
		"fusion_reaction":reaction_for_pair(a,b),
		"trigger_limits":{"internal_cooldown":0.5,"max_active":2,"first_hit_only":false},
		"balance":{"energy_multiplier":1.35,"cooldown_multiplier":1.30,"power_multiplier":1.45},
		"ranks":{
			1:"Grundfusion beider Signaturen",
			2:"Signatur von Quelle A verstaerkt",
			3:"Signatur von Quelle B verstaerkt",
			4:"Einzigartige Fusionsreaktion freigeschaltet"
		}
	}
