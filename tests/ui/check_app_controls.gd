extends SceneTree
# Android-App: Fähigkeiten tippen/ziehen/abbrechen, Zielhilfe-Wahl, eigene
# Knopfanordnung (Speichern, Laden, Editor).

const AppTouch=preload("res://components/app_touch.gd")
const AppLayout=preload("res://components/app_layout.gd")
const AppEditor=preload("res://components/app_layout_editor.gd")

class Game extends "res://main.gd":
	var casts:Array=[]
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func use_ability(slot:int)->void:casts.append([slot,facing])

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("APP_CONTROLS_FAIL "+label)

func touch(g,pos:Vector2,pressed:bool,index:int=0)->void:
	var t:=InputEventScreenTouch.new();t.position=pos;t.pressed=pressed;t.index=index
	g._unhandled_input(t)

func drag(g,pos:Vector2,index:int=0)->void:
	var d:=InputEventScreenDrag.new();d.position=pos;d.index=index
	g._unhandled_input(d)

func mouse(g,pos:Vector2,pressed:bool)->void:
	var m:=InputEventMouseButton.new();m.position=pos;m.pressed=pressed;m.button_index=MOUSE_BUTTON_LEFT
	g._unhandled_input(m)

func motion(g,pos:Vector2)->void:
	var m:=InputEventMouseMotion.new();m.position=pos;m.button_mask=MOUSE_BUTTON_MASK_LEFT
	g._unhandled_input(m)

func _initialize()->void:call_deferred("run")

