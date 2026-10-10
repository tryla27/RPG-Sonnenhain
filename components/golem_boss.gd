extends RefCounted
# Der Dunkle Golem: Endgegner des Himmelsgartens (docs/konzepte/2026-10-09-golem).
#
# Hier liegen Regeln und Zustand des Kampfes: Beschwörung am Altar, Schild,
# Steinhagel-Feld, Brockenwurf (mit liegenden Brocken und umgeworfenen Bäumen),
# Schrei, Zerfall in zwei halbe Golems, Himmelsfalter-Wellen und die Beute.
# Der Server rechnet alles; Spieler bekommen den Zustand über das Weltpaket
# (snapshot/apply_snapshot) und zeichnen ihn mit golem_design.gd.
#
# main.gd stellt bereit: enemies, make_enemy, world_time, golem_hit_players,
# golem_scream, golem_push_mobs, golem_minion_spawn, golem_trees_changed,
# decorative_tree_in_cell, region_at, terrain_blocked, play_world_sound.

const TYPE_BIG:=27
const TYPE_HALF:=28
const TYPES:=[27,28]
const ALTAR:=Vector2(14900,8650)
const ALTAR_USE_RANGE:=150.0
const ARENA_RADIUS:=650.0
const SUMMON_COST:={"Steinbeeren":30,"Rotkuchen":1,"Blaukuchen":1}

## Leben: ENEMY_TYPES 27/28 (6000/3000) mal Stufenfaktor wie alle Gegner
## (Himmelsgarten Stufe 40 → ×5,6), je weiterem Spieler +70 %.
const HP_PER_EXTRA_PLAYER:=0.70
const SPEED:=40.0
const FIELD_SPEED_MULT:=1.30
## Verlangsamung wirkt im Feld nur halb so stark.
const FIELD_SLOW_RESIST:=0.5
const HALF_SPEED:=52.0

const SHIELD_TIME:=8.0
const SHIELD_COOLDOWN:=30.0
const SHIELD_DAMAGE_MULT:=0.01
const FIELD_RADIUS:=320.0
const FIELD_TIME:=12.0
const HAIL_INTERVAL:=0.22
const HAIL_DELAY:=1.2
const HAIL_RADIUS:=46.0
## Schaden als Anteil des Golem-Grundschadens (enemy_damage(27), Stufe 40 ≈ 233).
const HAIL_DAMAGE:=0.30

const THROW_COOLDOWN:=10.0
const SCRAPE_TIME:=1.0
const THROW_FLIGHT:=480.0
const THROW_ROLL:=96.0
const FLIGHT_TIME:=0.8
const ROLL_TIME:=0.7
const BOULDER_RADIUS:=44.0
const THROW_DAMAGE:=1.0
const THROW_PUSH:=170.0
const MAX_BOULDERS:=24

const SCREAM_THRESHOLD:=0.40
const SCREAM_PAUSE:=1.4
const SCREAM_DAMAGE_FRACTION:=0.25

const MINION_TYPE:=25
const MINION_INTERVAL:=8.0
const MINION_MAX:=10
const TREE_REGROW_SECONDS:=600.0

## Nahkampf: Stampfer vor dem Golem.
const MELEE_DAMAGE:=1.3
const MELEE_COOLDOWN:=2.4
const MELEE_RANGE:=150.0
const MELEE_PUSH:=120.0

const XP_BIG:=1500
const XP_HALF:=300

# --- Zustand ---------------------------------------------------------------
## Hagel-Einschläge mit Vorwarnung: {pos, delay, damage}
var hail:Array=[]
## Steinhagel-Felder: {pos, life, next, owner}
var fields:Array=[]
## Fliegende/rollende Brocken: {from, dir, t, hits}
var throws:Array=[]
## Liegende Brocken bleiben bis zum nächsten Golem: [Vector2]
var boulders:Array=[]
## Umgeworfene Bäume: "tx:ty" -> Unix-Zeit, zu der sie wieder stehen.
var knocked_trees:Dictionary={}
## Schrei-Welle für das Bild: Startzeit (world_time) oder -1.
var scream_at:=-1.0
var scream_pos:=ALTAR
var minion_timer:=0.0
var fight_active:=false
var version:=0
## Wer am Kampf beteiligt war (Peer-ID, 0 = allein) bekommt die Golem-Rüstung.
var participants:Dictionary={}

