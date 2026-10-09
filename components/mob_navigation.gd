extends RefCounted
## Bounded local A*: cached per mob, swept segments, deterministic detours.
const CELL=32.0
const BUDGET=384
const DIRECTIONS=[Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0),Vector2i(0,-1),Vector2i(1,1),Vector2i(-1,1),Vector2i(-1,-1),Vector2i(1,-1)]

static func clear_segment(a:Vector2,b:Vector2,walkable:Callable)->bool:
	var count:=maxi(1,ceili(a.distance_to(b)/8.0))
	for index in range(1,count+1):
		if not bool(walkable.call(a.lerp(b,float(index)/count))):return false
	return true

static func route(origin:Vector2,target:Vector2,walkable:Callable)->Array:
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
		if open.is_empty():break
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
	return reconstruct(best,parents,origin)

static func reconstruct(cell:Vector2i,parents:Dictionary,origin:Vector2)->Array:
	var path:Array=[]
	while parents.has(cell):
		path.push_front(origin+Vector2(cell)*CELL)
		cell=parents[cell]
	return path

static func direction(enemy:Dictionary,target:Vector2,delta:float,walkable:Callable)->Vector2:
	var origin:Vector2=enemy["pos"]
	var wait:=maxf(0.0,float(enemy.get("nav_wait",0.0))-delta)
	var path:Array=enemy.get("nav_path",[])
	var changed:=Vector2(enemy.get("nav_target",target)).distance_to(target)>64.0
	if wait<=0.0 or changed:
		path=route(origin,target,walkable)
		enemy["nav_target"]=target
		wait=.6+fmod(absf(float(enemy.get("uid",0))),7.0)*.03
	# Reach corners precisely; skipping them early can cut through a tree root.
	while not path.is_empty() and origin.distance_to(path[0])<.5:path.pop_front()
	enemy["nav_path"]=path;enemy["nav_wait"]=wait
	if path.is_empty():return Vector2.ZERO
	return (Vector2(path[0])-origin).normalized()
