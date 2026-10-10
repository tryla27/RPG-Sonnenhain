extends RefCounted
## Fenster „STEUERUNG“ der Android-App: Zielhilfe wählen und Knöpfe anordnen
## (Angelo 11.10.2026, Vorbild Wild Rift: Knöpfe verschieben, vergrößern,
## Zielpriorität). Nur App; Daten und Speicherung in app_layout.gd.

const AppLayout=preload("res://components/app_layout.gd")

const MINUS:=Rect2(250,10,56,44)
const PLUS:=Rect2(458,10,56,44)
const RESET:=Rect2(526,10,130,44)
const DONE:=Rect2(664,10,90,44)
const PRIORITY_RECTS:=[Rect2(190,205,255,54),Rect2(461,205,255,54),Rect2(732,205,255,54)]
const ARRANGE:=Rect2(190,420,390,54)
const RESTORE:=Rect2(598,420,390,54)
const BACK:=Rect2(190,520,260,46)

## Im Editor gewählter Knopf ("" = keiner) und Griffabstand beim Ziehen.
var selected:=""
var grabbing:=false
var grab_offset:=Vector2.ZERO

# --- Einstellungsfenster ---------------------------------------------------

static func draw_settings(g)->void:
	var font:Font=g.font
	g.draw_string(font,Vector2(190,132),"STEUERUNG",HORIZONTAL_ALIGNMENT_LEFT,-1,28,Color("ffe2aa"))
	g.draw_string(font,Vector2(190,186),"ZIELHILFE: Wen Angriff und Fähigkeiten beim Antippen anvisieren",HORIZONTAL_ALIGNMENT_LEFT,798,14,Color("e9cc90"))
	for i in AppLayout.PRIORITIES.size():
		var key:String=AppLayout.PRIORITIES[i]
		g.ui_button(PRIORITY_RECTS[i],str(AppLayout.PRIORITY_NAMES[key]),true,AppLayout.priority==key)
	g.draw_string(font,Vector2(190,288),str(AppLayout.PRIORITY_TEXT[AppLayout.priority]),HORIZONTAL_ALIGNMENT_LEFT,798,13,Color("c9d8d0"))
	g.draw_string(font,Vector2(190,336),"FÄHIGKEITEN ZIELEN",HORIZONTAL_ALIGNMENT_LEFT,798,14,Color("e9cc90"))
	g.draw_string(font,Vector2(190,358),"Antippen: zielt automatisch. Halten und ziehen: von Hand zielen, der Pfeil zeigt die Richtung.",HORIZONTAL_ALIGNMENT_LEFT,798,13,Color("c9d8d0"))
	g.draw_string(font,Vector2(190,380),"Abbrechen: im roten Kreis oben rechts oder zurück zum Knopf loslassen.",HORIZONTAL_ALIGNMENT_LEFT,798,13,Color("c9d8d0"))
	g.ui_button(ARRANGE,"KNÖPFE ANORDNEN")
	g.ui_button(RESTORE,"STANDARD-ANORDNUNG",not AppLayout.is_default())
	g.ui_button(BACK,"ZURÜCK ZUM MENÜ")

static func click_settings(g,mouse:Vector2)->void:
	for i in AppLayout.PRIORITIES.size():
		if (PRIORITY_RECTS[i] as Rect2).has_point(mouse):
			AppLayout.set_priority(AppLayout.PRIORITIES[i])
			AppLayout.save_settings()
			g.play_sound("ui_klick")
			g.queue_redraw()
			return
	if ARRANGE.has_point(mouse):
		g.app_editor.selected=""
		g.app_editor.grabbing=false
		g.panel="app_layout"
	elif RESTORE.has_point(mouse) and not AppLayout.is_default():
		AppLayout.reset()
		AppLayout.save_settings()
		g.app_apply_layout()
	elif BACK.has_point(mouse):
		g.panel="app_menu"
	g.queue_redraw()

# --- Editor ------------------------------------------------------------------

## Knopf unter dem Punkt; bei Überlappung der kleinste.
static func element_at(pos:Vector2)->String:
	var best:=""
	var best_area:=INF
	for id in AppLayout.IDS:
		var b:Rect2=AppLayout.bounds(str(id))
		if not b.grow(4).has_point(pos):continue
		var area:=b.size.x*b.size.y
		if area<best_area:
			best_area=area
			best=str(id)
	return best

static func draw_editor(g)->void:
	var font:Font=g.font
	var ed=g.app_editor
	for id in AppLayout.IDS:
		var b:Rect2=AppLayout.bounds(str(id))
		var chosen:bool=str(id)==ed.selected
		g.draw_rect(b.grow(3),Color("ffe08a",0.95) if chosen else Color(1,1,1,0.4),false,3.0 if chosen else 1.5)
		if chosen:
			g.draw_rect(b.grow(3),Color("ffe08a",0.12))
	# Werkzeugleiste
	g.draw_rect(Rect2(240,4,524,56),Color(0.04,0.08,0.11,0.9))
	g.ui_button(MINUS,"−",ed.selected!="")
	g.ui_button(PLUS,"+",ed.selected!="")
	var label:="Knopf antippen"
	if ed.selected!="":label="%s · %d %%"%[str(AppLayout.LABELS[ed.selected]),roundi(AppLayout.scale(ed.selected)*100.0)]
	g.draw_string(font,Vector2(308,38),label,HORIZONTAL_ALIGNMENT_CENTER,148,12,Color("fff0ce"))
	g.ui_button(RESET,"STANDARD",not AppLayout.is_default())
	g.ui_button(DONE,"FERTIG")
	g.draw_string(font,Vector2(240,78),"Knopf antippen und ziehen = verschieben · − / + = Größe",HORIZONTAL_ALIGNMENT_LEFT,524,12,Color("fff0ce",0.9))

## Maus-/Touch-Ereignisse im Editor. true = verarbeitet.
static func input(g,event:InputEvent)->bool:
	var ed=g.app_editor
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		var pos:Vector2=event.position
		if event.pressed:
			if _toolbar(g,pos):return true
			var hit:=element_at(pos)
			ed.selected=hit
			ed.grabbing=hit!=""
			if hit!="":ed.grab_offset=AppLayout.center(hit)-pos
			g.queue_redraw()
		else:
			if ed.grabbing:AppLayout.save_settings()
			ed.grabbing=false
		return true
	if event is InputEventMouseMotion:
		if ed.grabbing and ed.selected!="":
			AppLayout.set_center(ed.selected,event.position+ed.grab_offset)
			g.app_apply_layout()
			g.queue_redraw()
		return true
	return false

static func _toolbar(g,pos:Vector2)->bool:
	var ed=g.app_editor
	if MINUS.has_point(pos) or PLUS.has_point(pos):
		if ed.selected!="":
			AppLayout.set_scale(ed.selected,AppLayout.scale(ed.selected)+(AppLayout.SCALE_STEP if PLUS.has_point(pos) else -AppLayout.SCALE_STEP))
			AppLayout.save_settings()
			g.app_apply_layout()
			g.play_sound("ui_klick")
			g.queue_redraw()
		return true
	if RESET.has_point(pos):
		AppLayout.reset()
		AppLayout.save_settings()
		ed.selected=""
		g.app_apply_layout()
		g.play_sound("ui_klick")
		g.queue_redraw()
		return true
	if DONE.has_point(pos):
		AppLayout.save_settings()
		ed.grabbing=false
		g.panel="app_controls"
		g.play_sound("ui_klick")
		g.queue_redraw()
		return true
	return false
