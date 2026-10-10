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
const AppLayout=preload("res://components/app_layout.gd")

## Standardwerte (Anordnung siehe AppLayout, eigene Werte aus dem Editor).
const ATTACK:=AppLayout.ATTACK
const SKILL_R:=28.0
const DODGE:=Vector2(940,594)
const ACTION:=Vector2(1114,404)
const MENU_BUTTONS:=[["chat","CHAT"],["inventory","TASCHE"],["app_menu","MENÜ"]]
## Bewegung: fester Stick (Angelo 10.10.2026: „links fixiert, nicht
## beweglich“). Greifen im Umkreis, die Basis wandert nie mit.
const MOVE_REST:=Vector2(150,500)
## Automatisches Zielen: Reichweite in Weltpixeln.
const AIM_RANGE:=520.0
## Zeitfenster, in dem derselbe Tap nicht noch einmal auslöst.
const TAP_WINDOW_MS:=350
const TAP_RADIUS:=8.0
## Fähigkeit ziehen (wie Wild Rift): ab DRAG_START Pixeln wird von Hand gezielt;
## Loslassen im Abbruchkreis (oder zurück am Knopf) bricht ab.
const DRAG_START:=18.0
const CANCEL_CENTER:=Vector2(1070,300)
const CANCEL_R:=46.0
const AIM_LENGTH:=260.0

const MENU_TILES:=[
	["inventory","INVENTAR","Ausrüstung, Tränke, Beute"],
	["skills","SPELLS","Skillbaum und Leiste"],
	["journal","QUESTS","Aufträge und Ziele"],
	["map","KARTE","Weltkarte"],
	["party","GRUPPE","Einladen, Gruppe verlassen"],
	["online","ONLINE","Wer gerade spielt"],
	["mechanics","HILFE","Mechaniken erklärt"],
	["pause","SPIELMENÜ","Einstellungen, Speichern"],
	["app_controls","STEUERUNG","Zielhilfe, Knöpfe anordnen"],
	["close","WEITERSPIELEN","Menü schließen"],
]

var _tap_pos:=Vector2(-9999,-9999)
var _tap_msec:=-100000
## Fähigkeit wird gerade gehalten/gezogen (Finger-ID, -1 = keine).
var skill_finger:=-1
var skill_slot:=0
var skill_vec:=Vector2.ZERO
var skill_pos:=Vector2.ZERO
var skill_drag:=false
var skill_cancel:=false

func cancel_skill()->void:
	skill_finger=-1
	skill_vec=Vector2.ZERO
	skill_drag=false
	skill_cancel=false

static func skill_center(slot:int)->Vector2:
	return AppLayout.center("ability_%d"%(clampi(slot,0,3)+1))

## Welcher Knopf liegt unter dem Finger? "" = keiner (dann evtl. Bewegung).
## Kleine Knöpfe zuerst, damit sich verschobene Knöpfe nicht überdecken.
static func button_at(pos:Vector2)->String:
	for slot in 4:
		var id:="ability_%d"%(slot+1)
		if pos.distance_to(AppLayout.center(id))<=AppLayout.radius(id)+5.0:return id
	for id in ["dodge","interact"]:
		if pos.distance_to(AppLayout.center(id))<=AppLayout.radius(id)+6.0:return id
	for id in ["heal","resource","chat","inventory","app_menu"]:
		if AppLayout.rect(id).grow(4).has_point(pos):return id
	if pos.distance_to(AppLayout.center("attack"))<=AppLayout.radius("attack")+6.0:return "attack"
	return ""

static func in_move_zone(pos:Vector2,blocked:Array)->bool:
	if pos.distance_to(AppLayout.center("move"))>AppLayout.radius("move"):return false
	for r in blocked:
		if (r as Rect2).has_point(pos):return false
	return true

static func menu_tile_rect(index:int)->Rect2:
	return Rect2(175+(index%4)*205,150+int(index/4.0)*125,195,105)

static func menu_action_at(pos:Vector2)->String:
	for i in MENU_TILES.size():
		if menu_tile_rect(i).has_point(pos):return str(MENU_TILES[i][0])
	return ""

