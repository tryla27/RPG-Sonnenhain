extends RefCounted

const FoodSystem = preload("res://components/food_system.gd")

const BERRIES := [
	"Himbeeren","Moosbeeren","Steinbeeren","Kristallbeeren","Aprikose","Heidelbeeren",
	"Pflaume","Nebelbeeren","Bernsteinfrucht","Quellbeeren","Daemmerbeeren","Himmelsfrucht"
]
const BERRY_REGIONS := [1,2,3,4,5,6,7,8,9,10,11,12]

const RECIPES := [
	{"name":"Waldbeer-Kompott","ingredients":{"Himbeeren":2,"Heidelbeeren":2,"Sonnenkraut":1},"learn_cost":0,"desc":"Warme Waldbeeren fuer lange Wege.","effect":"+25 HP sofort · +2 HP/s · 6:00"},
	{"name":"Moosbeeren-Eintopf","ingredients":{"Moosbeeren":3,"Aprikose":1,"Moosminze":1},"learn_cost":4,"desc":"Kraeftiger Eintopf aus dem Pilzwald.","effect":"+20 HP sofort · +3 HP/s · 6:00"},
	{"name":"Steinbeeren-Riegel","ingredients":{"Steinbeeren":3,"Bernsteinfrucht":1,"Steinwurz":1},"learn_cost":5,"desc":"Fest, haltbar und schuetzend.","effect":"+2 HP/s · +5% Resistenz · 6:00"},
	{"name":"Kristallgelee","ingredients":{"Kristallbeeren":2,"Quellbeeren":2,"Kristallthymian":1},"learn_cost":6,"desc":"Kuehlendes Gelee fuer konzentrierte Kaempfer.","effect":"+3 HP/s · +5% Cooldown-Tempo · 6:00"},
	{"name":"Nebelpflaumen-Tee","ingredients":{"Nebelbeeren":2,"Pflaume":2,"Glutblatt":1},"learn_cost":7,"desc":"Leichter Tee fuer schnelle Schritte.","effect":"+2 HP/s · +5% Bewegung · 6:00"},
	{"name":"Daemmerhimmel-Torte","ingredients":{"Daemmerbeeren":2,"Himmelsfrucht":2,"Blausalbei":1},"learn_cost":9,"desc":"Almas seltenes Reisegericht.","effect":"+4 HP/s · +4% Schaden · 6:00"},
	{"name":"Himmelsfrucht-Salat","ingredients":{"Himmelsfrucht":1,"Quellbeeren":2,"Aprikose":1,"Nebelklee":1},"learn_cost":10,"desc":"Frisch, leicht und ideal zum Sammeln.","effect":"+3 HP/s · +4% Sammelchance · 6:00"},
	{"name":"Quellbeeren-Brei","ingredients":{"Quellbeeren":3,"Moosbeeren":1,"Sternenfarn":1},"learn_cost":10,"desc":"Sanfte, reine Regeneration.","effect":"+3 HP/s · 6:00"},
	{"name":"Bernstein-Marmelade","ingredients":{"Bernsteinfrucht":2,"Himbeeren":2,"Bernsteinblatt":1},"learn_cost":11,"desc":"Zaeh und schuetzend wie Harz.","effect":"+2 HP/s · +5% Resistenz · 6:00"},
	{"name":"Heidelbeer-Pfannkuchen","ingredients":{"Heidelbeeren":3,"Aprikose":1,"Quellminze":1},"learn_cost":12,"desc":"Ein ruhiges Sammlerfruehstueck.","effect":"+3 HP/s · +4% Sammelchance · 6:00"},
	{"name":"Schimmerbeeren-Suppe","ingredients":{"Kristallbeeren":2,"Heidelbeeren":2,"Daemmerkraut":1},"learn_cost":14,"desc":"Blaue Suppe fuer reine Mana-Erholung.","effect":"+4 Mana/s · nur Mana · 6:00"},
	{"name":"Blauer Mondkuchen","ingredients":{"Kristallbeeren":2,"Quellbeeren":2,"Himmelsfrucht":1,"Himmelslavendel":1},"learn_cost":18,"desc":"Almas seltene Notration fuer Magier.","effect":"Mana sofort vollstaendig wiederherstellen"}
]

