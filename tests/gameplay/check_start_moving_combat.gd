extends SceneTree
## Echte Gegner-KI, Klassenangriffe und Geschosse in der Einstiegsgeometrie.
## Kontrollierter Einzelkampf; kein Ersatz für einen manuellen Balance-Durchgang.
const Lifecycle=preload("res://tests/quests/check_start_quest_lifecycle.gd")
var failures:=0
var rows:Array=[]
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1;push_error("START_MOVING_FAIL "+label)
func _initialize()->void:call_deferred("run")
func run()->void:
	seed(12102026)
	var g:=Lifecycle.Game.new();root.add_child(g)
	for cls in 3:
		g.pending_class=cls;g.pending_race=0;g.pending_gender=0;g.creation_name="Kampfprüfung"
		g.start_new_game();g.finish_intro()
		g.quest_dialogue("Mira")
		for type in 2:
			g.enemies.clear();g.projectiles.clear();g.enemy_projectiles.clear()
			g.player_pos=Vector2(2250,1280);g.panel=""
			var enemy:Dictionary=g.make_enemy(type,g.player_pos+Vector2(200,0))
			g.enemies.append(enemy)
			var origin:Vector2=enemy["pos"]
			var moved:=0.0
			var hp_before:float=g.hp
			var hits:=0
			var elapsed:=0.0
			for frame in 3600:
				var delta:=1.0/60.0
				g.invulnerable=maxf(0.0,g.invulnerable-delta)
				g.attack_timer=maxf(0.0,g.attack_timer-delta)
				g.update_enemies(delta)
				if not g.enemies.is_empty():
					moved=maxf(moved,origin.distance_to(enemy["pos"]))
					g.facing=(Vector2(enemy["pos"])-g.player_pos).normalized()
					# Zuerst muss die KI selbst anlaufen. Danach gelten echte
					# Angriffsabstände und die normale Abklingzeit.
					if moved>20 and g.attack_timer<=0 and g.player_pos.distance_to(enemy["pos"])<(100.0 if cls==0 else 280.0):
						g.normal_attack();hits+=1
				g.update_projectiles(delta);g.update_enemy_projectiles(delta)
				elapsed+=delta
				if g.enemies.is_empty() or g.hp<=0:break
			check(moved>20,"Klasse %d / Gegner %d verfolgt Spieler tatsächlich" % [cls,type])
			check(hits>0 and g.enemies.is_empty() and g.hp>0,"Klasse %d / Gegner %d regulärer Einzelkampf erfolgreich" % [cls,type])
			check(is_finite(g.hp) and g.hp<=g.max_hp(),"gültige Lebenswerte")
			if type==0:check(int(g.quests[0]["progress"])==1,"bewegter Schleim zählt für angenommenen Auftrag")
			rows.append({"class":cls,"mob":type,"seconds":snappedf(elapsed,.01),"attacks":hits,"moved":snappedf(moved,.01),"hp_before":hp_before,"hp_after":g.hp})
	g.queue_free()
	print("START_MOVING_COMBAT ",JSON.stringify(rows)," failures=",failures)
	quit(1 if failures else 0)
