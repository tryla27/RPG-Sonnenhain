extends Node

## Kümmert sich ausschließlich um Transport, Verbindungsaufbau und Netzwerkstatus.
## Spielzustand/RPC-Inhalte bleiben bewusst im jeweiligen Spielsystem.
signal state_changed(mode: String, status: String, invite_code: String, local_peer_id: int)
signal peer_joined(id: int)
signal peer_left(id: int)
signal connected_to_server
signal connection_failed
signal server_disconnected

var network_port := 27844
var server_url := "wss://game.sonnenhainrpg.de"

var mode := "offline"
var status := "Offline"
var invite_code := ""
var local_peer_id := 1

func _ready() -> void:
	_setup_multiplayer_signals()
	_emit_state()

func _setup_multiplayer_signals() -> void:
	if not multiplayer.peer_connected.is_connected(_on_peer_connected):
		multiplayer.peer_connected.connect(_on_peer_connected)
	if not multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	if not multiplayer.connected_to_server.is_connected(_on_connected_to_server):
		multiplayer.connected_to_server.connect(_on_connected_to_server)
	if not multiplayer.connection_failed.is_connected(_on_connection_failed):
		multiplayer.connection_failed.connect(_on_connection_failed)
	if not multiplayer.server_disconnected.is_connected(_on_server_disconnected):
		multiplayer.server_disconnected.connect(_on_server_disconnected)

func start_dedicated_server() -> void:
	disconnect_network(false)
	var peer := WebSocketMultiplayerPeer.new()
	var err := peer.create_server(network_port, "0.0.0.0")
	if err != OK:
		status = "Dedicated Server konnte nicht gestartet werden · Fehler %d" % err
		push_error(status)
		_emit_state()
		return
	multiplayer.multiplayer_peer = peer
	mode = "host"
	local_peer_id = 1
	status = "Dedicated Server aktiv · WebSocket-Port %d" % network_port
	_emit_state()
	print("[Sonnenhain] ", status)

func join_dedicated_server() -> void:
	disconnect_network(false)
	var peer := WebSocketMultiplayerPeer.new()
	var err := peer.create_client(server_url)
	if err != OK:
		status = "Online-Verbindung konnte nicht gestartet werden · Fehler %d" % err
		_emit_state()
		return
	multiplayer.multiplayer_peer = peer
	mode = "client"
	status = "Verbinde mit Sonnenhain-Server …"
	_emit_state()

func host_lan() -> void:
	disconnect_network(false)
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(network_port, 4)
	if err != OK:
		status = "Host konnte nicht gestartet werden · Fehler %d" % err
		_emit_state()
		return
	multiplayer.multiplayer_peer = peer
	mode = "host"
	local_peer_id = 1
	var address := _preferred_host_address()
	invite_code = _make_invite_code(address, network_port)
	status = "Host aktiv · Einladungscode %s" % invite_code
	_emit_state()

func join_lan_code(code: String) -> void:
	var endpoint := _decode_invite_code(code)
	if endpoint.is_empty():
		status = "Ungültiger Einladungscode."
		_emit_state()
		return
	disconnect_network(false)
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(str(endpoint["address"]), int(endpoint["port"]))
	if err != OK:
		status = "Verbindung konnte nicht gestartet werden · Fehler %d" % err
		_emit_state()
		return
	multiplayer.multiplayer_peer = peer
	mode = "client"
	status = "Verbinde mit %s …" % str(endpoint["address"])
	_emit_state()

func disconnect_network(show_message: bool = true) -> void:
	if mode != "offline" and multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	mode = "offline"
	invite_code = ""
	local_peer_id = 1
	if show_message:
		status = "Offline"
	_emit_state()

func _on_peer_connected(id: int) -> void:
	status = "Spieler %d verbunden" % id
	_emit_state()
	peer_joined.emit(id)

func _on_peer_disconnected(id: int) -> void:
	peer_left.emit(id)

func _on_connected_to_server() -> void:
	local_peer_id = multiplayer.get_unique_id()
	status = "Verbunden · Peer %d" % local_peer_id
	_emit_state()
	connected_to_server.emit()

func _on_connection_failed() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	mode = "offline"
	invite_code = ""
	local_peer_id = 1
	status = "Verbindung zum Sonnenhain-Server fehlgeschlagen."
	_emit_state()
	connection_failed.emit()

func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	mode = "offline"
	invite_code = ""
	local_peer_id = 1
	status = "Server-Verbindung beendet."
	_emit_state()
	server_disconnected.emit()

func _emit_state() -> void:
	state_changed.emit(mode, status, invite_code, local_peer_id)

func _to_base36(value: int) -> String:
	var chars := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	var n := maxi(0, value)
	if n == 0:
		return "0"
	var out := ""
	while n > 0:
		out = chars.substr(n % 36, 1) + out
		n = int(n / 36)
	return out

func _from_base36(value: String) -> int:
	var chars := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	var out := 0
	for i in value.length():
		var ch := value.to_upper().substr(i, 1)
		var idx := chars.find(ch)
		if idx < 0:
			return -1
		out = out * 36 + idx
	return out

func _ipv4_to_int(address: String) -> int:
	var parts := address.split(".")
	if parts.size() != 4:
		return -1
	var result := 0
	for part in parts:
		var octet := int(part)
		if octet < 0 or octet > 255:
			return -1
		result = (result << 8) | octet
	return result

func _int_to_ipv4(value: int) -> String:
	return "%d.%d.%d.%d" % [(value >> 24) & 255, (value >> 16) & 255, (value >> 8) & 255, value & 255]

func _make_invite_code(address: String, port: int) -> String:
	var packed := _ipv4_to_int(address)
	if packed < 0:
		return ""
	return "SH-%s-%s" % [_to_base36(packed), _to_base36(port)]

func _decode_invite_code(code: String) -> Dictionary:
	var cleaned := code.strip_edges().to_upper()
	var parts := cleaned.split("-")
	if parts.size() != 3 or parts[0] != "SH":
		return {}
	var packed := _from_base36(parts[1])
	var port := _from_base36(parts[2])
	if packed < 0 or port <= 0 or port > 65535:
		return {}
	return {"address": _int_to_ipv4(packed), "port": port}

func _preferred_host_address() -> String:
	var upnp := UPNP.new()
	var discover_result := upnp.discover(1600, 2, "InternetGatewayDevice")
	if discover_result == UPNP.UPNP_RESULT_SUCCESS and upnp.get_gateway() != null and upnp.get_gateway().is_valid_gateway():
		upnp.add_port_mapping(network_port, network_port, "Sonnenhain Koop", "UDP", 0)
		var public_ip := upnp.query_external_address()
		if public_ip != "":
			return public_ip
	for address in IP.get_local_addresses():
		if "." in address and not address.begins_with("127.") and not address.begins_with("169.254."):
			return address
	return "127.0.0.1"
