class_name AtmosphereProfile
extends Resource

@export_group("Schatten")
@export var shadow_opacity: float = 0.35
@export var shadow_softness: float = 0.5

@export_group("Nebel")
@export var fog_density: float = 0.0
@export var fog_color: Color = Color(0.7, 0.8, 0.85, 1.0)

@export_group("Dämmerung")
@export var dusk_strength: float = 0.0
@export var dusk_color: Color = Color(0.55, 0.35, 0.55, 1.0)

@export_group("Licht")
@export var ambient_brightness: float = 1.0
@export var saturation: float = 1.0
