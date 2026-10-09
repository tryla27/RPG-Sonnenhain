extends RefCounted
## Zustandslose Netzwerk-Hilfen: Koop-Einladungscodes sowie das Bereinigen
## von Quest-/Ereigniszeilen und Belohnungsgegenständen, die von anderen
## Spielern oder dem Server kommen.
##
## main.gd leitet die gleichnamigen Methoden hierher weiter, damit bestehende
## Aufrufer unverändert bleiben. Siehe docs/architecture/main-modularization.md,
## Schritt 2.

const GameContent = preload("res://components/game_content.gd")
const BASE36_CHARS := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const INVITE_PREFIX := "SH"

static func to_base36(value: int) -> String:
	var n := maxi(0, value)
	if n == 0: return "0"
	var out := ""
	while n > 0:
		out = BASE36_CHARS.substr(n % 36, 1) + out
		n = int(n / 36)
	return out

static func from_base36(value: String) -> int:
	var out := 0
	for i in value.length():
		var ch := value.to_upper().substr(i, 1)
		var idx := BASE36_CHARS.find(ch)
		if idx < 0: return -1
		out = out * 36 + idx
	return out

static func ipv4_to_int(address: String) -> int:
	var parts := address.split(".")
	if parts.size() != 4: return -1
	var result := 0
	for part in parts:
		var octet := int(part)
		if octet < 0 or octet > 255: return -1
		result = (result << 8) | octet
	return result

static func int_to_ipv4(value: int) -> String:
	return "%d.%d.%d.%d" % [(value >> 24) & 255, (value >> 16) & 255, (value >> 8) & 255, value & 255]

static func make_invite_code(address: String, port: int) -> String:
	var packed := ipv4_to_int(address)
	if packed < 0: return ""
	return "%s-%s-%s" % [INVITE_PREFIX, to_base36(packed), to_base36(port)]

static func decode_invite_code(code: String) -> Dictionary:
	var cleaned := code.strip_edges().to_upper()
	var parts := cleaned.split("-")
	if parts.size() != 3 or parts[0] != INVITE_PREFIX: return {}
	var packed := from_base36(parts[1])
	var port := from_base36(parts[2])
	if packed < 0 or port <= 0 or port > 65535: return {}
	return {"address":int_to_ipv4(packed), "port":port}

## Bereinigt [id, fortschritt]-Zeilen: gültige, eindeutige IDs; Fortschritt
## auf 0..limit_key des jeweiligen Katalogeintrags begrenzt.
static func sanitize_progress_rows(raw: Variant, catalog: Array, limit_key: String) -> Array:
	var out: Array = []
	if not raw is Array: return out
	var seen: Dictionary = {}
	for entry in raw:
		if not entry is Array or entry.size() < 2: continue
		var row_id := int(entry[0])
		if row_id < 0 or row_id >= catalog.size() or seen.has(row_id): continue
		seen[row_id] = true
		out.append([row_id, clampi(int(entry[1]), 0, int(catalog[row_id][limit_key]))])
	return out

static func sanitize_active_quest_rows(raw: Variant) -> Array:
	return sanitize_progress_rows(raw, GameContent.QUESTS, "count")

static func sanitize_active_borin_quest_rows(raw: Variant) -> Array:
	return sanitize_progress_rows(raw, GameContent.BORIN_QUESTS, "count")

static func sanitize_active_event_rows(raw: Variant) -> Array:
	return sanitize_progress_rows(raw, GameContent.WORLD_EVENTS, "goal")

static func network_reward_payload(item: Dictionary) -> Dictionary:
	var payload: Dictionary = item.duplicate(true)
	payload.erase("uid")
	# Identität eines Inventargegenstands gehört ausschließlich dem Browser-Save.
	payload.erase("stack_value")
	return payload
