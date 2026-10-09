extends RefCounted
## One equip rule shared by the client UI and durable server saves.
const BOSS_NAMES=["Helm des Kriegsherrn","Hut des Dunklen Arkanhüters","Hut des Jagdmeisters"]
static func boss_index(item:Dictionary)->int:
	if str(item.get("icon",""))!="head":return -1
	if str(item.get("name",""))=="Hut des Arkanhüters":return 1
	var named:int=BOSS_NAMES.find(str(item.get("name","")))
	if named>=0:return named
	var source:int=int(item.get("head_class",-1))
	return source if item.get("boss_hat",false)==true and source in [0,1,2] else -1
static func allowed(item:Dictionary,hero_class:int)->bool:
	return str(item.get("icon",""))=="head" and (boss_index(item)>=0 or int(item.get("head_class",-1))==hero_class)
static func normalize(item:Dictionary)->void:
	var source:int=boss_index(item)
	if source<0:return
	item["boss_hat"]=true
	item["head_class"]=source
	item["design"]=source
	item["name"]=BOSS_NAMES[source]

## Hut des Jagdmeisters: „Ewige Pfeile“. Normale Pfeile des Schützen fliegen
## weiter, bis sie einen Gegner oder ein Hindernis treffen.
const ETERNAL_ARROWS_NAME:="Ewige Pfeile"
const ETERNAL_ARROWS_TEXT:="Ewige Pfeile · Deine Pfeile fliegen weiter, bis sie etwas treffen."
## Sicherheitsgrenze, damit Pfeile ins Leere nicht ewig leben (gut 5000 px).
const ETERNAL_ARROW_LIFE:=8.0
const ARROW_LIFE:=1.2

static func grants_eternal_arrows(item:Dictionary)->bool:
	return boss_index(item)==2

static func eternal_arrows(inventory:Array,equipped_head_uid:int,hero_class:int)->bool:
	if hero_class!=2 or equipped_head_uid<0:return false
	for item in inventory:
		if item is Dictionary and int(item.get("uid",-1))==equipped_head_uid:return grants_eternal_arrows(item)
	return false

static func arrow_life(eternal:bool)->float:
	return ETERNAL_ARROW_LIFE if eternal else ARROW_LIFE
