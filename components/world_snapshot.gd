extends RefCounted
# Weltpaket des Servers (Gegner, Gegner-Geschosse, Beute) pro Spieler.
#
# Früher bekam jeder Spieler alle Gegner und Beutestücke der ganzen Welt in
# einem Paket. Bei vielen Spielern in verschiedenen Gebieten und liegender
# Beute wurde das Paket größer als der WebSocket-Puffer (64 KiB) und ging
# verloren: Gegner blieben stehen, Bosse erschienen nicht. Jetzt bekommt jeder
# nur, was in seiner Nähe ist, und die Puffer sind größer.

## Sichtweite für das Paket: deutlich mehr als Bildschirm und Minikarte (1500).
const INTEREST_RANGE:=2600.0
## Puffergröße für WebSocket-Pakete (Server ausgehend, Spiel eingehend).
const BUFFER_BYTES:=1<<20
const MAX_PENDING_BYTES := 64 * 1024
const MAX_WIRE_BYTES := 4 * BUFFER_BYTES
const ROW_KEYS := {
	"enemies": ["uid","type","pos","hp","max_hp","facing","walking","attack_state","attack_wait","target_peer","guardian_of","small_guardian","context","instance_id","region","elite","flash","shot","hit","seed","stun","slow","poison","poison_tick","marked","boss_spawn_timer","golem"],
	"shots": ["pos","dir","speed","life","damage","type","hit_radius","kind","ability_id","radius","age","duration"],
	"drops": ["drop_uid","pos","item","life","reserved_class","reserve_ms"]
}

## Spalten statt wiederholter Feldnamen; verlustfreie Kompression großer Pakete.
static func encode(snapshot: Dictionary) -> Dictionary:
	var packed := snapshot.duplicate(false)
	packed["_columns"] = 1
	for category in ROW_KEYS:
		var rows: Array = []
		for row in snapshot.get(category, []):
			var values: Array = []
			for key in ROW_KEYS[category]: values.append(row.get(key))
			rows.append(values)
		packed[category] = rows
	var raw := var_to_bytes(packed)
	if raw.size() < 1024: return packed
	var zipped := raw.compress(FileAccess.COMPRESSION_ZSTD)
	if zipped.size() >= raw.size(): return packed
	return {"protocol":snapshot.get("protocol"), "context":"world", "_wire":zipped, "_size":raw.size()}

static func decode(packet: Dictionary) -> Dictionary:
	var packed := packet
	if packet.has("_wire"):
		var size := int(packet.get("_size", 0))
		if size <= 0 or size > MAX_WIRE_BYTES or not packet["_wire"] is PackedByteArray: return {}
		var bytes: PackedByteArray = packet["_wire"].decompress(size, FileAccess.COMPRESSION_ZSTD)
		if bytes.size() != size: return {}
		var decoded: Variant = bytes_to_var(bytes)
		if not decoded is Dictionary: return {}
		packed = decoded
	if not packed.has("_columns"): return packed
	var snapshot := packed.duplicate(false)
	snapshot.erase("_columns")
	for category in ROW_KEYS:
		var rows: Array = []
		for values in packed.get(category, []):
			if not values is Array or values.size() != ROW_KEYS[category].size(): return {}
			var row: Dictionary = {}
			for i in values.size():
				if values[i] != null: row[ROW_KEYS[category][i]] = values[i]
			rows.append(row)
		snapshot[category] = rows
	return snapshot

## WebSocket bleibt auch bei "unreliable" geordnet: alte Pakete nicht stapeln.
static func can_send(peer: MultiplayerPeer, peer_id: int) -> bool:
	if not peer is WebSocketMultiplayerPeer: return true
	var socket: WebSocketPeer = peer.get_peer(peer_id)
	return socket != null and socket.get_current_outbound_buffered_amount() < MAX_PENDING_BYTES

static func transmit(g, peer_id: int, snapshot: Dictionary) -> void:
	if not can_send(g.multiplayer.multiplayer_peer,peer_id):
		g.server_performance.skipped += 1
		return
	var started := Time.get_ticks_usec()
	var packet := encode(snapshot)
	var bytes: int = packet["_wire"].size() if packet.has("_wire") else var_to_bytes(packet).size()
	g.server_performance.record_snapshot(bytes,Time.get_ticks_usec()-started)
	g.rpc_world_snapshot.rpc_id(peer_id,packet)

## Nur Zeilen, deren "pos" ([x, y]) höchstens `range` von `center` entfernt ist.
static func near(rows:Array,center:Vector2,range:float=INTEREST_RANGE)->Array:
	var out:Array=[]
	var limit:=range*range
	for row in rows:
		if not row is Dictionary:continue
		var p:Variant=row.get("pos",[])
		if not p is Array or p.size()<2:continue
		if Vector2(float(p[0]),float(p[1])).distance_squared_to(center)<=limit:out.append(row)
	return out

static func for_peer(base:Dictionary,center:Vector2)->Dictionary:
	var snap:=base.duplicate(false)
	snap["enemies"]=near(base.get("enemies",[]),center)
	snap["shots"]=near(base.get("shots",[]),center)
	snap["drops"]=near(base.get("drops",[]),center)
	return snap

static func widen(peer:WebSocketMultiplayerPeer)->void:
	peer.inbound_buffer_size=BUFFER_BYTES
	peer.outbound_buffer_size=BUFFER_BYTES
