extends RefCounted
## Sonnenhain-Soundbank: Katalog, Audio-Busse, Stimmenverwaltung mit Vorrang,
## Varianten ohne direkte Wiederholung, Entfernungsdämpfung, Musik-Ducking und
## die Ableitung von Monsterlauten aus dem Angriffszustand der Gegner.
##
## Die Dateien erzeugt tools/build_sfx.py; Konzept in docs/sound/KONZEPT.md.
## main.gd ruft weiterhin play_sound("name") auf; Namen aus CATALOG laufen
## hierüber, alle anderen über die bisherige Wiedergabe.

const BUS_MUSIC := "Musik"
const BUS_SFX := "Effekte"
const BUS_UI := "Oberfläche"
const BUS_AMBIENCE := "Umgebung"

## Volle Lautstärke bis NEAR, unhörbar ab HEARING (Weltpixel).
const NEAR := 160.0
const HEARING := 760.0

## name: Dateistamm unter audio/sfx/, Varianten, Pegel (dB), gleichzeitige
## Stimmen, Vorrang (höher verdrängt niedriger), Tonhöhenstreuung, Bus.
const CATALOG := {
	"schwert_schwung": {"path":"kampf/schwert_schwung", "variants":4, "db":-9.0, "max":2, "prio":3, "pitch":0.05},
	"stab_schwung": {"path":"kampf/stab_schwung", "variants":3, "db":-10.0, "max":2, "prio":3, "pitch":0.04},
	"bogen_spannen": {"path":"kampf/bogen_spannen", "variants":1, "db":-14.0, "max":1, "prio":2, "pitch":0.03},
	"bogen_schuss": {"path":"kampf/bogen_schuss", "variants":10, "db":-9.0, "max":2, "prio":3, "pitch":0.05},
	"krit": {"path":"kampf/krit", "variants":2, "db":-8.0, "max":2, "prio":4, "pitch":0.03},
	"treffer_weich": {"path":"treffer/treffer_weich", "variants":3, "db":-9.0, "max":3, "prio":3, "pitch":0.07},
	"treffer_chitin": {"path":"treffer/treffer_chitin", "variants":3, "db":-10.0, "max":3, "prio":3, "pitch":0.07},
	"treffer_fell": {"path":"treffer/treffer_fell", "variants":3, "db":-9.0, "max":3, "prio":3, "pitch":0.07},
	"treffer_stein": {"path":"treffer/treffer_stein", "variants":3, "db":-9.0, "max":3, "prio":3, "pitch":0.06},
	"treffer_geist": {"path":"treffer/treffer_geist", "variants":3, "db":-11.0, "max":3, "prio":3, "pitch":0.04},
	"treffer_metall": {"path":"treffer/treffer_metall", "variants":3, "db":-11.0, "max":3, "prio":3, "pitch":0.05},
	"tod_weich": {"path":"treffer/tod_weich", "variants":1, "db":-9.0, "max":2, "prio":4, "pitch":0.06},
	"tod_chitin": {"path":"treffer/tod_chitin", "variants":1, "db":-9.0, "max":2, "prio":4, "pitch":0.06},
	"tod_fell": {"path":"treffer/tod_fell", "variants":1, "db":-9.0, "max":2, "prio":4, "pitch":0.06},
	"tod_stein": {"path":"treffer/tod_stein", "variants":1, "db":-9.0, "max":2, "prio":4, "pitch":0.06},
	"tod_geist": {"path":"treffer/tod_geist", "variants":1, "db":-10.0, "max":2, "prio":4, "pitch":0.05},
	"tod_metall": {"path":"treffer/tod_metall", "variants":1, "db":-10.0, "max":2, "prio":4, "pitch":0.05},
	"spieler_schaden": {"path":"spieler/spieler_schaden", "variants":3, "db":-8.0, "max":1, "prio":6, "pitch":0.05},
	"spieler_tod": {"path":"spieler/spieler_tod", "variants":1, "db":-7.0, "max":1, "prio":9, "pitch":0.0, "duck":1.6},
	"spieler_ausweichen": {"path":"spieler/spieler_ausweichen", "variants":2, "db":-11.0, "max":1, "prio":4, "pitch":0.05},
	"spieler_trank": {"path":"spieler/spieler_trank", "variants":1, "db":-10.0, "max":1, "prio":5, "pitch":0.02},
	"spieler_wiederbeleben": {"path":"spieler/spieler_wiederbeleben", "variants":1, "db":-8.0, "max":1, "prio":8, "pitch":0.0, "duck":1.2},
	# Schritte je Untergrund (Schrittprobe 9.10.2026). db = Grundpegel -21 plus
	# Ausgleich der auf -3 dBFS angehobenen Dateien (tools/build_sfx.py --step-gains).
	"schritt_gras": {"path":"schritte/schritt_gras", "variants":4, "db":-22.4, "max":1, "prio":1, "pitch":0.05},
	"schritt_laub": {"path":"schritte/schritt_laub", "variants":4, "db":-22.4, "max":1, "prio":1, "pitch":0.05},
	"schritt_erde": {"path":"schritte/schritt_erde", "variants":4, "db":-24.8, "max":1, "prio":1, "pitch":0.05},
	"schritt_pflaster": {"path":"schritte/schritt_pflaster", "variants":4, "db":-22.4, "max":1, "prio":1, "pitch":0.05},
	"schritt_spawnstein": {"path":"schritte/schritt_spawnstein", "variants":4, "db":-25.5, "max":1, "prio":1, "pitch":0.05},
	"schritt_holz": {"path":"schritte/schritt_holz", "variants":4, "db":-28.0, "max":1, "prio":1, "pitch":0.05},
	"schritt_stein": {"path":"schritte/schritt_stein", "variants":4, "db":-22.4, "max":1, "prio":1, "pitch":0.05},
	"schritt_sand": {"path":"schritte/schritt_sand", "variants":4, "db":-24.6, "max":1, "prio":1, "pitch":0.05},
	"schritt_moor": {"path":"schritte/schritt_moor", "variants":4, "db":-22.4, "max":1, "prio":1, "pitch":0.05},
	"schritt_asche": {"path":"schritte/schritt_asche", "variants":4, "db":-22.4, "max":1, "prio":1, "pitch":0.05},
	"teleport_brummen": {"path":"welt/teleport_brummen", "variants":1, "db":-11.0, "max":1, "prio":1, "pitch":0.0, "loop":true, "bus":"umgebung"},
	"spieler_warnung": {"path":"spieler/spieler_warnung", "variants":1, "db":-13.0, "max":1, "prio":7, "pitch":0.0, "loop":true},
	"schleim_huepfen": {"path":"mobs/schleim_huepfen", "variants":3, "db":-12.0, "max":2, "prio":2, "pitch":0.08},
	"schleim_tod": {"path":"mobs/schleim_tod", "variants":1, "db":-9.0, "max":2, "prio":4, "pitch":0.06},
	"kaefer_zirpen": {"path":"mobs/kaefer_zirpen", "variants":2, "db":-15.0, "max":2, "prio":2, "pitch":0.06},
	"kaefer_schuss": {"path":"mobs/kaefer_schuss", "variants":1, "db":-11.0, "max":2, "prio":3, "pitch":0.07},
	"kaefer_sekret": {"path":"mobs/kaefer_sekret", "variants":1, "db":-10.0, "max":2, "prio":4, "pitch":0.06},
	"kaefer_tod": {"path":"mobs/kaefer_tod", "variants":1, "db":-9.0, "max":2, "prio":4, "pitch":0.06},
	"pilz_ankuendigung": {"path":"mobs/pilz_ankuendigung", "variants":1, "db":-12.0, "max":2, "prio":3, "pitch":0.05},
	"pilz_tod": {"path":"mobs/pilz_tod", "variants":1, "db":-9.0, "max":2, "prio":4, "pitch":0.06},
	"wolf_knurren": {"path":"mobs/wolf_knurren", "variants":2, "db":-10.0, "max":2, "prio":3, "pitch":0.06},
	"wolf_sprung": {"path":"mobs/wolf_sprung", "variants":1, "db":-10.0, "max":2, "prio":3, "pitch":0.05},
	"wolf_biss": {"path":"mobs/wolf_biss", "variants":1, "db":-9.0, "max":2, "prio":4, "pitch":0.07},
	"beute_muenzen": {"path":"beute/beute_muenzen", "variants":3, "db":-11.0, "max":2, "prio":3, "pitch":0.02},
	"beute_aufheben": {"path":"beute/beute_aufheben", "variants":2, "db":-11.0, "max":2, "prio":3, "pitch":0.02},
	"beute_selten": {"path":"beute/beute_selten", "variants":1, "db":-10.0, "max":1, "prio":5, "pitch":0.0},
	"beute_episch": {"path":"beute/beute_episch", "variants":1, "db":-9.0, "max":1, "prio":6, "pitch":0.0, "duck":0.8},
	"beute_legendaer": {"path":"beute/beute_legendaer", "variants":1, "db":-8.0, "max":1, "prio":7, "pitch":0.0, "duck":1.4},
	# Paket 2: Oberfläche (eigener Regler) und Fortschritt.
	"ui_klick": {"path":"ui/ui_klick", "variants":3, "db":-12.0, "max":2, "prio":2, "pitch":0.03, "bus":"ui"},
	"ui_fenster_auf": {"path":"ui/ui_fenster_auf", "variants":1, "db":-13.0, "max":1, "prio":2, "pitch":0.02, "bus":"ui"},
	"ui_fenster_zu": {"path":"ui/ui_fenster_zu", "variants":1, "db":-13.0, "max":1, "prio":2, "pitch":0.02, "bus":"ui"},
	"ui_fehler": {"path":"ui/ui_fehler", "variants":1, "db":-11.0, "max":1, "prio":4, "pitch":0.0, "bus":"ui"},
	"ui_dialog": {"path":"ui/ui_dialog", "variants":2, "db":-11.0, "max":1, "prio":3, "pitch":0.0, "bus":"ui"},
	"ui_hinweis": {"path":"ui/ui_hinweis", "variants":1, "db":-11.0, "max":1, "prio":4, "pitch":0.0, "bus":"ui"},
	"kaufen": {"path":"ui/kaufen", "variants":1, "db":-10.0, "max":1, "prio":4, "pitch":0.02, "bus":"ui"},
	"verkaufen": {"path":"ui/verkaufen", "variants":1, "db":-10.0, "max":1, "prio":4, "pitch":0.02, "bus":"ui"},
	"quest_angenommen": {"path":"fortschritt/quest_angenommen", "variants":1, "db":-9.0, "max":1, "prio":5, "pitch":0.0, "bus":"ui"},
	"quest_bereit": {"path":"fortschritt/quest_bereit", "variants":1, "db":-9.0, "max":1, "prio":5, "pitch":0.0, "bus":"ui"},
	"quest_abgeschlossen": {"path":"fortschritt/quest_abgeschlossen", "variants":1, "db":-8.0, "max":1, "prio":7, "pitch":0.0, "bus":"ui", "duck":1.6},
	"level_auf": {"path":"fortschritt/level_auf", "variants":1, "db":-7.0, "max":1, "prio":8, "pitch":0.0, "bus":"ui", "duck":2.0},
	"skillpunkt": {"path":"fortschritt/skillpunkt", "variants":1, "db":-9.0, "max":1, "prio":5, "pitch":0.0, "bus":"ui"},
	"freischaltung": {"path":"fortschritt/freischaltung", "variants":1, "db":-8.0, "max":1, "prio":7, "pitch":0.0, "bus":"ui", "duck":1.4},
	"wegstein_aktiviert": {"path":"welt/wegstein_aktiviert", "variants":1, "db":-8.0, "max":1, "prio":6, "pitch":0.0, "duck":1.2},
	"reise": {"path":"welt/reise", "variants":1, "db":-8.0, "max":1, "prio":6, "pitch":0.0},
	"truhe_auf": {"path":"welt/truhe_auf", "variants":1, "db":-9.0, "max":1, "prio":5, "pitch":0.02},
	"heilen": {"path":"welt/heilen", "variants":1, "db":-9.0, "max":1, "prio":6, "pitch":0.0, "duck":1.0},
	"boss_erscheint": {"path":"welt/boss_erscheint", "variants":1, "db":-7.0, "max":1, "prio":8, "pitch":0.0, "duck":1.8},
	# Rascheln beim Durchlaufen von Büschen.
	"busch_rascheln": {"path":"welt/busch_rascheln", "variants":3, "db":-16.0, "max":1, "prio":2, "pitch":0.08},
}

