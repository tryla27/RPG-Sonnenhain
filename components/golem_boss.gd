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
# golem_cell_open, golem_reset, decorative_tree_in_cell, region_at,
# terrain_blocked, play_world_sound.
#
# Golem v2 (Angelo 10.10.2026, docs/konzepte/2026-10-10-golem-v2): Prozent-
# Schaden ohne Rüstung, Trefferzonen (Kopf ×1,6), +22 % Feld und Wurf, Wegsuche
# im ganzen Himmelsgarten, Brocken zerbröseln nach dem Kampf, 15 Minuten Pause
# (nicht im Testmodus), schmales Weltpaket für Spieler außerhalb.

const TYPE_BIG:=27
const TYPE_HALF:=28
const TYPES:=[27,28]
const ALTAR:=Vector2(14900,8650)
const ALTAR_USE_RANGE:=150.0
const ARENA_RADIUS:=650.0
## Opfergaben: vorerst keine, Angelo testet den Golem zuerst (10.10.2026).
## Später gilt PLANNED_SUMMON_COST: SUMMON_COST einfach darauf setzen.
const SUMMON_COST:={}
const PLANNED_SUMMON_COST:={"Steinbeeren":30,"Rotkuchen":1,"Blaukuchen":1}

## Leben: ENEMY_TYPES 27/28 (8640/4320) mal Stufenfaktor wie alle Gegner
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
## Golem v2: Durchmesser +22 % (320 → 390).
const FIELD_RADIUS:=390.0
const FIELD_TIME:=12.0
## Felsregen: ein langer Klang für das ganze Feld statt eines Klangs pro Stein
## (Angelo, Klangprobe 10.10.). Leer = bisherige Einzelklänge.
const HAIL_RAIN_SOUND:=""
## Dichte wie vorher trotz größerem Feld (0,22 s × 320²/390²).
const HAIL_INTERVAL:=0.15
const HAIL_DELAY:=1.2
const HAIL_RADIUS:=46.0
## Schaden in Prozent der maximalen Lebenspunkte, Rüstung hilft nicht
## (Angelo 10.10.: Hagel 8 %).
const HAIL_HP_FRACTION:=0.08

const THROW_COOLDOWN:=10.0
const SCRAPE_TIME:=1.0
## Golem v2: Reichweite +22 % (480/96 → 586/117).
const THROW_FLIGHT:=586.0
const THROW_ROLL:=117.0
const FLIGHT_TIME:=0.8
const ROLL_TIME:=0.7
const BOULDER_RADIUS:=44.0
## Brocken: 55 % der maximalen Lebenspunkte (Hälften 27 %), Rüstung hilft nicht.
const THROW_HP_FRACTION:=0.55
const THROW_PUSH:=170.0
const MAX_BOULDERS:=24

const SCREAM_THRESHOLD:=0.40
const SCREAM_PAUSE:=1.4
## Schrei: 34 % der maximalen Lebenspunkte (vorher 25 %, +35 %).
const SCREAM_DAMAGE_FRACTION:=0.34

const MINION_TYPE:=25
const MINION_INTERVAL:=8.0
const MINION_MAX:=10
const TREE_REGROW_SECONDS:=600.0

## Nahkampf: Stampfer vor dem Golem. Erst hebt er 0,6 s die Faust, ein Ring am
## Boden zeigt die Trefferfläche; wer rechtzeitig herausgeht, nimmt nichts
## (Angelo 10.10.: Anzeige ja, 4 s Abklingzeit).
## Stampfer (Auto-Angriff): 45 % der maximalen Lebenspunkte (Hälften 22 %).
const STOMP_HP_FRACTION:=0.45
const MELEE_COOLDOWN:=4.0
const MELEE_RANGE:=150.0
const MELEE_PUSH:=120.0
const STOMP_WINDUP:=0.6
const STOMP_RADIUS:=110.0

const XP_BIG:=1500
const XP_HALF:=300

## Nach dem Sieg schläft der Golem 15 Minuten (für alle auf dem Server,
## nicht im Testmodus). Brocken zerbröseln in 3 s.
const COOLDOWN_SECONDS:=900.0
const CRUMBLE_TIME:=3.0
## Ist 5 Minuten niemand im Himmelsgarten, verschwindet er (ohne Pause).
const RESET_AFTER_ALONE:=300.0

