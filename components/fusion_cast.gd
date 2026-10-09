extends RefCounted
# Ablauf einer Fusion beim Wirken (Regel D1, Konzept 9.10.2026):
# Der Träger wird normal gewirkt, die Zweitfähigkeit zündet dort, wo der Träger
# trifft – erster getroffener Gegner, sonst Hindernis, sonst Reichweitenende.
# Ohne angreifenden Träger fliegt ein kurzer Träger-Impuls in Zielrichtung.
# Schutzschilde wirken weiter direkt auf den Spieler (Entscheidung Angelo).
# Nicht hier: die Fähigkeiten selbst (main.gd), Paarregeln (fusion_rules.gd).

const FusionRules=preload("res://components/fusion_rules.gd")

## Höchstens so viele Zündungen pro Wirken (Fächer, Durchschlag, Kette).
const MAX_TRIGGERS:=3
## Erlaubte Zündorte. Spieler- und Landeposition sind verboten.
const ALLOWED_SPAWNS:=["DAMAGE_IMPACT_POSITION","TARGET_POSITION","ATTACKER_POSITION","IMPULSE_IMPACT_POSITION"]
const IMPULSE_SPEED:=760.0
const IMPULSE_LIFE:=0.42
## Reichweitenende sofort wirkender Träger, wenn sie nichts treffen.
const FALLBACK_REACH:={0:155.0,2:100.0,5:170.0,12:165.0,13:255.0,17:200.0,19:185.0,23:157.0,37:185.0,39:175.0}

## Träger und Zweitfähigkeiten einer Paarfusion.
static func plan(a:int,b:int)->Dictionary:
	var template:=FusionRules.template_for_pair(a,b)
	if template.is_empty():return {}
	var carrier:=int(template["carrier"]["spell_id"])
	var impulse:=str(template["spawn_position"])=="IMPULSE_IMPACT_POSITION"
	var secondaries:Array=[a,b] if impulse else [int(template["secondary"]["spell_id"])]
	return {"carrier":carrier,"impulse":impulse,"secondaries":secondaries,"spawn":str(template["spawn_position"])}

## Gemeinsame Zündmarke aller Geschosse und Zonen eines Wirkens. Das Dictionary
## wird geteilt, damit das Limit über alle Teile des Wirkens zählt.
static func tag(fusion_id:int,secondaries:Array,rank:int,power:int,peer:int=0,remote_class:int=0,builtin:int=-1)->Dictionary:
	return {"fusion":fusion_id,"secondaries":secondaries.duplicate(),"rank":clampi(rank,1,4),"power":maxi(1,power),
		"peer":peer,"class":remote_class,"builtin":builtin,"left":MAX_TRIGGERS}

## Verbraucht eine Zündung; false, wenn das Limit erreicht ist.
static func take(fusion_tag:Dictionary)->bool:
	if int(fusion_tag.get("left",0))<=0:return false
	fusion_tag["left"]=int(fusion_tag["left"])-1
	return true

static func impulse_projectile(pos:Vector2,dir:Vector2,fusion_tag:Dictionary)->Dictionary:
	return {"pos":pos,"dir":dir.normalized(),"speed":IMPULSE_SPEED,"life":IMPULSE_LIFE,"damage":0,"kind":2,
		"element":"arkan","hits":[],"trail":[],"impulse":true,"fusion":fusion_tag}

## Zündpunkt für sofort wirkende Träger ohne Treffer: Ende ihrer Reichweite.
static func fallback_point(carrier:int,origin:Vector2,dir:Vector2)->Vector2:
	return origin+dir.normalized()*float(FALLBACK_REACH.get(carrier,160.0))

static func spawn_allowed(spawn:String)->bool:
	return spawn in ALLOWED_SPAWNS
