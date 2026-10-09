extends SceneTree
const Combat=preload("res://components/mob_combat.gd")
const VFX=preload("res://components/woodland_attack_vfx.gd")
class Game extends "res://main.gd":
	var barrier:=false
	var hits:Array=[]
	func _ready()->void:pass
	func _process(_delta:float)->void:pass
	func _draw()->void:pass
	func save_game()->void:pass
	func region_at(_p:Vector2)->int:return 1
	func waystone_safe_at(p:Vector2)->bool:return p.x>=400
	func terrain_blocked(p:Vector2,radius:float=-1.0)->bool:return barrier and p.x+maxf(0.0,radius)>=70
	func blocked_by_region_wall(_p:Vector2)->bool:return false
	func projectile_collision(a:Vector2,b:Vector2,_server:bool,_context:String="",_room:int=-1,_height:float=0)->Dictionary:
		return {"hit":barrier and minf(a.x,b.x)<70 and maxf(a.x,b.x)>=70,"pos":b}
	func apply_player_damage(raw:int)->void:
		hits.append(raw)
		hp-=raw
		invulnerable=.5
var failures:=0
func check(value:bool,label:String)->void:
	if not value:
		failures+=1
		print("FAIL ",label)
func mob(type:int)->Dictionary:
	return {"uid":10,"type":type,"pos":Vector2.ZERO,"home":Vector2.ZERO,"hp":100.0,"max_hp":100.0,"stun":0.0,"slow":0.0,"seed":0.0,"attack_wait":0.0,"poison":0.0,"flash":0.0}
