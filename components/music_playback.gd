extends RefCounted
# Musikübergänge und Loop-Wiedergabe; Thema und Lautstärkeregler liefert das Spiel.
const DEFAULT_FADE_SECONDS := 1.35
const GOLEM_FADE_SECONDS := 6.0
const GOLEM_PATH := "res://music/boss_golem.wav"

static func fade_seconds(theme: String) -> float:
	return GOLEM_FADE_SECONDS if theme == "boss_golem" else DEFAULT_FADE_SECONDS

static func update(g, delta: float = 0.0) -> void:
	if g.music_player == null or g.music_incoming == null: return
	if not g.music_enabled:
		g.music_player.stop()
		g.music_incoming.stop()
		g.music_fading = false
		g.music_theme = ""
		return
	var desired:String=g.desired_music_theme()
	if desired != g.music_theme:
		# Bei schnellem Hin- und Herreisen bleibt der gerade lautere Track erhalten.
		if g.music_fading:
			if g.music_fade_elapsed > g.music_fade_duration * 0.5:
				g.music_player.stop()
				var previous: AudioStreamPlayer = g.music_player
				g.music_player = g.music_incoming
				g.music_incoming = previous
			else:
				g.music_incoming.stop()
			g.music_fading = false
		var path:String=g.music_path_for_theme(desired)
		var stream: AudioStream = load(path)
		if stream == null: return
		if stream is AudioStreamOggVorbis: stream.loop = true
		if stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			stream.loop_begin = 0
			stream.loop_end = roundi(stream.get_length() * stream.mix_rate)
		g.music_theme = desired
		g.music_incoming.stop()
		g.music_incoming.stream = stream
		g.music_incoming.volume_db = -80.0
		g.music_incoming.play()
		g.music_fade_duration = fade_seconds(desired)
		g.music_fade_elapsed = 0.0
		g.music_fading = true
	var base_volume: float = -80.0 if g.music_volume <= 0.0 else ((-15.0 if g.panel == "pause" else -4.5) + linear_to_db(g.music_volume))
	if g.music_fading:
		g.music_fade_elapsed = minf(g.music_fade_duration, g.music_fade_elapsed + delta)
		var blend: float = g.music_fade_elapsed / g.music_fade_duration
		g.music_player.volume_db = base_volume + linear_to_db(maxf(0.001, cos(blend * PI * 0.5)))
		g.music_incoming.volume_db = base_volume + linear_to_db(maxf(0.001, sin(blend * PI * 0.5)))
		if blend >= 1.0:
			g.music_player.stop()
			var previous: AudioStreamPlayer = g.music_player
			g.music_player = g.music_incoming
			g.music_incoming = previous
			g.music_fading = false
	else:
		g.music_player.volume_db = move_toward(g.music_player.volume_db, base_volume, delta * 22.0)
