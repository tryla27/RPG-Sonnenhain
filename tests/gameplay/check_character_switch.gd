extends SceneTree
# Charakterwechsel ohne Neustart: Vom vorigen Charakter darf nichts im neuen
# landen (Quests, Bosse, Kartennebel, Gruppe, Truhen-Timer). Ein Wiederverbinden
# desselben Charakters mischt dagegen weiter (Fortschritt geht nicht verloren).

const TOKEN_A:="aa12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12"
const TOKEN_B:="bb12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12"

class Game:
	extends "res://main.gd"
	func slot_save_path(index:int,testing:bool=false)->String:return "user://test_switch_slot%d%s.json" % [index,"_t" if testing else ""]
	func request_server_save_open()->void:pass
	func preserve_save_conflict(_data:Dictionary)->void:pass
	func announce_multiplayer_context()->void:pass
	func ensure_live_multiplayer()->void:pass

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("CHARACTER_SWITCH_FAIL "+label)

func _initialize()->void:call_deferred("run")

func prepared()->Game:
	var g:=Game.new()
	g.reset_class_skills()
	for i in g.WORLD_EVENTS.size():
		g.event_states.append(0)
		g.event_progress.append(0)
	for i in g.QUESTS.size():g.quests.append({"state":0,"progress":0})
	for i in g.BORIN_QUESTS.size():g.borin_quests.append({"state":0,"progress":0})
	g.world_fog.configure(g.WORLD)
	return g

func seen_cells(g:Game)->int:
	var count:=0
	for b in g.world_fog.bytes:
		if b!=0:count+=1
	return count

## Serverstand von B: frischer Charakter mit einer eigenen, kleinen Quest.
func b_server_data(g:Game)->Dictionary:
	var fresh:=prepared()
	fresh.player_uuid="hero-b"
	fresh.character_created=true
	fresh.hero_name="Bea"
	fresh.quests[2]={"state":1,"progress":1}
	var data:Dictionary=fresh.capture_save_data()
	fresh.free()
	return data

func run()->void:
	var g:=prepared()
	# Charakter A spielt eine Weile.
	g.player_uuid="hero-a"
	g.character_created=true
	g.hero_name="Arno"
	g.quests[0]={"state":3,"progress":8}
	g.quests[1]={"state":2,"progress":5}
	g.bosses_defeated[0]=true
	g.event_states[0]=3
	g.world_fog.reveal(Vector2(4000,3000),900.0)
	g.party_state={"members":[{"uuid":"x","pos":[100,100],"context":"world"}]}
	g.chest_respawn_until[0]=Time.get_unix_time_from_system()+500
	g.pip_loan_level=7
	check(seen_cells(g)>0,"A hat Karte aufgedeckt")

	# Wechsel zu B, ohne Neustart.
	g.account_characters=[{"slot":1,"uuid":"hero-a","token":TOKEN_A,"name":"Arno"},{"slot":2,"uuid":"hero-b","token":TOKEN_B,"name":"Bea"}]
	g.open_account_character(1)
	check(g.player_uuid=="hero-b","neue Charakter-ID gesetzt")
	check(not g.character_created,"vor der Serverantwort kein aktiver Charakter")
	check(int(g.quests[0]["state"])==0 and int(g.quests[1]["state"])==0,"Quests von A gelöscht")
	check(not g.bosses_defeated[0] and int(g.event_states[0])==0,"Bosse und Ereignisse von A gelöscht")
	check(seen_cells(g)==0,"Kartennebel von A gelöscht")
	check(g.party_state.is_empty(),"Gruppe von A gelöscht")
	check(float(g.chest_respawn_until[0])==0.0 and g.pip_loan_level==0,"Timer und Pip-Leihe von A gelöscht")

	# Serverantwort für B: genau Bs Stand, nichts von A.
	g.server_save.reply(g,{"ok":true,"uuid":"hero-b","kind":"open","revision":3,"data":b_server_data(g)})
	check(g.character_created and g.hero_name=="Bea","B geladen")
	check(int(g.quests[0]["state"])==0 and int(g.quests[1]["state"])==0,"keine Quests von A in B")
	check(int(g.quests[2]["state"])==1,"Bs eigene Quest da")
	check(not g.bosses_defeated[0],"kein Boss von A in B")
	check(seen_cells(g)==0,"kein Kartennebel von A in B")

	# Wiederverbinden desselben Charakters mischt weiter: höherer Fortschritt bleibt.
	g.quests[2]={"state":2,"progress":4}
	var older:Dictionary=b_server_data(g)
	g.server_save.reply(g,{"ok":true,"uuid":"hero-b","kind":"open","revision":3,"data":older})
	check(int(g.quests[2]["state"])==2,"Wiederverbinden verliert keinen Fortschritt")

	# Spielstand ohne Nebel deckt nichts vom Vorgänger auf.
	g.world_fog.reveal(Vector2(2000,2000),900.0)
	g.world_fog.restore([],g.WORLD)
	check(seen_cells(g)==0,"Laden ohne Nebel löscht den alten Nebel")

	g.free()
	for i in range(1,4):DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_switch_slot%d.json" % i))
	if failures>0:
		print("CHARACTER_SWITCH_FAILED ",failures)
		quit(1)
		return
	print("CHARACTER_SWITCH_OK nothing from the previous character leaks into the next; reconnect still merges")
	quit()
