extends RefCounted

const FoodSystem = preload("res://components/food_system.gd")

const BERRIES := [
	"Himbeeren","Moosbeeren","Steinbeeren","Kristallbeeren","Aprikose","Heidelbeeren",
	"Pflaume","Nebelbeeren","Bernsteinfrucht","Quellbeeren","Daemmerbeeren","Himmelsfrucht"
]

const RECIPES := [
	{
		"name":"Waldbeer-Kompott",
		"ingredients":{"Himbeeren":2,"Heidelbeeren":2},
		"learn_cost":0,
		"desc":"Ein warmer Klassiker fuer lange Wege.",
		"effect":"30 HP sofort · +1 HP/s fuer 20s"
	},
	{
		"name":"Moosbeeren-Eintopf",
		"ingredients":{"Moosbeeren":3,"Aprikose":1},
		"learn_cost":35,
		"desc":"Kraeftiger Eintopf aus dem Pilzwald.",
		"effect":"+10 Energie · +20% Regeneration fuer 25s"
	},
	{
		"name":"Steinbeeren-Riegel",
		"ingredients":{"Steinbeeren":3,"Bernsteinfrucht":1},
		"learn_cost":55,
		"desc":"Fest, haltbar und schuetzend.",
		"effect":"12% weniger Schaden fuer 30s"
	},
	{
		"name":"Kristallgelee",
		"ingredients":{"Kristallbeeren":2,"Quellbeeren":2},
		"learn_cost":70,
		"desc":"Kuehlendes Gelee fuer konzentrierte Kaempfer.",
		"effect":"+15 Energie · 15% schnellere Cooldowns fuer 20s"
	},
	{
		"name":"Nebelpflaumen-Tee",
		"ingredients":{"Nebelbeeren":2,"Pflaume":2},
		"learn_cost":85,
		"desc":"Leichter Tee, der die Schritte beschleunigt.",
		"effect":"+12% Bewegungstempo fuer 25s"
	},
	{
		"name":"Daemmerhimmel-Torte",
		"ingredients":{"Daemmerbeeren":2,"Himmelsfrucht":2},
		"learn_cost":120,
		"desc":"Steinroses seltenstes Reisegericht.",
		"effect":"+8% Schaden und Bewegung fuer 20s"
	}
]

var selected := 0
var tab := 0
var learned: Array = [true,false,false,false,false,false]

func snapshot() -> Dictionary:
	return {"learned":learned.duplicate()}

func restore(raw: Variant) -> void:
	learned = [true,false,false,false,false,false]
	if not raw is Dictionary: return
	var stored: Variant = raw.get("learned",[])
	if stored is Array:
		for i in mini(stored.size(), learned.size()):
			learned[i] = bool(stored[i])
	learned[0] = true

func recipe(index: int = -1) -> Dictionary:
	var use_index := selected if index < 0 else index
	return RECIPES[clampi(use_index,0,RECIPES.size()-1)]

func inventory_count(g, item_name: String) -> int:
	var total := 0
	for item in g.inventory:
		if str(item.get("name","")) == item_name:
			total += int(item.get("count",1))
	return total

func ingredient_status(g, index: int = -1) -> Dictionary:
	var result := {}
	for item_name in recipe(index)["ingredients"]:
		result[item_name] = {
			"owned":inventory_count(g,item_name),
			"needed":int(recipe(index)["ingredients"][item_name])
		}
	return result

func can_cook(g, index: int = -1) -> bool:
	var use_index := selected if index < 0 else index
	if not bool(learned[use_index]): return false
	for item_name in RECIPES[use_index]["ingredients"]:
		if inventory_count(g,item_name) < int(RECIPES[use_index]["ingredients"][item_name]):
			return false
	if g.inventory.size() < 42: return true
	for item in g.inventory:
		if str(item.get("name","")) == str(RECIPES[use_index]["name"]) and int(item.get("count",1)) < g.stack_limit(item):
			return true
	for item_name in RECIPES[use_index]["ingredients"]:
		var needed := int(RECIPES[use_index]["ingredients"][item_name])
		for item in g.inventory:
			if str(item.get("name","")) == item_name and int(item.get("count",1)) <= needed:
				return true
	return false

