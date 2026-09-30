extends RefCounted

const PATH := "user://sonnenhain_controller.cfg"
const ACTIONS := ["attack", "dodge", "interact", "ability_1", "ability_2", "ability_3", "ability_4", "heal", "resource", "waystone", "skills", "inventory", "journal", "map", "pause"]
const DEFAULT := {"attack":102, "dodge":0, "interact":2, "ability_1":JOY_BUTTON_LEFT_SHOULDER, "ability_2":JOY_BUTTON_RIGHT_SHOULDER, "ability_3":101, "ability_4":3, "heal":11, "resource":12, "waystone":13, "skills":14, "inventory":JOY_BUTTON_BACK, "journal":JOY_BUTTON_LEFT_STICK, "map":JOY_BUTTON_RIGHT_STICK, "pause":JOY_BUTTON_START}
var bindings: Dictionary = DEFAULT.duplicate()
var device := -1
var deadzone := 0.22
var awaiting := ""
var status := "Linker Stick: laufen · rechter Stick: zielen"
var pointer := Vector2(576, 324)
var used := false
var held: Dictionary = {}

func setup() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK: return
	deadzone = clampf(float(cfg.get_value("controller", "deadzone", 0.22)), 0.1, 0.4)
	for action in ACTIONS:
		var code := int(cfg.get_value("bindings", action, DEFAULT[action]))
		if code in [-1, 101, 102] or (code >= 0 and code < JOY_BUTTON_MAX): bindings[action] = code

func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("controller", "deadzone", deadzone)
	for action in ACTIONS: cfg.set_value("bindings", action, bindings[action])
	cfg.save(PATH)

func stick(right := false) -> Vector2:
	if device < 0: return Vector2.ZERO
	var raw := Vector2(Input.get_joy_axis(device, JOY_AXIS_RIGHT_X if right else JOY_AXIS_LEFT_X), Input.get_joy_axis(device, JOY_AXIS_RIGHT_Y if right else JOY_AXIS_LEFT_Y))
	return filter_stick(raw)

func filter_stick(raw: Vector2) -> Vector2:
	var length := raw.length()
	if length <= deadzone: return Vector2.ZERO
	return raw.normalized() * clampf((length - deadzone) / (1.0 - deadzone), 0.0, 1.0)

func code_pressed(code: int) -> bool:
	if device < 0 or code < 0: return false
	if code == 101 or code == 102:
		return Input.get_joy_axis(device, JOY_AXIS_TRIGGER_LEFT if code == 101 else JOY_AXIS_TRIGGER_RIGHT) > 0.55
	return Input.is_joy_button_pressed(device, code)

func pressed(action: String) -> bool:
	return code_pressed(int(bindings.get(action, -1)))

func label(code: int) -> String:
	if code == -1: return "NICHT BELEGT"
	if code == 101: return "LT / L2"
	if code == 102: return "RT / R2"
	var names := {0:"A / Kreuz", 1:"B / Kreis", 2:"X / Quadrat", 3:"Y / Dreieck", 9:"LB / L1", 10:"RB / R1", 4:"Zurück / Select", 5:"Guide", 7:"L3", 8:"R3", 6:"Start / Options", 11:"D-Pad oben", 12:"D-Pad unten", 13:"D-Pad links", 14:"D-Pad rechts"}
	return str(names.get(code, "Taste %d" % code))

func assign(action: String, code: int) -> void:
	var previous := int(bindings[action])
	for other in ACTIONS:
		if other != action and int(bindings[other]) == code and code >= 0: bindings[other] = previous
	bindings[action] = code
	awaiting = ""
	status = "Belegung gespeichert: " + label(code)
	save()

func handle(g, event: InputEvent) -> bool:
	if not (event is InputEventJoypadButton or event is InputEventJoypadMotion): return false
	device = event.device
	used = true
	if not awaiting.is_empty():
		if event is InputEventJoypadButton and event.pressed: assign(awaiting, event.button_index)
		elif event is InputEventJoypadMotion and event.axis in [JOY_AXIS_TRIGGER_LEFT, JOY_AXIS_TRIGGER_RIGHT] and event.axis_value > 0.65:
			assign(awaiting, 101 if event.axis == JOY_AXIS_TRIGGER_LEFT else 102)
		return true
	if event is InputEventJoypadButton and event.pressed and (g.panel != "" or g.chat_open):
		if event.button_index == JOY_BUTTON_B or event.button_index == JOY_BUTTON_START:
			if g.panel == "controller": g.panel = "pause"
			elif g.panel not in ["start", "creation"]: g.panel = ""
			g.chat_open = false
		elif event.button_index == JOY_BUTTON_A:
			if g.panel == "intro": g.finish_intro()
			else: g.handle_panel_click(pointer)
	return true

