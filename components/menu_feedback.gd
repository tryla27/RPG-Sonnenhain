extends RefCounted
# Rückfrage vor dem Verlassen des Spiels und Klickklang für Menüknöpfe.
# Nicht hier: was beim Verlassen passiert (main.gd: leave_game) und die
# Klänge selbst (sound_bank.gd).

const BOX:=Rect2(326,236,500,196)
const CONFIRM_RECT:=Rect2(352,364,212,44)
const CANCEL_RECT:=Rect2(588,364,212,44)

## Offene Rückfrage: "" = keine, sonst das Menü, aus dem verlassen wird.
var exit_from:=""
## Knöpfe, die im zuletzt gezeichneten Bild sichtbar waren (für den Klickklang).
var drawn_buttons:Array=[]

func ask_exit(from_panel:String)->void:
	exit_from=from_panel

func asking()->bool:
	return exit_from!=""

## "confirm", "cancel" oder "" (Klick daneben, Rückfrage bleibt offen).
func click_exit(mouse:Vector2)->String:
	if CONFIRM_RECT.has_point(mouse):return "confirm"
	if CANCEL_RECT.has_point(mouse):
		exit_from=""
		return "cancel"
	return ""

func cancel_exit()->bool:
	if exit_from=="":return false
	exit_from=""
	return true

func draw_exit(g,web:bool)->void:
	g.draw_rect(Rect2(Vector2.ZERO,g.VIEW),Color(0.02,0.04,0.06,0.55))
	g.ui_box(BOX,Color("40514d"))
	g.text_at(BOX.position+Vector2(0,52),"Spiel wirklich verlassen?",24,Color("ffe2aa"),HORIZONTAL_ALIGNMENT_CENTER,int(BOX.size.x))
	g.text_at(BOX.position+Vector2(0,88),"Dein Fortschritt wird vorher gespeichert.",15,Color("d8e6dc"),HORIZONTAL_ALIGNMENT_CENTER,int(BOX.size.x))
	g.text_at(BOX.position+Vector2(0,112),"Du kehrst zur Startseite zurück." if web else "Du kehrst ins Hauptmenü zurück.",13,Color("aebfb9"),HORIZONTAL_ALIGNMENT_CENTER,int(BOX.size.x))
	g.ui_button(CONFIRM_RECT,"JA, VERLASSEN")
	g.ui_button(CANCEL_RECT,"ABBRECHEN")

## Zu Beginn jedes Bildes aufrufen; ui_button meldet seine Knöpfe mit note().
## Eingaben kommen zwischen zwei Bildern an und sehen so das letzte fertige Bild.
func begin_frame()->void:
	drawn_buttons=[]

func note(rect:Rect2,enabled:bool)->void:
	if enabled:drawn_buttons.append(rect)

## true, wenn der Klick einen sichtbaren, aktiven Menüknopf trifft.
func hits_button(mouse:Vector2)->bool:
	for rect in drawn_buttons:
		if (rect as Rect2).has_point(mouse):return true
	return false