## Trefferzonen in Einheiten u (Füße = 0, nach oben negativ), passend zum Bild.
## Geschosse treffen die Zone, durch die ihre Flugbahn läuft (Kopf vor Rumpf
## vor Beinen); Nahkampf zählt als Rumpf.
## Golem v2: passend zum 128-px-Sprite (1 Sprite-Pixel = 0,625 u, Füße y=124).
const HULL:=Rect2(-40,-78,80,86)
const HEAD_CENTER:=Vector2(0,-58)
const HEAD_RADIUS:=10.0
const TORSO:=Rect2(-34,-60,68,34)
const ZONE_MULT:={"head":1.6,"torso":1.0,"legs":0.75}

## Wegsuche: Raster 64 px über den Himmelsgarten, Körper 90 px (großer Golem).
const NAV_CELL:=64.0
const NAV_BODY:=90.0
const NAV_BUDGET:=600
## Kein Weg gefunden: erst nach 3 s wieder suchen (spart Rechenzeit).
const NAV_RETRY_UNREACHABLE:=3.0
const NAV_REPATH:=1.0
const STUCK_TIME:=2.0
const SIDESTEP_TIME:=0.9
const SMASH_TIME:=3.0

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
## Unix-Zeit, ab der der Altar wieder erweckt (0 = sofort).
var cooldown_until:=0.0
## Restzeit, in der die Brocken zerbröseln (>0 = gerade dabei).
var crumble:=0.0
var alone_time:=0.0
## Offene Rasterzellen für die Wegsuche (Vector2i -> bool), nur feste Hindernisse.
var nav_cells:Dictionary={}
## Leistung (Server): Rechenzeit der Golem-Teile in µs, für das Server-Log.
var perf_us:=0
var perf_max_us:=0
var perf_frames:=0
static func is_golem(enemy:Dictionary)->bool:
	return int(enemy.get("type",-1)) in TYPES

static func visual_scale(type:int)->float:
	return 4.0 if type==TYPE_BIG else 2.0

static func max_hp(base:float,players:int)->float:
	return base*(1.0+HP_PER_EXTRA_PLAYER*maxi(0,players-1))

## Prozent-Schaden: Stampfer, Brocken, Hagel (Anteil der max. Lebenspunkte).
static func hp_fraction(base_fraction:float,mult:float=1.0)->float:
	return base_fraction*mult

## Restzeit der Pause in Sekunden.
func cooldown_left(now:float=Time.get_unix_time_from_system())->float:
	return maxf(0.0,cooldown_until-now)

## Grund, warum nicht beschworen werden darf ("" = darf). Testmodus: keine Pause.
func summon_blocked(enemies:Array,test_mode:bool,now:float=Time.get_unix_time_from_system())->String:
	if not alive_golems(enemies).is_empty():return "Der Dunkle Golem ist bereits erwacht!"
	var left:=cooldown_left(now)
	if left>0.0 and not test_mode:return "Der Golem erwacht wieder in %s." % clock_text(left)
	return ""

static func clock_text(seconds:float)->String:
	var s:=ceili(seconds)
	return "%d:%02d" % [s/60,s%60]

## Trefferzone für eine Flugbahn a→b ("" = verfehlt).
static func shot_zone(golem_pos:Vector2,type:int,a:Vector2,b:Vector2)->String:
	var u:=visual_scale(type)
	var hull:=Rect2(golem_pos+HULL.position*u,HULL.size*u)
	if not segment_hits_rect(a,b,hull):return ""
	var dir:=(b-a).normalized() if a.distance_squared_to(b)>0.01 else Vector2.DOWN
	var head:=golem_pos+HEAD_CENTER*u
	var along:=(head-a).dot(dir)
	if (a+dir*along).distance_to(head)<=HEAD_RADIUS*u:return "head"
	var torso:=Rect2(golem_pos+TORSO.position*u,TORSO.size*u)
	if segment_hits_rect(a-dir*hull.size.length(),b+dir*hull.size.length(),torso):return "torso"
	return "legs"