static func is_golem(enemy:Dictionary)->bool:
	return int(enemy.get("type",-1)) in TYPES

static func visual_scale(type:int)->float:
	return 4.0 if type==TYPE_BIG else 2.0

static func max_hp(base:float,players:int)->float:
	return base*(1.0+HP_PER_EXTRA_PLAYER*maxi(0,players-1))

static func base_damage(g)->float:
	return float(g.enemy_damage(TYPE_BIG))

static func damage_mult(type:int)->float:
	return 1.0 if type==TYPE_BIG else 0.5

static func in_arena(p:Vector2,margin:float=0.0)->bool:
	return p.distance_to(ALTAR)<=ARENA_RADIUS+margin

## Fehlende Zutaten als Text ("" = alles da).
static func missing_offerings(counts:Dictionary)->String:
	var missing:Array=[]
	for name in SUMMON_COST:
		var need:int=int(SUMMON_COST[name])
		var have:int=int(counts.get(name,0))
		if have<need:missing.append("%d× %s" % [need-have,name])
	return ", ".join(missing)

static func tree_key(cell:Vector2i)->String:
	return "%d:%d" % [cell.x,cell.y]

func tree_knocked(cell:Vector2i,now:float=Time.get_unix_time_from_system())->bool:
	var key:=tree_key(cell)
	return knocked_trees.has(key) and float(knocked_trees[key])>now

func alive_golems(enemies:Array)->Array:
	var out:Array=[]
	for e in enemies:
		if is_golem(e) and float(e.get("hp",0))>0:out.append(e)
	return out

## Neuer Golem: alte Brocken verschwinden, Kampf beginnt.
func summon(g,players:int)->Dictionary:
	var golem:Dictionary=g.make_enemy(TYPE_BIG,ALTAR+Vector2(0,-40))
	var hp:=max_hp(float(golem["max_hp"]),players)
	golem["hp"]=hp;golem["max_hp"]=hp
	golem["golem"]={"state":"rise","timer":2.0,"shield_cd":6.0,"throw_cd":5.0,"screamed":false,"players":players}
	golem["context"]="world";golem["instance_id"]="world"
	boulders.clear()
	hail.clear();fields.clear();throws.clear()
	participants.clear()
	fight_active=true
	minion_timer=3.0
	version+=1
	return golem

static func make_half(g,big:Dictionary,side:int)->Dictionary:
	var info:Dictionary=big.get("golem",{})
	var half:Dictionary=g.make_enemy(TYPE_HALF,Vector2(big["pos"])+Vector2(side*90,10))
	var hp:=max_hp(float(half["max_hp"]),int(info.get("players",1)))
	half["hp"]=hp;half["max_hp"]=hp
	half["golem"]={"state":"rise","timer":1.2,"shield_cd":12.0+side*4.0,"throw_cd":4.0+side*2.0,"screamed":true,"players":int(info.get("players",1))}
	half["context"]="world";half["instance_id"]="world"
	return half

func in_field(p:Vector2)->bool:
	for f in fields:
		if p.distance_to(Vector2(float(f["pos"][0]),float(f["pos"][1])))<=FIELD_RADIUS:return true
	return false

## Schaden, den ein Golem gerade nimmt (Schild: −99 %).
static func incoming_mult(enemy:Dictionary)->float:
	var info:Dictionary=enemy.get("golem",{})
	return SHIELD_DAMAGE_MULT if str(info.get("state",""))=="shield" else 1.0

