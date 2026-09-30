extends RefCounted
## Reliable, revisioned save exchange with local recovery during disconnects.
var uuid := ""
var token := ""
var revision := 0
var dirty := true
var ready := false
var loading := false
var status := "Noch nicht auf dem Server gespeichert"
var latest: Dictionary = {}
var inflight: Dictionary = {}
var last_request := ""
var submitted_hash := ""
var last_send_ms := 0
var open_started_ms := 0
var retry_after_ms := 0

func restore(data: Dictionary) -> void:
	uuid = str(data.get("player_uuid",""))
	token = str(data.get("server_save_token",""))
	if token.length() != 64 or not token.is_valid_hex_number(false): token = Crypto.new().generate_random_bytes(32).hex_encode()
	revision = maxi(0,int(data.get("server_save_revision",0)))
	dirty = bool(data.get("server_save_dirty",true))
	last_request = str(data.get("server_save_request",""))
	submitted_hash = str(data.get("server_save_submitted_hash",""))
	latest = data.duplicate(true)
	inflight.clear()
	ready = false
	loading = false
	status = "Serverabgleich ausstehend" if dirty else "Serverstand · warte auf Verbindung"

func decorate(data: Dictionary) -> Dictionary:
	var local := data.duplicate(true)
	local["server_save_token"] = token
	local["server_save_revision"] = revision
	local["server_save_dirty"] = dirty
	local["server_save_request"] = last_request
	local["server_save_submitted_hash"] = submitted_hash
	return local

func digest(data: Dictionary) -> String:
	var clean: Dictionary = JSON.parse_string(JSON.stringify(data))
	for key in clean.keys():
		if String(key).begins_with("server_save_"): clean.erase(key)
	return JSON.stringify(clean).sha256_text()

func queue(g, data: Dictionary) -> void:
	if g.creative_mode or g.konflux_preview_mode or g.multiplayer_smoke_client_mode or not g.character_created: return
	if uuid != g.player_uuid or token.is_empty(): restore(data)
	latest = data.duplicate(true)
	dirty = true
	status = "Speichere auf Server …" if ready else "Lokal gesichert · Serverabgleich ausstehend"
	flush(g)

func connected(g) -> bool:
	return g.network_mode == "client" and g.multiplayer.multiplayer_peer != null and g.multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED

func begin(g) -> void:
	if g.creative_mode or g.konflux_preview_mode or g.multiplayer_smoke_client_mode or not g.character_created or not connected(g): return
	var data: Dictionary = g.capture_save_data()
	if uuid != g.player_uuid or token.is_empty(): restore(data)
	latest = data
	ready = false
	loading = true
	status = "Lade Server-Spielstand …"
	open_started_ms = Time.get_ticks_msec()
	retry_after_ms = open_started_ms+3000
	g.write_local_save(decorate(latest))
	g.rpc_zz_save_open.rpc_id(1,token,uuid)

func disconnected() -> void:
	ready = false
	loading = false
	inflight.clear()
	status = "Verbindung weg · lokal gesichert, Abgleich folgt"

func flush(g) -> void:
	if not dirty or not ready or not inflight.is_empty() or latest.is_empty() or not connected(g): return
	if Time.get_ticks_msec()-last_send_ms < 350: return
	last_request = Crypto.new().generate_random_bytes(16).hex_encode()
	submitted_hash = digest(latest)
	inflight = {"request":last_request,"data":latest.duplicate(true),"revision":revision}
	last_send_ms = Time.get_ticks_msec()
	g.write_local_save(decorate(latest))
	g.rpc_zz_save_put.rpc_id(1,token,uuid,revision,last_request,inflight["data"])

func update(g) -> void:
	if g.dedicated_server_mode or g.creative_mode or g.konflux_preview_mode or g.multiplayer_smoke_client_mode or not g.character_created: return
	if not connected(g): return
	var now := Time.get_ticks_msec()
	if not ready:
		if loading and now-open_started_ms > 10000:
			loading = false
			status = "Server-Speicherung antwortet nicht · lokal gesichert"
		if now > retry_after_ms:
			retry_after_ms = now+3000
			g.rpc_zz_save_open.rpc_id(1,token,uuid)
		return
	if not inflight.is_empty() and now-last_send_ms > 2000:
		last_send_ms = now
		g.rpc_zz_save_put.rpc_id(1,token,uuid,int(inflight["revision"]),str(inflight["request"]),inflight["data"])
	flush(g)

func reply(g, response: Dictionary) -> void:
	if g.creative_mode: return
	if str(response.get("uuid","")) != uuid or uuid != g.player_uuid: return
	if not bool(response.get("ok",false)):
		var error := str(response.get("error","unknown"))
		if error == "retry": return
		loading = false
		ready = false
		inflight.clear()
		retry_after_ms = Time.get_ticks_msec()+5000
		var labels := {"already_online":"Charakter bereits in einem anderen Fenster online", "disk_error":"Server kann gerade nicht speichern", "corrupt":"Serverstand beschädigt · vorhandene Daten bleiben geschützt", "invalid_save":"Spielstand konnte nicht geprüft werden", "revision_conflict":"Neuerer Serverstand vorhanden · gleiche ab", "identity_mismatch":"Spielstand und Charakter passen nicht zusammen", "unauthorized":"Speicherzugriff nicht bestätigt"}
		status = str(labels.get(error,"Server-Speicherfehler"))+" · lokal gesichert"
		g.message(status)
		return
	var kind := str(response.get("kind",""))
	var server_revision := int(response.get("revision",0))
	if kind == "open":
		var remote: Dictionary = response.get("data",{})
		var acknowledged: bool = last_request != "" and str(response.get("request","")) == last_request
		var keep_local: bool = dirty and (server_revision == revision or acknowledged)
		if not remote.is_empty() and not keep_local:
			if dirty:
				g.preserve_save_conflict(decorate(latest))
				g.message("Neuerer Serverstand geladen. Lokaler Stand als Konfliktkopie gesichert.")
			g.apply_save_data(remote,true)
			latest = g.capture_save_data()
			dirty = false
		else:
			if remote.is_empty(): dirty = true
			elif acknowledged and digest(latest) == submitted_hash: dirty = false
		revision = server_revision
		inflight.clear()
		ready = true
		loading = false
		status = "Server gespeichert ✓" if not dirty else "Speichere auf Server …"
		g.write_local_save(decorate(latest))
		g.announce_multiplayer_context()
		flush(g)
	elif kind == "saved":
		if inflight.is_empty() or str(response.get("request","")) != str(inflight["request"]): return
		if server_revision < revision: return
		revision = server_revision
		dirty = digest(latest) != digest(inflight["data"])
		inflight.clear()
		status = "Server gespeichert ✓" if not dirty else "Speichere auf Server …"
		g.write_local_save(decorate(latest))
		g.save_notice_text = "SERVER GESPEICHERT ✓"
		g.save_notice_timer = 2.8
		flush(g)
