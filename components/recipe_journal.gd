extends RefCounted
# Unterwegs lesbares Rezeptbuch: verwendet Almas gespeicherte Lernstände.
const Food = preload("res://components/food_system.gd")
var tab := 0
var selected := 0

func known(g) -> Array[int]: return g.steinrose.learned_indices()

func normalize(g) -> void:
	var rows := known(g)
	if selected not in rows: selected = rows[0] if not rows.is_empty() else -1

func ingredient_rows(g, index: int) -> Array:
	if index not in known(g): return []
	var rows: Array = []
	var status: Dictionary = g.steinrose.ingredient_status(g,index)
	for name in status:
		var region := Food.herb_region(str(name))
		var berry: int = g.steinrose.BERRIES.find(str(name))
		if berry >= 0: region = g.steinrose.BERRY_REGIONS[berry]
		var have := int(status[name]["owned"])
		var need := int(status[name]["needed"])
		rows.append({"name":name,"owned":have,"needed":need,"missing":maxi(0,need-have),"region":region})
	return rows

func set_tab(g, value: int) -> void:
	tab = clampi(value,0,1)
	normalize(g)
	g.play_sound("menu"); g.queue_redraw()

func click(g, mouse: Vector2) -> void:
	if Rect2(615,99,170,34).has_point(mouse): set_tab(g,0);return
	if Rect2(795,99,170,34).has_point(mouse): set_tab(g,1);return
	if tab == 0: g.quest_guide.click_journal(g,mouse);return
	var rows := known(g)
	for i in rows.size():
		if Rect2(165,180+i*28,355,25).has_point(mouse):
			selected = rows[i]; g.play_sound("menu"); g.queue_redraw();return

func keyboard_input(g, event: InputEvent) -> bool:
	if g.panel != "journal" or tab != 1: return false
	var direction := 0
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_UP,KEY_W]: direction = -1
		elif event.keycode in [KEY_DOWN,KEY_S]: direction = 1
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: direction = -1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: direction = 1
	if direction == 0: return false
	normalize(g)
	var rows := known(g)
	if not rows.is_empty(): selected = rows[posmod(rows.find(selected)+direction,rows.size())]
	g.queue_redraw();return true

func draw(g) -> void:
	g.text_at(Vector2(165,125),"QUESTS / REZEPTE",24,Color("ffeda9"))
	g.ui_button(Rect2(615,99,170,34),"QUESTS" + (" ✓" if tab==0 else ""))
	g.ui_button(Rect2(795,99,170,34),"REZEPTE" + (" ✓" if tab==1 else ""))
	if tab == 0: draw_quests(g);return
	normalize(g)
	g.text_at(Vector2(165,163),"ALMAS GELERNTE REZEPTE",16,Color("e9cc90"))
	var rows := known(g)
	for i in rows.size():
		var recipe: Dictionary = g.steinrose.recipe(rows[i])
		var box := Rect2(165,180+i*28,355,25)
		g.ui_box(box,Color("607666") if rows[i]==selected else Color("30474b"))
		g.text_at(box.position+Vector2(12,18),str(recipe["name"]),13,Color("fff0ce"))
	if selected < 0:
		g.text_at(Vector2(560,220),"Lerne bei Alma dein erstes Rezept.",16,Color("dce7d8"));return
	var recipe: Dictionary = g.steinrose.recipe(selected)
	g.ui_box(Rect2(545,170,435,390),Color("20343a"))
	g.text_at(Vector2(562,202),str(recipe["name"]),22,Color("ffe2aa"))
	g.text_at(Vector2(562,232),str(recipe["desc"]),13,Color("dce7d8"),HORIZONTAL_ALIGNMENT_LEFT,400)
	var ingredients := ingredient_rows(g,selected)
	for i in ingredients.size():
		var row: Dictionary = ingredients[i]
		var y := 268+i*54
		g.text_at(Vector2(562,y),"%s · %d / %d" % [row["name"],row["owned"],row["needed"]],16,Color("bde8bd") if row["missing"]==0 else Color("e8aaa0"))
		g.text_at(Vector2(562,y+20),"%s · %s" % [g.region_name(row["region"]),"vollständig" if row["missing"]==0 else "noch %d sammeln" % row["missing"]],12,Color("b9cbc3"),HORIZONTAL_ALIGNMENT_LEFT,400)
	g.text_at(Vector2(562,504),"WIRKUNG",14,Color("e9cc90"))
	g.text_at(Vector2(562,533),str(recipe["effect"]),13,Color("d8e6dc"),HORIZONTAL_ALIGNMENT_LEFT,400)
	g.text_at(Vector2(170,592),"Zutaten unterwegs sammeln · Kochen bei Alma · Pfeile / Mausrad: Rezept wählen",14,Color("d9e6d5"))

