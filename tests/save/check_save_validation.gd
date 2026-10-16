extends SceneTree
# Server-Prüfung: viele geerntete Pflanzen und leichter Uhrversatz dürfen den
# Spielstand nicht ablehnen; abgelehnte Stände nennen die Regel.
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("SAVE_VALIDATION_FAIL "+label)
func _initialize()->void:call_deferred("run")
func run()->void:
	var S=preload("res://components/server_save_store.gd").new()
	var g:=Game.new();root.add_child(g)
	for i in 6:await process_frame
	g.character_created=true;g.hero_name="T";g.player_uuid="u1"
	var base:Dictionary=JSON.parse_string(JSON.stringify(g.capture_save_data()))
	check(S.valid_data(base,"u1"),"Grundstand gültig")
	var many:=base.duplicate(true)
	for i in 200:many["food_state"]["plants"]["%d,%d"%[i,i]]=Time.get_unix_time_from_system()+200
	check(S.valid_data(many,"u1"),"200 geerntete Pflanzen sind gültig")
	var skew:=base.duplicate(true)
	var f:Dictionary=preload("res://components/food_system.gd").by_name("Waldbeer-Kompott")
	var fs:Dictionary=skew["food_state"]
	fs["active_food_name"]="Waldbeer-Kompott";fs["meal_hp_regen"]=f["meal_hp_regen"]
	fs["meal_until"]=Time.get_unix_time_from_system()+360.0+60.0
	check(S.valid_data(skew,"u1"),"Uhrversatz von einer Minute bei Mahlzeit")
	var bad:=base.duplicate(true)
	bad["slots"]=[1,1,1]
	check(not S.valid_data(bad,"u1") and S.last_reject!="","abgelehnter Stand nennt die Regel")
	if failures>0:
		quit(1);return
	print("SAVE_VALIDATION_OK")
	quit()
