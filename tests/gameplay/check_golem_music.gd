extends SceneTree
# Verhalten: Beginn beim Spawn, langsame Einblendung, Hälften und Loop-Ende.
const Playback = preload("res://components/music_playback.gd")
const Golem = preload("res://components/golem_boss.gd")

class Game extends "res://main.gd":
	func _ready() -> void: pass
	func _process(_delta: float) -> void: pass
	func save_game() -> void: pass

var failures := 0
func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
		push_error("GOLEM_MUSIC_FAIL " + label)

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var g := Game.new()
	root.add_child(g)
	g.panel = ""
	g.character_created = true
	g.player_pos = Golem.ALTAR
	g.music_player = AudioStreamPlayer.new()
	g.music_incoming = AudioStreamPlayer.new()
	g.add_child(g.music_player)
	g.add_child(g.music_incoming)
	g.panel = "start"
	g.update_music(2.0)
	check(g.music_player.stream is AudioStreamOggVorbis and g.music_player.stream.loop, "OGG-Dorfmusik bleibt loopbar")
	g.panel = ""
	g.update_music(2.0)
	var normal_theme: String = g.music_theme
	check(normal_theme != "boss_golem", "vor Spawn Gebietsmusik")
	check(g.music_fade_duration == 1.35, "normale Themen behalten Einblendzeit")
	check(g.music_player.stream is AudioStreamWAV and g.music_player.stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Gebietsmusik bleibt loopbar")
	g.enemies = [{"type":Golem.TYPE_BIG, "hp":100.0, "pos":Golem.ALTAR, "golem":{"state":"rise"}}]
	check(g.desired_music_theme() == "boss_golem", "Spawn beginnt bereits im rise-Zustand")
	check(g.music_path_for_theme("boss_golem") == Playback.GOLEM_PATH, "bestätigte Datei")
	g.update_music(0.0)
	check(g.music_fading and g.music_fade_duration == 6.0, "sechs Sekunden Einblendung")
	var stream: AudioStreamWAV = g.music_incoming.stream
	check(stream != null and absf(stream.get_length() - 120.0) < 0.01, "120 Sekunden")
	check(stream.loop_mode == AudioStreamWAV.LOOP_FORWARD and stream.loop_begin == 0, "Loop aktiv")
	check(stream.loop_end == 5292000, "Loop umfasst vollständige Datei")
	var quiet: float = g.music_incoming.volume_db
	g.update_music(1.0)
	check(g.music_incoming.volume_db > quiet and g.music_fading, "Lautstärke steigt langsam")
	g.update_music(2.0)
	check(g.music_fading and absf(g.music_fade_elapsed - 3.0) < 0.01, "bei drei Sekunden noch Einblendung")
	g.update_music(3.0)
	check(not g.music_fading and g.music_player.stream == stream, "voller Pegel nach sechs Sekunden")
	g.enemies = [{"type":Golem.TYPE_HALF,"hp":50.0,"pos":Golem.ALTAR}]
	g.update_music(0.1)
	check(g.music_theme == "boss_golem" and not g.music_fading, "Hälften starten Musik nicht neu")
	g.enemies.clear()
	g.update_music(0.0)
	check(g.music_theme == normal_theme and g.music_fade_duration == Playback.DEFAULT_FADE_SECONDS, "nach Sieg normaler Übergang")
	g.enemies = [{"type":Golem.TYPE_BIG,"hp":100.0,"pos":Golem.ALTAR}]
	g.update_music(0.1)
	check(g.music_theme == "boss_golem" and g.music_fade_duration == 6.0, "erneuter Spawn während Übergang")
	g.music_enabled = false
	g.update_music(0.1)
	check(not g.music_player.playing and not g.music_incoming.playing and g.music_theme == "", "Musik aus respektiert")
	g.music_enabled = true
	g.music_volume = 0.0
	g.update_music(6.0)
	check(g.music_player.volume_db <= -80.0, "Lautstärke null respektiert")
	g.music_volume = 0.9
	g.player_pos = Vector2.ZERO
	check(g.desired_music_theme() != "boss_golem", "fern vom Kampf keine Golem-Musik")
	g.free()
	print("GOLEM_MUSIC_CHECK failures=", failures)
	quit(1 if failures else 0)
