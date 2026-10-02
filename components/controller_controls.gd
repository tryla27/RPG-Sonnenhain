extends RefCounted

const PATH := "user://sonnenhain_controller.cfg"
const ACTIONS := ["attack", "dodge", "interact", "ability_1", "ability_2", "ability_3", "ability_4", "heal", "resource", "waystone", "skills", "inventory", "journal", "map", "pause", "chat", "mechanics", "online", "party"]
const DEFAULT := {"attack":102, "dodge":0, "interact":2, "ability_1":JOY_BUTTON_LEFT_SHOULDER, "ability_2":JOY_BUTTON_RIGHT_SHOULDER, "ability_3":101, "ability_4":3, "heal":11, "resource":12, "waystone":13, "skills":14, "inventory":JOY_BUTTON_BACK, "journal":JOY_BUTTON_LEFT_STICK, "map":JOY_BUTTON_RIGHT_STICK, "pause":JOY_BUTTON_START, "chat":-1, "mechanics":-1, "online":-1, "party":-1}
var bindings: Dictionary = DEFAULT.duplicate()
var device := -1
var deadzone := 0.22
var awaiting := ""
var status := "Linker Stick: laufen · rechter Stick: zielen"
var pointer := Vector2(576, 324)
var used := false
var held: Dictionary = {}
var nav_held: Dictionary = {}
var last_panel := ""
var blocked_codes: Dictionary = {}
var trigger_states: Dictionary = {}
var enabled := true
var focused := true

func connected_devices() -> Array[int]:
	return Input.get_connected_joypads()

func setup() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK: return
	enabled = bool(cfg.get_value("controller","enabled",true))
	deadzone = clampf(float(cfg.get_value("controller", "deadzone", 0.22)), 0.1, 0.4)
	for action in ACTIONS:
		var code := int(cfg.get_value("bindings", action, DEFAULT[action]))
		if code in [-1, 101, 102] or (code >= 0 and code < JOY_BUTTON_MAX): bindings[action] = code

func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("controller", "deadzone", deadzone)
	cfg.set_value("controller", "enabled", enabled)
	for action in ACTIONS: cfg.set_value("bindings", action, bindings[action])
	cfg.save(PATH)

func stick(right := false) -> Vector2:
	if not enabled or not focused or device < 0: return Vector2.ZERO
	var raw := Vector2(Input.get_joy_axis(device, JOY_AXIS_RIGHT_X if right else JOY_AXIS_LEFT_X), Input.get_joy_axis(device, JOY_AXIS_RIGHT_Y if right else JOY_AXIS_LEFT_Y))
	return filter_stick(raw)

func filter_stick(raw: Vector2) -> Vector2:
	if not raw.is_finite(): return Vector2.ZERO
	var length := raw.length()
	if length <= deadzone: return Vector2.ZERO
	return raw.normalized() * clampf((length - deadzone) / (1.0 - deadzone), 0.0, 1.0)

func code_pressed(code: int) -> bool:
	if not enabled or not focused or device < 0 or code < 0: return false
	if code == 101 or code == 102:
		var value := Input.get_joy_axis(device, JOY_AXIS_TRIGGER_LEFT if code == 101 else JOY_AXIS_TRIGGER_RIGHT)
		trigger_states[code] = value > (0.45 if bool(trigger_states.get(code,false)) else 0.55)
		return bool(trigger_states[code])
	return Input.is_joy_button_pressed(device, code)

func pressed(action: String) -> bool:
	var code := int(bindings.get(action, -1))
	return not blocked_codes.has(code) and code_pressed(code)

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
	blocked_codes[code] = true
	awaiting = ""
	status = "Belegung gespeichert: " + label(code)
	save()

