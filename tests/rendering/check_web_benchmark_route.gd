extends SceneTree
## Browser und native Messung müssen dieselben 240 Bilder abfahren. Ein
## Bericht darf erst nach der Zeichnung des letzten Bildes abgeschlossen sein.
class Benchmark extends "res://components/web_benchmark.gd":
	var sent:=false
	func send(_g)->void:sent=true
class Renderer extends RefCounted:
	var active:=true
	var created_instances:=0
	var models:Dictionary={}
	var signature:=""
	func metrics_snapshot()->Dictionary:return {"page_updates":0,"collections":0,"instances_created":0}
class Game extends RefCounted:
	var enemies:Array=[]
	var performance_draw_us:=1000
	var world_obstacles_3d:=Renderer.new()
	var static_chunks:Dictionary={}
	var panel:=""
	var spawn_timer:=0.0
	var rescue_state:=0
	var player_pos:=Vector2.ZERO
	var camera_pos:=Vector2.ZERO
	var camera_smooth:=Vector2.ZERO
	var VIEW:=Vector2(1152,648)
var failures:=0
func check(ok:bool,label:String)->void:
	if ok:return
	failures+=1;push_error("WEB_BENCHMARK_ROUTE_FAIL "+label)
func _initialize()->void:
	var benchmark:=Benchmark.new();var game:=Game.new();benchmark.active=true
	var positions:Array=[];var calls:=0
	while not benchmark.finished and calls<1000:
		benchmark.step(game);calls+=1
		if benchmark.route==1 and not benchmark.finished:positions.append(game.player_pos)
	check(benchmark.sent and benchmark.results.size()==4,"alle Routen abgeschlossen und Bericht gesendet")
	check(calls==4*240+1,"240 gezeichnete Bilder pro Route plus abschließende Messung")
	check(positions.size()==240,"Wiesenroute wird nicht beim Rückweg abgeschnitten")
	if positions.size()==240:
		var origin:Vector2=benchmark.ROUTES[1][1]
		check(positions[0]==origin and positions[59]==origin,"60 Bilder Stillstand")
		check(positions[150]==origin+Vector2(450,0),"vollständiger Hinweg")
		check(positions[239]==origin+Vector2(5,0),"Rückweg entspricht dem letzten nativen Messbild")
	for result in benchmark.results:
		check(result["frames"]==210,"nur erste 30 der 240 Bilder verworfen")
		check(result["enemies_max"]==0,"Landschaftsmodus weist keine Gegner aus")
	var ai:=Benchmark.new();var fight:=Game.new();ai.active=true;ai.variant="ai"
	fight.enemies=[{},{}]
	for frame in 241:ai.step(fight)
	check(fight.enemies.size()==2 and fight.rescue_state==0,"Kampfmodus lässt Gegner und Ereignis aktiv")
	check(ai.results[0]["enemies_min"]==2 and ai.results[0]["enemies_mean"]==2.0,"Gegnerzahl für belastbare Kampfvergleiche im Bericht")
	if failures>0:quit(1);return
	print("WEB_BENCHMARK_ROUTE_OK vollständige Route, 210 abgeschlossene Bilder, Gegnerzahl")
	quit()
