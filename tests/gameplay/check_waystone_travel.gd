extends SceneTree
# Jeder aktivierte Wegstein öffnet die Reiseauswahl; Sonnenhain ist immer ein Ziel.

class Game:
	extends "res://main.gd"
	func save_game()->void:pass
	func play_sound(_name:String)->void:pass
	func region_available(_zone:int)->bool:return true

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("WAYSTONE_TRAVEL_FAIL "+label)

func _initialize()->void:call_deferred("run")

func click(g:Game,target:int)->void:
	g.click_map(g.WaystoneMap.point(g,target))

func run()->void:
	var g:=Game.new()
	g.character_created=true
	check(g.travel_slots().size()==g.WAYSTONES.size() and g.travel_slots()[-1]==0,"elf Wegsteine plus Sonnenhain")
	for slot in g.travel_slots().size():
		var r:Rect2=g.travel_slot_rect(slot)
		check(r.end.y<=560,"Kachel %d passt ins Fenster" % slot)
	# Neuer Stein: aktivieren, nicht wegteleportieren.
	g.player_pos=g.WAYSTONES[3]+Vector2(40,0)
	g.use_waystone()
	check(g.waystone_unlocked[3] and g.panel=="map" and g.player_pos.distance_to(g.WAYSTONES[3])<100,"neuer Wegstein wird aktiviert, ohne zu reisen")
	# Aktivierter Stein: Reiseauswahl.
	g.use_waystone()
	check(g.panel=="map" and g.travel_from==3,"aktivierter Wegstein oeffnet die Reiseauswahl")
	click(g,5)
	check(g.panel=="map" and g.player_pos.distance_to(g.WAYSTONES[3])<100,"nicht aktivierter Stein ist gesperrt")
	click(g,0)
	check(g.panel=="" and g.player_pos.distance_to(g.WAYSTONES[0])<260,"Reise ins Dorf von draussen")
	# Vom Dorf zurück zum Außenstein.
	g.player_pos=g.WAYSTONES[0]
	g.use_waystone()
	check(g.panel=="map" and g.travel_from==0,"Dorfstein oeffnet die Reiseauswahl")
	click(g,3)
	check(g.panel=="" and g.player_pos.distance_to(g.WAYSTONES[3])<260 and g.last_waystone==3,"Reise vom Dorf zum Aussenstein")
	g.free()
	if failures>0:
		print("WAYSTONE_TRAVEL_FAILED ",failures)
		quit(1)
		return
	print("WAYSTONE_TRAVEL_OK every activated waystone travels anywhere, village always reachable")
	quit()
