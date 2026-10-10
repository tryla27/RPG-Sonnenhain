extends SceneTree
# Ausrüstung tauschen (Plätze wechseln), Item-Infos am Charakter, Escape im Vollbild.

const DisplayMode=preload("res://components/display_mode.gd")

class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_d:float)->void:pass
	func save_game()->void:pass
	func play_sound(_n:String)->void:pass
	func announce_multiplayer_context()->void:pass

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("EQUIP_SWAP_FAIL "+label)

func _initialize()->void:call_deferred("run")

func run()->void:
	var g:=Game.new()
	g.reset_class_skills();g.character_created=true;g.class_id=0;g.level=20
	g.inventory.clear()
	var old_armor:Dictionary=g.make_item("Alte Rüstung","armor",1,10,50)
	var potion:Dictionary=g.make_item("Heiltrank","potion",1,0,18)
	var new_armor:Dictionary=g.make_item("Neue Rüstung","armor",2,20,90)
	g.inventory.append(old_armor);g.inventory.append(potion);g.inventory.append(new_armor)
	g.use_item(0)
	check(g.equipped_armor_uid==int(old_armor["uid"]),"alte Rüstung angelegt")
	g.selected_item=2
	g.use_item(2)
	check(g.equipped_armor_uid==int(new_armor["uid"]),"neue Rüstung angelegt")
	check(int(g.inventory[0]["uid"])==int(new_armor["uid"]),"neue Rüstung steht auf dem Platz der alten")
	check(int(g.inventory[2]["uid"])==int(old_armor["uid"]),"alte Rüstung steht auf dem Platz der neuen")
	check(g.selected_item==0,"Auswahl folgt dem angelegten Teil")
	check(int(g.inventory[1]["uid"])==int(potion["uid"]),"andere Teile bleiben, wo sie sind")
	# Ausziehen tauscht nichts.
	g.use_item(0)
	check(g.equipped_armor_uid==-1 and int(g.inventory[0]["uid"])==int(new_armor["uid"]),"Ausziehen lässt die Plätze")
	# Anlegen in einen freien Platz tauscht nichts.
	g.use_item(2)
	check(g.equipped_armor_uid==int(old_armor["uid"]) and int(g.inventory[2]["uid"])==int(old_armor["uid"]),"freier Platz: kein Tausch")

	# Item-Infos am Charakter.
	var worn:Dictionary=g.worn_item_at(Vector2(520,260))
	check(not worn.is_empty() and int(worn["uid"])==int(old_armor["uid"]),"Infos für die getragene Rüstung")
	check(g.worn_item_at(Vector2(200,220)).is_empty(),"leerer Kopfplatz: keine Infos")

	# Escape im Vollbild: Hinweis beim zweiten Druck innerhalb von 4 s.
	var counter=DisplayMode.EscapeCounter.new()
	check(not counter.press(0),"erstes Escape: kein Hinweis")
	check(counter.press(1500),"zweites Escape: Hinweis F11")
	check(not counter.press(2000),"danach zählt es neu")
	check(not counter.press(9000) and counter.press(9900),"wieder zwei Mal → Hinweis")
	check(not counter.press(20000) and not counter.press(30000),"zu langsam: kein Hinweis")
	check(g.spawn_hum_level()==0.0,"Spawngeräusch entfernt")

	g.free()
	if failures>0:
		push_error("EQUIP_SWAP_FAILED %d" % failures);quit(1);return
	print("EQUIP_SWAP_OK")
	quit()
