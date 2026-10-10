extends RefCounted
## Bildschirmtastatur der Android-App (Angelo 10.10.2026: „Tastatur für alle
## Schreibflächen, ab dem Anmelden und im Ingame-Chat“).
##
## Gilt nur in der App (main.gd: app_mode). Browser und PC schreiben weiter wie
## bisher. Ein Schreibfeld heißt hier „Ziel“: account_0/1/2 (Name, Passwort,
## Passwort wiederholen), chat, creation (Heldenname). Die Tasten der
## Android-Tastatur kommen als gewöhnliche Tastenereignisse an und laufen durch
## dieselben Eingabefunktionen wie am PC.
##
## Weil die Tastatur die untere Bildhälfte verdeckt, zeigt eine Eingabeleiste
## oben, was gerade im Feld steht.

const TARGETS:={
	"account_0":{"label":"ACCOUNTNAME","max":24,"password":false},
	"account_1":{"label":"PASSWORT","max":72,"password":true},
	"account_2":{"label":"PASSWORT WIEDERHOLEN","max":72,"password":true},
	"chat":{"label":"NACHRICHT AN DIE GRUPPE","max":120,"password":false},
	"creation":{"label":"NAME DEINES HELDEN","max":16,"password":false},
}
const BAR:=Rect2(156,14,840,74)

## Feld, für das die Tastatur gerade offen ist ("" = keins).
var target:=""
## Für Vorschaubilder: Tastatur gilt als sichtbar, ohne Gerät.
var preview:=false
var _seen_open:=false
var _dismissed:=false
var _last_text:=""

static func supported()->bool:
	return DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD)

static func info(which:String)->Dictionary:
	return TARGETS.get(which,{"label":"","max":-1,"password":false})

## Öffnet die Tastatur für ein Feld; der vorhandene Text wird übernommen, damit
## Löschen und Weiterschreiben am Feldende ansetzen.
func open(which:String,text:String)->void:
	if which=="":
		close()
		return
	target=which
	_last_text=text
	_seen_open=false
	_dismissed=false
	if not supported():return
	var spec:=info(which)
	var kind:=DisplayServer.KEYBOARD_TYPE_PASSWORD if bool(spec["password"]) else DisplayServer.KEYBOARD_TYPE_DEFAULT
	DisplayServer.virtual_keyboard_show(text,Rect2(),kind,int(spec["max"]))

func close()->void:
	if target=="" and not preview:return
	target=""
	preview=false
	_seen_open=false
	if supported():DisplayServer.virtual_keyboard_hide()

## Höhe der Tastatur in Bildschirmpixeln (0 = zu).
static func height()->int:
	return DisplayServer.virtual_keyboard_get_height() if supported() else 0

func visible()->bool:
	return target!="" and (preview or _seen_open)

## Einmal pro Bild aufrufen. active = Feld, das laut Spielzustand gerade
## beschrieben wird. Wechselt das Feld (Enter springt weiter, Panel zu), folgt
## die Tastatur; schließt der Spieler sie selbst, meldet dismissed() das einmal.
func sync(active:String,text:String)->void:
	if target=="":return
	if active!=target:
		if active=="":close()
		else:open(active,text)
		return
	if preview:return
	var h:=height()
	if h>0:
		_seen_open=true
	elif _seen_open:
		_seen_open=false
		_dismissed=true

func dismissed()->bool:
	var was:=_dismissed
	_dismissed=false
	return was

## Nach jeder Taste: Was müsste jetzt in der Tastatur stehen? Hat das Spiel ein
## Zeichen verworfen (z. B. Leerzeichen im Accountnamen), wird der Tastaturtext
## neu gesetzt, damit Löschen danach wieder das richtige Zeichen trifft.
func typed(event:InputEventKey,text:String)->void:
	if target=="" or not event.pressed:return
	var expected:=_last_text
	if event.keycode==KEY_BACKSPACE:expected=expected.left(maxi(0,expected.length()-1))
	elif event.unicode>=32:expected+=String.chr(event.unicode)
	_last_text=text
	if expected!=text and event.keycode not in [KEY_ENTER,KEY_KP_ENTER,KEY_ESCAPE,KEY_TAB]:
		open(target,text)

## Eingabeleiste oben am Bildschirm.
static func draw_bar(c:CanvasItem,font:Font,which:String,text:String,clock:float)->void:
	var spec:=info(which)
	c.draw_rect(Rect2(0,0,1152,BAR.end.y+12),Color(0.02,0.05,0.08,0.55))
	c.draw_rect(BAR,Color("16262d"))
	c.draw_rect(BAR,Color("d9b56f"),false,2)
	c.draw_string(font,BAR.position+Vector2(18,24),str(spec["label"]),HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("e9cc90"))
	var shown:=text
	if bool(spec["password"]):shown="•".repeat(text.length())
	var limit:=int(spec["max"])
	var count:="%d / %d" % [text.length(),limit] if limit>0 else ""
	c.draw_string(font,BAR.position+Vector2(18,24),count,HORIZONTAL_ALIGNMENT_RIGHT,BAR.size.x-36.0,12,Color("9fb4ac"))
	# Lange Nachrichten: das Ende bleibt sichtbar.
	var width:=BAR.size.x-36.0
	while shown.length()>1 and font.get_string_size(shown,HORIZONTAL_ALIGNMENT_LEFT,-1,21).x>width-14.0:
		shown=shown.substr(1)
	var cursor:="_" if int(clock*2.0)%2==0 else ""
	if text=="":
		c.draw_string(font,BAR.position+Vector2(36,56),"Tippen …",HORIZONTAL_ALIGNMENT_LEFT,-1,21,Color("7f938d"))
	c.draw_string(font,BAR.position+Vector2(18,56),shown+cursor,HORIZONTAL_ALIGNMENT_LEFT,-1,21,Color("fff0cf"))