func run()->void:
	AppLayout.reset();AppLayout.set_priority("nearest")
	# Zielwahl
	var foes:=[{"pos":Vector2(100,0),"hp":90.0,"max_hp":100.0},{"pos":Vector2(300,0),"hp":5.0,"max_hp":40.0},{"pos":Vector2(200,0),"hp":60.0,"max_hp":900.0}]
	check(AppTouch.nearest_target(Vector2.ZERO,foes)==Vector2(100,0),"nächster")
	check(AppTouch.nearest_target(Vector2.ZERO,foes,520.0,"lowest")==Vector2(300,0),"wenigstes Leben")
	check(AppTouch.nearest_target(Vector2.ZERO,foes,520.0,"strongest")==Vector2(200,0),"stärkster")
	check(AppTouch.nearest_target(Vector2.ZERO,foes,150.0,"strongest")==Vector2(100,0),"Reichweite gilt für alle Wahlen")

	# Anordnung: Standard, verschieben, vergrößern, Speichern und Laden
	check(AppLayout.is_default() and AppLayout.center("attack")==AppLayout.ATTACK,"Standardanordnung")
	AppLayout.set_center("dodge",Vector2(700,300))
	AppLayout.set_scale("dodge",1.5)
	check(AppLayout.center("dodge")==Vector2(700,300) and is_equal_approx(AppLayout.radius("dodge"),45.0),"verschoben und vergrößert")
	AppLayout.set_scale("dodge",9.0)
	check(is_equal_approx(AppLayout.scale("dodge"),AppLayout.MAX_SCALE),"Größe begrenzt")
	AppLayout.set_center("dodge",Vector2(-50,9999))
	check(AppLayout.center("dodge")==Vector2(16,632),"Mitte bleibt auf dem Bildschirm")
	AppLayout.set_center("dodge",Vector2(700,300))
	check(AppTouch.button_at(Vector2(700,300))=="dodge" and AppTouch.button_at(AppTouch.DODGE)=="","Treffer folgt der neuen Lage")
	AppLayout.set_priority("lowest")
	var tmp:="user://check_app_controls.cfg"
	AppLayout.save_settings(tmp)
	AppLayout.reset();AppLayout.set_priority("nearest")
	AppLayout.load_settings(tmp)
	check(AppLayout.center("dodge")==Vector2(700,300) and AppLayout.priority=="lowest","Laden stellt Anordnung und Zielwahl her")
	DirAccess.remove_absolute(tmp)
	AppLayout.reset();AppLayout.set_priority("nearest")
	AppLayout.load_settings("user://gibt_es_nicht.cfg")
	check(AppLayout.is_default() and AppLayout.priority=="nearest","fehlende Datei: Standard")

	var g:=Game.new()
	root.add_child(g)
	for i in 4:await process_frame
	g.app_mode=true;g.touch_enabled=true;g.character_created=true;g.death_timer=0.0;g.panel=""
	g.reset_touch_joystick();g.reset_touch_aim()
	var skill:=AppTouch.skill_center(1)

	# Antippen: zielt automatisch auf den Gegner, wirkt beim Loslassen
	g.enemies.clear()
	g.enemies.append({"pos":g.player_pos+Vector2(0,200),"hp":50.0,"max_hp":50.0,"type":0})
	g.facing=Vector2.RIGHT
	touch(g,skill,true,2)
	check(g.casts.is_empty(),"Fähigkeit wirkt erst beim Loslassen")
	touch(g,skill,false,2)
	check(g.casts.size()==1 and g.casts[0][0]==1 and (g.casts[0][1] as Vector2).distance_to(Vector2.DOWN)<0.01,"Antippen: Auto-Ziel")
	await create_timer(0.4).timeout

	# Ziehen: von Hand zielen
	g.casts.clear()
	touch(g,skill,true,2)
	drag(g,skill+Vector2(80,0),2)
	check(g.app_touch.skill_drag and not g.app_touch.skill_cancel,"Ziehen erkannt")
	touch(g,skill+Vector2(80,0),false,2)
	check(g.casts.size()==1 and (g.casts[0][1] as Vector2).distance_to(Vector2.RIGHT)<0.01,"Ziehen: Richtung des Fingers")
	await create_timer(0.4).timeout

	# Abbrechen: im roten Kreis loslassen
	g.casts.clear()
	touch(g,skill,true,2)
	drag(g,skill+Vector2(0,-40),2)
	drag(g,AppTouch.CANCEL_CENTER,2)
	check(g.app_touch.skill_cancel,"Abbruchkreis erkannt")
	touch(g,AppTouch.CANCEL_CENTER,false,2)
	check(g.casts.is_empty() and g.app_touch.skill_finger==-1,"Abbruch: kein Zauber")
	await create_timer(0.4).timeout

	# Abbrechen: zurück zum Knopf
	touch(g,skill,true,2)
	drag(g,skill+Vector2(90,0),2)
	drag(g,skill+Vector2(3,0),2)
	touch(g,skill+Vector2(3,0),false,2)
	check(g.casts.is_empty(),"zurück zum Knopf bricht ab")
	await create_timer(0.4).timeout

	# Zielwahl wirkt auf den Angriff
	g.enemies.clear()
	g.enemies.append({"pos":g.player_pos+Vector2(100,0),"hp":90.0,"max_hp":90.0,"type":0})
	g.enemies.append({"pos":g.player_pos+Vector2(0,300),"hp":4.0,"max_hp":90.0,"type":0})
	AppLayout.set_priority("lowest")
	g.app_auto_aim(true)
	check(g.facing.distance_to(Vector2.DOWN)<0.01,"Auto-Ziel folgt der Wahl")
	AppLayout.set_priority("nearest")
	g.enemies.clear()

	# Einstellungsfenster und Editor
	g.panel="app_controls"
	AppEditor.click_settings(g,AppEditor.PRIORITY_RECTS[2].get_center())
	check(AppLayout.priority=="strongest","Fenster: Zielwahl")
	AppEditor.click_settings(g,AppEditor.ARRANGE.get_center())
	check(g.panel=="app_layout","Fenster öffnet den Editor")
	var atk:=AppLayout.center("attack")
	mouse(g,atk,true)
	check(g.app_editor.selected=="attack","Editor: Knopf gewählt")
	motion(g,atk+Vector2(-120,-60))
	mouse(g,atk+Vector2(-120,-60),false)
	check(AppLayout.center("attack").distance_to(atk+Vector2(-120,-60))<1.0,"Editor: Knopf verschoben")
	check(g.touch_aim_base==AppLayout.center("attack"),"Editor: Angriffsknopf folgt")
	mouse(g,AppEditor.PLUS.get_center(),true);mouse(g,AppEditor.PLUS.get_center(),false)
	check(is_equal_approx(AppLayout.scale("attack"),1.1),"Editor: größer")
	mouse(g,AppEditor.MINUS.get_center(),true);mouse(g,AppEditor.MINUS.get_center(),false)
	mouse(g,AppEditor.MINUS.get_center(),true);mouse(g,AppEditor.MINUS.get_center(),false)
	check(is_equal_approx(AppLayout.scale("attack"),0.9),"Editor: kleiner")
	mouse(g,AppLayout.center("move"),true)
	motion(g,Vector2(300,380))
	mouse(g,Vector2(300,380),false)
	check(g.touch_move_base==AppLayout.center("move") and AppLayout.center("move").distance_to(Vector2(300,380))<1.0,"Editor: Stick verschiebbar")
	mouse(g,AppEditor.RESET.get_center(),true);mouse(g,AppEditor.RESET.get_center(),false)
	check(AppLayout.is_default() and g.touch_move_base==AppLayout.center("move"),"Editor: Standard")
	mouse(g,AppEditor.DONE.get_center(),true);mouse(g,AppEditor.DONE.get_center(),false)
	check(g.panel=="app_controls","Editor: Fertig")

	# Browser-Touch bleibt unberührt
	g.app_mode=false;g.panel=""
	check(g.touch_button_at(Vector2(1032,526))=="attack","Browser-Touch unverändert")
	AppLayout.reset();AppLayout.set_priority("nearest");AppLayout.save_settings()

	if failures>0:
		push_error("APP_CONTROLS_FAILED %d"%failures);quit(1);return
	print("APP_CONTROLS_OK")
	quit()
