extends RefCounted
# Vollbild: F11 oder Knopf im Einstellungsmenü. Im Browser nutzt Godot dafür die
# Vollbild-Funktion des Browsers (ohne Leisten); auf 16:9-Bildschirmen füllt das
# Spiel dann den ganzen Schirm ohne Ränder.
#
# Escape (Wunsch 10.10.2026): Escape schließt Spielfenster, beendet aber nicht das
# Vollbild. Im Browser hält das Spiel dafür Escape mit der Keyboard-Lock-Funktion
# fest (Chrome, Edge, Brave, Opera); ganz beenden geht mit F11 oder Escape
# gedrückt halten. Nach zweimal Escape im Vollbild erscheint der Hinweis „F11“.

const BUTTON_RECT:=Rect2(860,368,130,42)

static func is_fullscreen()->bool:
	var mode:=DisplayServer.window_get_mode()
	return mode==DisplayServer.WINDOW_MODE_FULLSCREEN or mode==DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

static func toggle()->void:
	var entering:=not is_fullscreen()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if entering else DisplayServer.WINDOW_MODE_WINDOWED)
	lock_escape(entering)

## Browser: Escape im Vollbild an das Spiel geben statt das Vollbild zu beenden.
static func lock_escape(active:bool)->void:
	if OS.get_name()!="Web" or not ClassDB.class_exists("JavaScriptBridge"):return
	var code:="if(navigator.keyboard&&navigator.keyboard.lock){navigator.keyboard.lock(['Escape']).catch(function(){})}" if active else "if(navigator.keyboard&&navigator.keyboard.unlock){navigator.keyboard.unlock()}"
	JavaScriptBridge.eval(code,true)

static func is_escape(event:InputEvent)->bool:
	if not event is InputEventKey or not event.pressed or event.echo:return false
	var key:int=event.keycode if event.keycode!=KEY_NONE else event.physical_keycode
	return key==KEY_ESCAPE

## Zählt Escape im Vollbild; beim zweiten Druck innerhalb von 4 s → Hinweis.
class EscapeCounter extends RefCounted:
	const WINDOW_MS:=4000
	var last_ms:=-100000
	func press(now_ms:int)->bool:
		var second:=now_ms-last_ms<=WINDOW_MS
		last_ms=-100000 if second else now_ms
		return second

static func is_toggle_key(event:InputEvent)->bool:
	if not event is InputEventKey or not event.pressed or event.echo:return false
	var key:int=event.keycode if event.keycode!=KEY_NONE else event.physical_keycode
	return key==KEY_F11
