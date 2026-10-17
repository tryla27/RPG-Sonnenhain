extends SceneTree
## Gebietsbanner: erscheint beim ersten Betreten einmal, die Entdeckungsmeldung
## bleibt sichtbar, ein zweites Betreten zeigt nur die kurze Meldung.
class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
	func spawn_enemy()->void:pass
var failures:=0
func check(ok:bool,message:String)->void:
	if not ok:failures+=1;push_error(message)
func _initialize()->void:call_deferred("run")
func run()->void:
	var g:=Game.new();root.add_child(g)
	await process_frame
	g.character_created=true;g.panel="";g.hp=100
	g.player_pos=Vector2(900,900);g.previous_region=0
	g.update_player(1.0/60.0)
	g.player_pos=Vector2(3650,2650)
	g.update_player(1.0/60.0)
	check(g.discovered_regions[1],"Blütenwiesen entdeckt")
	check(g.region_banner.active() and g.region_banner.region==1,"Banner beim ersten Betreten")
	check(g.notice.begins_with("Gebiet entdeckt"),"Entdeckungsmeldung bleibt sichtbar: "+g.notice)
	check(g.RegionBanner.whisper(1)!="","Banner trägt den Erkundungsspruch")
	for i in 400:g.region_banner.tick(1.0/60.0)
	check(not g.region_banner.active(),"Banner blendet aus")
	g.player_pos=Vector2(900,900);g.update_player(1.0/60.0)
	g.player_pos=Vector2(3650,2650);g.update_player(1.0/60.0)
	check(not g.region_banner.active(),"Kein zweites Banner")
	check(g.notice.begins_with("Neues Gebiet"),"Kurzmeldung beim Wiederbetreten")
	g.free()
	if failures>0:quit(1);return
	print("REGION_BANNER_OK")
	quit()
