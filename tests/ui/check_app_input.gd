extends SceneTree
# Android-App: Bildschirmtastatur, Touch-Knöpfe, einmaliges Auslösen pro Tap,
# Zurück-Taste, Zielhilfe. Browser-Touch bleibt beim alten Layout.

const AppTouch=preload("res://components/app_touch.gd")
const AppKeyboard=preload("res://components/app_keyboard.gd")

class Game extends "res://main.gd":
	var waystone_used:=0
	var sent:Array=[]
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func use_waystone()->void:waystone_used+=1
	func send_chat_message(text:String)->void:sent.append(text)

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("APP_INPUT_FAIL "+label)

func touch(g,pos:Vector2,pressed:bool=true,index:int=0)->void:
	var t:=InputEventScreenTouch.new();t.position=pos;t.pressed=pressed;t.index=index
	g._unhandled_input(t)

func mouse(g,pos:Vector2,pressed:bool=true)->void:
	var m:=InputEventMouseButton.new();m.position=pos;m.pressed=pressed;m.button_index=MOUSE_BUTTON_LEFT
	m.device=InputEvent.DEVICE_ID_EMULATION
	g._unhandled_input(m)

func key(g,code:int,unicode:int=0,via_input:bool=false)->void:
	var k:=InputEventKey.new();k.keycode=code;k.unicode=unicode;k.pressed=true
	if via_input:g._input(k)
	else:g._unhandled_input(k)

func _initialize()->void:call_deferred("run")

