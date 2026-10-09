extends RefCounted
## Dauerhafter Nebel über der ganzen Welt (C1 „Start im Dunkeln“).
## Ein Raster über alle Gebietsgrenzen hinweg: Was ein Charakter einmal gesehen
## hat, bleibt aufgedeckt (pro Charakter gespeichert). Unaufgedecktes ist im
## Spielbild, auf der Minikarte und auf der großen Karte dunkel.
## Gruppenmitglieder decken nur auf, solange sie in der Nähe sind.

## 64 px pro Zelle (2 m). Ein Meter sind 32 px, eine Bodenkachel.
const CELL:=64
## 20 m Sichtweite.
const REVEAL_RADIUS:=640.0
## Gruppenmitglieder weiter weg als 50 m teilen ihre Sicht nicht.
const PARTY_SHARE_RANGE:=1600.0
## Alte Spielstände nutzten 256-px-Zellen; sie werden beim Laden umgerechnet.
const LEGACY_CELL:=256
## Erst nach so vielen Pixeln Bewegung wird neu aufgedeckt.
const REVEAL_STEP:=16.0
const DARK:=Color("04070b")

var world_size:=Vector2.ZERO
var cols:=0
var rows:=0
var bytes:=PackedByteArray()
var last_reveal:Array=[]

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
	bytes[index>>3]=int(bytes[index>>3]) | (1<<(index&7))

func seen(cell:Vector2i)->bool:
	var index:=cell_index(cell)
	if index<0:return false
	return (int(bytes[index>>3]) & (1<<(index&7)))!=0

func reveal(pos:Vector2,radius:float=REVEAL_RADIUS)->void:
	if cols<=0:return
	var center:=world_cell(pos)
	var span:=ceili(radius/CELL)+1
	var limit:=radius+CELL*0.5
	for y in range(maxi(0,center.y-span),mini(rows,center.y+span+1)):
		for x in range(maxi(0,center.x-span),mini(cols,center.x+span+1)):
			var world_center:=(Vector2(x,y)+Vector2(0.5,0.5))*CELL
			if world_center.distance_to(pos)<=limit:set_seen(Vector2i(x,y))

func party_positions(g)->Array:
	var local_context:=str(g.multiplayer_context()) if g.has_method("multiplayer_context") else "world"
	var local_instance:=str(g.multiplayer_instance_id()) if g.has_method("multiplayer_instance_id") else "world"
	var out:Array=[]
	if local_context!="world":return out
	var me:Vector2=g.player_pos
	out.append(me)
	for raw in (g.party_state.get("members",[]) as Array):
		if not raw is Dictionary:continue
		var row:Dictionary=raw
		if "player_uuid" in g and str(row.get("uuid",""))==str(g.player_uuid):continue
		if str(row.get("context","world"))!=local_context or str(row.get("instance_id","world"))!=local_instance:continue
		var p:Variant=row.get("pos",[])
		if p is Array and p.size()>=2:
			var pos:=Vector2(float(p[0]),float(p[1]))
			if not pos.is_finite() or pos.x<0 or pos.y<0 or pos.x>world_size.x or pos.y>world_size.y:continue
			if pos.is_equal_approx(me) or pos.distance_to(me)>PARTY_SHARE_RANGE:continue
			out.append(pos)
	return out

func update_from_game(g)->void:
	if world_size!=g.WORLD:configure(g.WORLD)
	var eyes:=party_positions(g)
	for pos in eyes:
		var fresh:=true
		for old in last_reveal:
			if Vector2(old).distance_to(pos)<REVEAL_STEP:
				fresh=false
				break
		if fresh:reveal(pos)
	last_reveal=eyes

func visible_now(pos:Vector2,g,radius:float=REVEAL_RADIUS)->bool:
	for eye in party_positions(g):
		if Vector2(eye).distance_to(pos)<=radius:return true
	return false

func explored_world(pos:Vector2)->bool:
	return seen(world_cell(pos))

## Speichern: feines Raster als Base64-Text. Dazu bleibt das alte grobe Raster
## (`legacy_snapshot`) im Spielstand, damit ältere Stände lesbar bleiben.
func snapshot()->String:
	return Marshalls.raw_to_base64(bytes)

func legacy_snapshot()->Array:
	var legacy_cols:=maxi(1,ceili(world_size.x/LEGACY_CELL))
	var legacy_rows:=maxi(1,ceili(world_size.y/LEGACY_CELL))
	var out:Array=[]
	out.resize(ceili(float(legacy_cols*legacy_rows)/8.0))
	out.fill(0)
	var ratio:=LEGACY_CELL/CELL
	for y in rows:
		for x in cols:
			if not seen(Vector2i(x,y)):continue
			var index:=int(y/ratio)*legacy_cols+int(x/ratio)
			if index>=0 and index>>3<out.size():out[index>>3]=int(out[index>>3]) | (1<<(index&7))
	return out

## Alles wieder verdeckt (neuer Charakter, Charakterwechsel).
func clear()->void:
	bytes.fill(0)
	last_reveal=[]

