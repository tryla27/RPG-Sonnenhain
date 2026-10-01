extends SceneTree
func _initialize():
	var store=preload("res://components/local_save_store.gd")
	var path:String="user://save-recovery-test.json"
	var first:Dictionary={"player_uuid":"recovery-test","inventory":[],"gold":10}
	var second:Dictionary=first.duplicate(true);second["gold"]=20
	assert(store.write(path,first)==OK);assert(store.write(path,second)==OK)
	assert(store.read(path)["gold"]==20)
	var f:=FileAccess.open(path,FileAccess.WRITE);f.store_string("broken");f.close()
	assert(store.read(path)["gold"]==10)
	assert(store.write(path,second)==OK);assert(store.read(path)["gold"]==20)
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists(path+suffix):DirAccess.remove_absolute(path+suffix)
	print("LOCAL_SAVE_RECOVERY_CHECK passed primary, backup, corrupt-primary recovery, rewrite")
	quit()
