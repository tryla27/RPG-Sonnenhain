extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://main.gd").new()
	root.add_child(game)
	game.konflux_preview_mode = true
	game.bindings = game.DEFAULT_BINDINGS.duplicate()
	var failures := 0
	var notice = load("res://components/patch_notice.gd").new()
	if not notice.consume("patch-1") or notice.consume("patch-1") or notice.consume(" "): failures += 1
	if not notice.consume("patch-2") or notice.consume("patch-2"): failures += 1
	var seen := {}
	for action in game.BIND_ACTIONS:
		var code: int = game.bindings[action]
		if code == 0 or seen.has(code): failures += 1
		seen[code] = true
		if action.begins_with("move_") or action == "attack": continue
		var event: InputEvent
		if code < 0:
			event = InputEventMouseButton.new()
			event.button_index = -code
		else:
			event = InputEventKey.new()
			event.keycode = code
		if not game.event_matches_binding(event, action): failures += 1
	var rules = load("res://components/experience_rules.gd")
	if not is_equal_approx(rules.multiplier(10,10),1.0): failures += 1
	if not is_equal_approx(rules.multiplier(15,10),0.32768): failures += 1
	if not is_equal_approx(rules.multiplier(10,15),1.4): failures += 1
	if rules.multiplier(1,100) > 1.5: failures += 1
	for mob in game.ENEMY_TYPES.size():
		var previous := 100000
		for hero_level in range(1,101):
			var reward: int = game.enemy_xp_reward(mob,0,hero_level)
			if reward > previous or reward < 0: failures += 1
			previous = reward
	if game.enemy_xp_reward(0,0,30) != 0: failures += 1
	if game.enemy_xp_reward(25,0,40) <= game.enemy_xp_reward(0,0,40): failures += 1
	game.konflux.enter(game)
	game.player_pos = game.KonfluxMap.CENTER
	game.konflux.interact(game)
	if game.konflux.active or game.player_pos != game.WAYSTONES[0]+Vector2(0,105): failures += 1
	game.konflux.enter(game)
	game.player_pos = game.KonfluxMap.CENTER
	game.use_waystone()
	if game.konflux.active or game.player_pos != game.WAYSTONES[0]+Vector2(0,105): failures += 1
	print("PROGRESSION_CONTROLS_CHECK failures=",failures," · 23 bindings / 2700 XP comparisons / spawn return E+F")
	game.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)
