extends RefCounted
## Bounded local A*: cached per mob, swept segments, deterministic detours.
const CELL=32.0
const BUDGET=384
## Höchstzahl echter Begehbarkeitsprüfungen je Suche (je ~25 µs). Danach gilt
## der beste Teilweg; die Suche wird später erneut versucht.
const MAX_CHECKS=1500
## Pro Serverbild nur so viele neue Suchen; weitere Gegner behalten ihren Weg
## ein Bild länger. -1 = unbegrenzt (Tests, Werkzeuge).
static var routes_left:=-1
## Ob die letzte route() ihr Ziel erreicht hat.
static var last_complete:=true
const DIRECTIONS=[Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0),Vector2i(0,-1),Vector2i(1,1),Vector2i(-1,1),Vector2i(-1,-1),Vector2i(1,-1)]

static func clear_segment(a:Vector2,b:Vector2,walkable:Callable)->bool:
	var count:=maxi(1,ceili(a.distance_to(b)/8.0))
	for index in range(1,count+1):
		if not bool(walkable.call(a.lerp(b,float(index)/count))):return false
	return true

static func route(origin:Vector2,target:Vector2,walkable_raw:Callable)->Array:
	# Dieselben Prüfpunkte kommen in benachbarten Segmenten mehrfach vor.
	var memo:Dictionary={};var checks:=[0]
	var walkable:=func(point:Vector2)->bool:
		var key:=Vector2i((point*16.0).round())
		if memo.has(key):return memo[key]
		checks[0]+=1
		var ok:=bool(walkable_raw.call(point));memo[key]=ok
		return ok
	last_complete=true
	var goal:=origin+ (target-origin).limit_length(640.0)
	if clear_segment(origin,goal,walkable):return [goal]
	var open:Array[Vector2i]=[Vector2i.ZERO]
	var costs:Dictionary={Vector2i.ZERO:0.0}
	var parents:Dictionary={}
	var closed:Dictionary={}
	var valid:Dictionary={Vector2i.ZERO:true}
	var best:=Vector2i.ZERO
	var best_distance:=origin.distance_to(goal)
	for iteration in BUDGET:
		if open.is_empty() or checks[0]>=MAX_CHECKS:break
		var chosen:=0
		var priority:=INF
		for index in open.size():
			var cell:Vector2i=open[index]
			var score:float=costs[cell]+(origin+Vector2(cell)*CELL).distance_to(goal)
			if score<priority:priority=score;chosen=index
		var current:Vector2i=open.pop_at(chosen)
		closed[current]=true
		var position:=origin+Vector2(current)*CELL
		var remaining:=position.distance_to(goal)
		if remaining<best_distance:best=current;best_distance=remaining
		if remaining<=CELL*1.5 and clear_segment(position,goal,walkable):
			var path:=reconstruct(current,parents,origin)
			path.append(goal)
			return path
		for offset in DIRECTIONS:
			var next:Vector2i=current+offset
			if closed.has(next) or absi(next.x)>22 or absi(next.y)>22:continue
			if not valid.has(next):valid[next]=bool(walkable.call(origin+Vector2(next)*CELL))
			if not valid[next]:continue
			if not clear_segment(position,origin+Vector2(next)*CELL,walkable):continue
			var cost:float=costs[current]+Vector2(offset).length()*CELL
			if not costs.has(next) or cost<float(costs[next]):
				costs[next]=cost;parents[next]=current
				if not open.has(next):open.append(next)
	last_complete=false
	return reconstruct(best,parents,origin)

static func reconstruct(cell:Vector2i,parents:Dictionary,origin:Vector2)->Array:
	var path:Array=[]
	while parents.has(cell):
		path.push_front(origin+Vector2(cell)*CELL)
		cell=parents[cell]
	return path

## Der gespeicherte Weg endet genau am (kaum bewegten) Ziel und der nächste
## Abschnitt ist frei.
static func still_valid(enemy:Dictionary,origin:Vector2,target:Vector2,path:Array,walkable:Callable)->bool:
	if path.is_empty() or not bool(enemy.get("nav_complete",false)):return false
	if Vector2(path.back()).distance_to(target)>64.0:return false
	return clear_segment(origin,path[0],walkable)

static func direction(enemy:Dictionary,target:Vector2,delta:float,walkable:Callable)->Vector2:
	var origin:Vector2=enemy["pos"]
	var wait:=maxf(0.0,float(enemy.get("nav_wait",0.0))-delta)
	var path:Array=enemy.get("nav_path",[])
	var changed:=Vector2(enemy.get("nav_target",target)).distance_to(target)>64.0
	if wait<=0.0 and not changed and still_valid(enemy,origin,target,path,walkable):
		# Ziel kaum bewegt und der vollständige alte Weg ist frei: weiter nutzen
		# statt neu zu suchen. Ein versperrter Schritt setzt nav_wait ohnehin auf 0
		# und ein geändertes Ziel erzwingt eine neue Suche.
		wait=.6+fmod(absf(float(enemy.get("uid",0))),7.0)*.03
	elif (wait<=0.0 or changed) and routes_left==0:
		# Suchkontingent dieses Bildes verbraucht: im nächsten Bild planen.
		wait=0.0
	elif wait<=0.0 or changed:
		if routes_left>0:routes_left-=1
		path=route(origin,target,walkable)
		enemy["nav_target"]=target
		enemy["nav_complete"]=last_complete and Vector2(path.back() if not path.is_empty() else origin).distance_to(target)<=1.0
		# Unerreichbare Ziele nicht alle 0,6 s erneut voll durchsuchen.
		wait=(.6 if last_complete else 1.5)+fmod(absf(float(enemy.get("uid",0))),7.0)*.03
	# Reach corners precisely; skipping them early can cut through a tree root.
	while not path.is_empty() and origin.distance_to(path[0])<.5:path.pop_front()
	enemy["nav_path"]=path;enemy["nav_wait"]=wait
	if path.is_empty():return Vector2.ZERO
	return (Vector2(path[0])-origin).normalized()