## Golem-Zustand fürs Weltpaket: ohne Wegsuche-Daten (Pfad bis 100 Punkte).
const NET_KEYS:=["state","timer","aim","stomp_at","screamed","players","smash"]
static func net_info(info:Dictionary)->Dictionary:
	var out:={}
	for key in NET_KEYS:
		if info.has(key):out[key]=info[key]
	return out

static func zone_mult(zone:String)->float:
	return float(ZONE_MULT.get(zone,1.0))

static func segment_hits_rect(a:Vector2,b:Vector2,r:Rect2)->bool:
	if r.has_point(a) or r.has_point(b):return true
	var corners:=[r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.end.y)]
	for k in 4:
		if Geometry2D.segment_intersects_segment(a,b,corners[k],corners[(k+1)%4])!=null:return true
	return false

static func damage_mult(type:int)->float:
	return 1.0 if type==TYPE_BIG else 0.5

static func in_arena(p:Vector2,margin:float=0.0)->bool:
	return p.distance_to(ALTAR)<=ARENA_RADIUS+margin

## Fehlende Zutaten als Text ("" = alles da).
static func missing_offerings(counts:Dictionary,cost:Dictionary=SUMMON_COST)->String:
	var missing:Array=[]
	for name in cost:
		var need:int=int(cost[name])
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
	crumble=0.0;alone_time=0.0
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
		"stomp":
			if float(info["timer"])<=0.0:
				var at:Array=info.get("stomp_at",[pos.x,pos.y])
				var spot:=Vector2(float(at[0]),float(at[1]))
				var u:=visual_scale(type)/4.0
				g.golem_hit_players(spot,STOMP_RADIUS*u,hp_fraction(STOMP_HP_FRACTION,damage_mult(type)),(spot-pos).normalized(),MELEE_PUSH)
				g.play_world_sound("brocken_landen",spot)
				info["state"]="walk"
				version+=1
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
				if HAIL_RAIN_SOUND!="":g.play_world_sound(HAIL_RAIN_SOUND,pos)
				version+=1
			elif float(info["throw_cd"])<=0.0 and best<900.0 and target!=Vector2.ZERO:
				var aim:=(target-pos).normalized()
				info["aim"]=[aim.x,aim.y];info["state"]="scrape";info["timer"]=SCRAPE_TIME;info["throw_cd"]=THROW_COOLDOWN
				g.play_world_sound("golem_schaben",pos)
			elif target!=Vector2.ZERO and best<=MELEE_RANGE*visual_scale(type)/4.0 and float(info["melee_cd"])<=0.0:
				info["melee_cd"]=MELEE_COOLDOWN
				var face:=(target-pos).normalized()
				enemy["facing"]=face
				var spot:=pos+face*60.0*visual_scale(type)/4.0
				info["state"]="stomp";info["timer"]=STOMP_WINDUP;info["stomp_at"]=[spot.x,spot.y]
			elif target!=Vector2.ZERO and best>110.0*visual_scale(type)/4.0:
				walk_towards(g,enemy,info,target,delta)
			elif target==Vector2.ZERO and pos.distance_to(ALTAR)>120.0:
				# Niemand im Himmelsgarten: zurück zum Altar.
				walk_towards(g,enemy,info,ALTAR,delta)
			else:
				enemy["walking"]=false
	enemy["golem"]=info

