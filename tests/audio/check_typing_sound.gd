extends SceneTree
# Tippgeräusch: Jeder angenommene Buchstabe klickt, Löschen klingt tiefer,
# abgelehnte Zeichen bleiben still, und schnelles Tippen wird gedrosselt.

const TypingSound=preload("res://components/typing_sound.gd")
const SoundBank=preload("res://components/sound_bank.gd")

class Game extends "res://main.gd":
	var played:Array=[]
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func play_sound(name:String)->void:played.append(name)

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("TYPING_SOUND_FAIL "+label)

func _initialize()->void:call_deferred("run")

func key(code:int,unicode:int=0)->InputEventKey:
	var e:=InputEventKey.new()
	e.keycode=code
	e.unicode=unicode
	e.pressed=true
	return e

func typed(g:Game,ch:String)->void:
	g.last_typing_ms=-1
	g._unhandled_input(key(KEY_A,ch.unicode_at(0)))

func run()->void:
	check(TypingSound.sound_for(2,3)=="ui_tippen","Zeichen dazu klickt")
	check(TypingSound.sound_for(3,2)=="ui_tippen_loeschen","Löschen klingt anders")
	check(TypingSound.sound_for(3,3)=="","ohne Änderung still")
	check(TypingSound.allowed(-1,0) and not TypingSound.allowed(1000,1020) and TypingSound.allowed(1000,1040),"höchstens 25 pro Sekunde")
	for s in ["ui_tippen","ui_tippen_loeschen"]:
		check(SoundBank.CATALOG.has(s) and SoundBank.is_ui(s),"%s im Katalog auf dem Oberflächen-Bus" % s)
		var path:String="res://audio/sfx/%s_01.wav" % String(SoundBank.CATALOG[s]["path"])
		check(ResourceLoader.exists(path),"Datei da: "+path)

	var g:=Game.new()
	# Charaktername
	g.panel="creation"
	typed(g,"B")
	check(g.creation_name=="B" and g.played==["ui_tippen"],"Name: Buchstabe klickt (%s)" % [g.played])
	g.played.clear();typed(g,"!")
	check(g.played.is_empty(),"Name: abgelehntes Zeichen bleibt still")
	g.last_typing_ms=-1;g._unhandled_input(key(KEY_BACKSPACE))
	check(g.creation_name=="" and g.played==["ui_tippen_loeschen"],"Name: Löschen")
	# Koop-Code
	g.played.clear();g.panel="multiplayer"
	typed(g,"x")
	check(g.join_code=="X" and g.played==["ui_tippen"],"Koop-Code klickt")
	# Chat
	g.played.clear();g.panel="";g.chat_open=true;g.chat_input=""
	typed(g,"h")
	check(g.chat_input=="h" and g.played==["ui_tippen"],"Chat klickt")
	g.played.clear();g._unhandled_input(key(KEY_ESCAPE))
	check(g.played.is_empty(),"Chat schließen ohne Löschgeräusch")
	g.chat_open=false
	# Konto-Formular
	g.played.clear();g.panel="account_login";g.account_focus=0
	g.last_typing_ms=-1;g.handle_account_key(key(KEY_A,"a".unicode_at(0)))
	check(g.account_name=="a" and g.played==["ui_tippen"],"Konto klickt (%s)" % [g.played])
	g.played.clear();g.handle_account_key(key(KEY_ESCAPE))
	check(g.played.is_empty(),"Konto verlassen ohne Löschgeräusch")
	# Drosselung: zwei Anschläge im selben Moment geben nur einen Laut.
	g.played.clear();g.panel="creation";g.creation_name=""
	g.last_typing_ms=-1
	g._unhandled_input(key(KEY_A,"a".unicode_at(0)))
	g._unhandled_input(key(KEY_A,"b".unicode_at(0)))
	check(g.creation_name=="ab" and g.played.size()==1,"Drosselung: beide Zeichen, ein Laut")
	g.free()
	if failures>0:
		print("TYPING_SOUND_FAILED ",failures)
		quit(1)
		return
	print("TYPING_SOUND_OK typing clicks, delete is deeper, rejected keys stay silent, throttled")
	quit()
