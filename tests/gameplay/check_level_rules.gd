extends SceneTree
## Gemeinsame Levelregel: bisherige XP-Kurve bis Stufe 100, danach je Aufstieg
## das Vierfache, Höchststufe 118. Große XP-Werte überstehen Speichern, Laden
## und die Serverprüfung exakt; Testmodus und Reparatur nutzen dieselbe Grenze.
const Rules=preload("res://components/level_rules.gd")
const Store=preload("res://components/server_save_store.gd")
class Game extends "res://main.gd":
	func save_game()->void:pass
	func announce_multiplayer_context()->void:pass
	func join_live_multiplayer()->void:pass
	func ensure_live_multiplayer()->void:pass
	func _process(_delta:float)->void:pass
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:failures+=1;push_error("LEVEL_RULES_FAIL "+label)
func old_curve(level:int)->int:return 120+(level-1)*85+(level-1)*(level-1)*10
func _initialize()->void:call_deferred("run")
func run()->void:
	# Kurve
	for level in [1,2,39,40,41,98,99]:check(Rules.xp_required(level)==old_curve(level),"bisherige Kurve bei %d"%level)
	check(Rules.xp_required(99)==104490,"99 → 100 kostet 104.490")
	check(Rules.xp_required(100)==417960 and Rules.xp_required(100)==4*Rules.xp_required(99),"100 → 101 vierfach")
	check(Rules.xp_required(101)==1671840 and Rules.xp_required(102)==6687360,"101 → 102 und 102 → 103")
	for level in range(101,Rules.MAX_LEVEL):check(Rules.xp_required(level)==4*Rules.xp_required(level-1),"vierfach bei %d"%level)
	check(Rules.xp_required(Rules.MAX_LEVEL-1)<Rules.MAX_EXACT_XP,"größter Bedarf exakt speicherbar")
	check(Rules.xp_required(Rules.MAX_LEVEL)==0 and Rules.xp_required(500)==0,"Höchststufe: kein weiterer Aufstieg")
	check(Rules.clamp_level(0)==1 and Rules.clamp_level(200)==Rules.MAX_LEVEL and Rules.clamp_level(77)==77,"Stufen werden geklemmt")
	var step:=Rules.add_xp(99,104489,1)
	check(step["level"]==100 and step["xp"]==0 and step["gained"]==1,"genau auf 100")
	step=Rules.add_xp(100,0,417960+5)
	check(step["level"]==101 and step["xp"]==5,"Rest bleibt erhalten")
	step=Rules.add_xp(117,0,Rules.MAX_EXACT_XP)
	check(step["level"]==Rules.MAX_LEVEL and step["xp"]==0,"Höchststufe erreicht, keine Überläufe")
	step=Rules.add_xp(1,0,-500)
	check(step["level"]==1 and step["xp"]==0,"negative XP ändern nichts")
	# Spiel
	var g:=Game.new();root.add_child(g)
	for i in 4:await process_frame
	g.character_created=true;g.hero_name="T";g.player_uuid="u-level"
	g.level=40;g.xp=0;var points:int=g.skill_points
	g.gain_xp(old_curve(40))
	check(g.level==41 and g.xp==0 and g.skill_points==points+1,"40 → 41 mit Skillpunkt")
	g.level=99;g.xp=104489;g.gain_xp(1)
	check(g.level==100 and g.xp==0,"99 → 100 im Spiel")
	g.gain_xp(417959)
	check(g.level==100 and g.xp==417959,"100 bleibt bis zum vierfachen Bedarf")
	g.gain_xp(1)
	check(g.level==101 and g.xp==0,"100 → 101 im Spiel")
	g.level=117;g.xp=Rules.xp_required(117)-3
	g.gain_xp(1000)
	check(g.level==Rules.MAX_LEVEL and g.xp==0,"Höchststufe im Spiel, XP stehen still")
	g.gain_xp(999999)
	check(g.level==Rules.MAX_LEVEL and g.xp==0,"über der Höchststufe passiert nichts")
	# Große XP: speichern, laden, Server
	g.level=116;g.xp=Rules.xp_required(116)-7
	var big:int=g.xp
	check(big>2147483647,"Prüfwert liegt über 2^31")
	var data:Dictionary=JSON.parse_string(JSON.stringify(g.capture_save_data()))
	check(Store.new().valid_data(data,"u-level"),"Server akzeptiert große XP")
	var too_big:=data.duplicate(true);too_big["xp"]=float(Rules.MAX_EXACT_XP)*4.0
	check(not Store.new().valid_data(too_big,"u-level"),"Server lehnt nicht exakt speicherbare XP ab")
	g.level=1;g.xp=0
	g.apply_save_data(data)
	check(g.level==116 and g.xp==big,"Laden behält Stufe und XP exakt (%d)"%g.xp)
	var high:=data.duplicate(true);high["level"]=250;high["xp"]=12345
	g.apply_save_data(high)
	check(g.level==Rules.MAX_LEVEL and g.xp==0,"zu hohe Stufe wird auf die Höchststufe geklemmt")
	# Testmodus und Reparatur nutzen dieselbe Grenze
	g.creative_mode=true;g.set_creative_level(105)
	check(g.level==105,"Testmodus über 40 möglich")
	g.set_creative_level(999)
	check(g.level==Rules.MAX_LEVEL,"Testmodus bis zur Höchststufe")
	g.creative_mode=false
	g.free()
	if failures>0:quit(1);return
	print("LEVEL_RULES_OK")
	quit()
