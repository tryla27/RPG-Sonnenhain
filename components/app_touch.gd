extends RefCounted
## Touch-Steuerung der Android-App (Angelo 10.10.2026: „verbessere die mobile
## Steuerung“, App getrennt vom restlichen Sonnenhain).
##
## Gilt nur in der App (main.gd: app_mode); die Browser-Touchsteuerung bleibt
## unverändert. Rechts liegt alles in Daumenreichweite um den Angriffsknopf:
## Fähigkeiten im Bogen, Ausweichen darunter, Aktion darüber. Oben rechts
## öffnen CHAT, TASCHE und MENÜ, was am PC über Tasten läuft (Inventar,
## Skills, Quests, Karte, Gruppe, Hilfe, Spielmenü).
## Angriff und Fähigkeiten zielen ohne Ziehen automatisch auf den nächsten Gegner.
## Ein Antippen löst nur einmal aus, auch wenn Android zusätzlich einen
## Mausklick nachschiebt (TapGuard).

const HudLayout=preload("res://components/hud_layout.gd")

const ATTACK:=Vector2(1046,528)
const ATTACK_R:=60.0
const SKILL_ARC:=122.0
const SKILL_ANGLES:=[186.0,214.0,242.0,270.0]
const SKILL_R:=28.0
const DODGE:=Vector2(940,594)
const DODGE_R:=30.0
const ACTION:=Vector2(1114,404)
const ACTION_R:=29.0
const HEAL_RECT:=Rect2(746,598,62,40)
const RESOURCE_RECT:=Rect2(814,598,62,40)
const MENU_BUTTONS:=[["chat","CHAT",Rect2(764,14,64,42)],["inventory","TASCHE",Rect2(834,14,64,42)],["app_menu","MENÜ",Rect2(904,14,64,42)]]
## Bewegung: linke Bildhälfte unterhalb der Statusanzeigen.
const MOVE_ZONE:=Rect2(0,150,600,498)
const MOVE_REST:=Vector2(150,500)
## Automatisches Zielen: Reichweite in Weltpixeln.
const AIM_RANGE:=520.0
## Zeitfenster, in dem derselbe Tap nicht noch einmal auslöst.
const TAP_WINDOW_MS:=350
const TAP_RADIUS:=8.0

const MENU_TILES:=[
	["inventory","INVENTAR","Ausrüstung, Tränke, Beute"],
	["skills","SPELLS","Skillbaum und Leiste"],
	["journal","QUESTS","Aufträge und Ziele"],
	["map","KARTE","Weltkarte"],
	["party","GRUPPE","Einladen, Gruppe verlassen"],
	["online","ONLINE","Wer gerade spielt"],
	["mechanics","HILFE","Mechaniken erklärt"],
	["pause","SPIELMENÜ","Einstellungen, Speichern"],
	["close","WEITERSPIELEN","Menü schließen"],
]

var _tap_pos:=Vector2(-9999,-9999)
var _tap_msec:=-100000

static func skill_center(slot:int)->Vector2:
	var a:=deg_to_rad(float(SKILL_ANGLES[clampi(slot,0,3)]))
	return ATTACK+Vector2(cos(a),sin(a))*SKILL_ARC

## Welcher Knopf liegt unter dem Finger? "" = keiner (dann evtl. Bewegung).
static func button_at(pos:Vector2)->String:
	if pos.distance_to(ATTACK)<=ATTACK_R+6.0:return "attack"
	for slot in 4:
		if pos.distance_to(skill_center(slot))<=SKILL_R+5.0:return "ability_%d"%(slot+1)
	if pos.distance_to(DODGE)<=DODGE_R+6.0:return "dodge"
	if pos.distance_to(ACTION)<=ACTION_R+6.0:return "interact"
	if HEAL_RECT.grow(3).has_point(pos):return "heal"
	if RESOURCE_RECT.grow(3).has_point(pos):return "resource"
	for entry in MENU_BUTTONS:
		if (entry[2] as Rect2).grow(4).has_point(pos):return str(entry[0])
	return ""

static func in_move_zone(pos:Vector2,blocked:Array)->bool:
	if not MOVE_ZONE.has_point(pos):return false
	for r in blocked:
		if (r as Rect2).has_point(pos):return false
	return true

