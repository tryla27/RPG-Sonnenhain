extends SceneTree
const Cache=preload("res://components/minimap_ground_cache.gd")
class Fog extends RefCounted:
	var visible:=true
	func explored_world(_point:Vector2)->bool:return visible
class Game extends RefCounted:
	var world_fog:=Fog.new()
	var queries:=0
	func visual_region_at(_point:Vector2)->int:queries+=1;return 1
	func distance_to_trail(_point:Vector2)->float:queries+=1;return 50.0
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:failures+=1;push_error(message)
func _initialize()->void:
	var cache:=Cache.new();var game:=Game.new()
	var first:=cache.visible_color(game,Vector2(101,102))
	check(first==Color("d2ba86") and game.queries==2,"Erste Geländefarbe verwendet tatsächliche Wege")
	for i in 120:cache.visible_color(game,Vector2(102,103))
	check(game.queries==2 and cache.evaluations==1,"Stillstand wiederholt keine Geometrieabfragen")
	game.world_fog.visible=false
	check(cache.visible_color(game,Vector2(101,102))==Color("0b1218"),"Nebel verdeckt bereits gecachtes Gelände sofort")
	game.world_fog.visible=true
	check(cache.visible_color(game,Vector2(101,102))==first,"Neues Aufdecken erscheint sofort")
	cache.color_at(game,Vector2(160,100));check(cache.evaluations==2,"Neue Weltzelle wird berechnet")
	for i in Cache.LIMIT+10:cache.color_at(game,Vector2(i*64,0))
	check(cache.colors.size()<=Cache.LIMIT,"Geländecache bleibt begrenzt")
	if failures>0:quit(1);return
	print("MINIMAP_GROUND_CACHE_OK feste Abfragen, sofortiger Nebel, begrenzter Speicher")
	quit()
