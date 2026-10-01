extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func button(pad, game, code: int, down: bool) -> void:
	pad.buttons[code] = down
	var event := InputEventJoypadButton.new()
	event.device = 0
	event.button_index = code
	event.pressed = down
	pad.handle(game,event)
	pad.update(game,1.0/60.0)

func run() -> void:
	var game = load("res://main.gd").new()
	root.add_child(game)
	game.konflux_preview_mode = true
	game.panel = ""
	game.creative_mode = true
	game.character_created = true
	var pad = load("res://tools/controller_fake.gd").new()
	game.controller = pad
	pad.update(game,0.016)
	var failures := 0
	# The keyboard E action and controller X must open the same real village gate.
	game.konflux.active = false
	game.interior_id = -1
	game.dungeon_id = -1
	game.arena_mode = ""
	var gate: Vector2 = game.VILLAGE_GATES[0]
	game.player_pos = gate
	game.opened_village_gates.erase(gate)
	button(pad,game,JOY_BUTTON_X,true)
	if not game.opened_village_gates.get(gate,false): failures += 1
	button(pad,game,JOY_BUTTON_X,false)
	# A remapped interaction must also work; the former button must no longer open it.
	pad.assign("interact",JOY_BUTTON_Y)
	button(pad,game,JOY_BUTTON_Y,false)
	game.opened_village_gates.erase(gate)
	button(pad,game,JOY_BUTTON_X,true)
	if game.opened_village_gates.get(gate,false): failures += 1
	button(pad,game,JOY_BUTTON_X,false)
	button(pad,game,JOY_BUTTON_Y,true)
	if not game.opened_village_gates.get(gate,false): failures += 1
	button(pad,game,JOY_BUTTON_Y,false)
	pad.bindings = pad.DEFAULT.duplicate()
	pad.save_calls = 0
	button(pad,game,JOY_BUTTON_START,true)
	if game.panel != "pause": failures += 1
	button(pad,game,JOY_BUTTON_START,false)
	button(pad,game,JOY_BUTTON_START,true)
	if game.panel != "": failures += 1 # Must not reopen on the same press.
	button(pad,game,JOY_BUTTON_START,false)
	game.panel = "pause"
	pad.pointer = Vector2(745,176)
	game.dash_timer = 0
	button(pad,game,JOY_BUTTON_A,true)
	if game.panel != "" or game.dash_timer > 0 or pad.pressed("dodge"): failures += 1
	button(pad,game,JOY_BUTTON_A,false)
	button(pad,game,JOY_BUTTON_A,true)
	if game.dash_timer <= 0: failures += 1
	button(pad,game,JOY_BUTTON_A,false)
	game.dash_timer = 0
	pad.left = Vector2(0.1,0.1)
	if game.movement_vector() != Vector2.ZERO: failures += 1
	pad.left = Vector2(1,1)
	if game.movement_vector().length() > 1.001: failures += 1
	pad.enabled = false
	if game.movement_vector() != Vector2.ZERO or pad.pressed("dodge"): failures += 1
	pad.enabled = true
	pad.focused = false
	if game.movement_vector() != Vector2.ZERO: failures += 1
	pad.focused = true
	pad.left = Vector2.ZERO
	pad.right = Vector2(-1,0)
	pad.used = true
	game.touch_enabled = true
	game.konflux.enter(game)
	game.update_player(0.016)
	if game.facing.distance_to(Vector2.LEFT) > 0.01: failures += 1
	pad.buttons[102] = true
	if not game.attack_input_active(): failures += 1 # Gamepad on a touch-capable browser.
	pad.buttons.clear()
	game.panel = "skills"
	game.menu_scroll = 0
	button(pad,game,JOY_BUTTON_RIGHT_SHOULDER,true)
	if game.menu_scroll != 1: failures += 1
	button(pad,game,JOY_BUTTON_RIGHT_SHOULDER,false)
	game.panel = "controller"
	pad.click(game,Vector2(830,140))
	if pad.enabled: failures += 1
	pad.click(game,Vector2(830,140))
	if not pad.enabled or pad.save_calls != 2: failures += 1
	pad.connected = false
	pad.update(game,0.016)
	if pad.device != -1 or pad.used or not pad.held.is_empty(): failures += 1
	pad.connected = true
	pad.update(game,0.016)
	if pad.device != 0: failures += 1
	print("CONTROLLER_FLOWS_CHECK failures=",failures," · start / confirm / roll / drift / diagonal / disable / focus / touch aiming / attack / scrolling / hotplug")
	game.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)