func update(g, delta: float) -> void:
	var pads := Input.get_connected_joypads()
	if not pads.has(device):
		device = int(pads[0]) if not pads.is_empty() else -1
		if device < 0:
			held.clear()
			used = false
			return
	var move := stick()
	if move.length_squared() > 0.0 or stick(true).length_squared() > 0.0: used = true
	if g.panel != "":
		pointer += move * delta * 650.0
		pointer = pointer.clamp(Vector2(140, 90), Vector2(1005, 600))
		if code_pressed(JOY_BUTTON_DPAD_UP): pointer.y -= delta * 400
		if code_pressed(JOY_BUTTON_DPAD_DOWN): pointer.y += delta * 400
		if code_pressed(JOY_BUTTON_DPAD_LEFT): pointer.x -= delta * 400
		if code_pressed(JOY_BUTTON_DPAD_RIGHT): pointer.x += delta * 400
	for action in ACTIONS:
		var down := pressed(action)
		var edge := down and not bool(held.get(action, false))
		held[action] = down
		if not edge or g.panel != "" or g.chat_open or g.death_timer > 0 or not awaiting.is_empty(): continue
		match action:
			"attack": pass # The normal combat loop handles held attacks.
			"dodge":
				if g.dash_cooldown <= 0: g.dodge()
			"interact": g.interact()
			"waystone": g.use_waystone()
			"heal": g.quick_potion(false)
			"resource": g.quick_potion(true)
			"pause": g.panel = "pause"
			"skills", "inventory", "journal", "map": g.toggle_panel(action)
			_:
				if action.begins_with("ability_"): g.use_ability(int(action.trim_prefix("ability_")) - 1)

func click(g, pos: Vector2) -> void:
	if Rect2(965,91,41,35).has_point(pos) or Rect2(585,562,385,36).has_point(pos):
		awaiting = ""
		g.panel = "pause"
		return
	if not awaiting.is_empty(): return
	for i in ACTIONS.size():
		if Rect2(170 + int(i / 8.0) * 420, 220 + (i % 8) * 37, 390, 32).has_point(pos):
			awaiting = ACTIONS[i]
			status = "Controller-Taste oder Trigger drücken · ESC bricht ab"
			return
	if Rect2(175,562,385,36).has_point(pos):
		bindings = DEFAULT.duplicate()
		deadzone = 0.22
		status = "Standardbelegung wiederhergestellt."
		save()
	if Rect2(800,174,55,30).has_point(pos): deadzone = maxf(0.1, deadzone - 0.02); save()
	if Rect2(870,174,55,30).has_point(pos): deadzone = minf(0.4, deadzone + 0.02); save()

func draw(g) -> void:
	g.text_at(Vector2(170,153), "CONTROLLER-EINSTELLUNGEN", 27, Color("ffdf9f"))
	var name := Input.get_joy_name(device) if device >= 0 else "Kein Controller erkannt · eine Taste drücken"
	g.text_at(Vector2(172,192), name.left(56), 14, Color("dbe9d5"))
	g.text_at(Vector2(590,194), "Stick-Totzone: %d %%" % roundi(deadzone * 100), 14, Color("dbe9d5"))
	g.ui_button(Rect2(800,174,55,30), "−")
	g.ui_button(Rect2(870,174,55,30), "+")
	for i in ACTIONS.size():
		var action: String = ACTIONS[i]
		var x := 170 + int(i / 8.0) * 420
		var y := 220 + (i % 8) * 37
		g.draw_rect(Rect2(x,y,390,32), Color("607666") if awaiting == action else Color("354a4a"))
		g.text_at(Vector2(x+9,y+22), g.BIND_NAMES[g.BIND_ACTIONS.find(action)], 14, Color("ffefd3"))
		g.text_at(Vector2(x+214,y+22), "DRÜCKEN …" if awaiting == action else label(int(bindings[action])), 13, Color("dbe9d5"))
	g.text_at(Vector2(172,540), status, 13, Color("ffe3a5"))
	g.ui_button(Rect2(175,562,385,36), "STANDARD WIEDERHERSTELLEN")
	g.ui_button(Rect2(585,562,385,36), "ZURÜCK")

func draw_cursor(g) -> void:
	if used and device >= 0 and g.panel != "":
		g.draw_circle(pointer, 7, Color("ffe3a5"))
		g.draw_circle(pointer, 9, Color("151e28"), false, 2)