## Laufen mit Wegsuche: gerade, wenn frei; sonst Weg um Felsen, Brocken und
## Mauern (neu jede Sekunde). Hängt er 2 s, weicht er seitlich aus; hängt er
## danach noch, bricht er 3 s geradeaus durch (Bäume fallen, Brocken zerbrechen).
func walk_towards(g,enemy:Dictionary,info:Dictionary,target:Vector2,delta:float)->void:
	var type:=int(enemy["type"])
	var pos:Vector2=enemy["pos"]
	var speed:=(SPEED if type==TYPE_BIG else HALF_SPEED)
	var slow:=float(enemy.get("slow",0.0))>0.0
	if in_field(pos):
		speed*=FIELD_SPEED_MULT
		if slow:speed*=1.0-(1.0-0.45)*FIELD_SLOW_RESIST
	elif slow:speed*=0.45
	var body:=body_radius(type)
	var smash:=float(info.get("smash",0.0))
	var side:=float(info.get("sidestep",0.0))
	var goal:=target
	if smash>0.0:
		info["smash"]=smash-delta
	elif side>0.0:
		info["sidestep"]=side-delta
		var dir_side:=Vector2(info.get("side_dir",[1,0])[0],info.get("side_dir",[1,0])[1])
		goal=pos+dir_side*200.0
	elif not _line_open_cached(g,info,pos,target,body,delta):
		info["repath"]=float(info.get("repath",0.0))-delta
		var path:Array=info.get("path",[])
		var old_goal:=Vector2(info.get("path_goal",[target.x,target.y])[0],info.get("path_goal",[target.x,target.y])[1])
		if float(info["repath"])<=0.0 or path.is_empty() or old_goal.distance_to(target)>128.0:
			path=find_path(g,pos,target,body)
			info["repath"]=NAV_REPATH if last_path_complete else NAV_RETRY_UNREACHABLE
			info["path_goal"]=[target.x,target.y]
		while not path.is_empty() and pos.distance_to(Vector2(path[0][0],path[0][1]))<24.0:path.pop_front()
		info["path"]=path
		if not path.is_empty():goal=Vector2(path[0][0],path[0][1])
	var step:=(goal-pos).normalized()*speed*delta
	var next:=pos+step
	var moved:=false
	if g.region_at(next)==12 and not g.waystone_safe_at(next):
		if smash>0.0:
			moved=true
			knock_trees_between(g,pos,next)
			crush_boulders(g,next,body*0.5)
		elif not boulder_at(next,body*0.35) and (cell_open(g,next,body) or not cell_open(g,pos,body)):
			moved=true
	if moved:
		enemy["pos"]=next
		enemy["facing"]=step.normalized()
		enemy["walking"]=true
		info["step"]=float(info.get("step",0.0))+delta
		if float(info["step"])>=0.9:
			info["step"]=0.0
			g.play_world_sound(step_sound(type),next)
	else:
		enemy["walking"]=false
	# Festhängen erkennen: kaum vorangekommen.
	var last:=Vector2(info.get("stuck_from",[pos.x,pos.y])[0],info.get("stuck_from",[pos.x,pos.y])[1])
	info["stuck_t"]=float(info.get("stuck_t",0.0))+delta
	if float(info["stuck_t"])>=STUCK_TIME:
		if Vector2(enemy["pos"]).distance_to(last)<speed*STUCK_TIME*0.25 and smash<=0.0:
			if int(info.get("stuck_count",0))%2==0:
				var away:=(target-pos).normalized().orthogonal()*(1.0 if randf()<0.5 else -1.0)
				info["sidestep"]=SIDESTEP_TIME;info["side_dir"]=[away.x,away.y]
			else:
				info["smash"]=SMASH_TIME
			info["stuck_count"]=int(info.get("stuck_count",0))+1
			info["path"]=[];info["repath"]=0.0
		elif Vector2(enemy["pos"]).distance_to(last)>=speed*STUCK_TIME*0.25:
			info["stuck_count"]=0
		info["stuck_t"]=0.0
		info["stuck_from"]=[enemy["pos"].x,enemy["pos"].y]

## Sichtlinie nur alle 0,25 s neu prüfen (sonst jedes Bild bis zu 28 Proben).
func _line_open_cached(g,info:Dictionary,pos:Vector2,target:Vector2,body:float,delta:float)->bool:
	info["los_t"]=float(info.get("los_t",0.0))-delta
	if float(info["los_t"])<=0.0:
		info["los_t"]=0.25
		info["los"]=line_open(g,pos,target,body)
	return bool(info.get("los",true))