func handle(g, event: InputEvent) -> bool:
	if not (event is InputEventJoypadButton or event is InputEventJoypadMotion): return false
	if not enabled or not focused: return true
	device = event.device
	if event is InputEventJoypadButton or absf(event.axis_value) > deadzone: used = true
	if not awaiting.is_empty():
		if event is InputEventJoypadButton and event.pressed: assign(awaiting, event.button_index)
		elif event is InputEventJoypadMotion and event.axis in [JOY_AXIS_TRIGGER_LEFT, JOY_AXIS_TRIGGER_RIGHT] and event.axis_value > 0.65:
			assign(awaiting, 101 if event.axis == JOY_AXIS_TRIGGER_LEFT else 102)
		return true
	if event is InputEventJoypadButton and event.pressed and (g.panel != "" or g.chat_open):
		blocked_codes[event.button_index] = true
		if g.panel in ["skills","journal"] and event.button_index in [JOY_BUTTON_LEFT_SHOULDER,JOY_BUTTON_RIGHT_SHOULDER]:
			var skill_max:int=maxi(0,ceili(float(g.SKILL_TREES[g.skill_tree_tab].size()-6)/3.0)) if g.panel=="skills" else 0
			g.menu_scroll = clampi(g.menu_scroll+(1 if event.button_index == JOY_BUTTON_RIGHT_SHOULDER else -1),0,maxi(0,g.QUESTS.size()-6) if g.panel == "journal" else skill_max)
			return true
		if g.panel == "controller" and not awaiting.is_empty(): return true
		if event.button_index == JOY_BUTTON_B or event.button_index == JOY_BUTTON_START:
			if g.panel == "controller": g.panel = "pause"
			elif g.panel == "quest_details": g.panel = g.quest_guide.return_panel
			elif g.panel=="creation_review":g.panel="creation"
			elif g.panel=="settings":g.panel="pause"
			elif g.panel not in ["start", "creation"]: g.panel = ""
			g.chat_open = false
		elif event.button_index == JOY_BUTTON_A:
			if g.chat_open:
				g.send_chat_message(g.chat_input)
				g.chat_input = ""
				g.chat_open = false
				return true
			if g.panel == "intro": g.finish_intro()
			else: g.handle_panel_click(pointer)
		elif int(bindings.get(g.panel,-1)) == event.button_index: g.panel = ""
	return true

func update(g, delta: float) -> void:
	var pads := connected_devices()
	if not pads.has(device):
		device = int(pads[0]) if not pads.is_empty() else -1
		if device < 0:
			held.clear()
			nav_held.clear()
			blocked_codes.clear()
			trigger_states.clear()
			used = false
			return
	if not enabled or not focused:
		held.clear()
		used = false
		return
	if used: g.online_list_open = g.binding_pressed("online")
	for code in blocked_codes.keys():
		if not code_pressed(int(code)): blocked_codes.erase(code)
	var move := stick()
	if move.length_squared() > 0.0 or stick(true).length_squared() > 0.0: used = true
	if g.panel != last_panel:
		last_panel = g.panel
		if g.panel != "":
			var points := panel_points(g)
			if not points.is_empty(): pointer = points[0]
	if g.panel != "":
		pointer += move * delta * 650.0
		pointer = pointer.clamp(Vector2(140, 90), Vector2(1005, 600))
		update_dpad_navigation(g)
	for action in ACTIONS:
		var down := pressed(action)
		var edge := down and not bool(held.get(action, false))
		held[action] = down
		if not edge or g.panel != "" or g.chat_open or g.death_timer > 0 or not awaiting.is_empty(): continue
		match action:
			"chat": g.chat_open = true
			"online": pass
			"attack": pass # The normal combat loop handles held attacks.
			"dodge":
				if g.dash_cooldown <= 0: g.dodge()
			"interact": g.interact()
			"waystone": g.use_waystone()
			"heal": g.quick_potion(false)
			"resource": g.quick_potion(true)
			"pause": g.panel = "pause"
			"skills", "inventory", "journal", "map", "party", "mechanics": g.toggle_panel(action)
			_:
				if action.begins_with("ability_"): g.use_ability(int(action.trim_prefix("ability_")) - 1)

func click(g, pos: Vector2) -> void:
	if Rect2(795,125,165,32).has_point(pos):
		enabled = not enabled
		used = false
		held.clear()
		save()
		status = "Controller aktiviert." if enabled else "Controller deaktiviert · Maus/Tastatur bleiben aktiv."
		return
	if Rect2(590,487,390,32).has_point(pos):
		var pads := connected_devices()
		device = int(pads[0]) if not pads.is_empty() else -1
		held.clear()
		trigger_states.clear()
		status = "Verbunden: "+Input.get_joy_name(device) if device >= 0 else "Verbinden und eine Taste drücken · Browser-Spiel anklicken."
		return
	if Rect2(965,91,41,35).has_point(pos) or Rect2(585,562,385,36).has_point(pos):
		awaiting = ""
		g.panel = "pause"
		return
	if not awaiting.is_empty(): return
	for i in ACTIONS.size():
		if Rect2(170 + int(i / 10.0) * 420, 208 + (i % 10) * 31, 390, 32).has_point(pos):
			awaiting = ACTIONS[i]
			status = "Taste / Trigger drücken · ESC abbrechen · Entfernen: Belegung löschen"
			return
	if Rect2(175,562,385,36).has_point(pos):
		bindings = DEFAULT.duplicate()
		deadzone = 0.22
		status = "Standardbelegung wiederhergestellt."
		save()
	if Rect2(800,174,55,30).has_point(pos): deadzone = maxf(0.1, deadzone - 0.02); save()
	if Rect2(870,174,55,30).has_point(pos): deadzone = minf(0.4, deadzone + 0.02); save()

