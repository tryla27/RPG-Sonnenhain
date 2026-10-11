extends SceneTree
const Boss=preload("res://components/golem_boss.gd")
class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_d:float)->void:pass
	func play_world_sound(_n:String,_p:Vector2)->void:pass
class BlockedBoss extends "res://components/golem_boss.gd":
	var searches:=0
	func find_path(_g,_from:Vector2,_to:Vector2,_body:float)->Array:
		searches+=1;last_path_complete=false;return []
	func _line_open_cached(_g,_info:Dictionary,_pos:Vector2,_target:Vector2,_body:float,_delta:float)->bool:return false
	func cell_open(_g,_pos:Vector2,_body:float)->bool:return false
func _initialize()->void:
	var g:=Game.new();var b:=BlockedBoss.new()
	var enemy={"type":27,"pos":Boss.ALTAR};var info:Dictionary={}
	for i in 60:b.walk_towards(g,enemy,info,Boss.ALTAR+Vector2(500,0),1.0/60)
	var ok:=b.searches==1
	b.walk_towards(g,enemy,info,Boss.ALTAR+Vector2(500,300),1.0/60)
	ok=ok and b.searches==2
	b.warm_nav(g)
	ok=ok and b.nav_warm_index<=8
	print("GOLEM_RETRY_BUDGET searches_first_second=",b.searches-1," warm_cells=",b.nav_warm_index," passed=",ok)
	g.free();quit(0 if ok else 1)