var selected := 0
var tab := 0
var learned: Array = [true,false,false,false,false,false,false,false,false,false,false,false]

func snapshot() -> Dictionary:
	return {"learned":learned.duplicate()}

func restore(raw: Variant) -> void:
	learned = [true,false,false,false,false,false,false,false,false,false,false,false]
	if raw is Dictionary:
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

func ingredient_label(item_name:String)->String:
	return item_name

func ingredient_status(g, index: int = -1) -> Dictionary:
	var result := {}
	var selected_recipe := recipe(index)
	for item_name in selected_recipe["ingredients"]:
		result[item_name] = {"owned":inventory_count(g,item_name),"needed":int(selected_recipe["ingredients"][item_name])}
	return result

func learned_indices() -> Array[int]:
	var result:Array[int]=[]
	for i in RECIPES.size():
		if bool(learned[i]): result.append(i)
	return result

func visible_recipe_indices() -> Array[int]:
	if tab==3:return learned_indices()
	var result:Array[int]=[]
	for i in RECIPES.size():result.append(i)
	return result

func can_cook(g, index: int = -1) -> bool:
	var use_index := selected if index < 0 else index
	if not bool(learned[use_index]): return false
	for item_name in RECIPES[use_index]["ingredients"]:
		if inventory_count(g,item_name) < int(RECIPES[use_index]["ingredients"][item_name]): return false
	if g.inventory.size() < 42: return true
	for item in g.inventory:
		if str(item.get("name","")) == str(RECIPES[use_index]["name"]) and int(item.get("count",1)) < g.stack_limit(item): return true
	for item_name in RECIPES[use_index]["ingredients"]:
		var needed := int(RECIPES[use_index]["ingredients"][item_name])
		for item in g.inventory:
			if str(item.get("name","")) == item_name and int(item.get("count",1)) <= needed: return true
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
		if count <= 0:g.inventory.remove_at(i)
		else:
			var old_count:int=maxi(1,int(item.get("count",1)))
			var old_value:int=g.item_sale_value(item)
			item["count"] = count
			item["stack_value"] = int(round(float(old_value)*count/old_count))
		if remaining <= 0: break
	return remaining == 0

func learn_recipe(g, index: int = -1) -> bool:
	var use_index := selected if index < 0 else index
	if bool(learned[use_index]):
		g.message("%s ist bereits gelernt." % RECIPES[use_index]["name"])
		return false
	var cost := int(RECIPES[use_index]["learn_cost"])
	if g.gold < cost:
		g.message("Alma: Fuer meinen Aufwand brauche ich %d Gold. Dir fehlen %d." % [cost,cost-g.gold])
		return false
	g.gold -= cost
	learned[use_index] = true
	g.message("Alma zeigt dir das Rezept fuer %s." % RECIPES[use_index]["name"])
	g.play_sound("level");g.save_game();g.queue_redraw()
	return true

func cook(g, index: int = -1) -> bool:
	var use_index := selected if index < 0 else index
	if not bool(learned[use_index]):
		g.message("Alma: Lerne das Rezept zuerst.")
		return false
	if not can_cook(g,use_index):
		g.message("Alma: Zutaten fehlen oder dein Inventar ist voll.")
		return false
	for item_name in RECIPES[use_index]["ingredients"]:
		if not remove_item_count(g,item_name,int(RECIPES[use_index]["ingredients"][item_name])): return false
	var info := FoodSystem.by_name(str(RECIPES[use_index]["name"]))
	var item: Dictionary = g.make_item(str(RECIPES[use_index]["name"]),"food",1,0,int(info.get("price",10)),"",g.level)
	if not g.add_item(item):
		g.message("Alma: Das Gericht konnte nicht eingepackt werden.")
		return false
	g.message("Alma kocht %s aus deinen Zutaten. Guten Appetit!" % RECIPES[use_index]["name"])
	g.play_sound("pickup");g.save_game();g.queue_redraw()
	return true

