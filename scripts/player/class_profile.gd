class_name ClassProfile
extends Resource

@export var id: String = "warrior"
@export var display_name: String = "Krieger"

@export_group("Bewegung")
@export var move_speed_multiplier: float = 1.0
@export var can_roll: bool = true
@export var roll_speed_multiplier: float = 1.0
@export var roll_distance_multiplier: float = 1.0
@export var roll_cooldown_multiplier: float = 1.0

@export_group("Kampf")
@export var physical_damage_multiplier: float = 1.0
@export var magic_damage_multiplier: float = 1.0
@export var ranged_damage_multiplier: float = 1.0
