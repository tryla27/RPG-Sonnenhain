extends "res://components/controller_controls.gd"
var connected := true
var buttons: Dictionary = {}
var left := Vector2.ZERO
var right := Vector2.ZERO
var save_calls := 0

func connected_devices() -> Array[int]:
	var devices: Array[int] = []
	if connected: devices.append(0)
	return devices

func code_pressed(code: int) -> bool:
	return enabled and focused and device >= 0 and bool(buttons.get(code,false))

func stick(aim := false) -> Vector2:
	return filter_stick(right if aim else left) if enabled and focused and device >= 0 else Vector2.ZERO

func save() -> void:
	save_calls += 1