## Bestes Ziel in Reichweite nach Wahl (nearest, lowest, strongest);
## Vector2.INF = keines. Bei Gleichstand gewinnt der Nähere.
static func nearest_target(from:Vector2,enemies:Array,reach:float=AIM_RANGE,mode:String="nearest")->Vector2:
	var best:=Vector2.INF
	var best_score:=INF
	for enemy in enemies:
		if not (enemy is Dictionary) or not enemy.has("pos"):continue
		var hp:=float(enemy.get("hp",1.0))
		if hp<=0.0:continue
		var p:Vector2=enemy["pos"]
		var d:=from.distance_squared_to(p)
		if d>reach*reach:continue
		var score:=d
		if mode=="lowest":score=hp+d*0.000001
		elif mode=="strongest":score=-float(enemy.get("max_hp",hp))+d*0.000001
		if score<best_score:
			best_score=score
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
			if t.index==g.app_touch.skill_finger:_release_skill(g)
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
			g.touch_move_base=AppLayout.center("move")
			g.touch_move_knob=g.touch_move_base
			g.touch_move_vector=Vector2.ZERO
			g.update_touch_joystick(pos)
			g.queue_redraw()
			return true
		return true
	if event is InputEventScreenDrag:
		g.last_touch_msec=now
		var d:InputEventScreenDrag=event as InputEventScreenDrag
		if d.index==g.app_touch.skill_finger:
			_drag_skill(g,d.position)
			g.queue_redraw()
			return true
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
				# Wild-Rift-Prinzip: Antippen = Auto-Ziel, Ziehen = von Hand
				# zielen, Loslassen wirkt, Abbruchkreis bricht ab.
				var st=g.app_touch
				st.skill_finger=index
				st.skill_slot=int(action.get_slice("_",1))-1
				st.skill_vec=Vector2.ZERO
				st.skill_pos=pos
				st.skill_drag=false
				st.skill_cancel=false

static func _drag_skill(g,pos:Vector2)->void:
	var st=g.app_touch
	var vec:Vector2=pos-AppLayout.center("ability_%d"%(st.skill_slot+1))
	st.skill_pos=pos
	if not st.skill_drag and vec.length()>=DRAG_START:st.skill_drag=true
	if not st.skill_drag:return
	if vec.length()>=DRAG_START:
		st.skill_vec=vec.normalized()
		g.facing=st.skill_vec
	# Abbrechen: im roten Kreis loslassen oder zurück zum Knopf ziehen.
	st.skill_cancel=pos.distance_to(CANCEL_CENTER)<=CANCEL_R or vec.length()<DRAG_START*0.6

static func _release_skill(g)->void:
	var st=g.app_touch
	var slot:int=st.skill_slot
	var cancelled:bool=st.skill_cancel
	var dragged:bool=st.skill_drag
	var vec:Vector2=st.skill_vec
	st.cancel_skill()
	if cancelled:
		g.message("Zauber abgebrochen.")
	elif dragged and vec!=Vector2.ZERO:
		g.facing=vec
		g.use_ability(slot)
	else:
		g.app_auto_aim(true)
		g.use_ability(slot)

