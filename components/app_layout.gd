extends RefCounted
## Anordnung der App-Steuerung und Zielhilfe-Wahl (Angelo 11.10.2026: „Rift
## mobile“ als Vorbild, alles einbauen). Nur Android-App.
##
## Jeder Knopf hat eine Mitte und einen Maßstab; Standardwerte stehen hier,
## eigene Werte speichert das Gerät unter user://app_controls.cfg. Der Editor
## (app_layout_editor.gd) ändert sie, app_touch.gd liest sie.

const PATH:="user://app_controls.cfg"
const IDS:=["move","attack","ability_1","ability_2","ability_3","ability_4","dodge","interact","heal","resource","chat","inventory","app_menu"]
const LABELS:={"move":"BEWEGEN","attack":"ANGRIFF","ability_1":"SPELL 1","ability_2":"SPELL 2","ability_3":"SPELL 3","ability_4":"SPELL 4","dodge":"ROLLE","interact":"AKTION","heal":"HP","resource":"ENERGIE","chat":"CHAT","inventory":"TASCHE","app_menu":"MENÜ"}
const ATTACK:=Vector2(1046,528)
const SKILL_ARC:=122.0
const SKILL_ANGLES:=[186.0,214.0,242.0,270.0]
## Runde Knöpfe: Radius; Rechtecke: Größe (Stick: Greifradius).
const ROUND:={"move":150.0,"attack":60.0,"ability_1":28.0,"ability_2":28.0,"ability_3":28.0,"ability_4":28.0,"dodge":30.0,"interact":29.0}
const BOXES:={"heal":Vector2(62,40),"resource":Vector2(62,40),"chat":Vector2(64,42),"inventory":Vector2(64,42),"app_menu":Vector2(64,42)}
const DEFAULT_CENTERS:={"move":Vector2(150,500),"dodge":Vector2(940,594),"interact":Vector2(1114,404),"heal":Vector2(777,618),"resource":Vector2(845,618),"chat":Vector2(796,35),"inventory":Vector2(866,35),"app_menu":Vector2(936,35)}
const MIN_SCALE:=0.6
const MAX_SCALE:=1.6
const SCALE_STEP:=0.1

const PRIORITIES:=["nearest","lowest","strongest"]
const PRIORITY_NAMES:={"nearest":"NÄCHSTER","lowest":"WENIGSTES LEBEN","strongest":"STÄRKSTER"}
const PRIORITY_TEXT:={
	"nearest":"Zielt auf den Gegner, der dir am nächsten steht.",
	"lowest":"Zielt auf den Gegner mit den wenigsten Lebenspunkten, gut gegen Schwache im Rudel.",
	"strongest":"Zielt auf den Gegner mit den meisten Lebenspunkten, gut für Bosse.",
}

## id → {"x","y","s"} nur für geänderte Knöpfe.
static var custom:Dictionary={}
static var priority:="nearest"

static func default_center(id:String)->Vector2:
	if id=="attack":return ATTACK
	if id.begins_with("ability_"):
		var slot:=clampi(int(id.get_slice("_",1))-1,0,3)
		var a:=deg_to_rad(float(SKILL_ANGLES[slot]))
		return ATTACK+Vector2(cos(a),sin(a))*SKILL_ARC
	return DEFAULT_CENTERS.get(id,Vector2.ZERO)

static func center(id:String)->Vector2:
	if custom.has(id):
		var c:Dictionary=custom[id]
		return Vector2(float(c["x"]),float(c["y"]))
	return default_center(id)

static func scale(id:String)->float:
	if custom.has(id):return clampf(float((custom[id] as Dictionary).get("s",1.0)),MIN_SCALE,MAX_SCALE)
	return 1.0

static func is_round(id:String)->bool:
	return ROUND.has(id)

## Radius (runde Knöpfe) im aktuellen Maßstab.
static func radius(id:String)->float:
	return float(ROUND.get(id,0.0))*scale(id)

## Größe (Rechtecke) im aktuellen Maßstab.
static func box_size(id:String)->Vector2:
	return (BOXES.get(id,Vector2.ZERO) as Vector2)*scale(id)

static func rect(id:String)->Rect2:
	var size:=box_size(id)
	return Rect2(center(id)-size*0.5,size)

## Ungefähre Fläche eines Knopfs (Auswahlring im Editor).
static func bounds(id:String)->Rect2:
	if is_round(id):
		var r:=radius(id) if id!="move" else 82.0*scale(id)
		return Rect2(center(id)-Vector2(r,r),Vector2(r,r)*2.0)
	return rect(id)

static func set_center(id:String,pos:Vector2)->void:
	var c:Vector2=Vector2(clampf(pos.x,16.0,1136.0),clampf(pos.y,16.0,632.0))
	custom[id]={"x":c.x,"y":c.y,"s":scale(id)}

static func set_scale(id:String,value:float)->void:
	var c:=center(id)
	custom[id]={"x":c.x,"y":c.y,"s":snappedf(clampf(value,MIN_SCALE,MAX_SCALE),0.05)}

static func reset()->void:
	custom.clear()

static func set_priority(value:String)->void:
	if value in PRIORITIES:priority=value

static func is_default()->bool:
	return custom.is_empty()

## Gespeicherte Werte laden (fehlt die Datei: Standard).
static func load_settings(path:String=PATH)->void:
	custom.clear()
	priority="nearest"
	var file:=ConfigFile.new()
	if file.load(path)!=OK:return
	set_priority(str(file.get_value("aim","priority","nearest")))
	for id in IDS:
		if not file.has_section_key("layout",id):continue
		var parts:PackedStringArray=str(file.get_value("layout",id,"")).split(",")
		if parts.size()!=3:continue
		custom[id]={"x":clampf(float(parts[0]),16.0,1136.0),"y":clampf(float(parts[1]),16.0,632.0),"s":clampf(float(parts[2]),MIN_SCALE,MAX_SCALE)}

static func save_settings(path:String=PATH)->void:
	var file:=ConfigFile.new()
	file.set_value("aim","priority",priority)
	for id in custom:
		var c:Dictionary=custom[id]
		file.set_value("layout",str(id),"%.1f,%.1f,%.2f"%[float(c["x"]),float(c["y"]),float(c["s"])])
	file.save(path)