## Klangmaterial je Gegnertyp (Index wie GameContent.ENEMY_TYPES).
const ENEMY_MATERIAL := [
	"weich", "chitin", "weich", "fell", "stein", "geist", "chitin", "stein", "fell", "stein",
	"chitin", "geist", "metall", "geist", "fell", "geist", "stein", "fell", "geist", "weich",
	"weich", "weich", "geist", "fell", "metall", "chitin", "metall",
]
## Eigene Todeslaute der erneuerten Waldmonster (der Mooswolf nutzt "tod_fell").
const ENEMY_DEATH := {0:"schleim_tod", 1:"kaefer_tod", 2:"pilz_tod"}

var streams := {}
var players: Array = []
var voice_info: Array = []
var last_variant := {}
var music_bus := -1
var duck_timer := 0.0
var mob_seen := {}
var loop_players := {}
var rng := RandomNumberGenerator.new()

## Die Busse stehen fest in res://default_bus_layout.tres. Im Browser (Web-Export
## ohne Threads) bleiben zur Laufzeit angelegte Busse stumm; das Anlegen hier ist
## nur noch Rückfall für Werkzeuge ohne Projekt-Layout.
static func ensure_buses() -> void:
	for bus_name in [BUS_MUSIC, BUS_SFX, BUS_UI, BUS_AMBIENCE]:
		if AudioServer.get_bus_index(bus_name) >= 0: continue
		AudioServer.add_bus()
		var index := AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, bus_name)
		AudioServer.set_bus_send(index, "Master")
		if bus_name == BUS_SFX:
			var limiter := AudioEffectHardLimiter.new()
			limiter.ceiling_db = -1.0
			AudioServer.add_bus_effect(index, limiter)

