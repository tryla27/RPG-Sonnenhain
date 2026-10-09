extends SceneTree
# Mit Konto zeigt das Startmenü dieselben Charaktere wie die Charakterauswahl
# und lädt sie vom Server, nicht fremde lokale Browser-Spielstände.

class Game extends "res://main.gd":
	var opened:=-1
	var last_error:=""
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func slot_save_path(index:int,testing:bool=false)->String:return "user://test_account_slot%d%s.json" % [index,"_t" if testing else ""]
	func open_account_character(index:int)->void:opened=index
	func message_error(value:String)->void:last_error=value
	func play_sound(_name:String)->void:pass

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("ACCOUNT_START_SLOTS_FAIL "+label)

func _initialize()->void:call_deferred("run")

func run()->void:
	var g:=Game.new()
	# Fremder lokaler Stand auf Platz 1 (anderes Konto im selben Browser).
	var f:=FileAccess.open(g.slot_save_path(1),FileAccess.WRITE)
	f.store_string(JSON.stringify({"hero_name":"Fremd","level":30,"class_id":1,"player_uuid":"other"}))
	f.close()
	g.refresh_save_slot_labels()
	check(str(g.save_slot_labels[0]).begins_with("Fremd"),"ohne Konto: lokale Stände wie bisher")

	g.account_logged_in=true
	g.account_characters=[{"slot":2,"uuid":"hero-b","token":"t","name":"Bea","level":4,"class_id":2}]
	g.refresh_save_slot_labels()
	check(g.save_slot_labels[0]=="LEER","mit Konto: fremder lokaler Stand nicht angezeigt (%s)" % g.save_slot_labels[0])
	check(str(g.save_slot_labels[1]).begins_with("Bea · LV 4"),"mit Konto: Kontocharakter auf seinem Platz")

	g.panel="start"
	g.selected_save_slot=1
	check(not g.start_slot_loadable(),"leerer Kontoplatz nicht ladbar")
	g.panel_click(Vector2(400,470))
	check(g.opened==-1 and g.last_error!="","leerer Platz lädt nichts, Hinweis erscheint")
	g.selected_save_slot=2
	check(g.start_slot_loadable(),"Kontoplatz ladbar")
	g.panel_click(Vector2(400,470))
	check(g.opened==0,"Laden öffnet den Kontocharakter vom Server")

	# Nach dem Spielen zeigt die Liste die aktuelle Stufe.
	g.character_created=true
	g.player_uuid="hero-b";g.hero_name="Bea";g.level=9;g.class_id=2
	g.refresh_save_slot_labels()
	check(str(g.save_slot_labels[1]).begins_with("Bea · LV 9"),"Stufe aktuell nach dem Spielen")

	g.free()
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_account_slot1.json"))
	if failures>0:
		print("ACCOUNT_START_SLOTS_FAILED ",failures)
		quit(1)
		return
	print("ACCOUNT_START_SLOTS_OK start menu shows and loads the account's own characters")
	quit()
