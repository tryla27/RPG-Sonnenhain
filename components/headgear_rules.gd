extends RefCounted
## One equip rule shared by the client UI and durable server saves.
const BOSS_NAMES=["Helm des Kriegsherrn","Hut des Arkanhüters","Hut des Jagdmeisters"]
static func boss_index(item:Dictionary)->int:
	if str(item.get("icon",""))!="head":return -1
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