func draw_quests(g) -> void:
	g.ui_box(Rect2(165, 145, 815, 73), Color("675f55") if g.rescue_state == 1 else Color("527668"))
	var story: String = ["Mira sorgt sich um Blütenweiler. Folge dem Weg östlich von Sonnenhain.", "Das Dorf ist umzingelt. Besiege die Dornenwesen (%d/%d)." % [g.rescue_kills, g.RESCUE_GOAL], "Das Dorf ist sicher. Sprich mit Nela am Dorfplatz und hole deinen Lohn.", "Nela: Die Plage stammt aus dem Turm der Alten Ruinen. Suche dort die Quelle."][g.rescue_state]
	if g.rescue_state == 3 and g.bosses_defeated[0]: story = "Im Turm lag ein zerbrochenes Siegel. Der Kristallhüter bewacht sein Gegenstück."
	if g.rescue_state == 3 and g.bosses_defeated[1]: story = "Beide Siegel weisen zur Asche und weiter zu den Sternen. Folge dem alten Weg."
	if g.rescue_state == 3 and g.bosses_defeated[2]: story = "Der Aschefürst fiel. Hinter dem Sternenbruch glimmt noch die letzte Wache."
	g.text_at(Vector2(180, 173), "HAUPTGESCHICHTE · Blütenweiler", 19, Color("ffe6a7"))
	g.text_at(Vector2(180, 201), story, 16, Color("e7eedc"))
	for row in 6:
		var id: int = row + g.menu_scroll
		if id >= g.QUESTS.size(): break
		var q: Dictionary = g.QUESTS[id]
		var state: int = g.quests[id]["state"]
		var status: String = ["Noch verfügbar", "Aktiv", "Abgeben!", "Erledigt"][state]
		var required: int = g.region_level(int(g.ENEMY_TYPES[int(q["target"])]["region"]))
		if state == 0 and g.level + 3 < required: status = "Ab Level %d" % maxi(1, required - 3)
		var y := 226 + row * 57
		g.ui_box(Rect2(165, y, 815, 53), Color("577b69") if state == 2 else Color("45665f"))
		g.text_at(Vector2(180, y + 21), "%s  ·  %s" % [q["title"], q["npc"]], 17, Color("fff1bc"))
		var group_suffix := " · GRUPPE" if not (g.party_state.get("members",[]) as Array).is_empty() and state == 1 else ""
		g.text_at(Vector2(180, y + 42), "%s %d/%d  ·  %d XP / %d Gold%s" % [g.ENEMY_TYPES[int(q["target"])]["name"], g.quests[id]["progress"], q["count"], q["xp"], q["gold"],group_suffix], 14, Color("d8e6d3"))
		g.text_at(Vector2(867, y + 29), status, 14, Color("fff0ad"))
	g.text_at(Vector2(170, 592), "Klicke eine Quest für Details. Mausrad / Pfeile: scrollen.", 15, Color("d9e6d5"))

	g.ui_button(Rect2(855,558,55,36),"↑")
	g.ui_button(Rect2(920,558,55,36),"↓")
