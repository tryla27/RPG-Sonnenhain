extends SceneTree
# Konto-Login darf einen lokal neueren, noch nicht hochgeladenen Spielstand
# (z. B. Fenna-Änderung kurz vor dem Schließen) nicht verwerfen.

const Store=preload("res://components/local_save_store.gd")
const TOKEN:="ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12"

class Game:
	extends "res://main.gd"
	var opens:=0
	var conflicts:=0
	func slot_save_path(index:int,testing:bool=false)->String:return "user://test_login_slot%d%s.json" % [index,"_t" if testing else ""]
	func request_server_save_open()->void:opens+=1
	func preserve_save_conflict(_data:Dictionary)->void:conflicts+=1
	func announce_multiplayer_context()->void:pass
	func ensure_live_multiplayer()->void:pass

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("LOGIN_KEEP_FAIL "+label)

func _initialize()->void:call_deferred("run")

func prepared()->Game:
	var g:=Game.new()
	for i in g.WORLD_EVENTS.size():
		g.event_states.append(0)
		g.event_progress.append(0)
	return g

func local_save(cloak:int,revision:int,dirty:bool)->void:
	var g:=prepared()
	g.player_uuid="hero-1"
	g.character_created=true
	g.hero_name="Testheld"
	g.cosmetic_cloak=cloak
	var data:Dictionary=g.capture_save_data()
	data["server_save_token"]=TOKEN
	data["server_save_revision"]=revision
	data["server_save_dirty"]=dirty
	Store.write(g.slot_save_path(1),data)
	g.free()

func login()->Game:
	var g:=prepared()
	g.account_characters=[{"slot":1,"uuid":"hero-1","token":TOKEN,"name":"Testheld"}]
	g.open_account_character(0)
	return g

func server_open(g:Game,revision:int,cloak:int)->void:
	var remote:Dictionary=g.capture_save_data()
	remote["cosmetic_cloak"]=cloak
	g.server_save.reply(g,{"ok":true,"uuid":"hero-1","kind":"open","revision":revision,"data":remote})

func run()->void:
	# 1. Lokale Änderung unbestätigt, Server gleich alt: lokal gewinnt und wird hochgeladen.
	local_save(2,5,true)
	var g:=login()
	check(g.opens==1,"Serverstand angefragt")
	check(g.cosmetic_cloak==2 and g.server_save.dirty and g.server_save.revision==5,"lokaler Stand vor der Antwort geladen")
	server_open(g,5,0)
	check(g.cosmetic_cloak==2,"Fenna-Umhang bleibt nach Login erhalten")
	check(g.server_save.dirty,"lokaler Stand wartet auf Upload")
	check(g.conflicts==0,"keine Konfliktkopie noetig")
	g.free()

	# 2. Server ist neuer (anderes Gerät): Server gewinnt, lokaler Stand wird Konfliktkopie.
	local_save(2,5,true)
	g=login()
	server_open(g,6,1)
	check(g.cosmetic_cloak==1,"neuerer Serverstand gewinnt")
	check(g.conflicts==1,"lokaler Stand als Konfliktkopie gesichert")
	g.free()

	# 3. Lokal nichts offen: Serverstand wird ganz normal geladen.
	local_save(2,5,false)
	g=login()
	check(not g.server_save.dirty and g.server_save.revision==0,"ohne offenen Stand wie bisher")
	server_open(g,5,3)
	check(g.cosmetic_cloak==3,"Serverstand geladen")
	g.free()

	for i in range(1,4):DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_login_slot%d.json" % i))
	if failures>0:
		print("LOGIN_KEEP_FAILED ",failures)
		quit(1)
		return
	print("LOGIN_KEEP_OK unsynced local saves survive account login")
	quit()
