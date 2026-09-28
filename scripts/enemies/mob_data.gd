class_name MobData
extends Resource

## Editierbare Daten für genau einen Gegner.
## Richtungs-Sprite-Layout: Zeilen = down, left, right, up.
@export var id: int = 0
@export var display_name: String = "Mob"
@export var region: int = 0
@export var base_hp: float = 10.0
@export var base_damage: int = 1
@export var speed: float = 80.0
@export var xp: int = 1
@export var color_hex: String = "ffffff"

@export_group("Animation")
@export var sprite_row: int = 0
@export var directional_sprite: Texture2D
@export var supports_directions: bool = false
@export var frame_size: Vector2i = Vector2i(32, 32)
@export var idle_frame: int = 0
@export var walk_frames: PackedInt32Array = PackedInt32Array([1, 2])
@export var attack_frame: int = 3
@export var animation_fps: float = 7.0

@export_group("Verhalten")
@export var ranged: bool = false
@export var boss: bool = false

func to_legacy_dict() -> Dictionary:
	return {
		"name": display_name,
		"region": region,
		"hp": base_hp,
		"damage": base_damage,
		"speed": speed,
		"xp": xp,
		"color": Color(color_hex),
		"mob_data": self
	}