## Steuerung zeichnen. state: Werte aus main.gd (siehe app_draw_touch_controls).
static func draw(g,state:Dictionary)->void:
	var font:Font=g.font
	var st=g.app_touch
	# Bewegung
	var base:Vector2=state["move_base"]
	var ms:=AppLayout.scale("move")
	var moving:bool=state["moving"]
	var a:=0.8 if moving else 0.32
	g.draw_circle(base,82*ms,Color(0.07,0.12,0.14,a*0.8))
	g.draw_arc(base,82*ms,0,TAU,40,Color("a9c4b8",a),3)
	g.draw_circle(state["move_knob"],34*ms,Color("5d756b",0.92 if moving else 0.55))
	g.draw_arc(state["move_knob"],34*ms,0,TAU,32,Color("e7d5a3",0.92 if moving else 0.55),3)
	if not moving:
		g.draw_string(font,base+Vector2(-50,(82*ms)+30),"BEWEGEN",HORIZONTAL_ALIGNMENT_CENTER,100,12,Color("d9e5dc",0.6))
	# Angriff mit Zielhilfe
	var aiming:bool=state["aiming"]
	var atk_r:=AppLayout.radius("attack")
	var atk_s:=AppLayout.scale("attack")
	var attack_base:Vector2=state["aim_base"] if aiming else AppLayout.center("attack")
	g.draw_circle(attack_base,atk_r,Color("725047",0.88 if aiming else 0.62))
	g.draw_arc(attack_base,atk_r,0,TAU,40,Color("f0daa3",0.9),3)
	g.draw_circle(state["aim_knob"] if aiming else attack_base,26.0*atk_s,Color("9a675b",0.92))
	g.draw_arc(state["aim_knob"] if aiming else attack_base,26.0*atk_s,0,TAU,28,Color("fff0c8",0.88),2)
	var aim_vec:Vector2=state["aim_vector"]
	if aiming and aim_vec.length_squared()>0.01:
		g.draw_line(attack_base,attack_base+aim_vec.normalized()*(atk_r+18.0),Color("ffe2a8",0.85),4)
	g.draw_string(font,attack_base+Vector2(-48,5),"AUTO-ZIEL" if bool(state["auto_aim"]) and aiming else "ANGRIFF",HORIZONTAL_ALIGNMENT_CENTER,96,11,Color("fff2cf"))
	# Fähigkeiten
	var skills:Array=state["skills"]
	for slot in 4:
		var key:="ability_%d"%(slot+1)
		var c:=AppLayout.center(key)
		var r:=AppLayout.radius(key)
		var sc:=AppLayout.scale(key)
		var info:Dictionary=skills[slot]
		var id:int=int(info["id"])
		var held:bool=st.skill_finger>=0 and st.skill_slot==slot
		g.draw_circle(c,r,Color("152228",0.9))
		g.draw_arc(c,r+(3.0 if held else 0.0),0,TAU,32,Color("fff0b8") if held else (Color("e0c27e",0.9) if id>=0 else Color("6f7c77",0.7)),3.5 if held else 2.5)
		if id>=0:
			g.draw_skill_icon(c-Vector2(15,15)*sc,id,30*sc)
			var cd:float=float(info["cooldown"])
			if cd>0.0:
				g.draw_circle(c,r-2.0,Color(0.06,0.1,0.13,0.7))
				g.draw_string(font,c+Vector2(-r,6),"%.1f"%cd if cd<10.0 else "%d"%ceili(cd),HORIZONTAL_ALIGNMENT_CENTER,r*2.0,14,Color("fff1c7"))
		else:
			g.draw_string(font,c+Vector2(-r,8),"–",HORIZONTAL_ALIGNMENT_CENTER,r*2.0,20,Color("83918b"))
		g.draw_circle(c+Vector2(r*0.72,r*0.72),9.0,Color("2b2219",0.95))
		g.draw_string(font,c+Vector2(r*0.72-9.0,r*0.72+4.0),str(slot+1),HORIZONTAL_ALIGNMENT_CENTER,18,10,Color("ffe3a5"))
	# Ausweichen und Aktion
	var dodge_ready:bool=state["dodge_ready"]
	var dc:=AppLayout.center("dodge")
	var dr:=AppLayout.radius("dodge")
	g.draw_circle(dc,dr,Color("3f5c62",0.92 if dodge_ready else 0.55))
	g.draw_arc(dc,dr,0,TAU,32,Color("f0daa3",0.85 if dodge_ready else 0.4),3)
	g.draw_string(font,dc+Vector2(-45,5),str(state["dodge_label"]),HORIZONTAL_ALIGNMENT_CENTER,90,11,Color("fff2cf"))
	var prompt:bool=state["action_hint"]
	var pulse:=0.5+0.5*sin(float(state["clock"])*5.0)
	var ac:=AppLayout.center("interact")
	var ar:=AppLayout.radius("interact")
	if prompt:g.draw_circle(ac,ar+6.0+pulse*3.0,Color("f3d98b",0.25+0.2*pulse))
	g.draw_circle(ac,ar,Color("556b4f",0.95 if prompt else 0.7))
	g.draw_arc(ac,ar,0,TAU,32,Color("fff0b8" if prompt else "c9b27b",0.9),3)
	g.draw_string(font,ac+Vector2(-45,5),"AKTION",HORIZONTAL_ALIGNMENT_CENTER,90,11,Color("fff2cf"))
	# Tränke
	for pair in [["heal","HP",Color("d77a6a")],["resource",str(state["resource_label"]),Color("6f9ee0")]]:
		var rc:Rect2=AppLayout.rect(str(pair[0]))
		g.draw_rect(rc,Color("223338",0.9))
		g.draw_rect(rc,(pair[2] as Color),false,2)
		g.draw_string(font,rc.position+Vector2(0,rc.size.y*0.65),str(pair[1]),HORIZONTAL_ALIGNMENT_CENTER,rc.size.x,11,Color("ffe7b0"))
	# Menüknöpfe
	for entry in MENU_BUTTONS:
		var rc:Rect2=AppLayout.rect(str(entry[0]))
		var badge:bool=str(entry[0])=="chat" and bool(state["chat_unread"])
		g.draw_rect(rc,Color("1c2d33",0.92))
		g.draw_rect(rc,Color("d9b56f" if badge else "b99b63",0.9),false,2)
		g.draw_string(font,rc.position+Vector2(0,rc.size.y*0.64),str(entry[1]),HORIZONTAL_ALIGNMENT_CENTER,rc.size.x,12,Color("fff0c8"))
		if badge:g.draw_circle(rc.position+Vector2(rc.size.x-6,6),5.0,Color("f0b35c"))
	if st.skill_finger>=0 and st.skill_drag:_draw_skill_aim(g,state)