static func material_for(type: int) -> String:
	return ENEMY_MATERIAL[type] if type >= 0 and type < ENEMY_MATERIAL.size() else "fell"

static func hit_sound_for(type: int) -> String:
	return "treffer_" + material_for(type)

static func death_sound_for(type: int) -> String:
	return ENEMY_DEATH.get(type, "tod_" + material_for(type))

static func loot_sound_for(rarity: int) -> String:
	if rarity >= 4: return "beute_legendaer"
	if rarity == 3: return "beute_episch"
	if rarity == 2: return "beute_selten"
	return "beute_aufheben"

static func file_path(name: String, variant: int) -> String:
	return "res://audio/sfx/%s_%02d.wav" % [CATALOG[name]["path"], variant + 1]

## Untergrund -> Schrittklang. Unbekannte Untergründe klingen wie Gras.
const STEP_SURFACES := {"gras":"schritt_gras", "laub":"schritt_laub", "erde":"schritt_erde", "pflaster":"schritt_pflaster", "spawnstein":"schritt_spawnstein", "holz":"schritt_holz", "stein":"schritt_stein", "sand":"schritt_sand", "moor":"schritt_moor", "asche":"schritt_asche"}
## Sichtbare Bodenfamilien im Dorf (start_tilemap_32.gd) -> Untergrund.
const VILLAGE_SURFACES := {"village_grass":"gras", "moss_grass":"gras", "village_stone":"pflaster", "plaza_stone":"pflaster", "building_apron":"pflaster", "arena_entry_stone":"pflaster", "spawn_crossing":"pflaster"}
## Gebiete draußen -> Untergrund abseits der Wege (Index wie region_at).
const REGION_SURFACES := {0:"gras", 1:"gras", 2:"laub", 3:"stein", 4:"moor", 5:"asche", 6:"sand", 7:"stein", 8:"gras", 9:"laub", 10:"moor", 11:"stein", 12:"gras"}

