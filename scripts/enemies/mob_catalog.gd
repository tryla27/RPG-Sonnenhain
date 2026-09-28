extends RefCounted

const MOB_PATHS: Array[String] = [
	"res://data/mobs/waldschleim.tres",
	"res://data/mobs/bluetenkaefer.tres",
	"res://data/mobs/pilzling.tres",
	"res://data/mobs/mooswolf.tres",
	"res://data/mobs/steingolem.tres",
	"res://data/mobs/ruinenbeholder.tres",
	"res://data/mobs/kristallkrabbe.tres",
	"res://data/mobs/kristallgolem.tres",
	"res://data/mobs/aschelaeufer.tres",
	"res://data/mobs/lavagolem.tres",
	"res://data/mobs/strandkrabbe.tres",
	"res://data/mobs/wassergeist.tres",
	"res://data/mobs/turmwaechter.tres",
	"res://data/mobs/kristallhueter.tres",
	"res://data/mobs/aschefuerst.tres",
	"res://data/mobs/sternenschatten.tres",
	"res://data/mobs/bruchwaechter.tres",
	"res://data/mobs/nebelhirsch.tres",
	"res://data/mobs/irrlicht.tres",
	"res://data/mobs/harzbestie.tres",
	"res://data/mobs/wurzelhexe.tres",
	"res://data/mobs/quellkriecher.tres",
	"res://data/mobs/perlengeist.tres",
	"res://data/mobs/gratgreif.tres",
	"res://data/mobs/schattenritter.tres",
	"res://data/mobs/himmelsfalter.tres",
	"res://data/mobs/sternenwaechterin.tres"
]

static func all() -> Array[MobData]:
	var result: Array[MobData] = []
	for path in MOB_PATHS:
		var data := load(path) as MobData
		if data != null:
			result.append(data)
	return result

static func legacy_types() -> Array:
	var result: Array = []
	for data in all():
		result.append(data.to_legacy_dict())
	return result

static func get_data(type_id: int) -> MobData:
	if type_id < 0 or type_id >= MOB_PATHS.size():
		return null
	return load(MOB_PATHS[type_id]) as MobData


static func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	var seen_ids := {}
	for index in MOB_PATHS.size():
		var path := MOB_PATHS[index]
		if not ResourceLoader.exists(path):
			errors.append("Mob-Datei fehlt: %s" % path)
			continue
		var data := load(path) as MobData
		if data == null:
			errors.append("MobData konnte nicht geladen werden: %s" % path)
			continue
		if data.id != index:
			errors.append("Mob-ID falsch: %s hat %d, erwartet %d" % [path, data.id, index])
		if seen_ids.has(data.id):
			errors.append("Doppelte Mob-ID %d" % data.id)
		seen_ids[data.id] = true
		if data.display_name.strip_edges() == "":
			errors.append("Mob ohne Namen: %s" % path)
		if data.base_hp <= 0.0:
			errors.append("%s: HP muss > 0 sein" % data.display_name)
		if data.base_damage < 0:
			errors.append("%s: Schaden darf nicht negativ sein" % data.display_name)
		if data.speed < 0.0:
			errors.append("%s: Geschwindigkeit darf nicht negativ sein" % data.display_name)
		if data.animation_fps <= 0.0:
			errors.append("%s: animation_fps muss > 0 sein" % data.display_name)
		if data.walk_frames.is_empty():
			errors.append("%s: mindestens ein Lauf-Frame erforderlich" % data.display_name)
		if data.ranged and data.ranged_max_distance <= data.ranged_min_distance:
			errors.append("%s: Fernkampf-Reichweite ungültig" % data.display_name)
	return errors