## Ein Golem-Zug. targets: [{pos, id}] (id 0 = lokaler Spieler).
func update_golem(g,enemy:Dictionary,targets:Array,delta:float)->void:
	var info:Dictionary=enemy.get("golem",{})
	if info.is_empty():return
	var type:=int(enemy["type"])
	var pos:Vector2=enemy["pos"]
	info["shield_cd"]=maxf(0.0,float(info.get("shield_cd",0))-delta)
	info["throw_cd"]=maxf(0.0,float(info.get("throw_cd",0))-delta)
	info["timer"]=maxf(0.0,float(info.get("timer",0))-delta)
	info["melee_cd"]=maxf(0.0,float(info.get("melee_cd",1.0))-delta)
	var target:=Vector2.ZERO
	var best:=INF
	for t in targets:
		var d:=Vector2(t["pos"]).distance_to(pos)
		if d<best:best=d;target=Vector2(t["pos"])
	var state:=str(info.get("state","walk"))
	match state:
		"rise","scream_pause":
			if float(info["timer"])<=0.0:
				if state=="scream_pause":
					scream_at=float(g.world_time)
					scream_pos=pos
					g.golem_scream(pos)
				info["state"]="walk"
		"shield":
			if float(info["timer"])<=0.0:info["state"]="walk"
		"scrape":
			if float(info["timer"])<=0.0:
				var dir:Vector2=Vector2(info.get("aim",[0,1])[0],info.get("aim",[0,1])[1]).normalized()
				throws.append({"from":[pos.x,pos.y+20],"dir":[dir.x,dir.y],"t":0.0,"hits":[],"mult":damage_mult(type)})
				g.play_world_sound("golem_wurf",pos)
				info["state"]="walk"
				version+=1
		_:
			# Schrei einmal unter 40 % (nur der große Golem).
			if type==TYPE_BIG and not bool(info.get("screamed",false)) and float(enemy["hp"])<float(enemy["max_hp"])*SCREAM_THRESHOLD:
				info["screamed"]=true;info["state"]="scream_pause";info["timer"]=SCREAM_PAUSE
				g.play_world_sound("golem_schrei",pos)
			elif float(info["shield_cd"])<=0.0 and best<900.0:
				info["state"]="shield";info["timer"]=SHIELD_TIME;info["shield_cd"]=SHIELD_COOLDOWN
				fields.append({"pos":[pos.x,pos.y],"life":FIELD_TIME,"next":0.3,"mult":damage_mult(type)})
				g.play_world_sound("golem_schild",pos)
				version+=1
			elif float(info["throw_cd"])<=0.0 and best<900.0 and target!=Vector2.ZERO:
				var aim:=(target-pos).normalized()
				info["aim"]=[aim.x,aim.y];info["state"]="scrape";info["timer"]=SCRAPE_TIME;info["throw_cd"]=THROW_COOLDOWN
				g.play_world_sound("golem_schaben",pos)
			elif target!=Vector2.ZERO and best<=MELEE_RANGE*visual_scale(type)/4.0 and float(info["melee_cd"])<=0.0:
				info["melee_cd"]=MELEE_COOLDOWN
				var face:=(target-pos).normalized()
				enemy["facing"]=face
				var u:=visual_scale(type)/4.0
				g.golem_hit_players(pos+face*60.0*u,110.0*u,roundi(base_damage(g)*MELEE_DAMAGE*damage_mult(type)),face,MELEE_PUSH)
				g.play_world_sound("brocken_landen",pos+face*60.0*u)
			elif target!=Vector2.ZERO and best>110.0*visual_scale(type)/4.0:
				var speed:=(SPEED if type==TYPE_BIG else HALF_SPEED)
				var slow:=float(enemy.get("slow",0.0))>0.0
				if in_field(pos):
					speed*=FIELD_SPEED_MULT
					if slow:speed*=1.0-(1.0-0.45)*FIELD_SLOW_RESIST
				elif slow:speed*=0.45
				var step:=(target-pos).normalized()*speed*delta
				var next:=pos+step
				if g.region_at(next)==g.region_at(pos) and not boulder_at(next,30.0):
					enemy["pos"]=next
					enemy["facing"]=step.normalized()
					enemy["walking"]=true
					info["step"]=float(info.get("step",0.0))+delta
					if float(info["step"])>=0.9:
						info["step"]=0.0
						g.play_world_sound("golem_schritt",next)
	enemy["golem"]=info