## Zielpfeil vom Helden und Abbruchkreis, solange eine Fähigkeit gezogen wird.
static func _draw_skill_aim(g,state:Dictionary)->void:
	var st=g.app_touch
	var font:Font=g.font
	var cancel:bool=st.skill_cancel
	var tint:=Color("ff8a78") if cancel else Color("ffe08a")
	var origin:Vector2=state["player_ui"]
	var zoom:float=float(state["zoom"])
	var dir:Vector2=st.skill_vec
	if dir!=Vector2.ZERO:
		var tip:=origin+dir*AIM_LENGTH*zoom
		g.draw_line(origin,tip,Color(tint,0.35),14.0*zoom)
		g.draw_line(origin,tip,Color(tint,0.9),4.0)
		var side:=dir.orthogonal()
		g.draw_colored_polygon(PackedVector2Array([tip+dir*16.0,tip+side*11.0,tip-side*11.0]),Color(tint,0.95))
	# Verbindung Knopf → Finger
	var from:Vector2=AppLayout.center("ability_%d"%(st.skill_slot+1))
	g.draw_line(from,st.skill_pos,Color(tint,0.55),2.0)
	g.draw_circle(st.skill_pos,10.0,Color(tint,0.8))
	# Abbruchkreis
	g.draw_circle(CANCEL_CENTER,CANCEL_R,Color(0.55,0.14,0.1,0.7 if cancel else 0.38))
	g.draw_arc(CANCEL_CENTER,CANCEL_R,0,TAU,36,Color("ffb09f",0.95 if cancel else 0.6),3)
	g.draw_line(CANCEL_CENTER+Vector2(-14,-14),CANCEL_CENTER+Vector2(14,14),Color("ffe2d8",0.9),4)
	g.draw_line(CANCEL_CENTER+Vector2(-14,14),CANCEL_CENTER+Vector2(14,-14),Color("ffe2d8",0.9),4)
	g.draw_string(font,CANCEL_CENTER+Vector2(-60,CANCEL_R+18),"ABBRECHEN",HORIZONTAL_ALIGNMENT_CENTER,120,12,Color("ffd9cf"))

## Menü mit großen Kacheln (ersetzt die Tasten I, K, J, M, P, TAB, H, ESC).
static func draw_menu(g)->void:
	var font:Font=g.font
	g.draw_string(font,Vector2(190,132),"MENÜ",HORIZONTAL_ALIGNMENT_LEFT,-1,28,Color("ffe2aa"))
	for i in MENU_TILES.size():
		var r:=menu_tile_rect(i)
		g.ui_button(r,"")
		g.draw_string(font,r.position+Vector2(0,46),str(MENU_TILES[i][1]),HORIZONTAL_ALIGNMENT_CENTER,r.size.x,19,Color("fff0ce"))
		g.draw_string(font,r.position+Vector2(8,76),str(MENU_TILES[i][2]),HORIZONTAL_ALIGNMENT_CENTER,r.size.x-16,12,Color("c9d8d0"))