func open(g) -> void:
	selected = clampi(selected,0,RECIPES.size()-1)
	tab = 0
	g.panel = "steinrose"
	g.play_sound("menu")
	g.queue_redraw()

func set_tab(g,index:int)->void:
	tab=clampi(index,0,3)
	if tab==3 and not bool(learned[selected]):
		var known:=learned_indices()
		if not known.is_empty():selected=known[0]
	g.play_sound("menu")
	g.queue_redraw()

func click(g, mouse: Vector2) -> void:
	for i in 4:
		if Rect2(165,170+i*48,220,40).has_point(mouse):
			set_tab(g,i);return
	if tab in [0,3]:
		var shown:=visible_recipe_indices()
		for row_index in shown.size():
			if Rect2(410,190+row_index*27,300,24).has_point(mouse):
				selected=shown[row_index]
				g.play_sound("menu");g.queue_redraw();return
	if tab==0 and Rect2(410,548,180,38).has_point(mouse):
		learn_recipe(g);return
	if tab==3 and Rect2(610,548,180,38).has_point(mouse):
		cook(g);return
	if Rect2(810,548,170,38).has_point(mouse) or Rect2(965,91,41,35).has_point(mouse):
		g.panel="";g.queue_redraw()

func draw_recipe_detail(g, allow_cook:bool=false) -> void:
	var detail:=recipe()
	g.ui_box(Rect2(730,180,250,350),Color("20343a"))
	g.text_at(Vector2(745,207),str(detail["name"]).to_upper(),15,Color("ffe2aa"),HORIZONTAL_ALIGNMENT_LEFT,220)
	var icon_id:=FoodSystem.index_for(str(detail["name"]))
	FoodSystem.icon(g,Vector2(752,219),icon_id,1.1)
	g.text_at(Vector2(745,274),str(detail["desc"]),10,Color("dce7d8"),HORIZONTAL_ALIGNMENT_LEFT,220)
	g.text_at(Vector2(745,305),"ZUTATEN",12,Color("e9cc90"))
	var y:=327.0
	var status:=ingredient_status(g)
	for item_name in detail["ingredients"]:
		var herb_region:int=FoodSystem.herb_region(str(item_name))
		if herb_region>0:
			var herb_info:Dictionary=FoodSystem.herb_for_region(herb_region)
			g.draw_item_icon(Vector2(746,y-19),"herb",Color(herb_info["color"]),0.48)
		else:
			var food_id:=FoodSystem.index_for(str(item_name))
			FoodSystem.icon(g,Vector2(746,y-19),food_id,0.48)
		var owned:=int(status[item_name]["owned"])
		var needed:=int(status[item_name]["needed"])
		g.text_at(Vector2(774,y),"%s  %d/%d" % [ingredient_label(str(item_name)),owned,needed],10,Color("bde8bd") if owned>=needed else Color("e8aaa0"),HORIZONTAL_ALIGNMENT_LEFT,194)
		y+=24
	g.text_at(Vector2(745,414),"WIRKUNG",12,Color("e9cc90"))
	g.text_at(Vector2(745,437),str(detail["effect"]),10,Color("d8e6dc"),HORIZONTAL_ALIGNMENT_LEFT,220)
	g.text_at(Vector2(745,467),"DAUER  06:00",11,Color("ffe1a0"))
	if str(detail["name"])=="Schimmerbeeren-Suppe":
		g.text_at(Vector2(745,490),"Nur Mana-Regeneration, kein HP-Bonus.",9,Color("8fc4ff"),HORIZONTAL_ALIGNMENT_LEFT,220)
	elif str(detail["name"])=="Blauer Mondkuchen":
		g.text_at(Vector2(745,490),"Sofort 100% Mana · kein 6-Minuten-Buff.",9,Color("8fc4ff"),HORIZONTAL_ALIGNMENT_LEFT,220)
	elif allow_cook:
		g.text_at(Vector2(745,490),"Deine Zutaten bestimmen den Preis.",9,Color("aebfb9"),HORIZONTAL_ALIGNMENT_LEFT,220)

