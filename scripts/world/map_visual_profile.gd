class_name MapVisualProfile
extends Resource

enum TraversalType {
	PASSABLE,
	SOFT_BLOCK,
	HARD_BLOCK,
	WATER,
	WALL
}

@export var traversal_type: TraversalType = TraversalType.PASSABLE
@export var visual_contrast: float = 1.0
@export var shadow_strength: float = 0.0
@export var edge_highlight: float = 0.0
@export var minimap_visible: bool = true
@export var minimap_priority: int = 0
