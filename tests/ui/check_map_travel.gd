extends SceneTree
# Reisen über die Karte (M): fern vom Wegstein kommt ein Hinweis, in der Nähe
# reist ein Klick direkt. Dazu: F11 schaltet Vollbild.

const WaystoneMap=preload("res://components/waystone_map.gd")
const DisplayMode=preload("res://components/display_mode.gd")

class Game extends "res://main.gd":
	var last_message:=""
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
	func play_sound(_name:String)->void:pass
	func mark_network_teleport()->void:pass
	func message(value:String)->void:last_message=value

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("MAP_TRAVEL_FAIL "+label)

func _initialize()->void:call_deferred("run")

func run()->void:
	var g:=Game.new()
	g.reset_class_skills()
	g.character_created=true
	g.level=10
	g.waystone_unlocked[1]=true
	var target:Vector2=WaystoneMap.point(g,1)

	# Fern vom Wegstein: Karte mit M, Klick auf ein Ziel zeigt den Hinweis.
	var far:=g.WAYSTONES[0]+Vector2(900,900)
	g.player_pos=far
	g.panel=""
	g.toggle_panel("map")
	check(not WaystoneMap.travel_ready(g),"fern: keine Reisekarte")
	g.click_map(target)
	check(g.player_pos==far,"fern: keine Reise")
	check(g.last_message=="Gehe zu einem Wegstein, um zu teleportieren.","fern: Hinweis erscheint (%s)" % g.last_message)

	# Am Spawnstein: dieselbe Karte mit M reist per Klick.
	g.player_pos=g.WAYSTONES[0]+Vector2(40,0)
	g.panel=""
	g.toggle_panel("map")
	check(WaystoneMap.travel_ready(g),"nah: Reisekarte")
	g.click_map(target)
	check(g.player_pos.distance_to(g.WAYSTONES[1])<260.0,"nah: Klick reist zum Wegstein")
	check(g.panel=="","nah: Karte schließt nach der Reise")

	# Nicht aktivierter Wegstein bleibt gesperrt, auch in der Nähe.
	g.player_pos=g.WAYSTONES[0]+Vector2(40,0)
	g.waystone_unlocked[2]=false
	g.toggle_panel("map")
	g.click_map(WaystoneMap.point(g,2))
	check(g.player_pos.distance_to(g.WAYSTONES[0])<100.0,"nicht aktiviert: keine Reise")

	# F11 schaltet Vollbild (Taste wird erkannt, nicht bei gehaltener Taste).
	var key:=InputEventKey.new()
	key.keycode=KEY_F11
	key.pressed=true
	check(DisplayMode.is_toggle_key(key),"F11 erkannt")
	key.echo=true
	check(not DisplayMode.is_toggle_key(key),"gehaltene F11 schaltet nicht mehrfach")

	g.free()
	if failures>0:
		print("MAP_TRAVEL_FAILED ",failures)
		quit(1)
		return
	print("MAP_TRAVEL_OK far shows hint, near travels by click, locked stays locked, F11 detected")
	quit()
