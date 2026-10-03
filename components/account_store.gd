extends RefCounted
## Server-side Sonnenhain account store. Accounts authenticate by name + password.
## Character save credentials stay server-side at rest and are only returned after login over WSS.

const HASH_ROUNDS := 12000
const MAX_CHARACTERS := 3
const REMEMBER_TOKEN_DAYS := 30
var directory := ""
var sessions: Dictionary = {}

func configure(path:String)->Error:
	directory=path
	var result:=DirAccess.make_dir_recursive_absolute(directory)
	if result==OK and OS.has_feature("linux"):FileAccess.set_unix_permissions(directory,448)
	return result

func normalize_name(raw:String)->String:
	var name:=raw.strip_edges().to_lower()
	if name.length()<3 or name.length()>24:return ""
	for i in name.length():
		var ch:=name.substr(i,1)
		if not ("abcdefghijklmnopqrstuvwxyz0123456789äöüß_-".contains(ch)):return ""
	return name

func account_key(name:String)->String:
	var normalized:=normalize_name(name)
	return normalized.sha256_text() if normalized!="" else ""

func account_path(key:String)->String:
	return directory.path_join(key+".json")

func derive_password(password:String,salt:String)->String:
	if password.length()<8 or password.length()>72:return ""
	var value:=(salt+":"+password).sha256_text()
	for i in HASH_ROUNDS:
		value=(value+":"+salt).sha256_text()
	return value

func read_account_file(path:String)->Dictionary:
	if not FileAccess.file_exists(path):return {}
	var file:=FileAccess.open(path,FileAccess.READ)
	if file==null or file.get_length()>131072:return {}
	var parsed:Variant=JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:return {}
	var data:Dictionary=parsed
	if int(data.get("schema",0))!=1:return {}
	return data

func read_account(key:String)->Dictionary:
	if key=="" or directory=="":return {}
	var path:=account_path(key)
	var primary:=read_account_file(path)
	if not primary.is_empty():return primary
	return read_account_file(path+".bak")

func write_account(key:String,data:Dictionary)->Error:
	var path:=account_path(key)
	var temp:=path+".tmp"
	var file:=FileAccess.open(temp,FileAccess.WRITE)
	if file==null:return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data))
	file.flush()
	var err:=file.get_error()
	file.close()
	if err!=OK:return err
	var verify:=read_account_file(temp)
	if verify.is_empty():return ERR_FILE_CORRUPT
	if FileAccess.file_exists(path):
		var current:=read_account_file(path)
		if not current.is_empty():
			err=DirAccess.copy_absolute(path,path+".bak")
			if err!=OK:return err
	err=DirAccess.rename_absolute(temp,path)
	if err==OK and OS.has_feature("linux"):
		FileAccess.set_unix_permissions(path,384)
		if FileAccess.file_exists(path+".bak"):FileAccess.set_unix_permissions(path+".bak",384)
	return err

func public_characters(account:Dictionary)->Array:
	var out:Array=[]
	var chars:Variant=account.get("characters",[])
	if not chars is Array:return out
	for raw in chars:
		if not raw is Dictionary:continue
		var c:Dictionary=raw
		out.append({
			"slot":clampi(int(c.get("slot",1)),1,3),
			"uuid":str(c.get("uuid","")),
			"token":str(c.get("token","")),
			"name":str(c.get("name","Held")).substr(0,32),
			"level":maxi(1,int(c.get("level",1))),
			"class_id":clampi(int(c.get("class_id",0)),0,2)
		})
	return out

func register(peer:int,name:String,password:String)->Dictionary:
	if peer<=0 or directory=="":return {"ok":false,"error":"unavailable"}
	var normalized:=normalize_name(name)
	if normalized=="":return {"ok":false,"error":"invalid_name"}
	if password.length()<8 or password.length()>72:return {"ok":false,"error":"weak_password"}
	var key:=account_key(normalized)
	if not read_account(key).is_empty():return {"ok":false,"error":"name_taken"}
	var salt:=Crypto.new().generate_random_bytes(16).hex_encode()
	var hash:=derive_password(password,salt)
	var account:Dictionary={
		"schema":1,
		"name":normalized,
		"display_name":name.strip_edges().substr(0,24),
		"salt":salt,
		"password_hash":hash,
		"created_at":int(Time.get_unix_time_from_system()),
		"updated_at":int(Time.get_unix_time_from_system()),
		"characters":[]
	}
	var err:=write_account(key,account)
	if err!=OK:return {"ok":false,"error":"disk_error"}
	sessions[peer]={"key":key,"name":normalized}
	return {"ok":true,"kind":"registered","name":account["display_name"],"characters":[]}

func issue_remember_token(peer:int)->Dictionary:
	if not sessions.has(peer):return {"ok":false,"error":"not_logged_in"}
	var key:=str(sessions[peer].get("key",""))
	var account:=read_account(key)
	if account.is_empty():return {"ok":false,"error":"account_missing"}
	var raw:=Crypto.new().generate_random_bytes(32).hex_encode()
	account["remember_token_hash"]=raw.sha256_text()
	account["remember_token_expires"]=int(Time.get_unix_time_from_system())+REMEMBER_TOKEN_DAYS*86400
	account["updated_at"]=int(Time.get_unix_time_from_system())
	if write_account(key,account)!=OK:return {"ok":false,"error":"disk_error"}
	return {"ok":true,"remember_token":raw,"remember_expires":int(account["remember_token_expires"])}

