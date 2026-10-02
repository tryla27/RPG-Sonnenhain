extends RefCounted
## Shared deterministic PvE attack model for offline and dedicated server.
const HEAVY=[4,7,9,12,13,14,16,24,26]
const RANGED=[2,5,11,13,14,15,18,20,22,25]
static func weapon_tier(level:int)->int:
	return 0 if level<8 else (1 if level<15 else (2 if level<22 else (3 if level<29 else (4 if level<36 else 5))))
static func profile(type:int,info:Dictionary,level:int,raw_damage:int)->Dictionary:
	var heavy=type in HEAVY
	var ranged=type in RANGED
	var early=int(info["region"]) in [1,2,6,8] and type not in [12,13,14]
	var rank=weapon_tier(level)
	var damage=roundi(raw_damage*(.8 if type==3 else 1.0))
	# Die drei Klassenbosse sind absichtlich deutlich über normalen Mobs:
	# größere Aggro, mehr Reichweite, schnellerer Zyklus und mehrere Skills.
	if type==12:
		return {
			"movement_speed":float(info["speed"])*1.02,"attack_cycle":1.85,"windup":.62,"active_time":.2,"recovery":.48,
			"attack_range":92.0,"hit_radius":20.0,"projectile_speed":360.0,"aggro_range":1450.0,"leash_range":3200.0,
			"damage":damage,"weapon_tier":rank,"heavy":true,"ranged":false,"preferred_min":0.0,"preferred_max":105.0,
			"abilities":[
				{"id":"kriegshieb","shape":"arc","range":98.0,"damage":roundi(damage*1.15),"half_angle":1.15,"phase":1.0},
				{"id":"ansturm","shape":"line","range":280.0,"damage":roundi(damage*1.35),"half_angle":0.0,"phase":1.0,"dash":210.0},
				{"id":"erdspalter","shape":"arc","range":155.0,"damage":roundi(damage*1.55),"half_angle":2.35,"phase":.68},
				{"id":"blutrausch","shape":"arc","range":125.0,"damage":roundi(damage*1.9),"half_angle":1.55,"phase":.38,"multi":2}
			]
		}
	if type==13:
		return {
			"movement_speed":float(info["speed"])*1.08,"attack_cycle":1.72,"windup":.55,"active_time":.14,"recovery":.42,
			"attack_range":470.0,"hit_radius":18.0,"projectile_speed":440.0,"aggro_range":1550.0,"leash_range":3300.0,
			"damage":damage,"weapon_tier":rank,"heavy":false,"ranged":true,"preferred_min":220.0,"preferred_max":390.0,
			"abilities":[
				{"id":"arkansalve","shape":"projectile","range":500.0,"damage":roundi(damage*1.05),"half_angle":0.0,"phase":1.0,"projectiles":3,"spread":.16},
				{"id":"arkane_lanze","shape":"projectile","range":560.0,"damage":roundi(damage*1.65),"half_angle":0.0,"phase":1.0},
				{"id":"raumbruch","shape":"arc","range":175.0,"damage":roundi(damage*1.45),"half_angle":PI,"phase":.7,"blink":240.0},
				{"id":"sternengewitter","shape":"projectile","range":560.0,"damage":roundi(damage*1.25),"half_angle":0.0,"phase":.4,"projectiles":7,"spread":.18}
			]
		}
	if type==14:
		return {
			"movement_speed":float(info["speed"])*1.18,"attack_cycle":1.48,"windup":.46,"active_time":.12,"recovery":.36,
			"attack_range":520.0,"hit_radius":16.0,"projectile_speed":520.0,"aggro_range":1650.0,"leash_range":3400.0,
			"damage":damage,"weapon_tier":rank,"heavy":false,"ranged":true,"preferred_min":270.0,"preferred_max":455.0,
			"abilities":[
				{"id":"praezisionsschuss","shape":"projectile","range":610.0,"damage":roundi(damage*1.55),"half_angle":0.0,"phase":1.0},
				{"id":"salve","shape":"projectile","range":540.0,"damage":roundi(damage*.88),"half_angle":0.0,"phase":1.0,"projectiles":5,"spread":.13},
				{"id":"tarnrolle","shape":"projectile","range":480.0,"damage":roundi(damage*1.1),"half_angle":0.0,"phase":.68,"blink":190.0},
				{"id":"jagdrausch","shape":"projectile","range":600.0,"damage":roundi(damage*1.0),"half_angle":0.0,"phase":.38,"projectiles":9,"spread":.105}
			]
		}
	var cycle=2.6 if heavy else (2.7 if ranged else 2.2)
	var windup=.9 if heavy else (.7 if ranged else (.65 if early else .55))
	var recovery=.75 if heavy else (.6 if ranged else .55)
	var reach=72.0 if heavy else (360.0 if ranged else (38.0 if type==3 else 44.0))
	if not early and not ranged:reach+=rank*2.0
	var first={"id":"basic","shape":"projectile" if ranged else "arc","range":reach,"damage":damage,"half_angle":1.05 if heavy else .7,"phase":1.0}
	var abilities:Array=[first]
	if not early:
		if type in [4,7,9,16,24,26]:
			abilities.append({"id":"ground_line","shape":"line","range":190.0,"damage":roundi(damage*.85),"half_angle":0.0,"phase":1.0})
		elif type in [5,6,8,19,20,21,22,23]:
			abilities.append({"id":"burst","shape":"arc","range":85.0,"damage":roundi(damage*.8),"half_angle":1.1,"phase":1.0})
		if level>=36:
			abilities.append({"id":"heavy_arc","shape":"arc","range":reach if not ranged else 100.0,"damage":damage,"half_angle":1.3,"phase":1.0})
	return {"movement_speed":float(info["speed"])*(.9 if heavy else 1.0),"attack_cycle":cycle,"windup":windup,"active_time":.18 if heavy else .12,"recovery":recovery,"attack_range":reach,"hit_radius":14.0,"projectile_speed":230.0 if early else 265.0,"aggro_range":620.0 if not early else 520.0,"leash_range":800.0,"damage":damage,"weapon_tier":rank,"abilities":abilities,"heavy":heavy,"ranged":ranged,"preferred_min":140.0 if ranged else 0.0,"preferred_max":250.0 if ranged else reach}

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
		if distance>=limit or home.distance_to(candidate["pos"])>=float(config["leash_range"]):continue
		var score:float=distance
		# Klassenbosse wechseln intelligent auf verwundbare Ziele statt stumpf
		# immer nur den nächsten Spieler zu verfolgen.
		if int(enemy["type"]) in [12,13,14]:
			var hp_ratio:=clampf(float(candidate.get("hp",1.0))/maxf(1.0,float(candidate.get("max_hp",1.0))),0.0,1.0)
			score*=.72+hp_ratio*.38
		if score<best:
			target=candidate;best=score
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
				var projectile_count:=maxi(1,int(ability.get("projectiles",1)))
				var spread:=float(ability.get("spread",0.0))
				for shot_index in projectile_count:
					var centered:=float(shot_index)-float(projectile_count-1)*.5
					result["events"].append({"kind":"projectile","dir":direction.rotated(centered*spread),"damage":ability["damage"],"attack_id":state["id"],"ability_id":str(ability.get("id","basic"))})
			else:
				for victim in targets:
					if hits(position,direction,victim["pos"],ability,float(config["hit_radius"])):
						for hit_index in maxi(1,int(ability.get("multi",1))):
							result["events"].append({"kind":"damage","target":victim["id"],"damage":ability["damage"],"attack_id":state["id"],"ability_id":str(ability.get("id","basic"))})
			if float(ability.get("dash",0.0))>0.0:
				result["events"].append({"kind":"boss_move","dir":direction,"distance":float(ability["dash"]),"ability_id":str(ability.get("id","basic"))})
			if float(ability.get("blink",0.0))>0.0:
				result["events"].append({"kind":"boss_move","dir":-direction,"distance":float(ability["blink"]),"ability_id":str(ability.get("id","basic"))})
		var finish=strike+float(config["active_time"])+float(config["recovery"])
		if float(state["age"])>=finish:
			enemy["attack_wait"]=maxf(0,float(config["attack_cycle"])-float(state["age"]))
			enemy["attack_state"]={}
		else:enemy["attack_state"]=state
		return result
	var abilities:Array=[]
	var hp_ratio:=clampf(float(enemy["hp"])/maxf(1.0,float(enemy["max_hp"])),0.0,1.0)
	for raw_ability in config["abilities"]:
		if hp_ratio<=float(raw_ability.get("phase",1.0)):abilities.append(raw_ability)
	if abilities.is_empty():abilities=[config["abilities"][0]]
	var sequence=int(enemy.get("attack_sequence",0))
	var ability:Dictionary=abilities[sequence%abilities.size()]
	if best<=float(ability["range"])+float(config["hit_radius"]) and float(enemy["attack_wait"])<=0:
		enemy["attack_sequence"]=sequence+1
		enemy["attack_state"]={"id":sequence+1,"age":0.0,"dir":toward,"ability":ability.duplicate(),"fired":false}
		enemy["facing"]=toward
		return result
	var preferred_min:=float(config.get("preferred_min",140.0))
	var preferred_max:=float(config.get("preferred_max",250.0))
	if bool(config["ranged"]):
		if best<preferred_min:
			result["move"]=-toward
		elif best>preferred_max:
			result["move"]=toward
		elif int(enemy["type"]) in [13,14]:
			var side:=1.0 if (sequence+int(absf(float(enemy.get("seed",0))*10.0)))%2==0 else -1.0
			result["move"]=toward.rotated(side*PI*.5)*.82
	else:
		if best>preferred_max:result["move"]=toward
		elif int(enemy["type"])==12 and best<58.0:result["move"]=-toward*.35
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
