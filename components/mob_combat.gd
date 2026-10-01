extends RefCounted
## Shared deterministic PvE attack model for offline and dedicated server.
const HEAVY=[4,7,9,12,13,14,16,24,26]
const RANGED=[2,5,11,15,18,20,22,25]
static func weapon_tier(level:int)->int:
	return 0 if level<8 else (1 if level<15 else (2 if level<22 else (3 if level<29 else (4 if level<36 else 5))))
static func profile(type:int,info:Dictionary,level:int,raw_damage:int)->Dictionary:
	var heavy=type in HEAVY
	var ranged=type in RANGED
	var early=int(info["region"]) in [1,2,6,8]
	var cycle=2.6 if heavy else (2.7 if ranged else 2.2)
	var windup=.9 if heavy else (.7 if ranged else (.65 if early else .55))
	var recovery=.75 if heavy else (.6 if ranged else .55)
	var reach=72.0 if heavy else (360.0 if ranged else (38.0 if type==3 else 44.0))
	var rank=weapon_tier(level)
	# Better weapon construction adds modest reach, never a second level damage multiplier.
	if not early and not ranged:reach+=rank*2.0
	var damage=roundi(raw_damage*(.8 if type==3 else 1.0))
	var first={"id":"basic","shape":"projectile" if ranged else "arc","range":reach,"damage":damage,"half_angle":1.05 if heavy else .7}
	var abilities:Array=[first]
	if not early:
		if type in [4,7,9,12,13,14,16,24,26]:
			abilities.append({"id":"ground_line","shape":"line","range":190.0,"damage":roundi(damage*.85),"half_angle":0.0})
		elif type in [5,6,8,19,20,21,22,23]:
			abilities.append({"id":"burst","shape":"arc","range":85.0,"damage":roundi(damage*.8),"half_angle":1.1})
		if level>=36 or type in [12,13,14]:
			abilities.append({"id":"heavy_arc","shape":"arc","range":reach if not ranged else 100.0,"damage":damage,"half_angle":1.3})
	return {"movement_speed":float(info["speed"])*(.9 if heavy else 1.0),"attack_cycle":cycle,"windup":windup,"active_time":.18 if heavy else .12,"recovery":recovery,"attack_range":reach,"hit_radius":14.0,"projectile_speed":230.0 if early else (310.0 if type in [12,13,14] else 265.0),"aggro_range":620.0 if not early else 520.0,"leash_range":950.0 if type in [12,13,14] else 800.0,"damage":damage,"weapon_tier":rank,"abilities":abilities,"heavy":heavy,"ranged":ranged}
static func cancel(enemy:Dictionary,rest:float=.4)->void:
	enemy["attack_state"]={}
	enemy["attack_wait"]=maxf(float(enemy.get("attack_wait",0.0)),rest)
static func hits(origin:Vector2,dir:Vector2,target:Vector2,ability:Dictionary,radius:float)->bool:
	var offset=target-origin
	var reach=float(ability["range"])
	if ability["shape"]=="line":
		return target.distance_to(Geometry2D.get_closest_point_to_segment(target,origin,origin+dir*reach))<=radius+10.0 and offset.dot(dir)>=-radius
	if offset.length()>reach+radius:return false
	if offset.length()<.001:return true
	return offset.normalized().dot(dir)>=cos(float(ability.get("half_angle",.8)))