func draw(g) -> void:
	g.text_at(Vector2(170,153), "CONTROLLER-EINSTELLUNGEN", 24, Color("ffdf9f"))
	g.ui_button(Rect2(795,125,165,32),"AN" if enabled else "AUS")
	var name := Input.get_joy_name(device) if device >= 0 else "Kein Controller erkannt · eine Taste drücken"
	g.text_at(Vector2(172,192), name.left(56), 14, Color("dbe9d5"))
	g.text_at(Vector2(590,194), "Stick-Totzone: %d %%" % roundi(deadzone * 100), 14, Color("dbe9d5"))
	g.ui_button(Rect2(800,174,55,30), "−")
	g.ui_button(Rect2(870,174,55,30), "+")
	for i in ACTIONS.size():
		var action: String = ACTIONS[i]
		var x := 170 + int(i / 10.0) * 420
		var y := 208 + (i % 10) * 31
		g.draw_rect(Rect2(x,y,390,32), Color("607666") if awaiting == action else Color("354a4a"))
		g.text_at(Vector2(x+9,y+22), g.BIND_NAMES[g.BIND_ACTIONS.find(action)], 14, Color("ffefd3"))
		g.text_at(Vector2(x+214,y+22), "DRÜCKEN …" if awaiting == action else label(int(bindings[action])), 13, Color("dbe9d5"))
	g.ui_button(Rect2(590,487,390,32),"CONTROLLER NEU ERKENNEN")
	g.text_at(Vector2(172,540), status, 13, Color("ffe3a5"))
	g.ui_button(Rect2(175,562,385,36), "STANDARD WIEDERHERSTELLEN")
	g.ui_button(Rect2(585,562,385,36), "ZURÜCK")

func draw_cursor(g) -> void:
	if used and device >= 0 and g.panel != "":
		g.draw_circle(pointer, 7, Color("ffe3a5"))
		g.draw_circle(pointer, 9, Color("151e28"), false, 2)

