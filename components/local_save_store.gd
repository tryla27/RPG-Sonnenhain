extends RefCounted
## Write verified snapshots before replacing the last readable generation.
static func parse(text:String)->Variant:
	var parser:=JSON.new()
	return parser.data if parser.parse(text)==OK else null
static func read(path:String) -> Dictionary:
	for candidate in [path,path+".bak"]:
		if not FileAccess.file_exists(candidate):continue
		var parsed:Variant=parse(FileAccess.get_file_as_string(candidate))
		if parsed is Dictionary and parsed.get("player_uuid","")!="" and parsed.get("inventory") is Array:return parsed
	return {}
static func write(path:String,data:Dictionary) -> Error:
	var temp:String=path+".tmp"
	var file:=FileAccess.open(temp,FileAccess.WRITE)
	if file==null:return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data));file.flush()
	var error:Error=file.get_error();file.close()
	if error!=OK:return error
	var parsed:Variant=JSON.parse_string(FileAccess.get_file_as_string(temp))
	if not parsed is Dictionary or JSON.stringify(parsed)!=JSON.stringify(JSON.parse_string(JSON.stringify(data))):return ERR_FILE_CORRUPT
	if FileAccess.file_exists(path):
		var previous:Variant=parse(FileAccess.get_file_as_string(path))
		if previous is Dictionary:
			error=DirAccess.copy_absolute(path,path+".bak")
			if error!=OK:return error
	return DirAccess.rename_absolute(temp,path)