static func step_sound_for(surface: String) -> String:
	return STEP_SURFACES.get(surface, "schritt_gras")

## Teleport-Brummen am Spawnstein: voll bis SPAWN_HUM_FULL, leise auslaufend bis SPAWN_HUM_EDGE.
const SPAWN_HUM_FULL := 150.0
const SPAWN_HUM_EDGE := 460.0

static func spawn_hum_gain(distance: float) -> float:
	if distance <= SPAWN_HUM_FULL: return 1.0
	if distance >= SPAWN_HUM_EDGE: return 0.0
	return pow(1.0 - (distance - SPAWN_HUM_FULL) / (SPAWN_HUM_EDGE - SPAWN_HUM_FULL), 1.4)

## Linearer Lautstärkefaktor nach Entfernung zur Spielfigur.
static func distance_gain(distance: float) -> float:
	if distance <= NEAR: return 1.0
	if distance >= HEARING: return 0.0
	return pow(1.0 - (distance - NEAR) / (HEARING - NEAR), 1.6)

func has(name: String) -> bool:
	return CATALOG.has(name)

## Oberflächenklänge folgen dem Regler „Oberfläche“ statt „Effekte“.
static func is_ui(name: String) -> bool:
	return str(CATALOG.get(name, {}).get("bus", "")) == "ui"