## Raster nach der Beschwörung nach und nach füllen (40 Zellen pro Bild),
## damit die erste Wegsuche nicht auf einmal alles rechnen muss.
var nav_warm_index:=0
func warm_nav(g,count:int=40)->void:
	var cols:=ceili(5000.0/NAV_CELL)
	var rows:=ceili(1920.0/NAV_CELL)
	var body:=body_radius(TYPE_BIG)
	for k in count:
		if nav_warm_index>=cols*rows:return
		var cx:=nav_warm_index%cols
		var cy:=nav_warm_index/cols
		nav_warm_index+=1
		cell_open(g,Vector2(11000.0+(cx+0.5)*NAV_CELL,7680.0+(cy+0.5)*NAV_CELL),body)

static func body_radius(type:int)->float:
	return NAV_BODY*visual_scale(type)/4.0

## Feste Hindernisse für den Golem (Felsen, Mauern, Wegstein-Schutz), je
## Rasterzelle einmal berechnet. Bäume tritt er nieder, deshalb zählen sie nicht.
func cell_open(g,p:Vector2,body:float)->bool:
	var key:=Vector3i(floori(p.x/NAV_CELL),floori(p.y/NAV_CELL),roundi(body))
	if nav_cells.has(key):return bool(nav_cells[key])
	var center:=Vector2((key.x+0.5)*NAV_CELL,(key.y+0.5)*NAV_CELL)
	var open:bool=g.golem_cell_open(center,body*0.6)
	nav_cells[key]=open
	return open

## Gerade Linie frei (Rasterzellen und liegende Brocken)?
func line_open(g,a:Vector2,b:Vector2,body:float)->bool:
	var length:=minf(a.distance_to(b),900.0)
	var dir:=(b-a).normalized()
	var steps:=maxi(1,ceili(length/32.0))
	for k in range(1,steps+1):
		var p:=a+dir*length*float(k)/steps
		if not cell_open(g,p,body) or boulder_at(p,body*0.35):return false
	return true

## A* auf dem 64-px-Raster mit Rechenbudget; liefert [[x,y], ...] oder den
## Weg zum nächstgelegenen erreichten Punkt.
var last_path_complete:=true

func find_path(g,from:Vector2,to:Vector2,body:float)->Array:
	var start:=Vector2i(floori(from.x/NAV_CELL),floori(from.y/NAV_CELL))
	var goal:=Vector2i(floori(to.x/NAV_CELL),floori(to.y/NAV_CELL))
	# Brocken einmal pro Suche auf Zellen legen statt je Nachbar alle prüfen.
	var rock_cells:={}
	var reach:=ceili((BOULDER_RADIUS+body*0.35)/NAV_CELL)+1
	for b in boulders:
		var bp:=Vector2(float(b[0]),float(b[1]))
		var bc:=Vector2i(floori(bp.x/NAV_CELL),floori(bp.y/NAV_CELL))
		for dx in range(-reach,reach+1):
			for dy in range(-reach,reach+1):
				var c:=bc+Vector2i(dx,dy)
				if Vector2((c.x+0.5)*NAV_CELL,(c.y+0.5)*NAV_CELL).distance_to(bp)<BOULDER_RADIUS+body*0.35:rock_cells[c]=true
	var heap:Array=[[0.0,start]]
	var cost:Dictionary={start:0.0}
	var parent:Dictionary={}
	var best:=start
	var best_h:=Vector2(start).distance_to(Vector2(goal))
	var expanded:=0
	while not heap.is_empty() and expanded<NAV_BUDGET:
		var current:Vector2i=_heap_pop(heap)[1]
		expanded+=1
		if current==goal:best=current;break
		var h:=Vector2(current).distance_to(Vector2(goal))
		if h<best_h:best_h=h;best=current
		for d in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1),Vector2i(1,1),Vector2i(-1,1),Vector2i(1,-1),Vector2i(-1,-1)]:
			var n:Vector2i=current+d
			var center:=Vector2((n.x+0.5)*NAV_CELL,(n.y+0.5)*NAV_CELL)
			if n!=goal and (rock_cells.has(n) or not cell_open(g,center,body)):continue
			if d.x!=0 and d.y!=0:
				# Keine Ecken schneiden.
				if not cell_open(g,Vector2((current.x+d.x+0.5)*NAV_CELL,(current.y+0.5)*NAV_CELL),body) or not cell_open(g,Vector2((current.x+0.5)*NAV_CELL,(current.y+d.y+0.5)*NAV_CELL),body):continue
			var c:float=float(cost[current])+(1.4142 if d.x!=0 and d.y!=0 else 1.0)
			if not cost.has(n) or c<float(cost[n]):
				cost[n]=c;parent[n]=current
				_heap_push(heap,[c+Vector2(n).distance_to(Vector2(goal)),n])
	last_path_complete=best==goal
	var path:Array=[]
	var cell:=best
	while parent.has(cell):
		path.push_front([(cell.x+0.5)*NAV_CELL,(cell.y+0.5)*NAV_CELL])
		cell=parent[cell]
	if best==goal and not path.is_empty():path[-1]=[to.x,to.y]
	return path

