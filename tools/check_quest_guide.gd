extends SceneTree

class TestGame:
	extends "res://main.gd"
	func _ready() -> void: pass
	func _process(_delta: float) -> void: pass
	func _draw() -> void: pass
	func save_game() -> void: pass
	func ack_server_transaction(_tx: String) -> void: pass

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var g = TestGame.new()
	root.add_child(g)
	g.konflux_preview_mode = true
	for q in g.QUESTS: g.quests.append({"state":0,"progress":0})
	var guide = g.quest_guide
	g.rescue_state = 3
	g.quests[1] = {"state":1,"progress":3}
	assert(guide.current_id(g) == 1)
	g.panel = "journal"
	g.handle_panel_click(Vector2(300,300))
	assert(g.panel == "quest_details" and guide.selected_id == 1)
	guide.click_details(g,Vector2(520,569))
	assert(guide.tracked_id == 1)
	assert(guide.target(g)["pos"] == g.region_rect(int(g.ENEMY_TYPES[1]["region"])).get_center())
	assert(guide.summary(g).contains("3/8"))
	guide.click_details(g,Vector2(830,569))
	assert(g.panel == "map")
	g.quests[1]["state"] = 2
	assert(guide.target(g)["pos"] == g.npc_position("Mira"))
	assert(guide.summary(g).contains("Abgabe bei Mira"))
	g.quests[1]["state"] = 3
	assert(guide.target(g).is_empty())
	g.quests[12]["state"] = 1
	assert(guide.target(g,12)["pos"] == g.LANDMARKS[2]["pos"]+Vector2(0,125))
	g.rescue_state = 1
	guide.tracked_id = -1
	assert(guide.target(g)["pos"] == g.RESCUE_POS)
	g.rescue_state = 2
	assert(guide.target(g)["pos"] == g.RESCUE_POS + Vector2(0,120))
	assert(absf(guide.marker_color(0.208333).a-guide.marker_color(0.625).a) > 0.6)
	g.rescue_state = 3
	guide.open(g,0)
	guide.click_details(g,Vector2(520,569))
	assert(guide.tracked_id == -1) # Viewing an unaccepted quest does not accept it.
	guide.click_details(g,Vector2(260,569))
	assert(g.panel == "journal")
	g.menu_scroll = 19
	g.handle_panel_click(Vector2(947,576))
	assert(g.menu_scroll == 19) # Last page is bounded.
	g.menu_scroll = 0
	g.handle_panel_click(Vector2(947,576))
	assert(g.menu_scroll == 1)
	g.player_pos = g.WAYSTONES[0]+Vector2(0,105)
	g.panel = ""
	var mouse := InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = true
	mouse.position = Vector2(100,140)
	g._unhandled_input(mouse)
	assert(g.panel == "quest_details")
	var key := InputEventKey.new()
	key.keycode = KEY_ESCAPE
	key.pressed = true
	g._unhandled_input(key)
	assert(g.panel == "")
	var scenery = load("res://components/start_scenery_32.gd")
	scenery.init_art()
	for texture in [scenery.objects,scenery.props]:
		assert(texture != null and texture.get_size() == Vector2(1536,1024))
		var image: Image = texture.get_image()
		assert(not image.is_empty() and image.get_pixel(0,0).a < 0.01)
	print("QUEST_GUIDE_OK clickable HUD and journal, selected targets, hand-in, boss position, story, pulse, scroll, restored textures")
	g.queue_free()
	await process_frame
	quit()
