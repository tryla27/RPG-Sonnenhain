extends Node
## Lokaler Einstieg mit echter KI und normalen Eingaben, ohne Live-Verbindung.
class Game extends "res://main.gd":
	func ensure_live_multiplayer()->void:pass
	func join_live_multiplayer()->void:pass
	func announce_multiplayer_context()->void:pass
	func save_game()->void:pass
	func slot_save_path(_index:int,_testing:bool=false)->String:return "user://entry-play-disposable.json"

func _ready()->void:call_deferred("run")
func run()->void:
	var g:=Game.new();add_child(g)
	var args:=OS.get_cmdline_user_args()
	g.pending_class=clampi(int(args[0]),0,2) if not args.is_empty() else 0
	g.pending_race=0;g.pending_gender=0;g.creation_name="Einstiegsprüfung"
	g.start_new_game()
	print("ENTRY_PLAY_READY class=",g.pending_class)
