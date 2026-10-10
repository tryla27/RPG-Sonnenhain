extends SceneTree
# Rückfrage vor dem Verlassen und Klickklang für Menüknöpfe.

class Game extends "res://main.gd":
	var heard:Array=[]
	var left:Array=[]
	func _ready()->void:
		reset_class_skills()
		for i in QUESTS.size():quests.append({"state":0,"progress":0})
		for i in WORLD_EVENTS.size():
			event_states.append(0)
			event_progress.append(0)
	func _process(_delta:float)->void:pass
	func _draw()->void:pass
	func save_game()->void:pass
	func play_sound(name:String)->void:
		heard.append(name)
		super(name)
	func leave_game(from:String)->void:left.append(from)

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("MENU_FEEDBACK_FAIL "+label)

func _initialize()->void:call_deferred("run")

## Simuliert, dass das Menü diese Knöpfe zuletzt gezeichnet hat.
func shown(g:Game,rects:Array)->void:
	g.menu_feedback.begin_frame()
	for r in rects:g.menu_feedback.note(r,true)

func clicks(g:Game)->int:
	return g.heard.count("ui_klick")

func run()->void:
	var g:=Game.new()
	root.add_child(g)
	var exit_settings:=Rect2(300,563,550,35)
	var exit_menu:=Rect2(190,540,300,44)
	var confirm:Rect2=g.MenuFeedback.CONFIRM_RECT
	var cancel:Rect2=g.MenuFeedback.CANCEL_RECT

	# Einstellungen: kein Verlassen-Knopf mehr (Angelo 10.10.2026), der alte Platz tut nichts.
	g.panel="settings"
	shown(g,[])
	g.handle_panel_click(exit_settings.get_center())
	check(not g.menu_feedback.asking() and g.panel=="settings" and g.left.is_empty(),"Einstellungen haben keinen Verlassen-Knopf mehr")

	# Spielmenü: Verlassen fragt nach, Abbrechen bleibt im Menü.
	g.panel="pause"
	shown(g,[exit_menu])
	g.handle_panel_click(exit_menu.get_center())
	check(g.menu_feedback.asking() and g.panel=="pause" and g.left.is_empty(),"Verlassen fragt erst nach")
	check(clicks(g)==1,"Klick beim Verlassen-Knopf")
	g.handle_panel_click(Vector2(200,150))
	check(g.menu_feedback.asking(),"Klick daneben schließt die Rückfrage nicht")
	g.handle_panel_click(cancel.get_center())
	check(not g.menu_feedback.asking() and g.panel=="pause" and g.left.is_empty(),"Abbrechen bleibt im Spiel")

	# Escape bricht ab, ohne das Menü zu schließen.
	g.handle_panel_click(exit_menu.get_center())
	var key:=InputEventKey.new()
	key.keycode=KEY_ESCAPE
	key.pressed=true
	g._unhandled_input(key)
	check(not g.menu_feedback.asking() and g.panel=="pause","Escape bricht die Rückfrage ab")

	# Bestätigen verlässt das Spiel.
	g.handle_panel_click(exit_menu.get_center())
	g.handle_panel_click(confirm.get_center())
	check(g.left==["pause"],"Spielmenü verlässt nach Bestätigung")

	# Klickklang: jeder sichtbare Knopf klickt genau einmal.
	g.heard.clear()
	g.panel="settings"
	var resume:=Rect2(300,221,550,42)
	shown(g,[resume])
	g.handle_panel_click(resume.get_center())
	check(g.panel=="" and clicks(g)==1,"Fortsetzen klickt einmal")
	g.heard.clear()
	g.panel="pause"
	var save_button:=Rect2(540,512,410,42)
	shown(g,[save_button])
	g.handle_panel_click(save_button.get_center())
	check(clicks(g)==1,"Knopf mit eigenem Klang klickt nicht doppelt")
	g.heard.clear()
	g.handle_panel_click(Vector2(700,450))
	check(clicks(g)==0,"Klick ins Leere bleibt still")
	g.menu_feedback.begin_frame()
	g.menu_feedback.note(Rect2(10,10,50,50),false)
	g.handle_panel_click(Vector2(30,30))
	check(clicks(g)==0,"Gesperrter Knopf klickt nicht")
	g.heard.clear()
	g.panel="settings"
	shown(g,[])
	g.handle_panel_click(Vector2(600,375+10))
	check(clicks(g)==1,"Lautstärkeregler klickt")

	g.queue_free()
	await process_frame
	if failures>0:
		print("MENU_FEEDBACK_FAILED ",failures)
		quit(1)
		return
	print("MENU_FEEDBACK_OK exit confirmation, escape cancel, click sounds once per button, sliders")
	quit()