func login_with_token(peer:int,name:String,token:String)->Dictionary:
	if peer<=0 or directory=="":return {"ok":false,"error":"unavailable"}
	var normalized:=normalize_name(name)
	if normalized=="" or token.length()!=64 or not token.is_valid_hex_number(false):return {"ok":false,"error":"invalid_login"}
	var key:=account_key(normalized)
	var account:=read_account(key)
	if account.is_empty():return {"ok":false,"error":"invalid_login"}
	if int(account.get("remember_token_expires",0))<int(Time.get_unix_time_from_system()):return {"ok":false,"error":"remember_expired"}
	if token.sha256_text()!=str(account.get("remember_token_hash","")):return {"ok":false,"error":"invalid_login"}
	sessions[peer]={"key":key,"name":normalized}
	return {"ok":true,"kind":"login","name":str(account.get("display_name",name)),"characters":public_characters(account)}

func login(peer:int,name:String,password:String)->Dictionary:
	if peer<=0 or directory=="":return {"ok":false,"error":"unavailable"}
	var normalized:=normalize_name(name)
	if normalized=="":return {"ok":false,"error":"invalid_login"}
	var key:=account_key(normalized)
	var account:=read_account(key)
	if account.is_empty():return {"ok":false,"error":"invalid_login"}
	var expected:=str(account.get("password_hash",""))
	var salt:=str(account.get("salt",""))
	var actual:=derive_password(password,salt)
	if actual=="" or actual!=expected:return {"ok":false,"error":"invalid_login"}
	sessions[peer]={"key":key,"name":normalized}
	return {"ok":true,"kind":"login","name":str(account.get("display_name",name)),"characters":public_characters(account)}

func claim_character(peer:int,slot:int,uuid:String,token:String,meta:Dictionary)->Dictionary:
	if not sessions.has(peer):return {"ok":false,"error":"not_logged_in"}
	slot=clampi(slot,1,3)
	if uuid.is_empty() or uuid.length()>64:return {"ok":false,"error":"invalid_character"}
	if token.length()!=64 or not token.is_valid_hex_number(false):return {"ok":false,"error":"invalid_character"}
	var key:=str(sessions[peer]["key"])
	var account:=read_account(key)
	if account.is_empty():return {"ok":false,"error":"account_missing"}
	var chars:Array=account.get("characters",[])
	var found:=-1
	for i in chars.size():
		var c:Variant=chars[i]
		if c is Dictionary and str(c.get("uuid",""))==uuid:
			found=i
			break
	if found<0:
		for i in chars.size():
			var c:Variant=chars[i]
			if c is Dictionary and int(c.get("slot",0))==slot:
				return {"ok":false,"error":"slot_occupied"}
		if chars.size()>=MAX_CHARACTERS:return {"ok":false,"error":"character_limit"}
		chars.append({})
		found=chars.size()-1
	chars[found]={
		"slot":slot,
		"uuid":uuid,
		"token":token,
		"name":str(meta.get("name","Held")).substr(0,32),
		"level":maxi(1,int(meta.get("level",1))),
		"class_id":clampi(int(meta.get("class_id",0)),0,2),
		"updated_at":int(Time.get_unix_time_from_system())
	}
	account["characters"]=chars
	account["updated_at"]=int(Time.get_unix_time_from_system())
	var err:=write_account(key,account)
	if err!=OK:return {"ok":false,"error":"disk_error"}
	return {"ok":true,"kind":"claimed","characters":public_characters(account)}

func sync_character_save(peer:int,uuid:String,token:String,data:Dictionary,revision:int)->bool:
	if not sessions.has(peer):return false
	var key:=str(sessions[peer].get("key",""))
	var account:=read_account(key)
	if account.is_empty():return false
	var chars:Variant=account.get("characters",[])
	if not chars is Array:return false
	var changed:=false
	for i in chars.size():
		if not chars[i] is Dictionary:continue
		var c:Dictionary=chars[i]
		if str(c.get("uuid",""))!=uuid or str(c.get("token",""))!=token:continue
		var next_name:=str(data.get("hero_name",c.get("name","Held"))).substr(0,32)
		var next_level:=clampi(int(data.get("level",c.get("level",1))),1,99)
		var next_class:=clampi(int(data.get("class_id",c.get("class_id",0))),0,2)
		var next_revision:=maxi(0,revision)
		if str(c.get("name",""))!=next_name or int(c.get("level",1))!=next_level or int(c.get("class_id",0))!=next_class or int(c.get("revision",-1))!=next_revision:
			c["name"]=next_name
			c["level"]=next_level
			c["class_id"]=next_class
			c["revision"]=next_revision
			c["updated_at"]=int(Time.get_unix_time_from_system())
			chars[i]=c
			changed=true
		break
	if not changed:return true
	account["characters"]=chars
	account["updated_at"]=int(Time.get_unix_time_from_system())
	return write_account(key,account)==OK

func release(peer:int)->void:
	sessions.erase(peer)