func setup(host: Node, voices: int = 16) -> void:
	ensure_buses()
	music_bus = AudioServer.get_bus_index(BUS_MUSIC)
	rng.seed = 271828
	for name in CATALOG:
		var list: Array = []
		for variant in int(CATALOG[name]["variants"]):
			var stream: AudioStream = load(file_path(name, variant))
			if stream != null: list.append(stream)
		streams[name] = list
		if bool(CATALOG[name].get("loop", false)) and not list.is_empty():
			make_loop(list[0])
			var loop_player := AudioStreamPlayer.new()
			loop_player.bus = BUS_AMBIENCE if str(CATALOG[name].get("bus", "")) == "umgebung" else BUS_SFX
			loop_player.stream = list[0]
			host.add_child(loop_player)
			loop_players[name] = loop_player
	for i in voices:
		var player := AudioStreamPlayer.new()
		player.bus = BUS_SFX
		host.add_child(player)
		players.append(player)
		voice_info.append({"name":"", "prio":-1, "started":0})

## Macht aus einer WAV-Datei eine nahtlose Schleife über die ganze Länge.
static func make_loop(stream: AudioStream) -> void:
	if not stream is AudioStreamWAV: return
	var wav: AudioStreamWAV = stream
	# Importierte WAVs sind komprimiert; die Länge daher aus Dauer und Abtastrate.
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = int(round(wav.get_length() * wav.mix_rate))

## Startet oder stoppt einen Schleifensound (z. B. Herzschlag bei wenig Leben).
func set_loop(name: String, active: bool, volume: float = 1.0) -> void:
	var player: AudioStreamPlayer = loop_players.get(name)
	if player == null: return
	var on := active and volume > 0.0
	if on:
		player.volume_db = float(CATALOG[name]["db"]) + linear_to_db(volume)
		if not player.playing: player.play()
	elif player.playing:
		player.stop()

## Spielt einen Katalogsound. volume = Effektlautstärke 0..1, distance in Weltpixeln.
func play(name: String, volume: float = 1.0, distance: float = 0.0) -> bool:
	if not CATALOG.has(name) or volume <= 0.0: return false
	var list: Array = streams.get(name, [])
	if list.is_empty() or players.is_empty(): return false
	var gain := distance_gain(distance)
	if gain <= 0.01: return false
	var entry: Dictionary = CATALOG[name]
	var slot := pick_voice(name, int(entry["prio"]), int(entry["max"]))
	if slot < 0: return false
	var variant := pick_variant(name, list.size())
	var player: AudioStreamPlayer = players[slot]
	player.stop()
	player.stream = list[variant]
	player.bus = BUS_UI if is_ui(name) else BUS_SFX
	player.volume_db = float(entry["db"]) + linear_to_db(volume * gain)
	var spread := float(entry["pitch"])
	player.pitch_scale = 1.0 + rng.randf_range(-spread, spread)
	player.play()
	voice_info[slot] = {"name":name, "prio":int(entry["prio"]), "started":Time.get_ticks_msec()}
	if entry.has("duck"): duck(float(entry["duck"]))
	return true

## Freie Stimme, sonst älteste gleichnamige über dem Limit, sonst die älteste
## mit niedrigerem oder gleichem Vorrang. -1: Sound fällt weg.
func pick_voice(name: String, prio: int, limit: int) -> int:
	var same: Array = []
	for i in players.size():
		if players[i].playing and voice_info[i]["name"] == name: same.append(i)
	if same.size() >= limit: return oldest(same)
	for i in players.size():
		if not players[i].playing: return i
	var candidates: Array = []
	for i in players.size():
		if int(voice_info[i]["prio"]) <= prio: candidates.append(i)
	return oldest(candidates) if not candidates.is_empty() else -1

