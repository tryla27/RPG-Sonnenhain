extends SceneTree
const Combat=preload("res://components/mob_combat.gd")
class Game extends "res://main.gd":
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func save_game()->void:pass
var failures=0
func check(value:bool,label:String)->void:
	if not value:
		failures+=1
		print("FAIL ",label)
func _initialize()->void:call_deferred("run")
func mob(type:int=4)->Dictionary:
	return {"uid":17,"type":type,"pos":Vector2.ZERO,"home":Vector2.ZERO,"hp":1000.0,"max_hp":1000.0,"stun":0.0,"seed":0.0,"attack_wait":0.0}
func run()->void:
	var game=Game.new()
	game.skill_levels.resize(16)
	game.skill_levels.fill(0)
	var csv="monster,map,level,cycle,windup,moves,unarmed_hits,unarmed_ttk_ideal,geared_hits,geared_ttk_ideal,stationary_ttd_ideal,stationary_hit_rate,dodge_hit_rate,geared_ttd_ideal,group2_ttk_ideal
"
	for type in game.ENEMY_TYPES.size():
		var info:Dictionary=game.ENEMY_TYPES[type]
		var config=Combat.profile(type,info,game.enemy_level(type),game.enemy_damage(type))
		check(float(config["attack_cycle"])>=float(config["windup"])+float(config["active_time"])+float(config["recovery"]),"valid timings "+str(type))
		if int(info["region"]) in [1,2,6,8] and type not in [12,13,14]:check(config["abilities"].size()==1,"early single move "+str(type))
		var offline=mob(type)
		var dedicated=offline.duplicate(true)
		var target=[{"id":2,"pos":Vector2(0,35)}]
		var counts=0
		for frame in 1800:
			var a=Combat.step(offline,config,target,1.0/60.0)
			var b=Combat.step(dedicated,config,target,1.0/60.0)
			check(a==b and offline==dedicated,"server/offline parity "+str(type))
			for event in a["events"]:counts+=1
		var attempts:=int(offline.get("attack_sequence",0))
		check(attempts>0 and attempts<=ceili(30.0/float(config["attack_cycle"]))+1,"attack frequency "+str(type))
		game.level=game.enemy_level(type)
		game.inventory=[];game.equipped_uid=-1;game.equipped_armor_uid=-1
		var health=float(game.make_enemy(type,Vector2.ZERO)["max_hp"])
		if type in [12,13,14]:health=game.boss_max_hp(type)
		var unarmed=ceili(health/game.normal_attack_power())
		var weapon:Dictionary=game.make_item("Pruefwaffe","sword",0,maxi(1,game.level),0)
		game.inventory=[weapon];game.equipped_uid=weapon["uid"]
		var geared=ceili(health/game.normal_attack_power())
		var armor:Dictionary=game.make_item("Pruefruestung","armor",0,maxi(1,roundi(game.level*.35)),0)
		game.inventory.append(armor);game.equipped_armor_uid=armor["uid"]
		var standing=mob(type)
		var dodging=mob(type)
		var stand_attempts=0;var stand_hits=0;var dodge_attempts=0;var dodge_hits=0
		var simulated_shots:Array=[[],[]]
		for frame in 1800:
			for mode in 2:
				var test=standing if mode==0 else dodging
				var state:Dictionary=test.get("attack_state",{})
				var position=Vector2(0,35)
				if mode==1 and not state.is_empty() and float(state["age"])>=float(config["windup"])-.05:position=Vector2(110,0)
				var events=Combat.step(test,config,[{"id":2,"pos":position}],1.0/60)
				for event in events["events"]:
					if event["kind"]=="projectile":
						simulated_shots[mode].append({"pos":Vector2.ZERO,"dir":event["dir"],"life":2.0})
					elif mode==0:stand_hits+=1
					else:dodge_hits+=1
				for shot_index in range(simulated_shots[mode].size()-1,-1,-1):
					var shot:Dictionary=simulated_shots[mode][shot_index]
					var previous:Vector2=shot["pos"]
					shot["pos"]=previous+Vector2(shot["dir"])*float(config["projectile_speed"])/60.0
					shot["life"]=float(shot["life"])-1.0/60.0
					if Combat.shot_hits(previous,shot["pos"],position,24):
						if mode==0:stand_hits+=1
						else:dodge_hits+=1
						simulated_shots[mode].remove_at(shot_index)
					elif float(shot["life"])<=0:simulated_shots[mode].remove_at(shot_index)
			stand_attempts=int(standing.get("attack_sequence",0));dodge_attempts=int(dodging.get("attack_sequence",0))
		csv+="%s,%d,%d,%.2f,%.2f,%d,%d,%.2f,%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n"%[info["name"],info["region"],game.level,config["attack_cycle"],config["windup"],config["abilities"].size(),unarmed,unarmed*.45,geared,geared*.45,game.max_hp()/float(config["damage"])*float(config["attack_cycle"]),float(stand_hits)/maxi(1,stand_attempts),float(dodge_hits)/maxi(1,dodge_attempts),game.max_hp()/maxi(1,int(config["damage"])-game.equipment_power(game.equipped_armor_uid))*float(config["attack_cycle"]),geared*.45/2.0]
	var config=Combat.profile(4,game.ENEMY_TYPES[4],16,30)
	var enemy=mob()
	var front=[{"id":2,"pos":Vector2(0,35)},{"id":3,"pos":Vector2(0,45)},{"id":4,"pos":Vector2(0,-35)}]
	Combat.step(enemy,config,front,.01)
	var events=Combat.step(enemy,config,front,float(config["windup"])+.01)["events"]
	check(events.size()==2,"group arc hits two front players, excludes rear")
	check(Combat.step(enemy,config,front,.01)["events"].is_empty(),"no repeated active-frame damage")
	var frozen:Vector2=enemy["attack_state"]["dir"]
	Combat.step(enemy,config,[{"id":2,"pos":Vector2(60,0)}],.01)
	check(enemy["attack_state"]["dir"]==frozen,"locked aim")
	enemy["stun"]=1.0
	check(Combat.step(enemy,config,front,1)["events"].is_empty() and enemy["attack_state"].is_empty(),"stun cancels attack")
	enemy["stun"]=0;enemy["hp"]=0
	check(Combat.step(enemy,config,front,1)["events"].is_empty(),"death cancels attack")
	var retreat=mob()
	retreat["pos"]=Vector2(100,0)
	var returned=Combat.step(retreat,config,[{"id":2,"pos":Vector2(2000,0)}],.1)
	check(returned["move"].x<0 and bool(retreat["returning"]),"leash returns home")
	check(Combat.shot_hits(Vector2(-100,0),Vector2(100,0),Vector2.ZERO,20),"swept projectile no tunnelling")
	check(not Combat.shot_hits(Vector2(-100,0),Vector2(100,0),Vector2(0,100),20),"projectile miss")
	var line={"shape":"line","range":180.0}
	check(Combat.hits(Vector2.ZERO,Vector2.RIGHT,Vector2(100,5),line,14),"line hits corridor")
	check(not Combat.hits(Vector2.ZERO,Vector2.RIGHT,Vector2(100,70),line,14),"line excludes outside corridor")
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--report="):
			var file=FileAccess.open(arg.substr(9),FileAccess.WRITE)
			if file:file.store_string(csv)
	print("MOB_COMBAT_CHECK failures=",failures," · 27 profiles / overloaded class bosses / 30s parity / group arcs / lock / stun / death / leash / swept projectiles")
	game.free()
	quit(1 if failures else 0)