static func menu_tile_rect(index:int)->Rect2:
	return Rect2(190+(index%3)*270,150+int(index/3.0)*130,250,110)

static func menu_action_at(pos:Vector2)->String:
	for i in MENU_TILES.size():
		if menu_tile_rect(i).has_point(pos):return str(MENU_TILES[i][0])
	return ""

## Nächster lebender Gegner in Reichweite (Vector2.INF = keiner).
static func nearest_target(from:Vector2,enemies:Array,reach:float=AIM_RANGE)->Vector2:
	var best:=Vector2.INF
	var best_d:=reach*reach
	for enemy in enemies:
		if not (enemy is Dictionary) or not enemy.has("pos"):continue
		if float(enemy.get("hp",1.0))<=0.0:continue
		var p:Vector2=enemy["pos"]
		var d:=from.distance_squared_to(p)
		if d<best_d:
			best_d=d
			best=p
	return best

## Gleicher Tap (Position, kurz hintereinander) schon behandelt?
func claimed(pos:Vector2,now_msec:int)->bool:
	return now_msec-_tap_msec<=TAP_WINDOW_MS and pos.distance_to(_tap_pos)<=TAP_RADIUS

func claim(pos:Vector2,now_msec:int)->void:
	_tap_pos=pos
	_tap_msec=now_msec

## Android schiebt zu jedem Antippen einen Mausklick nach (oder vorher). Im
## Spielfeld läuft alles über Touch, deshalb wird der Klick dort verworfen. In
## Fenstern übernimmt der Klick das Antippen (dort funktionieren dann auch Ziehen
## und Regler); derselbe Tap löst aber nie zweimal aus.
static func skip_mouse(g,event:InputEvent)->bool:
	if not (event is InputEventMouseButton or event is InputEventMouseMotion):return false
	if event.device!=InputEvent.DEVICE_ID_EMULATION:return false
	if g.panel=="":return true
	if event is InputEventMouseButton and event.pressed:
		var now:=Time.get_ticks_msec()
		if g.app_touch.claimed(event.position,now):return true
		g.app_touch.claim(event.position,now)
	return false

## Touch-Ereignisse der App. true = verarbeitet.
static func handle(g,event:InputEvent)->bool:
	var now:=Time.get_ticks_msec()
	if event is InputEventScreenTouch:
		g.last_touch_msec=now
		var t:InputEventScreenTouch=event as InputEventScreenTouch
		var pos:=t.position
		if not t.pressed:
			g.touch_attack_ids.erase(t.index)
			if t.index==g.touch_move_id:g.reset_touch_joystick()
			if t.index==g.touch_aim_id:g.reset_touch_aim(t.index)
			g.queue_redraw()
			return true
		if g.app_touch.claimed(pos,now):return true
		if g.panel!="":
			# Erster Finger: der nachgeschobene Mausklick bedient das Fenster.
			# Weitere Finger bekommen keinen Mausklick, also hier direkt.
			if t.index!=0:
				g.app_touch.claim(pos,now)
				g.handle_panel_click(pos)
				g.queue_redraw()
			return true
		g.app_touch.claim(pos,now)
		if g.online_list_open:
			g.online_list_open=false
			g.queue_redraw()
			return true
		var action:=button_at(pos)
		if action!="":
			_press(g,action,t.index,pos)
			g.queue_redraw()
			return true
		if g.party_widget_rect().has_point(pos) and (int(g.party_state.get("invite_from",0))>0 or not (g.party_state.get("members",[]) as Array).is_empty()):
			g.panel="party"
			g.play_sound("ui_klick")
			g.queue_redraw()
			return true
		if HudLayout.MINIMAP_RECT.grow(6).has_point(pos):
			g.panel="map"
			g.menu_scroll=0
			g.play_sound("ui_klick")
			g.queue_redraw()
			return true
		if g.quest_hud_rect().has_point(pos):
			g.quest_guide.open(g,g.quest_guide.current_id(g),"")
			g.queue_redraw()
			return true
		if g.touch_move_id==-1 and in_move_zone(pos,[g.quest_hud_rect()]):
			g.touch_move_id=t.index
			g.touch_move_base=Vector2(clampf(pos.x,90.0,480.0),clampf(pos.y,240.0,560.0))
			g.touch_move_knob=g.touch_move_base
			g.touch_move_vector=Vector2.ZERO
			g.update_touch_joystick(pos)
			g.queue_redraw()
			return true
		return true
	if event is InputEventScreenDrag:
		g.last_touch_msec=now
		var d:InputEventScreenDrag=event as InputEventScreenDrag
		if d.index==g.touch_move_id:
			g.update_touch_joystick(d.position)
			g.queue_redraw()
			return true
		if d.index==g.touch_aim_id:
			g.update_touch_aim(d.position)
			g.queue_redraw()
			return true
	return false