func boulder_at(p:Vector2,margin:float=0.0)->bool:
	for b in boulders:
		if p.distance_to(Vector2(b[0],b[1]))<BOULDER_RADIUS+margin:return true
	return false

## Felder, Hagel, Würfe, Wellen und Bäume. authority=true auf Server/allein.
func update_world(g,delta:float,authority:bool)->void:
	for i in range(fields.size()-1,-1,-1):
		var f:Dictionary=fields[i]
		f["life"]=float(f["life"])-delta
		if f["life"]<=0.0:
			fields.remove_at(i);version+=1;continue
		if not authority:continue
		f["next"]=float(f["next"])-delta
		while float(f["next"])<=0.0:
			f["next"]=float(f["next"])+HAIL_INTERVAL
			var center:=Vector2(f["pos"][0],f["pos"][1])
			var spot:=center+Vector2.RIGHT.rotated(randf()*TAU)*sqrt(randf())*FIELD_RADIUS
			hail.append({"pos":[spot.x,spot.y],"delay":HAIL_DELAY,"damage":roundi(base_damage(g)*HAIL_DAMAGE*float(f.get("mult",1.0)))})
	for i in range(hail.size()-1,-1,-1):
		var h:Dictionary=hail[i]
		h["delay"]=float(h["delay"])-delta
		if h["delay"]>0.0:continue
		var p:=Vector2(h["pos"][0],h["pos"][1])
		if authority:g.golem_hit_players(p,HAIL_RADIUS,int(h["damage"]),Vector2.ZERO,0.0)
		g.play_world_sound("steinhagel",p)
		hail.remove_at(i)
	for i in range(throws.size()-1,-1,-1):
		var t:Dictionary=throws[i]
		var start:=Vector2(t["from"][0],t["from"][1])
		var dir:=Vector2(t["dir"][0],t["dir"][1])
		var before:=throw_position(start,dir,float(t["t"]))
		t["t"]=float(t["t"])+delta
		var now:=throw_position(start,dir,float(t["t"]))
		if authority:
			var hits:Array=t["hits"]
			g.golem_hit_players(now,BOULDER_RADIUS+20.0,roundi(base_damage(g)*THROW_DAMAGE*float(t.get("mult",1.0))),dir,THROW_PUSH,hits)
			g.golem_push_mobs(now,BOULDER_RADIUS+16.0,dir,THROW_PUSH*delta*4.0)
			knock_trees_between(g,before,now)
		if float(t["t"])>=FLIGHT_TIME+ROLL_TIME or (float(t["t"])>FLIGHT_TIME and g.terrain_blocked(now)):
			if authority:
				boulders.append([now.x,now.y])
				while boulders.size()>MAX_BOULDERS:boulders.pop_front()
			g.play_world_sound("brocken_landen",now)
			throws.remove_at(i)
			version+=1
	if authority and fight_active:
		minion_timer-=delta
		if minion_timer<=0.0:
			minion_timer=MINION_INTERVAL
			g.golem_minion_spawn(MINION_TYPE,MINION_MAX)
	# Bäume wachsen nach 10 Minuten nach.
	if authority and not knocked_trees.is_empty():
		var now_unix:=Time.get_unix_time_from_system()
		for key in knocked_trees.keys():
			if float(knocked_trees[key])<=now_unix:
				knocked_trees.erase(key);version+=1
				g.golem_trees_changed(key)

## Brocken: erst 480 px Flug, dann 96 px Rollen (abgebremst).
static func throw_position(start:Vector2,dir:Vector2,t:float)->Vector2:
	if t<=FLIGHT_TIME:return start+dir*THROW_FLIGHT*(t/FLIGHT_TIME)
	var r:=clampf((t-FLIGHT_TIME)/ROLL_TIME,0.0,1.0)
	return start+dir*(THROW_FLIGHT+THROW_ROLL*(1.0-(1.0-r)*(1.0-r)))

