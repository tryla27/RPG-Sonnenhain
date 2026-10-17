extends SceneTree
## Verborgene Funde: erreichbar, einmalig je Charakter, gespeichert und vom
## Server akzeptiert.
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func _process(_delta:float)->void:pass
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;push_error("HIDDEN_FINDS_FAIL "+label)
func _initialize()->void:call_deferred("run")
func run()->void:
	var g:=Game.new();root.add_child(g)
	for i in 6:await process_frame
	g.character_created=true;g.hero_name="T";g.player_uuid="u1"
	var Finds=g.HiddenFinds
	for i in Finds.FINDS.size():
		var find:Dictionary=Finds.FINDS[i]
		var a:Vector2=find["from"];var b:Vector2=find["pos"]
		check(g.region_at(b)==int(find["region"]),"Gebiet passt: %d"%i)
		for s in 41:
			var p:=a.lerp(b,s/40.0)
			check(not g.terrain_blocked(p,18) and not g.blocked_by_region_wall(p),"Pfad begehbar: %d bei %s"%[i,p])
		check(g.distance_to_trail(b)>200,"abseits des Hauptwegs: %d"%i)
	var gold_before:int=g.gold;var xp_before:int=g.xp;var level_before:int=g.level
	g.player_pos=Finds.FINDS[0]["pos"]+Vector2(10,0)
	check(g.hidden_finds.nearby(g.player_pos)==0,"in Reichweite")
	check(g.interaction_prompt({}).contains("untersuchen"),"Hinweis wird angezeigt")
	g.claim_hidden_find(0)
	check(g.gold==gold_before+int(Finds.FINDS[0]["gold"]),"Gold erhalten")
	check(g.xp!=xp_before or g.level!=level_before,"Erfahrung erhalten")
	var gold_after:int=g.gold
	g.claim_hidden_find(0)
	check(g.gold==gold_after,"nur einmal")
	var data:Dictionary=JSON.parse_string(JSON.stringify(g.capture_save_data()))
	check(data.get("hidden_finds",[])==[true,false,false,false],"gespeichert")
	var S=preload("res://components/server_save_store.gd").new()
	check(S.valid_data(data,"u1"),"Server akzeptiert den Stand")
	var bad:=data.duplicate(true);bad["hidden_finds"]=["x"]
	check(not S.valid_data(bad,"u1"),"ungültige Werte abgelehnt")
	g.hidden_finds.reset();g.apply_save_data(data)
	check(g.hidden_finds.found[0] and not g.hidden_finds.found[1],"geladen")
	var old:=data.duplicate(true);old.erase("hidden_finds")
	g.apply_save_data(old)
	check(not g.hidden_finds.found[0],"alte Stände ohne Feld: nichts gefunden")
	g.free()
	if failures>0:quit(1);return
	print("HIDDEN_FINDS_OK")
	quit()
