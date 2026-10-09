extends RefCounted
# Vollbild: F11 oder Knopf im Einstellungsmenü. Im Browser nutzt Godot dafür die
# Vollbild-Funktion des Browsers (ohne Leisten); auf 16:9-Bildschirmen füllt das
# Spiel dann den ganzen Schirm ohne Ränder. Escape beendet das Vollbild im Browser.

const BUTTON_RECT:=Rect2(860,368,130,42)

static func is_fullscreen()->bool:
	var mode:=DisplayServer.window_get_mode()
	return mode==DisplayServer.WINDOW_MODE_FULLSCREEN or mode==DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN

static func toggle()->void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if is_fullscreen() else DisplayServer.WINDOW_MODE_FULLSCREEN)

static func is_toggle_key(event:InputEvent)->bool:
	if not event is InputEventKey or not event.pressed or event.echo:return false
	var key:int=event.keycode if event.keycode!=KEY_NONE else event.physical_keycode
	return key==KEY_F11