## Höhe des Brockens über dem Boden (für das Bild): Bogen im Flug, 0 beim Rollen.
static func throw_height(t:float)->float:
	if t>=FLIGHT_TIME:return 0.0
	var x:=t/FLIGHT_TIME
	return 4.0*x*(1.0-x)*70.0

func knock_trees_between(g,a:Vector2,b:Vector2)->void:
	var steps:=maxi(1,ceili(a.distance_to(b)/32.0))
	for s in steps+1:
		var p:=a.lerp(b,float(s)/steps)
		var cell:=Vector2i(floori(p.x/64.0),floori(p.y/64.0))
		for dx in range(-1,2):
			for dy in range(-1,2):
				var c:=cell+Vector2i(dx,dy)
				var tree:Dictionary=g.decorative_tree_in_cell(c.x,c.y)
				if tree.is_empty() or Vector2(tree["point"]).distance_to(p)>BOULDER_RADIUS+20.0:continue
				knocked_trees[tree_key(c)]=Time.get_unix_time_from_system()+TREE_REGROW_SECONDS
				version+=1
				g.golem_trees_changed(tree_key(c))

## Sieg erst, wenn kein Golem mehr lebt. Rückgabe: "split", "victory" oder "".
func on_defeated(g,enemy:Dictionary)->String:
	var type:=int(enemy.get("type",-1))
	if type==TYPE_BIG:
		g.enemies.append(make_half(g,enemy,-1))
		g.enemies.append(make_half(g,enemy,1))
		g.play_world_sound("golem_zerfall",Vector2(enemy["pos"]))
		version+=1
		return "split"
	if type==TYPE_HALF and alive_golems(g.enemies).is_empty():
		fight_active=false
		hail.clear();fields.clear()
		version+=1
		return "victory"
	return ""

# --- Netz und Speichern ------------------------------------------------------

func snapshot(now_world:float)->Dictionary:
	return {"hail":hail.duplicate(true),"fields":fields.duplicate(true),"throws":throws.duplicate(true),"boulders":boulders.duplicate(true),"trees":knocked_trees.duplicate(),"scream_age":(now_world-scream_at) if scream_at>=0.0 else -1.0,"scream_pos":[scream_pos.x,scream_pos.y],"active":fight_active,"version":version}

func apply_snapshot(raw:Variant,now_world:float)->bool:
	if not raw is Dictionary:return false
	var changed_trees:bool=raw.get("trees",{})!=knocked_trees
	hail=_rows(raw.get("hail",[]),64)
	fields=_rows(raw.get("fields",[]),8)
	throws=_rows(raw.get("throws",[]),8)
	var b:Variant=raw.get("boulders",[])
	boulders=(b as Array).slice(0,MAX_BOULDERS) if b is Array else []
	var trees:Variant=raw.get("trees",{})
	knocked_trees=trees.duplicate() if trees is Dictionary and trees.size()<=256 else {}
	var age:=float(raw.get("scream_age",-1.0))
	if age>=0.0 and age<6.0 and (scream_at<0.0 or absf((now_world-scream_at)-age)>1.0):
		scream_at=now_world-age
		var sp:Variant=raw.get("scream_pos",[ALTAR.x,ALTAR.y])
		if sp is Array and sp.size()>=2:scream_pos=Vector2(float(sp[0]),float(sp[1]))
	fight_active=bool(raw.get("active",false))
	return changed_trees

static func _rows(raw:Variant,limit:int)->Array:
	if not raw is Array:return []
	var out:Array=[]
	for row in raw:
		if row is Dictionary and out.size()<limit:out.append(row)
	return out

## Dauerhaft auf dem Server: Brocken und Bäume.
func save_state()->Dictionary:
	return {"boulders":boulders.duplicate(true),"trees":knocked_trees.duplicate()}

func load_state(raw:Variant)->void:
	if not raw is Dictionary:return
	var b:Variant=raw.get("boulders",[])
	boulders=(b as Array).slice(0,MAX_BOULDERS) if b is Array else []
	var t:Variant=raw.get("trees",{})
	knocked_trees=t.duplicate() if t is Dictionary else {}
	version+=1
