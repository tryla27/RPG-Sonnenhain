class_name MovementRules
extends RefCounted

static func effective_move_speed(base_speed: float, race: RaceProfile, character_class: ClassProfile) -> float:
	var race_mult := 1.0 if race == null else race.move_speed_multiplier
	var class_mult := 1.0 if character_class == null else character_class.move_speed_multiplier
	return base_speed * race_mult * class_mult

static func can_roll(character_class: ClassProfile) -> bool:
	return character_class == null or character_class.can_roll

static func effective_roll_speed(base_speed: float, character_class: ClassProfile) -> float:
	if character_class == null:
		return base_speed
	return base_speed * character_class.roll_speed_multiplier

static func effective_roll_distance(base_distance: float, character_class: ClassProfile) -> float:
	if character_class == null:
		return base_distance
	return base_distance * character_class.roll_distance_multiplier