func remove_item_count(g, item_name: String, amount: int) -> bool:
	if inventory_count(g,item_name) < amount: return false
	var remaining := amount
	for i in range(g.inventory.size()-1,-1,-1):
		var item: Dictionary = g.inventory[i]
		if str(item.get("name","")) != item_name: continue
		var count := int(item.get("count",1))
		var take := mini(count,remaining)
		count -= take
		remaining -= take
		if count <= 0:
			g.inventory.remove_at(i)
		else:
			item["count"] = count
			item["stack_value"] = maxi(0,g.item_sale_value(item)-int(item.get("value",0)))
		if remaining <= 0: break
	return remaining == 0

func learn_recipe(g, index: int = -1) -> bool:
	var use_index := selected if index < 0 else index
	if bool(learned[use_index]):
		g.message("%s ist bereits gelernt." % RECIPES[use_index]["name"])
		return false
	var cost := int(RECIPES[use_index]["learn_cost"])
	if g.gold < cost:
		g.message("Steinrose: Dieses Rezept kostet %d Gold. Dir fehlen %d." % [cost,cost-g.gold])
		return false
	g.gold -= cost
	learned[use_index] = true
	g.message("Rezept gelernt: %s." % RECIPES[use_index]["name"])
	g.play_sound("level")
	g.save_game()
	g.queue_redraw()
	return true

func cook(g, index: int = -1) -> bool:
	var use_index := selected if index < 0 else index
	if not bool(learned[use_index]):
		g.message("Steinrose: Lerne das Rezept zuerst.")
		return false
	if not can_cook(g,use_index):
		g.message("Steinrose: Zutaten fehlen oder dein Inventar ist voll.")
		return false
	for item_name in RECIPES[use_index]["ingredients"]:
		if not remove_item_count(g,item_name,int(RECIPES[use_index]["ingredients"][item_name])):
			return false
	var info := FoodSystem.by_name(str(RECIPES[use_index]["name"]))
	var item: Dictionary = g.make_item(str(RECIPES[use_index]["name"]),"food",1,0,int(info.get("price",30)),"",g.level)
	if not g.add_item(item):
		g.message("Steinrose: Das Gericht konnte nicht eingepackt werden.")
		return false
	g.message("Steinrose kocht %s. Guten Appetit!" % RECIPES[use_index]["name"])
	g.play_sound("pickup")
	g.save_game()
	g.queue_redraw()
	return true

func open(g) -> void:
	selected = clampi(selected,0,RECIPES.size()-1)
	tab = 0
	g.panel = "steinrose"
	g.play_sound("menu")
	g.queue_redraw()

func click(g, mouse: Vector2) -> void:
	for i in 4:
		if Rect2(165,170+i*48,220,40).has_point(mouse):
			tab = i
			g.play_sound("menu")
			g.queue_redraw()
			return
	for i in RECIPES.size():
		if Rect2(410,185+i*44,300,38).has_point(mouse):
			selected = i
			g.play_sound("menu")
			g.queue_redraw()
			return
	if Rect2(410,548,180,38).has_point(mouse):
		learn_recipe(g)
		return
	if Rect2(610,548,180,38).has_point(mouse):
		cook(g)
		return
	if Rect2(810,548,170,38).has_point(mouse) or Rect2(965,91,41,35).has_point(mouse):
		g.panel = ""
		g.queue_redraw()