static func _heap_push(heap:Array,item:Array)->void:
	heap.append(item)
	var i:=heap.size()-1
	while i>0:
		var up:=(i-1)/2
		if float(heap[up][0])<=float(item[0]):break
		heap[i]=heap[up];i=up
	heap[i]=item

static func _heap_pop(heap:Array)->Array:
	var top:Array=heap[0]
	var last:Array=heap.pop_back()
	if heap.is_empty():return top
	var i:=0
	var n:=heap.size()
	while true:
		var l:=i*2+1
		if l>=n:break
		var r:=l+1
		var c:=l if r>=n or float(heap[l][0])<=float(heap[r][0]) else r
		if float(heap[c][0])>=float(last[0]):break
		heap[i]=heap[c];i=c
	heap[i]=last
	return top

## Durchbrechen: Brocken im Weg zerspringen.
func crush_boulders(g,p:Vector2,radius:float)->void:
	for i in range(boulders.size()-1,-1,-1):
		if p.distance_to(Vector2(boulders[i][0],boulders[i][1]))<BOULDER_RADIUS+radius:
			g.play_world_sound("brocken_landen",Vector2(boulders[i][0],boulders[i][1]))
			boulders.remove_at(i)
			version+=1

## Großer Golem: schwerer Schritt; halbe Golems: eigener Stampfer.
static func step_sound(type:int)->String:
	return "golem_schritt" if type==TYPE_BIG else "golem_schritt_klein"

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
			hail.append({"pos":[spot.x,spot.y],"delay":HAIL_DELAY,"fraction":hp_fraction(HAIL_HP_FRACTION,float(f.get("mult",1.0)))})
	for i in range(hail.size()-1,-1,-1):
		var h:Dictionary=hail[i]
		h["delay"]=float(h["delay"])-delta
		if h["delay"]>0.0:continue
		var p:=Vector2(h["pos"][0],h["pos"][1])
		if authority:g.golem_hit_players(p,HAIL_RADIUS,float(h.get("fraction",HAIL_HP_FRACTION)),Vector2.ZERO,0.0)
		if HAIL_RAIN_SOUND=="":g.play_world_sound("steinhagel",p)
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
			g.golem_hit_players(now,BOULDER_RADIUS+20.0,hp_fraction(THROW_HP_FRACTION,float(t.get("mult",1.0))),dir,THROW_PUSH,hits)
			g.golem_push_mobs(now,BOULDER_RADIUS+16.0,dir,THROW_PUSH*delta*4.0)
			knock_trees_between(g,before,now)
		if float(t["t"])>=FLIGHT_TIME+ROLL_TIME or (float(t["t"])>FLIGHT_TIME and g.terrain_blocked(now)):
			if authority:
				boulders.append([now.x,now.y])
				while boulders.size()>MAX_BOULDERS:boulders.pop_front()
			g.play_world_sound("brocken_landen",now)
			throws.remove_at(i)
			version+=1
	# Nach dem Kampf zerbröseln die Brocken.
	if crumble>0.0:
		crumble-=delta
		if crumble<=0.0:
			crumble=0.0
			if authority:
				boulders.clear();version+=1
	# Niemand mehr im Himmelsgarten: nach 5 Minuten verschwindet der Golem.
	if authority and fight_active:
		if g.golem_targets().is_empty():
			alone_time+=delta
			if alone_time>=RESET_AFTER_ALONE:
				g.golem_reset()
				end_fight(false)
				return
		else:alone_time=0.0
	if authority and fight_active:
		warm_nav(g)
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