func oldest(indices: Array) -> int:
	var best := -1
	for i in indices:
		if best < 0 or int(voice_info[i]["started"]) < int(voice_info[best]["started"]): best = i
	return best

func pick_variant(name: String, count: int) -> int:
	if count <= 1: return 0
	var choice := rng.randi_range(0, count - 2)
	if choice >= int(last_variant.get(name, -1)): choice += 1
	choice = mini(choice, count - 1)
	last_variant[name] = choice
	return choice

## Senkt die Musik für 'seconds' um 6 dB.
func duck(seconds: float) -> void:
	duck_timer = maxf(duck_timer, seconds)

func tick(delta: float) -> void:
	duck_timer = maxf(0.0, duck_timer - delta)
	if music_bus < 0: return
	var target := -6.0 if duck_timer > 0.0 else 0.0
	var current := AudioServer.get_bus_volume_db(music_bus)
	AudioServer.set_bus_volume_db(music_bus, move_toward(current, target, delta * (40.0 if target < current else 12.0)))

## Leitet aus dem Angriffszustand der Gegner Laute ab (offline und im Koop).
## Gibt [[name, pos], ...] zurück; merkt sich je Gegner, was schon klang.
## detect_deaths: im Koop verschwinden besiegte Gegner nur aus dem Abbild des
## Servers; ein angeschlagener Gegner, der verschwindet, bekommt den Todeslaut.
func observe_mobs(enemies: Array, listener: Vector2, detect_deaths: bool = false) -> Array:
	var out: Array = []
	var alive := {}
	for enemy in enemies:
		var uid := int(enemy.get("uid", -1))
		if uid < 0: continue
		alive[uid] = true
		var pos: Vector2 = enemy.get("pos", Vector2.ZERO)
		if pos.distance_to(listener) >= HEARING: continue
		var state: Dictionary = enemy.get("attack_state", {})
		var memory: Dictionary = mob_seen.get(uid, {"attack":-1, "fired":false})
		memory["type"] = int(enemy.get("type", -1))
		memory["pos"] = pos
		memory["hp_ratio"] = clampf(float(enemy.get("hp", 1.0)) / maxf(1.0, float(enemy.get("max_hp", 1.0))), 0.0, 1.0)
		if not state.is_empty():
			var attack_id := int(state.get("id", -1))
			var ability: Dictionary = state.get("ability", {})
			var ability_id := str(ability.get("id", ""))
			var shape := str(ability.get("shape", ""))
			if attack_id != int(memory["attack"]):
				memory.merge({"attack":attack_id, "fired":false}, true)
				var windup := windup_sound(int(enemy.get("type", -1)), ability_id)
				if windup != "": out.append([windup, pos])
			if bool(state.get("fired", false)) and not bool(memory["fired"]):
				memory["fired"] = true
				var strike := strike_sound(int(enemy.get("type", -1)), shape)
				if strike != "": out.append([strike, pos])
		mob_seen[uid] = memory
	for uid in mob_seen.keys():
		if alive.has(uid): continue
		var gone: Dictionary = mob_seen[uid]
		if detect_deaths and gone.has("pos") and float(gone.get("hp_ratio", 1.0)) < 0.5 and Vector2(gone["pos"]).distance_to(listener) < HEARING:
			out.append([death_sound_for(int(gone.get("type", -1))), gone["pos"]])
		mob_seen.erase(uid)
	return out

static func windup_sound(type: int, ability_id: String) -> String:
	match type:
		0: return "schleim_huepfen"
		1: return "kaefer_zirpen"
		2: return "" # Pilzlinge spielen ausschließlich das Giftzischen bei der Freisetzung.
		3: return "wolf_knurren"
	return ""

static func strike_sound(type: int, shape: String) -> String:
	match type:
		1: return "kaefer_schuss" if shape == "projectile" else ""
		3: return "wolf_sprung" if shape == "leap" else "wolf_biss"
	return ""
