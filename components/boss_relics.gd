extends RefCounted
## Stable identity for boss mastery gifts, including already-owned legacy items.
const IDS=["warlord","arcane","hunt"]
const NAMES=["Herz des Kriegsherrn","Arkansplitter","Herz der Jagd"]
const SKILLS=["WUT + BLUTRAUSCH","RISSSPRUNG · LEERTASTE","JAGDRAUSCH + SCHATTENROLLE"]
const ALIASES={"Kriegsherrenblut":0,"Essenz des Kriegsherrn":0,"Essenz des Arkanhüters":1,"Essenz des Dunklen Arkanhüters":1,"Essenz des Jagdmeisters":2}

static func index(item:Dictionary)->int:
	var name:=str(item.get("name",""))
	if name in NAMES:return NAMES.find(name)
	if ALIASES.has(name):return int(ALIASES[name])
	var id:=str(item.get("class_relic_id",""))
	if id in IDS:return IDS.find(id)
	var source:Variant=item.get("mastery_class",-1)
	if item.get("class_relic",false)==true and (source is int or source is float) and is_finite(float(source)) and float(source)==floorf(float(source)) and int(source) in [0,1,2]:return int(source)
	return -1

static func normalize(item:Dictionary)->void:
	var source:=index(item)
	if source<0:
		if item.get("class_relic",false)==true:
			item["class_relic"]=false
			item.erase("mastery_class");item.erase("mastery_skill");item.erase("class_relic_id")
		return
	item["name"]=NAMES[source];item["icon"]="essence"
	item["class_relic"]=true;item["boss_relic"]=true
	item["class_relic_id"]=IDS[source];item["mastery_class"]=source
	item["mastery_skill"]=SKILLS[source]
	item["tooltip"]="Schaltet %s dauerhaft frei." % SKILLS[source]
	for stat in ["power","str","agi","int"]:item[stat]=0
	item.erase("skill_unlock");item["element"]=""
