extends RefCounted
## Durable character snapshots. The private capability is never broadcast as player identity.
const MAX_BYTES := 262144
const MAX_REVISION := 9007199254740990
var directory := ""
var sessions: Dictionary = {}
var owners: Dictionary = {}

func configure(path: String) -> Error:
	directory = path
	var result := DirAccess.make_dir_recursive_absolute(directory)
	if result == OK and OS.has_feature("linux"): FileAccess.set_unix_permissions(directory,448)
	return result

func key_for(token: String) -> String:
	if token.length() != 64 or not token.is_valid_hex_number(false): return ""
	return token.sha256_text()

func filename(key: String) -> String:
	return directory.path_join(key+".json")

func read_record(key: String) -> Dictionary:
	var path := filename(key)
	var existed := false
	for candidate in [path,path+".bak"]:
		if not FileAccess.file_exists(candidate): continue
		existed = true
		var file := FileAccess.open(candidate,FileAccess.READ)
		if file == null or file.get_length() > MAX_BYTES+4096: continue
		var parser := JSON.new()
		var parsed := parser.parse(file.get_as_text())
		var record: Variant = parser.data if parsed == OK else null
		file.close()
		if record is Dictionary and int(record.get("schema",0)) == 1 and record.get("data") is Dictionary and int(record.get("revision",0)) >= 1:
			var data: Dictionary = record["data"]
			if String(record.get("digest","")) == JSON.stringify(data).sha256_text(): return record
	return {"error":"corrupt"} if existed else {}

func release(peer: int) -> void:
	if not sessions.has(peer): return
	var key: String = sessions[peer]["key"]
	if int(owners.get(key,0)) == peer: owners.erase(key)
	sessions.erase(peer)

func open(peer: int, token: String, uuid: String) -> Dictionary:
	var key := key_for(token)
	if key == "" or uuid.is_empty() or uuid.length() > 64 or directory.is_empty(): return {"ok":false,"error":"invalid_identity"}
	if owners.has(key) and int(owners[key]) != peer: return {"ok":false,"error":"already_online"}
	var record := read_record(key)
	if record.has("error"): return {"ok":false,"error":"corrupt"}
	if not record.is_empty() and str(record.get("uuid","")) != uuid: return {"ok":false,"error":"identity_mismatch"}
	release(peer)
	sessions[peer] = {"key":key,"uuid":uuid}
	owners[key] = peer
	return {"ok":true,"kind":"open","uuid":uuid,"revision":int(record.get("revision",0)),"request":record.get("request",""),"data":record.get("data",{})}

func valid_food_state(raw:Variant)->bool:
	if not raw is Dictionary or raw.size()>3:return false
	var plants:Variant=raw.get("plants",{})
	if not plants is Dictionary or plants.size()>64:return false
	for key in plants:
		var value:Variant=plants[key]
		if not key is String or key.length()>32 or not (value is float or value is int) or not is_finite(float(value)) or float(value)<0:return false
	for field in ["regen_rate","regen_until"]:
		var value:Variant=raw.get(field,0)
		if not (value is float or value is int) or not is_finite(float(value)) or float(value)<0:return false
	return float(raw.get("regen_rate",0))<=3

