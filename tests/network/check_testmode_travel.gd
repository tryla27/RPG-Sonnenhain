extends SceneTree
# Testmodus: Reisen über die Karte von überall muss der Server annehmen, sonst
# glaubt er den Spieler am alten Ort (Mobs dort, Golem-Altar „zu weit weg“).

class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_d:float)->void:pass

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("TESTMODE_TRAVEL_FAIL "+label)

func _initialize()->void:call_deferred("run")

func run()->void:
	var g:=Game.new()
	var far:=Vector2(6700,7600)
	var arrival:Vector2=g.waystone_arrival(11)
	check(not g.valid_network_teleport(far,arrival,{"hp":100.0},"world"),"normal: Reise nur von einem Wegstein")
	check(g.valid_network_teleport(far,arrival,{"hp":100.0,"test_mode":true},"world"),"Testmodus: Reise von überall zum Wegstein")
	check(not g.valid_network_teleport(far,Vector2(14900,8650),{"hp":100.0,"test_mode":true},"world"),"Testmodus: kein Sprung an beliebige Orte")
	check(g.valid_network_teleport(g.WAYSTONES[3],arrival,{"hp":100.0},"world"),"normal vom Wegstein weiter erlaubt")
	g.free()
	if failures>0:
		push_error("TESTMODE_TRAVEL_FAILED %d" % failures);quit(1);return
	print("TESTMODE_TRAVEL_OK")
	quit()
