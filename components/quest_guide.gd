extends RefCounted
## A shared quest selection keeps the HUD, details and both maps consistent.
const AUTO := -2
const STORY := -1
var tracked_id := AUTO
var selected_id := STORY
var return_panel := "journal"

func current_id(g) -> int:
	if tracked_id == STORY and g.rescue_state < 3: return STORY
	if tracked_id >= 0 and tracked_id < g.quests.size() and int(g.quests[tracked_id]["state"]) in [1,2]: return tracked_id
	if g.rescue_state < 3: return STORY
	for state in [2,1]:
		for i in g.quests.size():
			if int(g.quests[i]["state"]) == state: return i
	return AUTO

func open(g, id: int, source: String = "journal") -> void:
	selected_id = id if id >= STORY and id < g.quests.size() else STORY
	return_panel = source
	g.panel = "quest_details"
	g.play_sound("menu")
	g.queue_redraw()

func title(g, id: int) -> String:
	return "Die Dornenplage · Blütenweiler" if id == STORY else String(g.QUESTS[id]["title"])

func summary(g) -> String:
	var id := current_id(g)
	if id == AUTO: return "Sprich mit Mira, Borin oder Liora im Dorf."
	if id == STORY:
		return ["Mira: Folge dem Weg nach Blütenweiler.", "Dornenplage · %d/%d" % [g.rescue_kills,g.RESCUE_GOAL], "Dornenplage · Abgabe bei Nela"][g.rescue_state]
	var q: Dictionary = g.QUESTS[id]
	return "%s · Abgabe bei %s" % [q["title"],q["npc"]] if int(g.quests[id]["state"]) == 2 else "%s · %d/%d" % [q["title"],g.quests[id]["progress"],q["count"]]

func target(g, id: int = AUTO) -> Dictionary:
	if id == AUTO: id = current_id(g)
	if id == AUTO: return {}
	if id == STORY:
		if g.rescue_state >= 3: return {}
		return {"pos":g.RESCUE_POS + Vector2(0,120) if g.rescue_state == 2 else g.RESCUE_POS,"label":"Nela · Belohnung abholen" if g.rescue_state == 2 else "Blütenweiler · Dornenplage","area":g.rescue_state < 2}
	if id < 0 or id >= g.quests.size(): return {}
	var q: Dictionary = g.QUESTS[id]
	var state := int(g.quests[id]["state"])
	if state == 3: return {}
	if state in [0,2]: return {"pos":g.npc_position(String(q["npc"])),"label":"%s · %s" % [q["npc"],"Auftrag annehmen" if state == 0 else "Belohnung abholen"],"area":false}
	var enemy_id := int(q["target"])
	if enemy_id in [12,13,14]:
		var landmark: Dictionary = g.LANDMARKS[enemy_id-12+2]
		return {"pos":landmark["pos"]+Vector2(0,125),"label":"%s · %s" % [landmark["name"],g.ENEMY_TYPES[enemy_id]["name"]],"area":false}
	var zone := int(g.ENEMY_TYPES[enemy_id]["region"])
	return {"pos":g.region_rect(zone).get_center(),"label":"%s · %s suchen" % [g.region_name(zone),g.ENEMY_TYPES[enemy_id]["name"]],"area":true}

func marker_color(seconds: float) -> Color:
	return Color("ffe34b",0.3 + 0.7 * (0.5 + 0.5 * sin(seconds * TAU * 1.2)))

func draw_marker(g, point: Vector2, compact: bool = false) -> void:
	# Real time keeps the yellow pulse running while the quest/map menu is open.
	var color := marker_color(Time.get_ticks_msec()/1000.0)
	var radius := 6.0 if compact else 10.0
	g.draw_circle(point,radius+3,Color("29251b",0.9))
	g.draw_arc(point,radius,0,TAU,24,color,2 if compact else 3)
	g.draw_circle(point,2.5 if compact else 4.0,color)

func draw_on_map(g, inset: Rect2, map_scale: Vector2) -> void:
	var goal := target(g)
	if goal.is_empty(): return
	draw_marker(g,inset.position + Vector2(goal["pos"]) * map_scale)

func draw_on_minimap(g, center: Vector2, radius: float, scale_map: Vector2, _start: Vector2) -> void:
	var goal := target(g)
	if goal.is_empty(): return
	var offset: Vector2 = (Vector2(goal["pos"]) - g.player_pos) * scale_map
	var far := offset.length() > radius - 13
	var point := center + offset.limit_length(radius-13)
	draw_marker(g,point,true)
	if far:
		var dir := offset.normalized()
		g.draw_colored_polygon(PackedVector2Array([point+dir*8,point-dir*2+dir.orthogonal()*4,point-dir*2-dir.orthogonal()*4]),marker_color(Time.get_ticks_msec()/1000.0))

