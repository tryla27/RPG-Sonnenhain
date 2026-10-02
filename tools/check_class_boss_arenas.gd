extends SceneTree
class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass

var failures:=0
func check(value:bool,label:String)->void:
	if not value:
		failures+=1
		print("FAIL ",label)

func _initialize()->void:
	call_deferred("run")

func run()->void:
	var g=Game.new()
	# Jede Bossarena muss komplett in ihrer vorgesehenen Map liegen und Abstand
	# zur Wegstein-Safezone halten.
	for i in 3:
		var center:Vector2=g.CLASS_BOSS_SITES[i]
		check(g.region_at(center)==6+i,"arena region "+str(i))
		var nearest:=INF
		for stone in g.WAYSTONES:
			nearest=minf(nearest,center.distance_to(stone))
		check(nearest>g.CLASS_BOSS_ARENA_RADIUS+g.WAYSTONE_SAFE_RADIUS+30.0,"arena waystone separation "+str(i))
		# 16 Richtungen x mehrere Radien: keine prozeduralen Bäume/Felsen im Kampfraum.
		for ring in [0.0,90.0,180.0,280.0,360.0]:
			for n in 16:
				var p:Vector2=center+Vector2.RIGHT.rotated(float(n)*TAU/16.0)*float(ring)
				check(g.class_boss_arena_walkable(p,28.0) if ring<=360.0 else true,"arena walkable "+str(i))
				check(not g.terrain_blocked(p,28.0),"arena terrain clear "+str(i))
				check(not g.waystone_safe_at(p),"arena outside safezone "+str(i))
		# Simuliere festgefahrenen Boss und prüfe Recovery-Punkt.
		var type:=12+i
		var boss:=g.make_enemy(type,center)
		boss["hp"]=1000.0;boss["max_hp"]=1000.0
		boss["facing"]=Vector2.RIGHT
		var recovery:Vector2=g.class_boss_recovery_point(boss)
		check(recovery.distance_to(center)<=150.0,"recovery near center "+str(i))
		check(g.class_boss_arena_walkable(recovery,g.mob_hit_radius(boss)),"recovery walkable "+str(i))
		check(not g.terrain_blocked(recovery,g.mob_hit_radius(boss)),"recovery terrain clear "+str(i))

	# Randkorrektur: Boss darf nicht dauerhaft außerhalb seines Rings bleiben.
	for i in 3:
		var type:=12+i
		var center:Vector2=g.CLASS_BOSS_SITES[i]
		var boss:=g.make_enemy(type,center+Vector2(g.CLASS_BOSS_ARENA_RADIUS-20.0,0))
		boss["hp"]=1000.0;boss["max_hp"]=1000.0
		boss["home"]=center
		boss["attack_wait"]=999.0
		g.enemies=[boss]
		g.player_pos=center-Vector2(250,0)
		g.advance_mob(boss,1.0/30.0,false)
		check(Vector2(boss["pos"]).distance_to(center)<g.CLASS_BOSS_ARENA_RADIUS,"boss contained "+str(i))

	print("CLASS_BOSS_ARENA_CHECK failures=",failures," · clear terrain / safezone gap / recovery / containment")
	g.free()
	quit(1 if failures else 0)
