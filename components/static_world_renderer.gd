extends "res://main.gd"
var prop: Dictionary = {}
## Render existing code-native scenery once. No gameplay, saves, audio or input.
func _ready() -> void:
	set_process(false)
	set_process_input(false)
	set_process_unhandled_input(false)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _process(_delta: float) -> void:
	pass

func _input(_event: InputEvent) -> void:
	pass

func _draw() -> void:
	draw_set_transform(-static_draw_bounds.position)
	if prop.is_empty(): draw_static_overworld(static_draw_bounds)
	else: paint_village_prop(prop)