func draw(g) -> void:
	g.text_at(Vector2(165,138),"STEINROSE · KUECHE & REZEPTE",29,Color("ffe1a0"))
	g.text_at(Vector2(165,160),"Neue Beeren, Gerichte und nicht stapelnde Reiseeffekte",13,Color("b9cbc3"))
	var labels := ["REZEPTE","NEUE BEEREN","EFFEKTE","KOCHEN"]
	for i in labels.size():
		g.ui_button(Rect2(165,170+i*48,220,40),labels[i],true,tab==i)
	g.ui_box(Rect2(165,380,220,150),Color("253b3d"))
	g.text_at(Vector2(178,405),"Steinrose",17,Color("ffe2aa"))
	g.text_at(Vector2(178,430),"Ich verwandle deine Beeren",12,Color("d8e6dc"))
	g.text_at(Vector2(178,448),"in staerkende Gerichte.",12,Color("d8e6dc"))
	g.text_at(Vector2(178,475),"Lerne Rezepte oder lass",12,Color("d8e6dc"))
	g.text_at(Vector2(178,493),"mich sofort fuer dich kochen.",12,Color("d8e6dc"))

	g.text_at(Vector2(410,162),"REZEPTE",15,Color("e9cc90"))
	for i in RECIPES.size():
		var row := Rect2(410,185+i*44,300,38)
		g.ui_box(row,Color("607666") if i==selected else Color("30474b"))
		var output_id := FoodSystem.index_for(str(RECIPES[i]["name"]))
		FoodSystem.icon(g,row.position+Vector2(4,2),output_id,0.85)
		g.text_at(row.position+Vector2(45,24),str(RECIPES[i]["name"]),13,Color("fff0ce"))
		g.text_at(row.position+Vector2(267,24),"✓" if learned[i] else "%dG" % int(RECIPES[i]["learn_cost"]),11,Color("bce6bd") if learned[i] else Color("e7c48d"))

	var detail := recipe()
	g.ui_box(Rect2(730,170,250,360),Color("20343a"))
	g.text_at(Vector2(745,198),str(detail["name"]).to_upper(),17,Color("ffe2aa"),HORIZONTAL_ALIGNMENT_LEFT,220)
	var icon_id := FoodSystem.index_for(str(detail["name"]))
	FoodSystem.icon(g,Vector2(752,212),icon_id,1.45)
	g.text_at(Vector2(745,278),str(detail["desc"]),12,Color("dce7d8"),HORIZONTAL_ALIGNMENT_LEFT,220)
	g.text_at(Vector2(745,310),"ZUTATEN",13,Color("e9cc90"))
	var row_y := 334.0
	var status := ingredient_status(g)
	for item_name in detail["ingredients"]:
		var food_id := FoodSystem.index_for(str(item_name))
		FoodSystem.icon(g,Vector2(746,row_y-20),food_id,0.58)
		var owned := int(status[item_name]["owned"])
		var needed := int(status[item_name]["needed"])
		g.text_at(Vector2(778,row_y),"%s  %d/%d" % [item_name,owned,needed],11,Color("bde8bd") if owned>=needed else Color("e8aaa0"),HORIZONTAL_ALIGNMENT_LEFT,190)
		row_y += 30
	g.text_at(Vector2(745,410),"EFFEKT",13,Color("e9cc90"))
	g.text_at(Vector2(745,434),str(detail["effect"]),11,Color("d8e6dc"),HORIZONTAL_ALIGNMENT_LEFT,220)
	g.text_at(Vector2(745,472),"Nur ein Spezial-Foodbuff",11,Color("aebfb9"))
	g.text_at(Vector2(745,490),"gleichzeitig aktiv.",11,Color("aebfb9"))

	if tab == 1:
		g.ui_box(Rect2(410,465,300,65),Color("233b42"))
		for i in BERRIES.size():
			var col := i / 6
			var row := i % 6
			var x := 417.0 + col*145.0
			var y := 480.0 + row*16.0
			var id := FoodSystem.index_for(BERRIES[i])
			g.text_at(Vector2(x,y),"%s · %d" % [BERRIES[i],inventory_count(g,BERRIES[i])],9,Color(FoodSystem.FOODS[id]["color"]),HORIZONTAL_ALIGNMENT_LEFT,140)
	elif tab == 2:
		g.ui_box(Rect2(410,465,300,65),Color("233b42"))
		g.text_at(Vector2(420,484),"Buffs ersetzen einander statt zu stapeln.",10,Color("d8e6dc"))
		g.text_at(Vector2(420,504),"HP-Regeneration bleibt separat bestehen.",10,Color("d8e6dc"))
	elif tab == 3:
		g.ui_box(Rect2(410,465,300,65),Color("233b42"))
		g.text_at(Vector2(420,486),"Bereit zum Kochen." if can_cook(g) else "Zutaten fehlen oder Inventar voll.",11,Color("bde8bd") if can_cook(g) else Color("e8aaa0"))
		g.text_at(Vector2(420,507),"Ausgabe: 1x %s" % detail["name"],10,Color("d8e6dc"))

	g.ui_button(Rect2(410,548,180,38),"REZEPT LERNEN",not learned[selected])
	g.ui_button(Rect2(610,548,180,38),"KOCHEN",can_cook(g))
	g.ui_button(Rect2(810,548,170,38),"SCHLIESSEN")
