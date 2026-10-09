extends SceneTree
# Kapelle: Von der Tür aus sind Elara, das Heilpodest und die Gänge zwischen den Bänken erreichbar.

const R=preload("res://components/village_interiors_32.gd")
const RADIUS:=18.0 # größter Figurenradius (Ork)
const STEP:=8.0

var failures:=0
func check(ok:bool,label:String)->void:
	if not ok:
		failures+=1
		push_error("CHAPEL_PATHS_FAIL "+label)

func key(p:Vector2)->Vector2i:return Vector2i(roundi(p.x/STEP),roundi(p.y/STEP))

func reachable_from(start:Vector2)->Dictionary:
	var seen:={}
	var queue:Array=[start]
	seen[key(start)]=true
	while not queue.is_empty():
		var p:Vector2=queue.pop_front()
		for d in [Vector2(STEP,0),Vector2(-STEP,0),Vector2(0,STEP),Vector2(0,-STEP)]:
			var q:Vector2=p+d
			if seen.has(key(q)) or R.blocked(q,Vector2.ZERO,R.ELARA_ID,RADIUS):continue
			seen[key(q)]=true
			queue.append(q)
	return seen

func near(seen:Dictionary,target:Vector2,distance:float)->bool:
	for k in seen:
		if (Vector2(k)*STEP).distance_to(target)<=distance:return true
	return false

func _initialize()->void:
	var start:=R.exit_offset(R.ELARA_ID)-Vector2(0,40)
	check(not R.blocked(start,Vector2.ZERO,R.ELARA_ID,RADIUS),"Eingang frei")
	var seen:=reachable_from(start)
	check(near(seen,R.actor_offset(R.ELARA_ID,"Elara"),40.0),"Elara erreichbar")
	var field:=R.healing_field_pos(Vector2.ZERO,R.ELARA_ID)
	check(seen.has(key(field)) or near(seen,field,8.0),"Heilpodest begehbar")
	var pews:Array=R.furniture(R.ELARA_ID).slice(5,9)
	for side in [[0,2],[1,3]]:
		var upper:Rect2=pews[side[0]]
		var lower:Rect2=pews[side[1]]
		var between:=Vector2(upper.get_center().x,(upper.end.y+lower.position.y)*0.5)
		check(near(seen,between,8.0),"Gang zwischen den Bankreihen bei %s begehbar" % between)
	if failures>0:
		print("CHAPEL_PATHS_FAILED ",failures)
		quit(1)
		return
	print("CHAPEL_PATHS_OK Elara, healing dais and pew aisles reachable from the door")
	quit()