static func _press(g,action:String,index:int,pos:Vector2)->void:
	if action=="attack":
		g.begin_touch_aim(index,pos)
		if g.detonate_mage_autoattack():return
		if g.attack_timer<=0.0:g.normal_attack()
		return
	g.touch_attack_ids[index]=action
	match action:
		"dodge":
			if g.dash_cooldown<=0.0:g.dodge()
		"interact":g.app_interact()
		"chat":g.open_mobile_chat()
		"inventory":g.toggle_panel("inventory")
		"app_menu":
			g.panel="app_menu"
			g.play_sound("ui_klick")
		"heal":g.quick_potion(false)
		"resource":g.quick_potion(true)
		_:
			if action.begins_with("ability_"):
				# Ohne gezogenes Ziel: auf den nächsten Gegner richten.
				if not g.touch_aim_manual or g.touch_aim_id<0:g.app_auto_aim(true)
				g.use_ability(int(action.get_slice("_",1))-1)

## Steuerung zeichnen. state: Werte aus main.gd (siehe draw_touch_controls).
static func draw(g,state:Dictionary)->void:
	var font:Font=g.font
	# Bewegung
	var base:Vector2=state["move_base"]
	var moving:bool=state["moving"]
	var a:=0.8 if moving else 0.32
	g.draw_circle(base,82,Color(0.07,0.12,0.14,a*0.8))
	g.draw_arc(base,82,0,TAU,40,Color("a9c4b8",a),3)
	g.draw_circle(state["move_knob"],34,Color("5d756b",0.92 if moving else 0.55))
	g.draw_arc(state["move_knob"],34,0,TAU,32,Color("e7d5a3",0.92 if moving else 0.55),3)
	if not moving:
		g.draw_string(font,base+Vector2(-50,112),"BEWEGEN",HORIZONTAL_ALIGNMENT_CENTER,100,12,Color("d9e5dc",0.6))
	# Angriff mit Zielhilfe
	var aiming:bool=state["aiming"]
	var attack_base:Vector2=state["aim_base"] if aiming else ATTACK
	g.draw_circle(attack_base,ATTACK_R,Color("725047",0.88 if aiming else 0.62))
	g.draw_arc(attack_base,ATTACK_R,0,TAU,40,Color("f0daa3",0.9),3)
	g.draw_circle(state["aim_knob"] if aiming else attack_base,26.0,Color("9a675b",0.92))
	g.draw_arc(state["aim_knob"] if aiming else attack_base,26.0,0,TAU,28,Color("fff0c8",0.88),2)
	var aim_vec:Vector2=state["aim_vector"]
	if aiming and aim_vec.length_squared()>0.01:
		g.draw_line(attack_base,attack_base+aim_vec.normalized()*(ATTACK_R+18.0),Color("ffe2a8",0.85),4)
	g.draw_string(font,attack_base+Vector2(-48,5),"AUTO-ZIEL" if bool(state["auto_aim"]) and aiming else "ANGRIFF",HORIZONTAL_ALIGNMENT_CENTER,96,11,Color("fff2cf"))
	# Fähigkeiten im Bogen
	var skills:Array=state["skills"]
	for slot in 4:
		var c:=skill_center(slot)
		var info:Dictionary=skills[slot]
		var id:int=int(info["id"])
		g.draw_circle(c,SKILL_R,Color("152228",0.9))
		g.draw_arc(c,SKILL_R,0,TAU,32,Color("e0c27e",0.9) if id>=0 else Color("6f7c77",0.7),2.5)
		if id>=0:
			g.draw_skill_icon(c-Vector2(15,15),id,30)
			var cd:float=float(info["cooldown"])
			if cd>0.0:
				g.draw_circle(c,SKILL_R-2.0,Color(0.06,0.1,0.13,0.7))
				g.draw_string(font,c+Vector2(-SKILL_R,6),"%.1f"%cd if cd<10.0 else "%d"%ceili(cd),HORIZONTAL_ALIGNMENT_CENTER,SKILL_R*2.0,14,Color("fff1c7"))
		else:
			g.draw_string(font,c+Vector2(-SKILL_R,8),"–",HORIZONTAL_ALIGNMENT_CENTER,SKILL_R*2.0,20,Color("83918b"))
		g.draw_circle(c+Vector2(SKILL_R*0.72,SKILL_R*0.72),9.0,Color("2b2219",0.95))
		g.draw_string(font,c+Vector2(SKILL_R*0.72-9.0,SKILL_R*0.72+4.0),str(slot+1),HORIZONTAL_ALIGNMENT_CENTER,18,10,Color("ffe3a5"))
	# Ausweichen und Aktion
	var dodge_ready:bool=state["dodge_ready"]
	g.draw_circle(DODGE,DODGE_R,Color("3f5c62",0.92 if dodge_ready else 0.55))
	g.draw_arc(DODGE,DODGE_R,0,TAU,32,Color("f0daa3",0.85 if dodge_ready else 0.4),3)
	g.draw_string(font,DODGE+Vector2(-45,5),str(state["dodge_label"]),HORIZONTAL_ALIGNMENT_CENTER,90,11,Color("fff2cf"))
	var prompt:bool=state["action_hint"]
	var pulse:=0.5+0.5*sin(float(state["clock"])*5.0)
	if prompt:g.draw_circle(ACTION,ACTION_R+6.0+pulse*3.0,Color("f3d98b",0.25+0.2*pulse))
	g.draw_circle(ACTION,ACTION_R,Color("556b4f",0.95 if prompt else 0.7))
	g.draw_arc(ACTION,ACTION_R,0,TAU,32,Color("fff0b8" if prompt else "c9b27b",0.9),3)
	g.draw_string(font,ACTION+Vector2(-45,5),"AKTION",HORIZONTAL_ALIGNMENT_CENTER,90,11,Color("fff2cf"))
	# Tränke
	for pair in [[HEAL_RECT,"HP",Color("d77a6a")],[RESOURCE_RECT,str(state["resource_label"]),Color("6f9ee0")]]:
		var r:Rect2=pair[0]
		g.draw_rect(r,Color("223338",0.9))
		g.draw_rect(r,(pair[2] as Color),false,2)
		g.draw_string(font,r.position+Vector2(0,26),str(pair[1]),HORIZONTAL_ALIGNMENT_CENTER,r.size.x,11,Color("ffe7b0"))
	# Menüknöpfe oben rechts
	for entry in MENU_BUTTONS:
		var r:Rect2=entry[2]
		var badge:bool=str(entry[0])=="chat" and bool(state["chat_unread"])
		g.draw_rect(r,Color("1c2d33",0.92))
		g.draw_rect(r,Color("d9b56f" if badge else "b99b63",0.9),false,2)
		g.draw_string(font,r.position+Vector2(0,27),str(entry[1]),HORIZONTAL_ALIGNMENT_CENTER,r.size.x,12,Color("fff0c8"))
		if badge:g.draw_circle(r.position+Vector2(r.size.x-6,6),5.0,Color("f0b35c"))

## Menü mit großen Kacheln (ersetzt die Tasten I, K, J, M, P, TAB, H, ESC).
static func draw_menu(g)->void:
	var font:Font=g.font
	g.draw_string(font,Vector2(190,132),"MENÜ",HORIZONTAL_ALIGNMENT_LEFT,-1,28,Color("ffe2aa"))
	for i in MENU_TILES.size():
		var r:=menu_tile_rect(i)
		g.ui_button(r,"")
		g.draw_string(font,r.position+Vector2(0,48),str(MENU_TILES[i][1]),HORIZONTAL_ALIGNMENT_CENTER,r.size.x,22,Color("fff0ce"))
		g.draw_string(font,r.position+Vector2(0,78),str(MENU_TILES[i][2]),HORIZONTAL_ALIGNMENT_CENTER,r.size.x,13,Color("c9d8d0"))
