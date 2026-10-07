extends RefCounted
## Eight-neighbor blob masks plus pixel-crisp, globally continuous organic verges.
## Missing neighbors are lower-priority materials; ground is always fully opaque.
const DIRECTIONS:=[Vector2i(0,-1),Vector2i(1,0),Vector2i(0,1),Vector2i(-1,0),Vector2i(1,-1),Vector2i(1,1),Vector2i(-1,1),Vector2i(-1,-1)]
const PRIORITY:={"arena_border":1,"arena_entry_stone":2,"plaza_stone":3,"spawn_crossing":3,"building_apron":4,"village_stone":5,"old_cobble_rework":5,"village_path":6,"garden_path":6,"arena_ground":6,"forest_ground":7,"village_grass":8,"moss_grass":9}

static func rank(id:String)->int:return int(PRIORITY.get(id,0))

static func normalize(mask:int)->int:
	# N,E,S,W then NE,SE,SW,NW. Diagonals need both adjoining sides.
	for i in 4:
		var next:=(i+1)%4
		if not (mask&(1<<i)) or not (mask&(1<<next)):mask&=~(1<<(4+i))
	return mask

static func all_masks()->Array[int]:
	var result:Array[int]=[]
	for mask in 256:
		var valid:=normalize(mask)
		if valid not in result:result.append(valid)
	result.sort()
	return result

static func mask_for(current:String,cell:Vector2i,families:Dictionary)->int:
	var mask:=0
	for i in 8:
		var neighbor:String=str(families.get(cell+DIRECTIONS[i],current))
		if rank(neighbor)>=rank(current):mask|=1<<i
	return normalize(mask)

static func verge_width(position:int)->int:
	# Smooth integer steps from a shared WORLD coordinate, not independent tile noise.
	return 5+roundi(1.4*sin(position*0.11)+0.9*sin(position*0.037+1.7))

static func foreground_pixel(mask:int,p:Vector2i,cell:Vector2i)->bool:
	var world:=cell*32+p
	var distances:=[p.y,31-p.x,31-p.y,p.x]
	var widths:=[verge_width(world.x),verge_width(world.y),verge_width(world.x),verge_width(world.y)]
	for side in 4:
		if not (mask&(1<<side)) and int(distances[side])<int(widths[side]):return false
	for corner in 4:
		var a:int=int(distances[corner])
		var b:int=int(distances[(corner+1)%4])
		var side_a:bool=bool(mask&(1<<corner))
		var side_b:bool=bool(mask&(1<<((corner+1)%4)))
		if side_a and side_b and not (mask&(1<<(4+corner))) and a+b<8:return false
		if not side_a and not side_b and a+b<int(widths[corner])+int(widths[(corner+1)%4])+3:return false
	return true

static func background_family(current:String,cell:Vector2i,p:Vector2i,families:Dictionary)->String:
	var best:=current
	var nearest:=INF
	for i in 8:
		var neighbor:String=str(families.get(cell+DIRECTIONS[i],current))
		if rank(neighbor)>=rank(current):continue
		var delta:Vector2i=DIRECTIONS[i]
		var dx:=0.0 if delta.x==0 else float(p.x+1 if delta.x<0 else 32-p.x)
		var dy:=0.0 if delta.y==0 else float(p.y+1 if delta.y<0 else 32-p.y)
		var distance:=Vector2(dx,dy).length_squared()
		if distance<nearest:nearest=distance;best=neighbor
	return best
