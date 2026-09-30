extends SceneTree

func _initialize() -> void:
	var controls = load("res://components/controller_controls.gd").new()
	var failures := 0
	for raw in [Vector2.ZERO, Vector2(0.05,0.03), Vector2(0.21,0)]:
		if controls.filter_stick(raw) != Vector2.ZERO: failures += 1
	if not controls.filter_stick(Vector2(1,1)).is_equal_approx(Vector2(1,1).normalized()): failures += 1
	if controls.filter_stick(Vector2(0.6,0)).x <= 0 or controls.filter_stick(Vector2(0.6,0)).x >= 1: failures += 1
	var seen := {}
	for action in controls.ACTIONS:
		var code: int = controls.bindings[action]
		if code >= 0 and seen.has(code): failures += 1
		seen[code] = true
		if controls.label(code).is_empty(): failures += 1
	var old_file := FileAccess.get_file_as_bytes(controls.PATH) if FileAccess.file_exists(controls.PATH) else PackedByteArray()
	controls.assign("interact", controls.bindings["dodge"])
	if controls.bindings["interact"] != JOY_BUTTON_A or controls.bindings["dodge"] != JOY_BUTTON_X: failures += 1
	var restored = load("res://components/controller_controls.gd").new()
	restored.setup()
	if restored.bindings != controls.bindings: failures += 1
	if old_file.is_empty(): DirAccess.remove_absolute(controls.PATH)
	else:
		var file := FileAccess.open(controls.PATH, FileAccess.WRITE)
		file.store_buffer(old_file)
	print("CONTROLLER_CHECK failures=", failures, " · deadzone / diagonal limit / unique defaults / swap / persistence")
	quit(1 if failures > 0 else 0)
