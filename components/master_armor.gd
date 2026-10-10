extends RefCounted
# Legendäre Rüstungen ab Stufe 40 (Konzept docs/konzepte/2026-10-10-ruestungen).
# Daten, Erkennung und Wirkungsregeln, zustandslos. Die Wirkungen greifen in
# main.gd an den bestehenden Stellen (Schaden nehmen/machen, Laufen, Tränke).
# Das Aussehen am Charakter ist der Rüstungsentwurf DESIGN_BASE + id (rpg_hero.gd).

const DESIGN_BASE:=6
const LEVEL:=40
const WIND:=0
const ARKAN:=1
const DORNEN:=2
const BOLLWERK:=3
const BLUTMOND:=4
const STERNENQUELL:=5
const GOLEM:=6

const ARMORS:=[
	{"name":"Windläufer-Harnisch","power":34,"str":0,"agi":24,"int":0,"price":6400,"effect":"+10 % Lauftempo · +10 % Angriffstempo"},
	{"name":"Arkanweber-Robe","power":28,"str":0,"agi":0,"int":26,"price":6800,"effect":"Fähigkeiten kosten 15 % weniger · alle 8 s fängt ein Arkanschild 60 Schaden ab"},
	{"name":"Dornenpanzer","power":40,"str":14,"agi":0,"int":0,"price":7000,"effect":"Wirft 30 % des Nahkampfschadens zurück · 15 % Chance, den Angreifer 1 s festzuwurzeln"},
	{"name":"Bollwerk des Wächters","power":52,"str":18,"agi":0,"int":0,"price":7600,"effect":"12 % Chance, einen Treffer ganz zu blocken · unter 30 % Leben +20 Schutz"},
	{"name":"Blutmond-Mantel","power":30,"str":10,"agi":10,"int":0,"price":7200,"effect":"6 % des Schadens heilt dich (gegen Elite und Bosse 10 %)"},
	{"name":"Sternenquell-Gewand","power":30,"str":0,"agi":12,"int":12,"price":6600,"effect":"+4 Leben/s nach 5 s ohne Treffer · Tränke heilen 25 % mehr"},
	{"name":"Golem-Rüstung","power":100,"str":20,"agi":0,"int":0,"price":0,"effect":"Steinhaut: −10 % Lauftempo · unter 40 % Leben 5 s lang −50 % Schaden (alle 60 s)"},
]
## Torvald verkauft nur die sechs ersten; die Golem-Rüstung gibt es nur vom Dunklen Golem.
const SHOP_IDS:=[0,1,2,3,4,5]
## Klassenbosse: passende Rüstung (Krieger, Magier, Schütze), 10 % Chance.
const CLASS_BOSS_ARMOR:=[BOLLWERK,ARKAN,WIND]
const CLASS_BOSS_CHANCE:=0.10
const ELITE_CHANCE:=0.02
const ELITE_MIN_REGION_LEVEL:=33

static func index(item:Dictionary)->int:
	if str(item.get("icon",""))!="armor":return -1
	if item.has("master_armor"):
		var id:=int(item["master_armor"])
		return id if id>=0 and id<ARMORS.size() else -1
	for i in ARMORS.size():
		if str(item.get("name",""))==str(ARMORS[i]["name"]):return i
	return -1

static func design(id:int)->int:
	return DESIGN_BASE+id if id>=0 else -1

## Rüstungsentwurf (0–12) → Rüstungs-ID (0–6) oder -1. Netz und Server nutzen
## den Entwurf aus dem Spielerzustand ("armor").
static func id_from_design(armor_design:int)->int:
	var id:=armor_design-DESIGN_BASE
	return id if id>=0 and id<ARMORS.size() else -1

## Füllt einen mit make_item erzeugten Gegenstand mit den Werten der Rüstung.
static func apply(item:Dictionary,id:int)->void:
	var info:Dictionary=ARMORS[id]
	item["master_armor"]=id
	item["name"]=info["name"]
	item["icon"]="armor"
	item["rarity"]=4
	item["power"]=int(info["power"])
	item["str"]=int(info["str"]);item["agi"]=int(info["agi"]);item["int"]=int(info["int"])
	item["level"]=LEVEL
	item["design"]=design(id)
	item["tooltip"]=str(info["effect"])

static func shop_offer(id:int)->Dictionary:
	var info:Dictionary=ARMORS[id]
	return {"name":info["name"],"icon":"armor","power":info["power"],"price":info["price"],"rarity":4,"level":LEVEL,"master_armor":id}

## Rotationsangebot bei Torvald (ab Stufe 40), sonst leer.
static func smith_offer(player_level:int,rotation:int)->Dictionary:
	if player_level<LEVEL:return {}
	return shop_offer(SHOP_IDS[posmod(rotation,SHOP_IDS.size())])

# --- Wirkungen -------------------------------------------------------------

static func move_mult(id:int)->float:
	if id==WIND:return 1.10
	if id==GOLEM:return 0.90
	return 1.0

static func attack_speed_mult(id:int)->float:
	return 1.10 if id==WIND else 1.0

static func ability_cost_mult(id:int)->float:
	return 0.85 if id==ARKAN else 1.0

const ARKAN_SHIELD:=60
const ARKAN_SHIELD_COOLDOWN:=8.0
const BLOCK_CHANCE:=0.12
const THORNS:=0.30
const THORN_ROOT_CHANCE:=0.15
const REGEN_DELAY:=5.0
const REGEN_PER_SECOND:=4.0
const GOLEM_GUARD_THRESHOLD:=0.40
const GOLEM_GUARD_TIME:=5.0
const GOLEM_GUARD_COOLDOWN:=60.0

## Zusätzlicher Schutz (Bollwerk bei wenig Leben).
static func bonus_armor(id:int,hp_ratio:float)->int:
	return 20 if id==BOLLWERK and hp_ratio<0.30 else 0

static func block_chance(id:int)->float:
	return BLOCK_CHANCE if id==BOLLWERK else 0.0

## Rückwurf auf den Angreifer bei Nahkampftreffern.
static func thorns_damage(id:int,raw:int)->int:
	return maxi(1,roundi(raw*THORNS)) if id==DORNEN and raw>0 else 0

static func lifesteal(id:int,elite_or_boss:bool)->float:
	if id!=BLUTMOND:return 0.0
	return 0.10 if elite_or_boss else 0.06

static func potion_mult(id:int)->float:
	return 1.25 if id==STERNENQUELL else 1.0

static func regen(id:int,seconds_since_hit:float)->float:
	return REGEN_PER_SECOND if id==STERNENQUELL and seconds_since_hit>=REGEN_DELAY else 0.0
