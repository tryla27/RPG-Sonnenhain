extends SceneTree

const LocalStore=preload("res://components/local_save_store.gd")
const AccountStore=preload("res://components/account_store.gd")

func snapshot(uuid:String,name:String,level:int,xp:int)->Dictionary:
	return {
		"player_uuid":uuid,
		"hero_name":name,
		"level":level,
		"xp":xp,
		"gold":level*100,
		"inventory":[],
		"character_created":true
	}

func wipe(path:String)->void:
	for suffix in ["",".bak",".prev",".tmp"]:
		var p:String=path+suffix
		if FileAccess.file_exists(p):DirAccess.remove_absolute(p)

func _initialize()->void:
	var root:="user://save-recovery-check"
	DirAccess.make_dir_recursive_absolute(root)
	var path:=root.path_join("slot1.json")
	wipe(path)

	assert(LocalStore.write(path,snapshot("recover-uuid","Alt",5,100))==OK)
	assert(LocalStore.write(path,snapshot("recover-uuid","Mitte",8,250))==OK)
	assert(LocalStore.write(path,snapshot("recover-uuid","Neu",12,600))==OK)
	var candidates:=LocalStore.recovery_candidates(path)
	assert(candidates.size()>=3)
	assert(str(candidates[0]["name"])=="Neu")
	assert(str(candidates[1]["name"])=="Mitte")
	assert(str(candidates[2]["name"])=="Alt")

	var broken:=FileAccess.open(path,FileAccess.WRITE)
	assert(broken!=null)
	broken.store_string("{kaputt")
	broken.close()
	var fallback:=LocalStore.read(path)
	assert(str(fallback.get("hero_name",""))=="Mitte")
	assert(int(fallback.get("level",0))==8)

	var chosen:Dictionary=candidates[2]["data"]
	assert(LocalStore.restore_to(path,chosen,"recovery_test")==OK)
	var restored:=LocalStore.read(path)
	assert(str(restored.get("hero_name",""))=="Alt")
	assert(int(restored.get("level",0))==5)
	assert(FileAccess.file_exists(path+".prev"))

	var account_dir:=root.path_join("accounts")
	DirAccess.make_dir_recursive_absolute(account_dir)
	var accounts:=AccountStore.new()
	assert(accounts.configure(account_dir)==OK)
	var name:="recoveraccount"
	var key:=accounts.account_key(name)
	for suffix in ["",".bak",".tmp"]:
		var ap:String=accounts.account_path(key)+suffix
		if FileAccess.file_exists(ap):DirAccess.remove_absolute(ap)
	var reg:=accounts.register(21,name,"recovery-password")
	assert(bool(reg.get("ok",false)))
	var token:=accounts.issue_remember_token(21)
	assert(bool(token.get("ok",false)))
	assert(FileAccess.file_exists(accounts.account_path(key)+".bak"))
	var account_file:=FileAccess.open(accounts.account_path(key),FileAccess.WRITE)
	assert(account_file!=null)
	account_file.store_string("{kaputt")
	account_file.close()
	accounts.release(21)
	var login:=accounts.login(22,name,"recovery-password")
	assert(bool(login.get("ok",false)))

	print("SAVE_RECOVERY_OK local generations, corrupt fallback, confirmed restore and account backup")
	quit()