func run()->void:
	# Layout: jeder Knopf an seiner Stelle, keine Überlappung.
	check(AppTouch.button_at(AppTouch.ATTACK)=="attack","Angriff")
	for slot in 4:
		check(AppTouch.button_at(AppTouch.skill_center(slot))=="ability_%d"%(slot+1),"Fähigkeit %d"%(slot+1))
		for other in range(slot+1,4):
			check(AppTouch.skill_center(slot).distance_to(AppTouch.skill_center(other))>=AppTouch.SKILL_R*2.0,"Fähigkeiten überlappen nicht")
	check(AppTouch.button_at(AppTouch.DODGE)=="dodge","Ausweichen")
	check(AppTouch.button_at(AppTouch.ACTION)=="interact","Aktion")
	check(AppTouch.button_at(Vector2(200,450))=="","Bewegungsfläche frei")
	for entry in AppTouch.MENU_BUTTONS:
		var r:Rect2=entry[2]
		check(AppTouch.button_at(r.get_center())==str(entry[0]),"Menüknopf "+str(entry[0]))
		check(r.end.x<=976.0,"Menüknopf neben der Minikarte")
	check(AppTouch.nearest_target(Vector2.ZERO,[{"pos":Vector2(300,0),"hp":5.0},{"pos":Vector2(100,0),"hp":0.0},{"pos":Vector2(0,200),"hp":3.0}])==Vector2(0,200),"Zielhilfe: nächster lebender Gegner")
	check(AppTouch.nearest_target(Vector2.ZERO,[{"pos":Vector2(900,0),"hp":5.0}])==Vector2.INF,"Zielhilfe: außer Reichweite")
	var guard:=AppTouch.new()
	guard.claim(Vector2(10,10),1000)
	check(guard.claimed(Vector2(12,10),1100),"gleicher Tap erkannt")
	check(not guard.claimed(Vector2(12,10),1000+AppTouch.TAP_WINDOW_MS+1),"später Tap ist neu")
	check(not guard.claimed(Vector2(80,10),1100),"anderer Ort ist neu")

	var g:=Game.new()
	root.add_child(g)
	for i in 4:await process_frame
	# Browser/PC: altes Layout, keine App-Regeln.
	g.app_mode=false;g.touch_enabled=true
	check(g.touch_button_at(Vector2(1032,526))=="attack","Browser-Touch unverändert")
	g.app_mode=true
	g.reset_touch_joystick();g.reset_touch_aim()
	check(g.touch_move_base==AppTouch.MOVE_REST,"App: Stick in Ruhelage")

	# Anmelden: Felder, verworfene Zeichen, Enter springt weiter.
	g.panel="account_login";g.account_name="";g.account_password="";g.account_focus=0
	check(g.app_text_target()=="account_0","Ziel Accountname")
	for c in "Abc d":key(g,KEY_NONE if c!=" " else KEY_SPACE,c.unicode_at(0),true)
	check(g.account_name=="Abcd","Name ohne Leerzeichen (%s)"%g.account_name)
	key(g,KEY_ENTER,0,true)
	check(g.account_focus==1 and g.panel=="account_login","Enter: weiter zum Passwort")
	check(g.app_text_target()=="account_1","Ziel Passwort")
	key(g,KEY_NONE,"x".unicode_at(0),true)
	check(g.account_password=="x","Passwort getippt")
	check(AppKeyboard.info("account_1")["password"],"Passwortfeld verdeckt")

	# Chat: öffnet mit Tastatur, Enter sendet und schließt.
	g.panel="";g.character_created=true;g.death_timer=0.0
	g.open_mobile_chat()
	check(g.chat_open and g.app_keyboard.target=="chat","Chat öffnet die Tastatur")
	for c in "Hi!":key(g,KEY_NONE,c.unicode_at(0))
	check(g.chat_input=="Hi!","Chat getippt")
	key(g,KEY_ENTER)
	check(not g.chat_open and g.sent==["Hi!"],"Enter sendet")
	g.app_keyboard_tick()
	check(g.app_keyboard.target=="","Tastatur zu nach dem Senden")

	# Ein Tap löst nur einmal aus, egal ob Touch oder Mausklick zuerst kommt.
	g.panel=""
	var bag:Rect2=AppTouch.MENU_BUTTONS[1][2]
	touch(g,bag.get_center());touch(g,bag.get_center(),false)
	check(g.panel=="inventory","TASCHE öffnet das Inventar")
	mouse(g,bag.get_center());mouse(g,bag.get_center(),false)
	check(g.panel=="inventory","nachgeschobener Klick schließt nicht wieder")
	await create_timer(0.4).timeout
	g.panel=""
	var menu_btn:Rect2=AppTouch.MENU_BUTTONS[2][2]
	mouse(g,menu_btn.get_center())
	check(g.panel=="","Spielfeld: Mausklick allein tut nichts")
	touch(g,menu_btn.get_center());touch(g,menu_btn.get_center(),false)
	check(g.panel=="app_menu","MENÜ öffnet das Menü")
	await create_timer(0.4).timeout
	var quests:=AppTouch.menu_tile_rect(2).get_center()
	mouse(g,quests);touch(g,quests);touch(g,quests,false);mouse(g,quests,false)
	check(g.panel=="journal","Menü: QUESTS öffnet das Questbuch (%s)"%g.panel)

	# Zurück-Taste schließt Chat.
	g.panel="";g.chat_open=true;g.chat_input="abc"
	g.app_go_back()
	check(not g.chat_open,"Zurück schließt den Chat")

	# Zielhilfe beim Angriff.
	g.panel="";g.enemies.clear()
	g.enemies.append({"pos":g.player_pos+Vector2(250,0),"hp":50.0,"max_hp":50.0,"type":0})
	g.facing=Vector2.DOWN
	g.begin_touch_aim(3,AppTouch.ATTACK)
	check(g.facing.distance_to(Vector2.RIGHT)<0.01,"Angriff zielt auf den Gegner")
	g.reset_touch_aim(3);g.enemies.clear()

	# AKTION am Wegstein öffnet die Weltkarte.
	g.player_pos=g.WAYSTONES[1]+Vector2(0,60)
	g.app_interact()
	check(g.waystone_used==1,"AKTION nutzt den Wegstein")

	if failures>0:
		push_error("APP_INPUT_FAILED %d"%failures);quit(1);return
	print("APP_INPUT_OK")
	quit()