func click_journal(g, mouse: Vector2) -> void:
	if Rect2(165,145,815,73).has_point(mouse): open(g,STORY); return
	for row in 6:
		var id: int = row + g.menu_scroll
		if id < g.quests.size() and Rect2(165,226+row*57,815,53).has_point(mouse): open(g,id); return
	if Rect2(855,558,55,36).has_point(mouse): g.menu_scroll = maxi(0,g.menu_scroll-1)
	if Rect2(920,558,55,36).has_point(mouse): g.menu_scroll = mini(maxi(0,g.quests.size()-6),g.menu_scroll+1)

func click_details(g, mouse: Vector2) -> void:
	if Rect2(170,548,180,42).has_point(mouse): g.panel = return_panel; return
	if target(g,selected_id).is_empty(): return
	if Rect2(390,548,260,42).has_point(mouse) or Rect2(690,548,280,42).has_point(mouse):
		var active: bool = selected_id == STORY and g.rescue_state < 3 or selected_id >= 0 and int(g.quests[selected_id]["state"]) in [1,2]
		if active: tracked_id = selected_id
		g.save_game()
		if mouse.x >= 690:
			# Available quests can point to their giver without pretending they are accepted.
			g.panel = "map" if active else "quest_details"
		g.queue_redraw()

func draw_details(g) -> void:
	var id := selected_id
	g.text_at(Vector2(170,128),"QUESTDETAILS",24,Color("ffe6a7"))
	g.ui_box(Rect2(165,146,815,375),Color("405b55"))
	g.text_at(Vector2(185,183),title(g,id),23,Color("fff0b3"))
	var goal := target(g,id)
	var status := "Abgeschlossen"
	var objective := ""
	var giver := "Mira · Abschluss bei Nela in Blütenweiler"
	var reward := "160 XP · 80 Gold · seltene Klassenwaffe der Morgenwache"
	var progress := ""
	var next_step := ""
	var active := false
	if id == STORY:
		status = ["Folge dem östlichen Weg","Aktiv","Bereit zur Abgabe","Abgeschlossen"][g.rescue_state]
		objective = "Rette Blütenweiler vor den Dornenwesen."
		progress = "%d / %d Dornenwesen besiegt" % [g.rescue_kills,g.RESCUE_GOAL]
		next_step = ["Folge dem Weg nach Osten und erreiche Blütenweiler.","Besiege die Dornenwesen rund um den Dorfplatz.","Sprich mit Nela am Dorfplatz und hole deine Belohnung.","Suche die Quelle der Plage in den Alten Ruinen."][g.rescue_state]
		active = g.rescue_state < 3
	else:
		var q: Dictionary = g.QUESTS[id]
		var state := int(g.quests[id]["state"])
		var enemy: Dictionary = g.ENEMY_TYPES[int(q["target"])]
		status = ["Noch nicht angenommen","Aktiv","Bereit zur Abgabe","Abgeschlossen"][state]
		objective = "Besiege %d %s in %s." % [q["count"],enemy["name"],g.region_name(int(enemy["region"]))]
		giver = String(q["npc"]) + " · Sonnenhain"
		reward = "%d XP · %d Gold · %s" % [q["xp"],q["gold"],q["reward"]]
		progress = "%d / %d besiegt" % [g.quests[id]["progress"],q["count"]]
		next_step = ["Sprich mit %s, um diesen Auftrag anzunehmen." % q["npc"],"Suche das gelb markierte Zielgebiet auf der Karte.","Kehre zu %s zurück und sprich den Questgeber an." % q["npc"],"Du hast die Belohnung bereits erhalten."][state]
		var required: int = maxi(1,g.region_level(int(enemy["region"]))-3)
		if state == 0 and g.level < required: next_step = "Ab Level %d bei %s verfügbar." % [required,q["npc"]]
		active = state in [1,2]
	for line in [[216,"Status: "+status],[251,"Auftrag: "+objective],[287,"Fortschritt: "+progress],[323,"Questgeber: "+giver],[359,"Belohnung: "+reward]]:
		g.text_at(Vector2(185,line[0]),line[1],16,Color("e7eedc"),HORIZONTAL_ALIGNMENT_LEFT,775)
	g.text_at(Vector2(185,406),next_step,16,Color("fff0b3"),HORIZONTAL_ALIGNMENT_LEFT,775)
	if not goal.is_empty():
		g.text_at(Vector2(185,448),"Ziel: "+String(goal["label"]),16,Color("ffe34b"),HORIZONTAL_ALIGNMENT_LEFT,775)
		g.text_at(Vector2(185,482),"Gelb blinkend: Questziel · Pfeil am Minimaprand: Richtung",14,Color("d8e6d3"))
	g.ui_button(Rect2(170,548,180,42),"Zurück")
	g.ui_button(Rect2(390,548,260,42),"Wird verfolgt" if current_id(g) == id else "Quest verfolgen",active,current_id(g) == id and active)
	g.ui_button(Rect2(690,548,280,42),"Ziel auf Karte zeigen",active)
