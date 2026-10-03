extends RefCounted
## Verified local snapshots with two recovery generations.
## Primary API stays compatible with the old slot-based save path.

static func parse(text:String)->Variant:
	var parser:=JSON.new()
	return parser.data if parser.parse(text)==OK else null

static func valid_snapshot(value:Variant)->bool:
	return value is Dictionary and str(value.get("player_uuid",""))!="" and value.get("inventory") is Array

static func read_candidate(path:String)->Dictionary:
	if not FileAccess.file_exists(path):return {}
	var parsed:Variant=parse(FileAccess.get_file_as_string(path))
	return parsed if valid_snapshot(parsed) else {}

static func read(path:String) -> Dictionary:
	for candidate in [path,path+".bak",path+".prev"]:
		var data:=read_candidate(candidate)
		if not data.is_empty():return data
	return {}

static func recovery_candidates(path:String)->Array:
	var out:Array=[]
	for row in [
		{"source":"local","path":path},
		{"source":"backup","path":path+".bak"},
		{"source":"previous","path":path+".prev"}
	]:
		var data:=read_candidate(str(row["path"]))
		if data.is_empty():continue
		out.append({
			"source":str(row["source"]),
			"path":str(row["path"]),
			"data":data,
			"uuid":str(data.get("player_uuid","")),
			"name":str(data.get("hero_name","Held")),
			"level":maxi(1,int(data.get("level",1))),
			"xp":maxi(0,int(data.get("xp",0))),
			"gold":maxi(0,int(data.get("gold",0))),
			"saved_at":maxi(0,int(data.get("saved_at",0))),
			"generation":maxi(0,int(data.get("save_generation",0)))
		})
	return out

static func prepare_snapshot(data:Dictionary,origin:String="local")->Dictionary:
	var out:Dictionary=data.duplicate(true)
	out["saved_at"]=int(Time.get_unix_time_from_system())
	out["save_generation"]=maxi(0,int(out.get("save_generation",0)))+1
	out["save_origin"]=origin
	return out

static func write_exact(path:String,data:Dictionary) -> Error:
	var temp:String=path+".tmp"
	var file:=FileAccess.open(temp,FileAccess.WRITE)
	if file==null:return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data));file.flush()
	var error:Error=file.get_error();file.close()
	if error!=OK:return error
	var parsed:Variant=JSON.parse_string(FileAccess.get_file_as_string(temp))
	if not valid_snapshot(parsed) or JSON.stringify(parsed)!=JSON.stringify(JSON.parse_string(JSON.stringify(data))):
		return ERR_FILE_CORRUPT
	return DirAccess.rename_absolute(temp,path)

static func preserve_previous(path:String)->Error:
	if not FileAccess.file_exists(path):return OK
	var current:=read_candidate(path)
	if current.is_empty():return OK
	return DirAccess.copy_absolute(path,path+".prev")

static func write(path:String,data:Dictionary) -> Error:
	var next:=prepare_snapshot(data,"local")
	var temp:String=path+".tmp"
	var file:=FileAccess.open(temp,FileAccess.WRITE)
	if file==null:return FileAccess.get_open_error()
	file.store_string(JSON.stringify(next));file.flush()
	var error:Error=file.get_error();file.close()
	if error!=OK:return error
	var parsed:Variant=JSON.parse_string(FileAccess.get_file_as_string(temp))
	if not valid_snapshot(parsed) or JSON.stringify(parsed)!=JSON.stringify(JSON.parse_string(JSON.stringify(next))):
		return ERR_FILE_CORRUPT
	if FileAccess.file_exists(path):
		var previous:Variant=read_candidate(path)
		if not previous.is_empty():
			if FileAccess.file_exists(path+".bak"):
				var bak:=read_candidate(path+".bak")
				if not bak.is_empty():
					error=DirAccess.copy_absolute(path+".bak",path+".prev")
					if error!=OK:return error
			error=DirAccess.copy_absolute(path,path+".bak")
			if error!=OK:return error
	return DirAccess.rename_absolute(temp,path)

static func restore_to(path:String,data:Dictionary,origin:String)->Error:
	if not valid_snapshot(data):return ERR_FILE_CORRUPT
	var error:=preserve_previous(path)
	if error!=OK:return error
	var restored:=prepare_snapshot(data,origin)
	return write_exact(path,restored)
