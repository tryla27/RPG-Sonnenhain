class_name MovementRules
extends RefCounted

static func effective_move_speed(base_speed: float, race: RaceProfile, character_class: ClassProfile) -> float:
	var race_mult := 1.0 if race == null else race.move_speed_multiplier
	var class_mult := 1.0 if character_class == null else character_class.move_speed_multiplier
	return base_speed * race_mult * class_mult

static func can_roll(character_class: ClassProfile) -> bool:
	return character_class == null or character_class.can_roll

static func effective_roll_speed(base_speed: float, race: RaceProfile, character_class: ClassProfile) -> float:
	var race_mult := 1.0 if race == null else race.roll_speed_multiplier
	var class_mult := 1.0 if character_class == null else character_class.roll_speed_multiplier
	return base_speed * race_mult * class_mult

static func effective_roll_distance(base_distance: float, race: RaceProfile, character_class: ClassProfile) -> float:
	var race_mult := 1.0 if race == null else race.roll_distance_multiplier
	var class_mult := 1.0 if character_class == null else character_class.roll_distance_multiplier
	return base_distance * race_mult * class_mult

static func effective_roll_cooldown(base_cooldown: float, race: RaceProfile, character_class: ClassProfile) -> float:
	var race_mult := 1.0 if race == null else race.roll_cooldown_multiplier
	var class_mult := 1.0 if character_class == null else character_class.roll_cooldown_multiplier
	return base_cooldown * race_mult * class_mult