func panel_points(g) -> Array:
	var points: Array = []
	match g.panel:
		"start":
			points=[Vector2(575,405),Vector2(575,475),Vector2(298,558),Vector2(571,558),Vector2(844,558)]
		"creation":
			points=[Vector2(575,250),Vector2(390,320),Vector2(600,320),Vector2(347,387),Vector2(567,387),Vector2(787,387),Vector2(347,465),Vector2(572,465),Vector2(797,465),Vector2(575,546),Vector2(220,546)]
		"creation_review":
			points=[Vector2(280,562),Vector2(772,562)]
		"skills":
			for i in 3:points.append(Vector2(260+i*204,170))
			for i in g.skill_choices().size():points.append(Vector2(295+i*275,290))
			for i in 4:points.append(Vector2(550,421+i*37))
		"inventory":
			points.append(Vector2(229,235))
			points.append(Vector2(229,314))
			points.append(Vector2(550,274))
			points.append(Vector2(349,479))
			if g.class_id == 1: points.append(Vector2(454,479))
			points.append(Vector2(866,172))
			points.append(Vector2(947,172))
			for cell in 25:
				var col := cell % 5
				var row := int(cell / 5.0)
				points.append(Vector2(668+col*65,224+row*55))
			points.append(Vector2(803,559))
			points.append(Vector2(986,109))
		"shop":
			if g.pending_purchase >= 0:
				points.append(Vector2(454,414))
				points.append(Vector2(680,414))
			else:
				points.append(Vector2(800,165))
				points.append(Vector2(900,165))
				for i in 3:
					points.append(Vector2(291+i*258,273))
				for i in mini(42,g.inventory.size()):
					var col := i % 11
					var row := int(i / 11.0)
					points.append(Vector2(194+col*72,416+row*40))
				points.append(Vector2(669,582))
				if g.selected_item >= 0: points.append(Vector2(878,582))
			points.append(Vector2(986,109))
		"journal":
			points.append(Vector2(570,181))
			for row in mini(6,g.quests.size()-g.menu_scroll): points.append(Vector2(570,252+row*57))
			points.append(Vector2(882,576))
			points.append(Vector2(947,576))
			points.append(Vector2(986,109))
		"quest_details":
			points = [Vector2(260,569),Vector2(520,569),Vector2(830,569),Vector2(986,109)]
		"travel":
			for i in range(1,g.WAYSTONES.size()):
				var col := (i-1)%3
				var row := int((i-1)/3.0)
				points.append(Vector2(294+col*271,215+row*96))
			points.append(Vector2(986,109))
		"pause":
			for i in 7:points.append(Vector2(745,176+i*51))
			points.append(Vector2(745,533))
			points.append(Vector2(340,503))
			points.append(Vector2(340,562))
		"patches":
			points=[Vector2(986,109)]
		"settings":
			points = [Vector2(575,242),Vector2(925,242),Vector2(925,291),Vector2(925,340),Vector2(575,291),Vector2(575,453)]
			if not g.creative_mode:
				points.append(Vector2(430,499))
				points.append(Vector2(720,499))
			points.append(Vector2(575,580))
		"controller":
			points.append(Vector2(875,140))
			points.append(Vector2(780,503))
			points.append(Vector2(828,189))
			points.append(Vector2(898,189))
			for i in ACTIONS.size():
				var x := 365.0 + int(i/10.0)*420.0
				var y := 224.0 + (i%10)*31.0
				points.append(Vector2(x,y))
			points.append(Vector2(368,580))
			points.append(Vector2(778,580))
		"party":
			if int(g.party_state.get("invite_from",0)) > 0:
				points = [Vector2(373,309),Vector2(743,309),Vector2(830,567)]
			else:
				if not (g.party_state.get("members",[]) as Array).is_empty():
					points.append(Vector2(373,533))
				points.append(Vector2(830,567))
		_:
			if g.panel != "" and g.panel not in ["start","creation","multiplayer","arena_reward","victory"]:
				points.append(Vector2(986,109))
	return points


func nearest_point_index(points: Array, origin: Vector2) -> int:
	if points.is_empty(): return -1
	var best := 0
	var best_dist := INF
	for i in points.size():
		var d := origin.distance_squared_to(points[i])
		if d < best_dist:
			best_dist = d
			best = i
	return best


func move_focus(g, direction: Vector2) -> void:
	var points := panel_points(g)
	if points.is_empty(): return
	var current := nearest_point_index(points,pointer)
	if current < 0:
		pointer = points[0]
		return
	var origin: Vector2 = points[current]
	var best := -1
	var best_score := INF
	for i in points.size():
		if i == current: continue
		var delta: Vector2 = points[i]-origin
		if direction.dot(delta) <= 1.0: continue
		var primary := absf(delta.x) if absf(direction.x)>0.5 else absf(delta.y)
		var secondary := absf(delta.y) if absf(direction.x)>0.5 else absf(delta.x)
		var score := primary + secondary*2.4
		if score < best_score:
			best_score = score
			best = i
	if best >= 0:
		pointer = points[best]
		used = true


func nav_pressed(code: int) -> bool:
	return code_pressed(code)


func update_dpad_navigation(g) -> void:
	var dirs := {
		JOY_BUTTON_DPAD_UP:Vector2.UP,
		JOY_BUTTON_DPAD_DOWN:Vector2.DOWN,
		JOY_BUTTON_DPAD_LEFT:Vector2.LEFT,
		JOY_BUTTON_DPAD_RIGHT:Vector2.RIGHT
	}
	for code in dirs:
		var down := nav_pressed(int(code))
		var edge := down and not bool(nav_held.get(code,false))
		nav_held[code] = down
		if edge: move_focus(g,dirs[code])


func self_test() -> bool:
	var a := filter_stick(Vector2(0.05,0.05))
	var b := filter_stick(Vector2(1.0,0.0))
	var pts := [Vector2(100,100),Vector2(200,100),Vector2(100,200)]
	var nearest_ok := nearest_point_index(pts,Vector2(190,105)) == 1
	return a == Vector2.ZERO and b.x > 0.9 and absf(b.y) < 0.01 and nearest_ok and label(102) == "RT / R2"

