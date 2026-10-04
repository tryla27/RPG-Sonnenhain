extends SceneTree
class Game:
	extends "res://main.gd"
	func _ready()->void:pass
	func _draw()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
var g
func key(code:int,pressed:bool=true,shift:bool=false,unicode:int=0,echo:bool=false)->void:
	var e:=InputEventKey.new();e.keycode=code;e.pressed=pressed;e.shift_pressed=shift;e.unicode=unicode;e.echo=echo
	root.push_input(e)
func _initialize()->void:call_deferred("run")
func run()->void:
	g=Game.new();g.bindings=g.DEFAULT_BINDINGS.duplicate();root.add_child(g)
	var competing:=Button.new();competing.focus_mode=Control.FOCUS_ALL;root.add_child(competing);competing.grab_focus()
	for form in ["account_login","account_register"]:
		g.panel=form;g.account_focus=0
		var count:=3 if form=="account_register" else 2
		for repeat in 4:
			for field in count:
				key(KEY_TAB);assert(g.account_focus==(field+1)%count);assert(not g.online_list_open)
			for field in count:
				key(KEY_SHIFT);key(KEY_TAB,true,true);key(KEY_SHIFT,false)
				assert(g.account_focus==posmod(-field-1,count))
			key(KEY_SHIFT);key(KEY_SHIFT,false);assert(g.account_focus==1)
			key(KEY_TAB,true,false,0,true);assert(g.account_focus==1)
			g.account_focus=0
		g.account_focus=1;g.account_password=""
		key(KEY_SHIFT);key(KEY_A,true,true,65);key(KEY_SHIFT,false)
		assert(g.account_focus==1 and g.account_password=="A")
		key(KEY_SHIFT);key(KEY_1,true,true,33);key(KEY_SHIFT,false)
		assert(g.account_focus==1 and g.account_password=="A!")
		key(KEY_BACKSPACE);assert(g.account_password=="A")
		var physical:=InputEventKey.new();physical.physical_keycode=KEY_TAB;physical.pressed=true
		root.push_input(physical);assert(g.account_focus==2 if count==3 else g.account_focus==0)
		for field in count:
			g.handle_panel_click(Vector2(310,(255 if count==3 else 275)+field*90+2))
			assert(g.account_focus==field)
		key(KEY_ESCAPE);assert(g.panel=="account_gate" and g.account_password=="")
	competing.release_focus();competing.focus_mode=Control.FOCUS_NONE
	g.panel="";key(KEY_TAB);assert(g.online_list_open)
	key(KEY_TAB,false);assert(not g.online_list_open)
	print("ACCOUNT_FOCUS_OK real viewport events with competing Control focus; login/register; four Tab/Shift+Tab cycles; Shift tap; uppercase and symbols; echo; physical keys; visible field click bounds")
	g.queue_free();competing.queue_free();quit()