func valid_data(data: Dictionary, uuid: String) -> bool:
	if not valid_food_state(data.get("food_state",{})):return false
	if data.size() > 80: return false
	if str(data.get("player_uuid","")) != uuid or not bool(data.get("character_created",false)): return false
	if not data.get("inventory") is Array or data["inventory"].size() > 42: return false
	if not data.get("position") is Array or data["position"].size() != 2: return false
	for axis in data["position"]:
		if not (axis is float or axis is int) or not is_finite(float(axis)) or float(axis) < 0 or float(axis) > 110000: return false
	for field in ["level","xp","gold","class_id","hero_race","hero_gender","next_uid","skill_points"]:
		if not (data.get(field) is int or data.get(field) is float): return false
		if not is_finite(float(data[field])) or float(data[field]) < 0 or float(data[field]) > 2147483647: return false
	if int(data["level"]) < 1 or int(data["level"]) > 100000 or int(data["class_id"]) > 2 or int(data["hero_race"]) > 2 or int(data["hero_gender"]) > 1: return false
	if not data.get("hero_name") is String or String(data["hero_name"]).length() > 32: return false
	var uids := {}
	for item in data["inventory"]:
		if not item is Dictionary or item.size() > 32: return false
		if not item.get("uid") is int and not item.get("uid") is float: return false
		var uid := int(item["uid"])
		if uid < 0 or uids.has(uid): return false
		uids[uid] = true
		if not item.get("name") is String or String(item["name"]).length() > 160: return false
		if not item.get("icon") is String or String(item["icon"]) not in ["sword","staff","bow","armor","ring","potion","herb","essence","gem","food"]: return false
		if item["icon"]=="food" and preload("res://components/food_system.gd").by_name(item["name"]).is_empty():return false
		for field in ["power","rarity","value","count","level","str","agi","int","design"]:
			var value: Variant = item.get(field,1 if field == "count" else 0)
			if not (value is int or value is float) or not is_finite(float(value)) or float(value) < 0 or float(value) > 2147483647: return false
		if int(item.get("rarity",0)) > 4 or int(item.get("count",1)) < 1: return false
	for field in ["equipped_uid","equipped_armor_uid","equipped_ring_uid","equipped_ring2_uid"]:
		var value: Variant = data.get(field,-1)
		if not (value is int or value is float): return false
		if int(value) != -1 and not uids.has(int(value)): return false
	if int(data.get("equipped_ring2_uid",-1)) >= 0 and (int(data["class_id"]) != 1 or int(data["equipped_ring2_uid"]) == int(data.get("equipped_ring_uid",-1))): return false
	for field in ["learned","skill_levels","slots","quests","event_states","event_progress","opened_chests","dungeon_chests_opened","bosses_defeated","waystone_unlocked","discovered_regions","processed_server_transactions","recent_players","village_gates","arena_leaderboard"]:
		if not data.get(field,[]) is Array or data.get(field,[]).size() > (256 if field == "processed_server_transactions" else 100): return false
	for quest in data.get("quests",[]):
		if not quest is Dictionary or not (quest.get("state") is int or quest.get("state") is float) or not (quest.get("progress") is int or quest.get("progress") is float): return false
		if int(quest["state"]) < 0 or int(quest["state"]) > 3 or int(quest["progress"]) < 0 or int(quest["progress"]) > 1000: return false
	for field in ["hp","energy","music_volume","effects_volume","shop_timer"]:
		var value: Variant = data.get(field,0)
		if not (value is int or value is float) or not is_finite(float(value)): return false
	for field in ["skill_levels","slots","event_states","event_progress"]:
		for value in data.get(field,[]):
			if not (value is float or value is int) or not is_finite(float(value)): return false
	for field in ["learned","opened_chests","dungeon_chests_opened","bosses_defeated","waystone_unlocked","discovered_regions","village_gates"]:
		for value in data.get(field,[]):
			if not value is bool: return false
	for value in data.get("processed_server_transactions",[]):
		if not value is String or String(value).length() > 96: return false
	if not data.get("shop_stock",{}) is Dictionary: return false
	for stock in data.get("shop_stock",{}).values():
		if not stock is Array or stock.size() > 100: return false
		for item in stock:
			if not item is Dictionary or not item.get("name") is String or not item.get("icon") is String: return false
	return JSON.stringify(data).to_utf8_buffer().size() <= MAX_BYTES

func write_record(key: String, record: Dictionary) -> Error:
	var path := filename(key)
	var temp := path+".tmp"
	var file := FileAccess.open(temp,FileAccess.WRITE)
	if file == null: return FileAccess.get_open_error()
	file.store_string(JSON.stringify(record))
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK: return error
	if JSON.parse_string(FileAccess.get_file_as_string(temp)) == null: return ERR_FILE_CORRUPT
	if FileAccess.file_exists(path):
		# Keep the last valid generation; never replace it with a corrupt primary.
		var previous: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if previous is Dictionary and previous.get("data") is Dictionary and str(previous.get("digest","")) == JSON.stringify(previous["data"]).sha256_text():
			error = DirAccess.copy_absolute(path,path+".bak")
			if error != OK: return error
	error = DirAccess.rename_absolute(temp,path)
	if error == OK and OS.has_feature("linux"):
		FileAccess.set_unix_permissions(path,384)
		if FileAccess.file_exists(path+".bak"): FileAccess.set_unix_permissions(path+".bak",384)
	return error

func put(peer: int, token: String, uuid: String, revision: int, request: String, data: Dictionary) -> Dictionary:
	var key := key_for(token)
	if key == "" or not sessions.has(peer) or str(sessions[peer]["key"]) != key or str(sessions[peer]["uuid"]) != uuid: return {"ok":false,"error":"unauthorized","uuid":uuid}
	if request.is_empty() or request.length() > 96 or not valid_data(data,uuid): return {"ok":false,"error":"invalid_save","uuid":uuid}
	var record := read_record(key)
	if record.has("error"): return {"ok":false,"error":"corrupt","uuid":uuid}
	if str(record.get("request","")) == request:
		return {"ok":true,"kind":"saved","uuid":uuid,"revision":int(record["revision"]),"request":request}
	var actual_revision := int(record.get("revision",0))
	if revision != actual_revision: return {"ok":false,"error":"revision_conflict","uuid":uuid,"revision":actual_revision}
	if actual_revision >= MAX_REVISION: return {"ok":false,"error":"revision_limit","uuid":uuid}
	var clean: Dictionary = JSON.parse_string(JSON.stringify(data))
	for field in clean.keys():
		if String(field).begins_with("server_save_"): clean.erase(field)
	var next := {"schema":1,"uuid":uuid,"revision":actual_revision+1,"request":request,"updated_at":int(Time.get_unix_time_from_system()),"data":clean,"digest":JSON.stringify(clean).sha256_text()}
	var error := write_record(key,next)
	if error != OK: return {"ok":false,"error":"disk_error","uuid":uuid}
	return {"ok":true,"kind":"saved","uuid":uuid,"revision":actual_revision+1,"request":request}
