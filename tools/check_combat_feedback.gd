extends SceneTree
class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func _draw()->void:pass
	func save_game()->void:pass
var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1;push_error(label)
func _initialize()->void:call_deferred("run")
func run()->void:
	seed(58104)
	var g:=Game.new();root.add_child(g)
	g.set_process(false);g.set_process_input(false);g.level=40;g.panel=""
	for gate in g.VILLAGE_GATES:g.opened_village_gates[gate]=true
	g.bosses_defeated=[true,true,true]
	for region in range(1,13):
		g.player_pos=g.region_rect(region).get_center();g.enemies.clear()
		for attempt in 45:g.spawn_enemy()
		check(not g.enemies.is_empty(),"Offline spawn absent on map %d"%region)
		check(g.normal_mob_count()<=10,"Offline spawn limit exceeded")
		for enemy in g.enemies:check(g.spawn_position_allowed(enemy["pos"],region),"Invalid offline spawn map %d"%region)
		g.enemies.clear();g.remote_players={2:{"pos":[g.player_pos.x,g.player_pos.y],"context":"world","instance_id":"world"}}
		g.dedicated_server_mode=true
		for attempt in 45:g.spawn_dedicated_enemy()
		check(not g.enemies.is_empty(),"Server spawn absent on map %d"%region)
		check(g.normal_mob_count()<=8,"Server spawn limit exceeded")
		for enemy in g.enemies:check(g.spawn_position_allowed(enemy["pos"],region),"Invalid server spawn map %d"%region)
		g.dedicated_server_mode=false
	g.player_pos=Vector2(825,1095);g.enemies.clear()
	for attempt in 40:g.spawn_enemy();g.spawn_dedicated_enemy()
	# Server fixture still points outside the safe zone: clear it before the Map-0 check.
	g.enemies.clear();g.remote_players={2:{"pos":[825.0,1095.0],"context":"world"}}
	for attempt in 40:g.spawn_enemy();g.spawn_dedicated_enemy()
	check(g.enemies.is_empty(),"Normal enemies spawned in Map 0")
	g.network_mode="client";g.spawn_enemy();g.spawn_nearby_boss()
	check(g.enemies.is_empty(),"Client duplicated server mobs")
	g.network_mode="offline"
	var home:Vector2=g.house_positions()[0]
	var a:=home+Vector2(96,190);var b:=home+Vector2(96,70)
	check(g.projectile_collision(a,b,false)["hit"],"Offline swept house impact missing")
	check(g.projectile_collision(a,b,true)["hit"],"Server swept house impact missing")
	g.projectiles=[{"pos":a,"dir":Vector2.UP,"speed":2000.0,"life":2.0,"kind":3,"damage":10,"hits":[]}]
	g.update_projectiles(.08)
	check(g.projectiles.is_empty() and g.combat_feedback.breaks.size()==1,"Offline arrow wall impact animation missing")
	g.projectiles=[{"pos":a,"dir":Vector2.UP,"speed":2000.0,"life":2.0,"kind":2,"damage":10,"hits":[]}]
	g.update_dedicated_player_projectiles(.08)
	check(g.projectiles.is_empty(),"Server projectile tunneled through house")

	for id in [3,7,16,18,20,25,26,28,29,30]:
		for cls in [0,1,2]:
			var shots:Array=g.ability_projectiles(id,a,Vector2.UP,cls,40)
			check(shots.size()==(3 if id in [7,20,26] else 1),"Skill projectile count incorrect %d"%id)
			g.projectiles=shots;g.combat_feedback.breaks.clear()
			g.update_dedicated_player_projectiles(.4)
			check(g.projectiles.is_empty() and not g.combat_feedback.breaks.is_empty(),"Skill did not break on building %d"%id)
	for element in ["","feuer","eis","blitz","gift"]:
		g.projectiles=[{"pos":a,"dir":Vector2.UP,"speed":2000.0,"life":2.0,"kind":2,"damage":0,"hits":[],"element":element}]
		g.combat_feedback.breaks.clear();g.update_projectiles(.08)
		check(not g.combat_feedback.breaks.is_empty() and g.combat_feedback.breaks.back()["element"]==element,"Element impact lost: "+element)
	g.projectiles.clear()
	var site:Vector2=g.LANDMARKS[2]["pos"]
	g.player_pos=site+Vector2(0,300);g.enemies.clear();g.boss_cooldowns=[0.0,0.0,0.0]
	g.spawn_nearby_boss();g.spawn_nearby_boss()
	check(g.enemies.size()==3,"Tower encounter must spawn one boss and exactly two guards")
	var boss:Dictionary=g.enemies[0]
	check(is_equal_approx(g.mob_visual_scale(boss),1.3),"Tower boss is not 30 percent larger")
	for guard in g.enemies.slice(1):
		check(int(guard.get("guardian_of",-1))==int(boss["uid"]),"Guard parent mismatch")
		check(g.mob_visual_scale(guard)<.6,"Stone guard too large")
		check(not g.mob_targets(guard,false).is_empty(),"Stone guard cannot target player")
	g.dedicated_server_mode=true;g.remote_players={2:{"pos":[g.player_pos.x,g.player_pos.y],"context":"world"}};g.enemies.clear()
	g.spawn_dedicated_bosses();g.spawn_dedicated_bosses()
	check(g.enemies.size()==3,"Dedicated encounter duplicated guards")
	check(g.enemies[0]["uid"]!=g.enemies[1]["uid"] and g.enemies[1]["uid"]!=g.enemies[2]["uid"],"Encounter IDs collide")
	g.dedicated_server_mode=false
	g.panel="creation";g.creation_name="Testheld";g.creation_class_selected=false
	g.handle_panel_click(Vector2(800,462))
	check(g.pending_class==2 and g.creation_class_selected,"Character selection not clickable")
	check(g.mob_hit_radius(g.make_enemy(0,Vector2.ZERO))<15,"Small slime hit circle too large")
	check(is_equal_approx(g.mob_profile(boss)["attack_range"],g.MobCombat.profile(12,g.ENEMY_TYPES[12],g.enemy_level(12),g.enemy_damage(12))["attack_range"]*1.3),"Boss attack radius not adapted")
	var sound:=g.CombatFeedback.break_sound(true)
	check(sound.data.size()>0 and sound.mix_rate==22050,"Projectile break sound invalid")
	print("COMBAT_FEEDBACK_CHECK failures=",failures," | Maps 1-12 offline/server spawns; Map0 safe; swept impacts; boss +2 guards; class selection; sound")
	g.queue_free();await process_frame;quit(1 if failures else 0)