## `fine` ist der Base64-Text aus `snapshot()`; fehlt er, wird das alte grobe
## Raster `raw` (256 px) auf das feine Raster übertragen.
func restore(raw:Variant,size:Vector2,fine:Variant="")->void:
	configure(size)
	clear()
	if fine is String and fine!="":
		var decoded:=Marshalls.base64_to_raw(fine)
		if decoded.size()==bytes.size():
			bytes=decoded
			return
	if not raw is Array:return
	var legacy_cols:=maxi(1,ceili(size.x/LEGACY_CELL))
	var ratio:=LEGACY_CELL/CELL
	for i in mini(raw.size()*8,legacy_cols*maxi(1,ceili(size.y/LEGACY_CELL))):
		var value:Variant=raw[i>>3]
		if not (value is int or value is float):continue
		if (clampi(int(value),0,255) & (1<<(i&7)))==0:continue
		var base:=Vector2i(i%legacy_cols,int(i/legacy_cols))*ratio
		for dy in ratio:
			for dx in ratio:set_seen(base+Vector2i(dx,dy))

## Prüfung für den Server: gültiger Base64-Text in der richtigen Größe.
static func valid_snapshot(value:Variant,size:Vector2)->bool:
	if not value is String:return false
	if value=="":return true
	if String(value).length()>16384:return false
	var needed:=ceili(float(maxi(1,ceili(size.x/CELL))*maxi(1,ceili(size.y/CELL)))/8.0)
	return Marshalls.base64_to_raw(value).size()==needed

func explored_fraction()->float:
	if cols<=0:return 0.0
	var found:=0
	for b in bytes:
		var v:=int(b)
		while v:
			found+=v&1
			v>>=1
	return float(found)/float(cols*rows)

## Dunkelheit (0 = gesehen, 1 = dunkel) an einem Gitterpunkt zwischen vier Zellen.
func corner_dark(x:int,y:int)->float:
	var lit:=0
	for c in [Vector2i(x-1,y-1),Vector2i(x,y-1),Vector2i(x-1,y),Vector2i(x,y)]:
		if seen(c):lit+=1
	return 1.0-float(lit)/4.0

## Dunkelheit im Spielbild: Ein Dreiecksnetz mit Farbverlauf je Ecke ergibt
## weiche Ränder über eine Zelle (2 m). Gezeichnet in Weltkoordinaten.
func draw_world_darkness(g,view:Rect2)->void:
	if cols<=0:return
	var x0:=maxi(0,floori(view.position.x/CELL)-1)
	var y0:=maxi(0,floori(view.position.y/CELL)-1)
	var x1:=mini(cols,ceili(view.end.x/CELL)+1)
	var y1:=mini(rows,ceili(view.end.y/CELL)+1)
	var points:=PackedVector2Array()
	var colors:=PackedColorArray()
	var indices:=PackedInt32Array()
	var clear_dark:=Color(DARK,0.0)
	for y in range(y0,y1):
		for x in range(x0,x1):
			var a:=corner_dark(x,y)
			var b:=corner_dark(x+1,y)
			var c:=corner_dark(x+1,y+1)
			var d:=corner_dark(x,y+1)
			if a+b+c+d<=0.0:continue
			var base:=points.size()
			var p:=Vector2(x,y)*CELL
			points.append_array([p,p+Vector2(CELL,0),p+Vector2(CELL,CELL),p+Vector2(0,CELL)])
			colors.append_array([clear_dark.lerp(DARK,a),clear_dark.lerp(DARK,b),clear_dark.lerp(DARK,c),clear_dark.lerp(DARK,d)])
			indices.append_array([base,base+1,base+2,base,base+2,base+3])
	if indices.is_empty():return
	RenderingServer.canvas_item_add_triangle_array(g.get_canvas_item(),indices,points,colors)

## Große Karte: unaufgedeckte Zellen zeilenweise zu Streifen zusammengefasst.
func draw_overlay(g,inset:Rect2,map_scale:Vector2)->void:
	if cols<=0:return
	var tint:=Color("071018",0.86)
	for y in rows:
		var run_start:=-1
		for x in cols+1:
			var dark:=x<cols and not seen(Vector2i(x,y))
			if dark and run_start<0:run_start=x
			elif not dark and run_start>=0:
				# Auf ganze Pixel runden, damit zwischen den Zeilen keine Streifen bleiben.
				var top_left:=(inset.position+Vector2(run_start,y)*CELL*map_scale).floor()
				var bottom_right:=(inset.position+Vector2(x,y+1)*CELL*map_scale).floor()
				g.draw_rect(Rect2(top_left,bottom_right-top_left),tint)
				run_start=-1

func draw_live_party_vision(g,inset:Rect2,map_scale:Vector2)->void:
	for raw in party_positions(g):
		var pos:=Vector2(raw)
		var center:=inset.position+pos*map_scale
		var radius:=REVEAL_RADIUS*minf(map_scale.x,map_scale.y)
		g.draw_circle(center,maxf(3.0,radius),Color("9ee7d2",0.06))
		g.draw_arc(center,maxf(4.0,radius),0,TAU,24,Color("9ee7d2",0.35),1.0)
