extends SceneTree

const Game = preload("res://main.gd")
const AccountStore = preload("res://components/account_store.gd")

func _initialize()->void:
	call_deferred("run")

func run()->void:
	var failures:=0
	var g=Game.new()
	g.account_name="Tester"
	g.account_password="abcdefgh"
	g.account_password_confirm="abcdefgh"
	g.account_pending_action=""
	if not g.account_form_valid(true):failures+=1
	g.account_password_confirm="abcdefgi"
	if g.account_form_valid(true):failures+=1
	g.account_password_confirm=""
	if g.account_form_valid(true):failures+=1
	if not g.account_form_valid(false):failures+=1

	var store=AccountStore.new()
	var dir:="user://account-registration-check"
	DirAccess.make_dir_recursive_absolute(dir)
	for filename in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute(dir.path_join(filename))
	if store.configure(dir)!=OK:failures+=1
	var created:Dictionary=store.register(1,"Tryla_Test","abcdefgh")
	if not bool(created.get("ok",false)):failures+=1
	var login_ok:Dictionary=store.login(2,"tryla_test","abcdefgh")
	if not bool(login_ok.get("ok",false)):failures+=1
	var login_bad:Dictionary=store.login(3,"tryla_test","abcdefgi")
	if bool(login_bad.get("ok",false)) or str(login_bad.get("error",""))!="invalid_login":failures+=1
	print("ACCOUNT_REGISTRATION_CHECK failures=",failures," · confirmation / exact password / case-normalized name")
	quit(1 if failures else 0)
