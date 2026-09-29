class_name RaceProfile
extends Resource

@export var id: String = "human"
@export var display_name: String = "Mensch"

@export_group("Bewegung")
@export var move_speed_multiplier: float = 1.0
@export var acceleration_multiplier: float = 1.0
@export var roll_speed_multiplier: float = 1.0
@export var roll_distance_multiplier: float = 1.0
@export var roll_cooldown_multiplier: float = 1.0

@export_group("Kampf")
@export var max_hp_multiplier: float = 1.0
@export var physical_damage_multiplier: float = 1.0
@export var melee_damage_multiplier: float = 1.0
@export var hand_weapon_damage_multiplier: float = 1.0
@export var defense_multiplier: float = 1.0

@export_group("Darstellung")
@export var body_scale: float = 1.0
