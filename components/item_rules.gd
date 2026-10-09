extends RefCounted
## Zustandslose Gegenstandsregeln: Erzeugung von Gegenständen und Beute,
## Stapelgrößen, Verkaufswert, Anzeigenamen, Elementfarben und Formvarianten.
##
## Laufender Spielzustand (nächste UID, Heldenstufe, Klasse) wird von main.gd
## übergeben; main.gd stellt alle bisherigen Methoden unter denselben Namen
## bereit. Zufall läuft weiterhin über den globalen Zufallsgenerator, damit
## sich Beutechancen nicht verändern.
## Siehe docs/architecture/main-modularization.md, Schritt 2.

const GameContent = preload("res://components/game_content.gd")
const BossRelics=preload("res://components/boss_relics.gd")
const ArcaneNecklaces = preload("res://components/arcane_necklaces.gd")
const FoodSystem = preload("res://components/food_system.gd")

const WEAPON_ICONS := ["sword", "staff", "bow"]
const LOOT_RANKS := ["Alte", "Feine", "Seltene", "Epische", "Legendäre"]
const LOOT_WORDS := {"sword":"Klinge", "staff":"Stab", "bow":"Bogen", "gem":"Essenz", "ring":"Ring", "armor":"Rüstung", "herb":"Kräuter"}

## Baut einen neuen Gegenstand. uid und item_level kommen vom Aufrufer.
static func build_item(uid: int, name: String, icon: String, rarity: int, power: int, value: int, element: String, item_level: int) -> Dictionary:
	var ilvl := maxi(1, item_level)
	var bonus: int = maxi(0, rarity + int(ilvl / 9.0))
	var strength: int = bonus if icon == "sword" else (int(bonus / 2.0) if icon in ["armor", "ring", "necklace"] else 0)
	var agility: int = bonus if icon == "bow" else (int(bonus / 2.0) if icon in ["armor", "ring", "necklace"] else 0)
	var intellect: int = bonus if icon == "staff" else (int(bonus / 2.0) if icon in ["armor", "ring", "necklace"] else 0)
	var fair_value := value if icon == "potion" else 10 + ilvl * 4 + maxi(0, power) * (3 if icon in ["sword", "staff", "bow"] else 2) + rarity * rarity * 32 + (25 if element != "" else 0) + (strength + agility + intellect) * 5
	var item := {"uid":uid, "name":name, "icon":icon, "rarity":rarity, "power":power, "value":fair_value, "element":element, "level":ilvl, "str":strength, "agi":agility, "int":intellect, "count":1, "design":absi(hash(name)) % 4, "locked":false}
	if icon == "food":
		item["value"] = value
		item["design"] = maxi(0,FoodSystem.index_for(name))
	BossRelics.normalize(item)
	ArcaneNecklaces.normalize(item)
	return item

## Würfelt die Werte eines Beutegegenstands für einen Gegnertyp aus.
## Ergebnis: name, icon, rarity, power, element, level (für build_item).
static func roll_loot(type: int, area_level: int, loot_weapon: String) -> Dictionary:
	var chance := randf()
	var rarity := 0
	if area_level >= 30 and chance < 0.0008: rarity = 4
	elif area_level >= 16 and chance < 0.025: rarity = 3
	elif chance < 0.13: rarity = 2
	elif chance < 0.47: rarity = 1
	var name: String = GameContent.ENEMY_TYPES[type]["name"]
	var rank: String = LOOT_RANKS[rarity]
	var icon: String = [loot_weapon, "gem", "ring", "armor", "herb"][randi_range(0, 4)]
	var item_name: String = "%s %s" % [rank, LOOT_WORDS[icon]]
	if icon=="herb":
		var herb_info:Dictionary=FoodSystem.herb_for_region(int(GameContent.ENEMY_TYPES[type]["region"]))
		if not herb_info.is_empty():item_name=str(herb_info["name"])
	elif rarity >= 3:
		item_name = "%s des %s" % [item_name, name]
	var strength: int = (3 + area_level * 2 + rarity * 5 if icon in ["sword", "staff", "bow"] else (1 + int(area_level / 5) + rarity * 2 if icon == "armor" else (8 + area_level + rarity * 4 if icon == "ring" else 0)))
	var element := ""
	if icon in ["sword", "staff", "bow"] and rarity >= 1 and randf() < 0.32:
		element = "gift" if type in [2, 3, 10] else ("eis" if type in [6, 7, 11] else ("blitz" if type in [5, 8, 9] else ["eis", "blitz", "gift"].pick_random()))
		item_name = "%s · %s" % [item_name, element.capitalize()]
	return {"name":item_name, "icon":icon, "rarity":rarity, "power":strength, "element":element, "level":area_level}

static func class_weapon_icon_for(value: int) -> String:
	return WEAPON_ICONS[clampi(value, 0, 2)]

static func stack_limit(item: Dictionary) -> int:
	var icon: String = str(item.get("icon", ""))
	if icon == "food": return 30
	if icon == "potion": return 16
	if icon=="necklace" and ArcaneNecklaces.index(item)==6 and int(item.get("count",1))==1:return 1
	if icon in ["gem", "herb", "essence", "necklace"]: return 1000000000
	return 1

static func item_sale_value(item: Dictionary) -> int:
	return int(item.get("stack_value", int(item.get("value", 0)) * int(item.get("count", 1))))

static func item_skill_unlock_id(item: Dictionary) -> int:
	BossRelics.normalize(item)
	ArcaneNecklaces.normalize(item)
	if ArcaneNecklaces.index(item)>=0:return -1
	var explicit:=int(item.get("skill_unlock",-1))
	if explicit>=0:return explicit
	var item_name:=str(item.get("name",""))
	var element:=str(item.get("element","")).to_lower()
	# Backward compatibility for already-owned Arkankern items from older saves.
	if item_name.begins_with("Arkankern") and element=="blitz":
		return 18 # Blitzlanze
	return -1

static func item_type(icon: String) -> String:
	match icon:
		"necklace": return "Arkanhalskette"
		"sword": return "Waffe"
		"staff": return "Stab"
		"bow": return "Bogen"
		"food": return "Nahrung"
		"potion": return "Trank"
		"gem": return "Kristall"
		"ring": return "Schmuck"
		"armor": return "Rüstung"
		"head": return "Kopfausrüstung"
		"herb": return "Kräuter"
		_: return "Gegenstand"

static func element_color(element: String) -> Color:
	match element:
		"feuer": return Color("ff9147")
		"eis": return Color("a3e9fb")
		"blitz": return Color("ffe480")
		"gift": return Color("b3e978")
		_: return Color("f5e9cc")

static func weapon_visual_stage(item: Dictionary) -> int:
	# Jede neue Ausrüstungsstufe verfeinert Form und Verzierung, nicht nur den Farbton.
	return clampi(int((int(item.get("level", 1)) + int(item.get("rarity", 0)) * 2) / 10.0), 0, 4)

static func item_design(item: Dictionary) -> int:
	if item.get("icon")=="necklace":return maxi(0,ArcaneNecklaces.index(item))
	if item.get("icon")=="food": return maxi(0,FoodSystem.index_for(str(item.get("name",""))))
	return clampi(int(item.get("design", absi(hash(String(item.get("name", "Ausrüstung")))) % 12)), 0, 11)
