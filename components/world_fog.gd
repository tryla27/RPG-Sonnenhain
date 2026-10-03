extends RefCounted
## Persistent world-map fog of war on one grid spanning all region borders.
## Party members contribute live vision when they are in the same world instance.
const CELL:=256
const REVEAL_RADIUS:=430.0
var world_size:=Vector2.ZERO
var cols:=0
var rows:=0
var bytes:=PackedByteArray()

func configure(size:Vector2)->void:
	world_size=size
	cols=maxi(1,ceili(size.x/CELL))
	rows=maxi(1,ceili(size.y/CELL))
	var needed:=ceili(float(cols*rows)/8.0)
	if bytes.size()!=needed:
		var old:=bytes
		bytes=PackedByteArray()
		bytes.resize(needed)
		for i in mini(old.size(),bytes.size()):bytes[i]=old[i]

func cell_index(cell:Vector2i)->int:
	if cell.x<0 or cell.y<0 or cell.x>=cols or cell.y>=rows:return -1
	return cell.y*cols+cell.x

func world_cell(pos:Vector2)->Vector2i:
	return Vector2i(floori(pos.x/CELL),floori(pos.y/CELL))

func set_seen(cell:Vector2i)->void:
	var index:=cell_index(cell)
	if index<0:return
	var byte_index:=index>>3
	var bit:=index&7
	bytes[byte_index]=int(bytes[byte_index]) | (1<<bit)

func seen(cell:Vector2i)->bool:
	var index:=cell_index(cell)
	if index<0:return false
	var byte_index:=index>>3
	var bit:=index&7
	return (int(bytes[byte_index]) & (1<<bit))!=0

func reveal(pos:Vector2,radius:float=REVEAL_RADIUS)->void:
	if cols<=0:return
	var center:=world_cell(pos)
	var span:=ceili(radius/CELL)+1
	for y in range(center.y-span,center.y+span+1):
		for x in range(center.x-span,center.x+span+1):
			var cell:=Vector2i(x,y)
			var world_center:=(Vector2(cell)+Vector2(0.5,0.5))*CELL
			if world_center.distance_to(pos)<=radius+CELL*.72:set_seen(cell)

func party_positions(g)->Array:
	var out:Array=[g.player_pos]
	var local_context:=str(g.multiplayer_context()) if g.has_method("multiplayer_context") else "world"
	var local_instance:=str(g.multiplayer_instance_id()) if g.has_method("multiplayer_instance_id") else "world"
	for raw in (g.party_state.get("members",[]) as Array):
		if not raw is Dictionary:continue
		var row:Dictionary=raw
		if str(row.get("context","world"))!=local_context or str(row.get("instance_id","world"))!=local_instance:continue
		var p:Variant=row.get("pos",[])
		if p is Array and p.size()>=2:
			var pos:=Vector2(float(p[0]),float(p[1]))
			if pos.is_finite() and pos.x>=0 and pos.y>=0 and pos.x<=world_size.x and pos.y<=world_size.y:out.append(pos)
	return out

func update_from_game(g)->void:
	if world_size!=g.WORLD:configure(g.WORLD)
	for pos in party_positions(g):reveal(pos)

func visible_now(pos:Vector2,g,radius:float=REVEAL_RADIUS)->bool:
	for eye in party_positions(g):
		if Vector2(eye).distance_to(pos)<=radius:return true
	return false

func explored_world(pos:Vector2)->bool:
	return seen(world_cell(pos))

func snapshot()->Array:
	var out:Array=[]
	out.resize(bytes.size())
	for i in bytes.size():out[i]=int(bytes[i])
	return out

func restore(raw:Variant,size:Vector2)->void:
	configure(size)
	if not raw is Array:return
	for i in mini(raw.size(),bytes.size()):
		var value:Variant=raw[i]
		if value is int or value is float:bytes[i]=clampi(int(value),0,255)

func explored_fraction()->float:
	if cols<=0:return 0.0
	var found:=0
	for y in rows:
		for x in cols:
			if seen(Vector2i(x,y)):found+=1
	return float(found)/float(cols*rows)

func draw_overlay(g,inset:Rect2,map_scale:Vector2)->void:
	if cols<=0:return
	var cell_screen:=Vector2(CELL,CELL)*map_scale
	for y in rows:
		for x in cols:
			var cell:=Vector2i(x,y)
			if seen(cell):continue
			var world_pos:=Vector2(cell)*CELL
			var r:=Rect2(inset.position+world_pos*map_scale,cell_screen+Vector2.ONE)
			g.draw_rect(r,Color("071018",0.82))

func draw_live_party_vision(g,inset:Rect2,map_scale:Vector2)->void:
	for raw in party_positions(g):
		var pos:=Vector2(raw)
		var center:=inset.position+pos*map_scale
		var radius:=REVEAL_RADIUS*minf(map_scale.x,map_scale.y)
		g.draw_circle(center,maxf(3.0,radius),Color("9ee7d2",0.06))
		g.draw_arc(center,maxf(4.0,radius),0,TAU,24,Color("9ee7d2",0.35),1.0)
