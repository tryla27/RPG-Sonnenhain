extends RefCounted
# Tippgeräusch für alle Texteingaben (Konto, Koop-Code, Charaktername, Chat).
# Hier liegt nur die Regel, welcher Laut wann spielt; die Klänge selbst stehen
# in sound_bank.gd (ui_tippen, ui_tippen_loeschen).

## Höchstens 25 Anschläge pro Sekunde, damit schnelles Tippen nicht knattert.
const MIN_GAP_MS:=40

## Laut für eine Textänderung von `before` auf `after` Zeichen ("" = keiner).
static func sound_for(before:int,after:int)->String:
	if after>before:return "ui_tippen"
	if after<before:return "ui_tippen_loeschen"
	return ""

static func allowed(last_ms:int,now_ms:int)->bool:
	return last_ms<0 or now_ms-last_ms>=MIN_GAP_MS
