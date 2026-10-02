extends SceneTree

class TestGame extends "res://main.gd":
	func _ready() -> void: pass
	func _process(_delta: float) -> void: pass
	func save_game() -> void: pass

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = TestGame.new()
	root.add_child(game)
	game.panel = ""
	game.player_pos = game.TAVERN_HOUSE
	var exterior: String = game.desired_music_theme()
	game.music_player = AudioStreamPlayer.new()
	game.music_incoming = AudioStreamPlayer.new()
	game.add_child(game.music_player)
	game.add_child(game.music_incoming)
	game.music_enabled = true
	game.enter_tavern()
	if game.desired_music_theme() != "taverne": quit(1); return
	game.update_music(0.1)
	var stream = game.music_incoming.stream as AudioStreamOggVorbis
	if stream == null or not stream.loop or stream.get_length() < 140.0: quit(2); return
	game.leave_tavern()
	if game.desired_music_theme() != exterior: quit(3); return
	game.update_music(0.1)
	if game.music_theme != exterior: quit(4); return
	game.music_enabled = false
	game.update_music(0.1)
	if game.music_player.playing or game.music_incoming.playing: quit(5); return
	print("TAVERN_MUSIC_OK: enter, instrumental OGG, loop, leave, interrupted fade, music off")
	game.music_player.stream = null
	game.music_incoming.stream = null
	stream = null
	game.sound_streams.clear()
	game.queue_free()
	await process_frame
	quit(0)