func _initialize()->void:call_deferred("run")
func run()->void:
	var game:=Game.new()
	game.hp=1000;game.player_pos=Vector2(200,0)
	var beetle:=mob(1)
	var config:=game.mob_profile(beetle)
	check(bool(config["ranged"]) and config["abilities"].size()==1,"beetle ranged only")
	Combat.step(beetle,config,[{"id":0,"pos":game.player_pos}],.01)
	var shot_events:Array=Combat.step(beetle,config,[{"id":0,"pos":game.player_pos}],.71)["events"]
	check(shot_events.size()==1 and shot_events[0]["kind"]=="projectile" and shot_events[0]["ability_id"]=="druesensekret","one gland shot, no contact damage")
	beetle=mob(1);game.enemies=[beetle]
	game.advance_mob(beetle,.01,false);game.advance_mob(beetle,.71,false)
	check(game.enemy_projectiles.size()==1 and Vector2(game.enemy_projectiles[0]["pos"]).distance_to(Vector2(16,-8))<.01,"projectile comes from front gland")
	for frame in 60:game.advance_mob_shots(1.0/60,false)
	check(game.hits.size()==1,"moving secretion hits once")
	game.hits.clear();game.enemy_projectiles.clear();game.player_pos=Vector2(60,0);game.invulnerable=0
	var mushroom:=mob(2);game.enemies=[mushroom]
	game.advance_mob(mushroom,.01,false)
	game.advance_mob(mushroom,.86,false)
	check(game.enemy_projectiles.size()==1 and game.enemy_projectiles[0]["kind"]=="cloud","mushroom releases stationary cloud")
	check(game.hits.is_empty(),"no hidden direct mushroom hit")
	var cloud:Dictionary=game.enemy_projectiles[0]
	for frame in 157:
		game.invulnerable=maxf(0.0,game.invulnerable-1.0/60)
		game.advance_mob_shots(1.0/60,false)
	check(game.hits.size()==4,"four spaced poison pulses")
	check(game.enemy_projectiles.is_empty(),"poison cloud expires")
	game.hits.clear();game.invulnerable=0;game.player_pos=Vector2(120,0)
	cloud=cloud.duplicate();cloud["life"]=2.6;cloud["age"]=0;cloud["next_pulse"]=0
	game.enemy_projectiles=[cloud]
	game.advance_mob_shots(.01,false)
	check(game.hits.is_empty(),"outside dust radius is safe")
	game.player_pos=Vector2(80,0);game.barrier=true
	cloud["age"]=0;cloud["next_pulse"]=0
	game.advance_mob_shots(.01,false)
	check(game.hits.is_empty(),"dust cannot poison through a wall")
	game.barrier=false;mushroom["stun"]=1
	game.advance_mob_shots(.01,false)
	check(game.enemy_projectiles.is_empty(),"source stun dissipates dust")
	game.player_pos=Vector2(150,0);game.invulnerable=0
	var wolf:=mob(3);game.enemies=[wolf]
	game.advance_mob(wolf,.01,false)
	check(wolf["attack_state"]["ability"]["id"]=="sprungbiss","wolf leaps at distant target")
	game.advance_mob(wolf,.8,false)
	check(game.hits.is_empty() and Vector2(wolf["pos"]).is_zero_approx(),"no damage or teleport at takeoff")
	for frame in 20:game.advance_mob(wolf,1.0/60,false)
	check(Vector2(wolf["pos"]).distance_to(game.player_pos)<1 and game.hits.size()==1,"smooth leap, one landing bite")
	for frame in 30:game.advance_mob(wolf,1.0/60,false)
	check(game.hits.size()==1,"no repeated landing damage")
	game.hits.clear();wolf=mob(3);game.enemies=[wolf];game.player_pos=Vector2(25,0);game.invulnerable=0
	game.advance_mob(wolf,.01,false)
	check(wolf["attack_state"]["ability"]["id"]=="biss","close wolf chooses bite")
	game.advance_mob(wolf,.66,false)
	check(game.hits.size()==1 and Vector2(wolf["pos"]).is_zero_approx(),"close bite without jump")
	game.hits.clear();wolf=mob(3);game.enemies=[wolf];game.player_pos=Vector2(150,0);game.barrier=true;game.invulnerable=0
	game.advance_mob(wolf,.01,false);game.advance_mob(wolf,1.13,false)
	check(Vector2(wolf["pos"]).x<70 and game.hits.is_empty(),"large frame cannot jump through wall or damage beyond it")
	game.barrier=false;wolf=mob(3);game.enemies=[wolf]
	game.advance_mob(wolf,.01,false);game.advance_mob(wolf,.9,false)
	wolf["stun"]=1;game.advance_mob(wolf,.5,false)
	check(wolf["attack_state"].is_empty() and game.hits.is_empty(),"airborne stun cancels landing hit")
	wolf=mob(3);game.enemies=[wolf];game.player_pos=Vector2(150,0)
	game.advance_mob(wolf,.01,false);game.advance_mob(wolf,.81,false)
	game.player_pos=Vector2(150,100)
	for frame in 20:game.advance_mob(wolf,1.0/60,false)
	check(game.hits.is_empty() and Vector2(wolf["pos"]).distance_to(Vector2(150,0))<1,"sideways dodge avoids locked leap")
	wolf=mob(3);wolf["attack_sequence"]=1;game.enemies=[wolf];game.player_pos=Vector2(65,0)
	game.advance_mob(wolf,.1,false)
	check(wolf.get("attack_state",{}).is_empty() and Vector2(wolf["pos"]).x>0,"gap between bite and leap ranges causes approach")
	var gait_phase:=float(wolf.get("gait_phase",0.0))
	check(gait_phase>0 and bool(wolf.get("walking",false)),"actual movement advances drawn gait")
	wolf["stun"]=1;game.advance_mob(wolf,.1,false)
	check(is_equal_approx(float(wolf.get("gait_phase",0.0)),gait_phase) and not bool(wolf.get("walking",false)),"stunned wolf stops stepping")
	for type in 3:
		game.player_pos=Vector2(300,0)
		var normal:=mob(type);normal["attack_wait"]=1;game.enemies=[normal]
		game.advance_mob(normal,.1,false)
		var slowed:=mob(type);slowed["attack_wait"]=1;slowed["slow"]=1;game.enemies=[slowed]
		game.advance_mob(slowed,.1,false)
		check(float(normal.get("gait_phase",0))>float(slowed.get("gait_phase",0)) and float(slowed.get("gait_phase",0))>0,"slower movement slows animation %d"%type)
		var frozen_phase:=float(slowed.get("gait_phase",0));slowed["stun"]=1
		game.advance_mob(slowed,.1,false)
		check(is_equal_approx(float(slowed.get("gait_phase",0)),frozen_phase) and not bool(slowed.get("walking",false)),"stun stops woodland stepping %d"%type)
	var timed:Dictionary={"duration":2.6,"pulse_interval":.65}
	check(Combat.cloud_pulses(timed,2.5)==4 and Combat.cloud_pulses(timed,.1)==0,"pulse schedule survives coarse delta without duplicates")
	check(VFX.leap_height(.475)>21 and absf(VFX.leap_height(.55))<.01,"wolf rises and lands in active phase")
	game.free()
	if failures==0:print("WOODLAND_ATTACKS_OK gland range / poison area pulses / distance-aware bite and swept leap / walls / stun / expiry")
	quit(1 if failures else 0)