func draw_recipe_page(g) -> void:
	g.text_at(Vector2(410,177),"REZEPTE ENTDECKEN & LERNEN",14,Color("e9cc90"))
	for row_index in RECIPES.size():
		var row:=Rect2(410,190+row_index*27,300,24)
		g.ui_box(row,Color("607666") if row_index==selected else Color("30474b"))
		var output_id:=FoodSystem.index_for(str(RECIPES[row_index]["name"]))
		FoodSystem.icon(g,row.position+Vector2(2,-3),output_id,0.55)
		g.text_at(row.position+Vector2(30,17),str(RECIPES[row_index]["name"]),10,Color("fff0ce"))
		g.text_at(row.position+Vector2(258,17),"GELERNT" if learned[row_index] else "%dG" % int(RECIPES[row_index]["learn_cost"]),8,Color("bce6bd") if learned[row_index] else Color("e7c48d"))
	draw_recipe_detail(g)
	g.text_at(Vector2(410,525),"Nur kleiner Aufwand: Zutaten bringst du selbst mit.",9,Color("b9cbc3"))

func draw_berries_page(g) -> void:
	g.text_at(Vector2(410,177),"BEEREN & KRAEUTER",14,Color("e9cc90"))
	g.text_at(Vector2(410,198),"Dein Bestand und die Herkunft der 12 Regionalfruechte.",10,Color("b9cbc3"))
	for i in BERRIES.size():
		var col:int=i/6
		var row:int=i%6
		var x:=410.0+col*285.0
		var y:=220.0+row*48.0
		g.ui_box(Rect2(x,y,265,40),Color("263d43"))
		var food_id:=FoodSystem.index_for(BERRIES[i])
		FoodSystem.icon(g,Vector2(x+6,y+4),food_id,0.62)
		g.text_at(Vector2(x+42,y+17),BERRIES[i],11,Color(FoodSystem.FOODS[food_id]["color"]).lightened(.25))
		g.text_at(Vector2(x+42,y+34),"Bestand %d · %s" % [inventory_count(g,BERRIES[i]),g.region_name(BERRY_REGIONS[i])],9,Color("c9d6cf"),HORIZONTAL_ALIGNMENT_LEFT,210)
	g.ui_box(Rect2(410,516,550,24),Color("20343a"))
	g.text_at(Vector2(420,533),"Fehlende Zutaten werden auf Rezept- und Kochseite rot markiert.",9,Color("d8e6dc"))

func draw_effects_page(g) -> void:
	g.text_at(Vector2(410,177),"WIRKUNGEN & REGELN",14,Color("e9cc90"))
	g.ui_box(Rect2(410,192,550,80),Color("20343a"))
	if g.food_system.meal_active():
		var remain:int=g.food_system.meal_remaining()
		var icon_id:=FoodSystem.index_for(g.food_system.active_food_name)
		if icon_id>=0:FoodSystem.icon(g,Vector2(420,205),icon_id,0.9)
		g.text_at(Vector2(462,214),"AKTIV · "+g.food_system.active_food_name,11,Color("ffe2aa"))
		g.text_at(Vector2(462,235),g.food_system.meal_effect_text(),10,Color("bde8bd"))
		g.text_at(Vector2(462,255),"Restzeit %02d:%02d" % [int(remain/60),remain%60],10,Color("d8e7ff"))
	else:
		g.text_at(Vector2(425,220),"Kein Langzeit-Essenseffekt aktiv.",11,Color("c9d6cf"))
		g.text_at(Vector2(425,244),"Iss ein gekochtes Gericht, um 6:00 Minuten Regeneration zu erhalten.",9,Color("aebfb9"))
	g.text_at(Vector2(410,296),"GRUNDREGELN",12,Color("e9cc90"))
	var rules:=["• Immer nur 1 Langzeit-Gericht aktiv.","• Neues Langzeit-Gericht ersetzt den alten Effekt.","• HP-Gerichte regenerieren vor allem Leben.","• Schimmerbeeren-Suppe regeneriert nur Mana.","• Mondkuchen fuellt Mana sofort und ersetzt keinen Buff."]
	for i in rules.size():g.text_at(Vector2(420,320+i*22),rules[i],10,Color("d8e6dc"))
	g.text_at(Vector2(410,444),"GERICHTE IM UEBERBLICK",12,Color("e9cc90"))
	for i in RECIPES.size():
		var col:int=i/6
		var row:int=i%6
		var x:=420.0+col*275.0
		var y:=466.0+row*13.0
		g.text_at(Vector2(x,y),"%s · %s" % [RECIPES[i]["name"],RECIPES[i]["effect"]],8,Color("c8d7cf"),HORIZONTAL_ALIGNMENT_LEFT,265)