## Kampf vorbei: Felder weg, Brocken zerbröseln; nach einem Sieg 15 Minuten Pause.
func end_fight(victory:bool,now:float=Time.get_unix_time_from_system())->void:
	fight_active=false
	hail.clear();fields.clear();throws.clear()
	crumble=CRUMBLE_TIME if not boulders.is_empty() else 0.0
	alone_time=0.0
	if victory:cooldown_until=now+COOLDOWN_SECONDS
	version+=1

## Brocken: erst 586 px Flug, dann 117 px Rollen (abgebremst).
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
		end_fight(true)
		return "victory"
	return ""

# --- Netz und Speichern ------------------------------------------------------

func snapshot(now_world:float)->Dictionary:
	return {"hail":hail.duplicate(true),"fields":fields.duplicate(true),"throws":throws.duplicate(true),"boulders":boulders.duplicate(true),"trees":knocked_trees.duplicate(),"scream_age":(now_world-scream_at) if scream_at>=0.0 else -1.0,"scream_pos":[scream_pos.x,scream_pos.y],"active":fight_active,"version":version,"cooldown":cooldown_left(),"crumble":crumble}

## Schmales Paket für Spieler außerhalb des Himmelsgartens: nur Kartensymbol
## und Pause (spart ≈ 2,8 KB pro Paket und Spieler).
func lite_snapshot()->Dictionary:
	return {"lite":true,"active":fight_active,"version":version,"cooldown":cooldown_left()}

## Golem-Teil des Weltpakets für einen Spieler an `pos`.
static func needs_full(pos:Vector2)->bool:
	return Rect2(11000,7680,5000,1920).grow(700.0).has_point(pos)

## Geänderte Baumschlüssel zwischen zwei Ständen (für gezieltes Neuzeichnen).
static func tree_diff(a:Dictionary,b:Dictionary)->Array:
	var out:Array=[]
	for key in a:
		if not b.has(key):out.append(key)
	for key in b:
		if not a.has(key):out.append(key)
	return out

## Rückgabe: geänderte Baumschlüssel (leer = nichts neu zu zeichnen).
func apply_snapshot(raw:Variant,now_world:float,now_unix:float=Time.get_unix_time_from_system())->Array:
	if not raw is Dictionary:return []
	cooldown_until=now_unix+clampf(float(raw.get("cooldown",0.0)),0.0,COOLDOWN_SECONDS)
	fight_active=bool(raw.get("active",false))
	if bool(raw.get("lite",false)):
		hail.clear();fields.clear();throws.clear()
		return []
	var new_trees:Variant=raw.get("trees",{})
	var changed_trees:Array=tree_diff(knocked_trees,new_trees if new_trees is Dictionary else {})
	var crumble_raw:=clampf(float(raw.get("crumble",0.0)),0.0,CRUMBLE_TIME)
	crumble=crumble_raw
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
	return changed_trees

static func _rows(raw:Variant,limit:int)->Array:
	if not raw is Array:return []
	var out:Array=[]
	for row in raw:
		if row is Dictionary and out.size()<limit:out.append(row)
	return out

## Dauerhaft auf dem Server: Brocken, Bäume und die Pause des Altars.
func save_state()->Dictionary:
	return {"boulders":boulders.duplicate(true),"trees":knocked_trees.duplicate(),"cooldown_until":cooldown_until}

func load_state(raw:Variant)->void:
	if not raw is Dictionary:return
	var b:Variant=raw.get("boulders",[])
	boulders=(b as Array).slice(0,MAX_BOULDERS) if b is Array else []
	var t:Variant=raw.get("trees",{})
	knocked_trees=t.duplicate() if t is Dictionary else {}
	cooldown_until=float(raw.get("cooldown_until",0.0))
	# Nach einem Neustart lebt kein Golem mehr (Gegner werden nicht gespeichert):
	# liegengebliebene Brocken zerbröseln wie nach jedem Kampf.
	fight_active=false
	crumble=CRUMBLE_TIME if not boulders.is_empty() else 0.0
	version+=1