static func step(enemy:Dictionary,config:Dictionary,targets:Array,delta:float)->Dictionary:
	var result={"move":Vector2.ZERO,"events":[]}
	var dt=maxf(0,delta)
	var position:Vector2=enemy["pos"]
	if not enemy.has("home"):enemy["home"]=position
	var home:Vector2=enemy["home"]
	if float(enemy.get("hp",0))<=0 or float(enemy.get("stun",0))>0:
		cancel(enemy);return result
	enemy["attack_wait"]=maxf(0,float(enemy.get("attack_wait",.2+fmod(absf(float(enemy.get("seed",0))),.7)))-dt)
	var target:Dictionary={}
	var best=INF
	var remembered=int(enemy.get("target_peer",-1))
	for candidate in targets:
		var distance=position.distance_to(candidate["pos"])
		var limit=float(config["leash_range"]) if int(candidate["id"])==remembered else float(config["aggro_range"])
		if distance<limit and home.distance_to(candidate["pos"])<float(config["leash_range"]) and distance<best:
			target=candidate;best=distance
	if position.distance_to(home)>float(config["leash_range"]) or target.is_empty():
		cancel(enemy,.6)
		enemy["target_peer"]=-1
		if position.distance_to(home)>8:
			result["move"]=(home-position).normalized()
			enemy["returning"]=true
		else:
			enemy["returning"]=false
		return result
	enemy["returning"]=false
	enemy["target_peer"]=target["id"]
	var toward:Vector2=(Vector2(target["pos"])-position).normalized()
	if toward.length_squared()<.001:toward=Vector2.DOWN
	var state:Dictionary=enemy.get("attack_state",{})
	if not state.is_empty():
		var previous=float(state["age"])
		# Aim locks at the end of windup, then cannot chase a dodging player.
		if previous<float(config["windup"]):
			state["dir"]=toward
			enemy["facing"]=toward
		state["age"]=previous+dt
		var strike=float(config["windup"])
		var ability:Dictionary=state["ability"]
		if not bool(state["fired"]) and float(state["age"])>=strike:
			state["fired"]=true
			var direction:Vector2=state["dir"]
			if ability["shape"]=="projectile":
				result["events"].append({"kind":"projectile","dir":direction,"damage":ability["damage"],"attack_id":state["id"]})
			else:
				for victim in targets:
					if hits(position,direction,victim["pos"],ability,float(config["hit_radius"])):
						result["events"].append({"kind":"damage","target":victim["id"],"damage":ability["damage"],"attack_id":state["id"]})
		var finish=strike+float(config["active_time"])+float(config["recovery"])
		if float(state["age"])>=finish:
			enemy["attack_wait"]=maxf(0,float(config["attack_cycle"])-float(state["age"]))
			enemy["attack_state"]={}
		else:enemy["attack_state"]=state
		return result
	var abilities:Array=config["abilities"]
	var count=abilities.size()
	if int(enemy["type"]) in [12,13,14] and float(enemy["hp"])>float(enemy["max_hp"])*.5:count=mini(count,2)
	var sequence=int(enemy.get("attack_sequence",0))
	var ability:Dictionary=abilities[sequence%count]
	if best<=float(ability["range"])+float(config["hit_radius"]) and float(enemy["attack_wait"])<=0:
		enemy["attack_sequence"]=sequence+1
		enemy["attack_state"]={"id":sequence+1,"age":0.0,"dir":toward,"ability":ability.duplicate(),"fired":false}
		enemy["facing"]=toward
		return result
	if bool(config["ranged"]) and best<140:
		result["move"]=-toward
	elif not bool(config["ranged"]) or best>250:
		result["move"]=toward
	enemy["facing"]=toward
	return result
static func shot_hits(a:Vector2,b:Vector2,p:Vector2,radius:float)->bool:
	return p.distance_to(Geometry2D.get_closest_point_to_segment(p,a,b))<=radius

static func visual_progress(state:Dictionary,config:Dictionary)->float:
	if state.is_empty():return -1.0
	var age=float(state.get("age",0))
	var windup=float(config["windup"])
	var active=float(config["active_time"])
	var recovery=float(config["recovery"])
	var impact=.35 if bool(config["heavy"]) else .4
	var finish=.43 if bool(config["heavy"]) else .55
	if age<windup:return clampf(age/windup,0,1)*impact
	if age<windup+active:return lerpf(impact,finish,clampf((age-windup)/active,0,1))
	return lerpf(finish,1.0,clampf((age-windup-active)/recovery,0,1))
