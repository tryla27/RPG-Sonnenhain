extends SceneTree
# Pfeile zerschellen an Laternen, Spawn-Stein und Mauern mit Bild und Klang –
# allein und online (eigener Schuss sofort, Server-Meldung nicht doppelt).

class Game extends "res://main.gd":
	var sounds:Array=[]
	func _ready()->void:pass
	func _process(_d:float)->void:pass
	func save_game()->void:pass
	func play_sound(n:String)->void:sounds.append(n)
	func play_world_sound(n:String,_p:Vector2)->void:sounds.append(n)

const VillageFixtures=preload("res://components/village_fixtures.gd")

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("ARROW_IMPACT_FAIL "+label)

func _initialize()->void:call_deferred("run")

func shoot(g,from:Vector2,dir:Vector2,online:bool=false)->void:
	g.projectiles.append({"pos":from,"dir":dir.normalized(),"speed":650.0,"life":2.0,"damage":0 if online else 20,"kind":3,"element":"","hits":[],"network_visual":online})
	for i in 60:
		g.update_projectiles(1.0/60.0)
		if g.projectiles.is_empty():break

func run()->void:
	var g:=Game.new()
	g.reset_class_skills();g.character_created=true;g.class_id=2
	var lamp:Vector2=VillageFixtures.LAMPS[1]
	check(g.projectile_world_blocked(lamp+Vector2(0,-8)),"Server: Laterne hält Pfeile auf")
	check(g.projectile_material(lamp+Vector2(0,-8))=="metall","Laterne ist Metall")
	check(g.projectile_material(g.WAYSTONES[0]+Vector2(0,8))=="stein" or g.projectile_world_blocked(g.WAYSTONES[0]),"Spawn-Stein ist Stein")

	# Allein: Pfeil auf die Laterne zerschellt mit Klang.
	g.player_pos=lamp+Vector2(-200,-8)
	g.enemies.clear();g.sounds.clear();g.combat_feedback.breaks.clear()
	shoot(g,lamp+Vector2(-150,-8),Vector2.RIGHT)
	check(g.projectiles.is_empty(),"Pfeil endet an der Laterne")
	check(not g.combat_feedback.breaks.is_empty(),"Zerschell-Bild allein")
	check("arrow_break" in g.sounds and "treffer_metall" in g.sounds,"Bruch- und Metallklang allein (%s)" % [g.sounds])

	# Holz wird bereits als Hindernis erkannt, braucht aber auch seinen Klang.
	var wood: Vector2 = g.BORIN_MAGIC_TREE_POS
	check(g.projectile_material(wood)=="holz" and g.projectile_world_blocked(wood),"Runenbaum ist ein Holzhindernis")
	g.player_pos=wood+Vector2(0,-150)
	g.sounds.clear()
	g.play_break_sound(wood-Vector2(0,6),3,Vector2.DOWN)
	check("arrow_break" in g.sounds and "treffer_holz" in g.sounds,"Pfeil: Holzklang")
	check("treffer_metall" not in g.sounds and "treffer_stein" not in g.sounds,"Holz hat keinen falschen Materialklang")
	g.sounds.clear()
	g.play_break_sound(wood-Vector2(0,6),2,Vector2.DOWN)
	check("magic_break" in g.sounds and "treffer_holz" in g.sounds,"Zauber: Holzklang")
	g.dedicated_server_mode=true;g.sounds.clear()
	g.play_break_sound(wood,3)
	check(g.sounds.is_empty(),"Server spielt keinen Klang")
	g.dedicated_server_mode=false
	g.player_pos=wood+Vector2(900,0)
	g.play_break_sound(wood,3)
	check(g.sounds.is_empty(),"ferner Aufprall bleibt stumm")
	g.player_pos=lamp+Vector2(-200,-8)

	# Online: eigener (sichtbarer) Pfeil zerschellt sofort, Server-Meldung danach nicht doppelt.
	g.network_mode="client"
	check(g.uses_server_world(),"online in der Serverwelt")
	g.player_pos=wood+Vector2(0,-150);g.sounds.clear()
	g.play_break_sound(wood-Vector2(0,6),3,Vector2.DOWN)
	check("treffer_holz" in g.sounds,"online: Holzklang")
	g.player_pos=lamp+Vector2(-200,-8)
	g.sounds.clear();g.combat_feedback.breaks.clear()
	shoot(g,lamp+Vector2(-150,-8),Vector2.RIGHT,true)
	check(not g.combat_feedback.breaks.is_empty() and "arrow_break" in g.sounds,"online: eigener Pfeil zerschellt mit Klang")
	var before:int=g.sounds.size()
	var hit:Vector2=g.combat_feedback.breaks[-1]["pos"] if not g.combat_feedback.breaks.is_empty() else lamp
	g.rpc_projectile_break({"pos":[hit.x+10,hit.y],"dir":[1,0],"kind":3,"element":"","context":"world","instance_id":"world"})
	check(g.sounds.size()==before,"Server-Meldung an derselben Stelle wird übersprungen")
	g.rpc_projectile_break({"pos":[hit.x+600,hit.y],"dir":[1,0],"kind":3,"element":"","context":"world","instance_id":"world"})
	check(g.sounds.size()>before,"andere Stelle (z. B. Mitspieler) wird gespielt")

	g.free()
	if failures>0:
		push_error("ARROW_IMPACT_FAILED %d" % failures);quit(1);return
	print("ARROW_IMPACT_OK")
	quit()
