extends SceneTree
# Hut des Jagdmeisters: Der Schütze bekommt „Ewige Pfeile“. Normale Pfeile
# fliegen weiter, bis sie etwas treffen; ohne Hut oder als andere Klasse nicht.

const HeadgearRules=preload("res://components/headgear_rules.gd")

class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func play_sound(_name:String)->void:pass
	func save_game()->void:pass
	func uses_server_world()->bool:return false

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("ETERNAL_ARROWS_FAIL "+label)

func _initialize()->void:call_deferred("run")

func shot_life(g:Game)->float:
	g.projectiles.clear()
	g.attack_timer=0.0
	g.normal_attack()
	return float(g.projectiles[0]["life"]) if not g.projectiles.is_empty() else -1.0

## Startpunkt mit freier Bahn über 1700 px nach rechts (keine Hindernisse).
func open_lane(g:Game)->Vector2:
	for y in range(600,9000,200):
		for x in range(400,14000,300):
			var a:=Vector2(x,y)
			if g.is_blocked(a,a) or g.waystone_safe_at(a):continue
			if not g.projectile_collision(a,a+Vector2(1700,0),false)["hit"]:return a
	return Vector2.ZERO

func run()->void:
	var g:=Game.new()
	g.class_id=2
	g.reset_class_skills()
	g.character_created=true
	g.player_pos=Vector2(5200,2600)
	g.facing=Vector2.RIGHT
	var hat:Dictionary=g.class_boss_hat_item(2)
	hat["uid"]=901
	g.inventory.append(hat)
	check(HeadgearRules.grants_eternal_arrows(hat),"Hut des Jagdmeisters verleiht Ewige Pfeile")
	check(not HeadgearRules.grants_eternal_arrows(g.class_boss_hat_item(0)),"Helm des Kriegsherrn nicht")

	var normal:=shot_life(g)
	check(is_equal_approx(normal,HeadgearRules.ARROW_LIFE),"ohne Hut normale Reichweite (%s)" % normal)
	g.equipped_head_uid=901
	check(g.eternal_arrows_active(),"Hut aufgesetzt: aktiv")
	var eternal:=shot_life(g)
	check(eternal>=HeadgearRules.ETERNAL_ARROW_LIFE-0.01,"mit Hut fliegt der Pfeil weiter (%s)" % eternal)
	check(g.local_player_state().get("eternal_arrows",false)==true,"Server erfährt vom Hut")

	# Der Pfeil endet beim ersten Treffer: Gegner weit hinter der alten Reichweite.
	g.projectiles.clear();g.enemies.clear()
	g.player_pos=open_lane(g)
	check(g.player_pos!=Vector2.ZERO,"freie Schussbahn gefunden")
	var far:=g.player_pos+Vector2(1600,0)
	g.enemies.append(g.make_enemy(0,far))
	g.attack_timer=0.0
	g.normal_attack()
	var arrow:Dictionary=g.projectiles[0]
	var flown:=0.0
	while not g.projectiles.is_empty() and flown<6.0:
		g.update_projectiles(0.05)
		flown+=0.05
	check(g.projectiles.is_empty() and flown<6.0,"Pfeil endet bei Treffer oder Hindernis, nicht im Leeren weiter (%.2fs)" % flown)
	check(arrow["pos"].distance_to(g.player_pos)>780.0,"Pfeil kommt weiter als früher (%.0f px)" % arrow["pos"].distance_to(g.player_pos))

	# Andere Klasse mit demselben Hut: keine Wirkung.
	g.class_id=0
	check(not g.eternal_arrows_active(),"Krieger mit Hut: keine Ewigen Pfeile")
	g.free()
	if failures>0:
		print("ETERNAL_ARROWS_FAILED ",failures)
		quit(1)
		return
	print("ETERNAL_ARROWS_OK ranger hat grants eternal arrows that fly until they hit")
	quit()