func draw_cook_page(g) -> void:
	g.text_at(Vector2(410,177),"KOCHEN · NUR GELERNTE REZEPTE",14,Color("e9cc90"))
	var shown:=learned_indices()
	if shown.is_empty():
		g.text_at(Vector2(410,215),"Noch keine Rezepte gelernt.",11,Color("e8aaa0"))
		return
	for row_index in shown.size():
		var recipe_index:int=shown[row_index]
		var row:=Rect2(410,190+row_index*27,300,24)
		g.ui_box(row,Color("607666") if recipe_index==selected else Color("30474b"))
		var output_id:=FoodSystem.index_for(str(RECIPES[recipe_index]["name"]))
		FoodSystem.icon(g,row.position+Vector2(2,-3),output_id,0.55)
		g.text_at(row.position+Vector2(30,17),str(RECIPES[recipe_index]["name"]),10,Color("fff0ce"))
		g.text_at(row.position+Vector2(250,17),"BEREIT" if can_cook(g,recipe_index) else "FEHLT",8,Color("bce6bd") if can_cook(g,recipe_index) else Color("e8aaa0"))
	draw_recipe_detail(g,true)
	g.text_at(Vector2(410,525),"Kochen kostet kein zusaetzliches Gold.",9,Color("bde8bd"))

func draw(g) -> void:
	g.text_at(Vector2(165,138),"ALMA · KUECHE DER STEINROSE",29,Color("ffe1a0"))
	g.text_at(Vector2(165,160),"Besondere Beeren + 1 Kraut · Alma nimmt nur einen kleinen Aufwand",12,Color("b9cbc3"))
	var labels:=["REZEPTE","BEEREN & VORRAT","WIRKUNGEN","KOCHEN"]
	for i in labels.size():g.ui_button(Rect2(165,170+i*48,220,40),labels[i],true,tab==i)
	g.ui_box(Rect2(165,380,220,150),Color("253b3d"))
	g.text_at(Vector2(178,405),"Alma",17,Color("ffe2aa"))
	g.text_at(Vector2(178,430),"Wirtin der Steinrose.",12,Color("d8e6dc"))
	g.text_at(Vector2(178,452),"Bring mir deine Fruechte,",12,Color("d8e6dc"))
	g.text_at(Vector2(178,470),"ich uebernehme den Rest.",12,Color("d8e6dc"))
	g.text_at(Vector2(178,500),"Ein Gericht wirkt 6 Minuten.",11,Color("aebfb9"))
	match tab:
		0:draw_recipe_page(g)
		1:draw_berries_page(g)
		2:draw_effects_page(g)
		3:draw_cook_page(g)
	if tab==0:g.ui_button(Rect2(410,548,180,38),"REZEPT LERNEN",not learned[selected])
	if tab==3:g.ui_button(Rect2(610,548,180,38),"KOCHEN",can_cook(g))
	g.ui_button(Rect2(810,548,170,38),"SCHLIESSEN")
