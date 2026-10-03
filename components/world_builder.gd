extends RefCounted
## Ingame 32px world authoring tool. Data-driven and intentionally isolated from normal saves.
const Palette=preload("res://components/world_material_palette_32.gd")
const TILE:=32
const FILE_PATH:="user://sonnenhain_world_builder.json"
const CANVAS:=Rect2(360,142,600,384)
const VIEW_CELLS:=Vector2i(18,12)

var active:=false
var layer:="ground"
var material_id:="grass_meadow"
var camera_cell:=Vector2i.ZERO
var cells:Dictionary={"ground":{},"walls":{},"objects":{},"triggers":{}}
var undo_stack:Array=[]
var redo_stack:Array=[]
var status:="32px-Raster · Änderungen sind nur Builder-Daten, kein Spielstand."
var validation:Array=[]
var dragging:=false
var last_painted:=Vector2i(-99999,-99999)

func reset()->void:
	cells={"ground":{},"walls":{},"objects":{},"triggers":{}}
	undo_stack.clear();redo_stack.clear();validation.clear()
	status="Neue Builder-Karte."

func key(cell:Vector2i)->String:return "%d,%d"%[cell.x,cell.y]
func from_key(value:String)->Vector2i:
	var p:=value.split(",")
	return Vector2i(int(p[0]),int(p[1])) if p.size()==2 else Vector2i.ZERO

func screen_to_cell(pos:Vector2)->Vector2i:
	var local:=pos-CANVAS.position
	return camera_cell+Vector2i(floori(local.x/TILE),floori(local.y/TILE))

func cell_to_screen(cell:Vector2i)->Vector2:
	return CANVAS.position+Vector2(cell-camera_cell)*TILE

func inside_canvas(pos:Vector2)->bool:return CANVAS.has_point(pos)

func snapshot_change(target_layer:String,cell:Vector2i,before:Variant,after:Variant)->void:
	undo_stack.append({"layer":target_layer,"cell":cell,"before":before,"after":after})
	if undo_stack.size()>120:undo_stack.pop_front()
	redo_stack.clear()

func set_cell(target_layer:String,cell:Vector2i,value:Variant)->void:
	if not cells.has(target_layer):return
	var layer_cells:Dictionary=cells[target_layer]
	var k:=key(cell)
	var before:Variant=layer_cells.get(k,null)
	if before==value:return
	snapshot_change(target_layer,cell,before,value)
	if value==null:layer_cells.erase(k)
	else:layer_cells[k]=value
	cells[target_layer]=layer_cells

func paint(cell:Vector2i)->void:
	if cell==last_painted:return
	last_painted=cell
	if layer in ["ground","walls"]:set_cell(layer,cell,material_id)
	elif layer=="objects":set_cell(layer,cell,{"kind":"prop","variant":0})
	elif layer=="triggers":set_cell(layer,cell,{"kind":"interaction","radius":64})

func erase(cell:Vector2i)->void:
	if cell==last_painted:return
	last_painted=cell
	set_cell(layer,cell,null)

func undo()->void:
	if undo_stack.is_empty():return
	var change:Dictionary=undo_stack.pop_back()
	var layer_cells:Dictionary=cells[change["layer"]]
	var k:=key(change["cell"])
	if change["before"]==null:layer_cells.erase(k)
	else:layer_cells[k]=change["before"]
	cells[change["layer"]]=layer_cells
	redo_stack.append(change)
	status="Rückgängig."

func redo()->void:
	if redo_stack.is_empty():return
	var change:Dictionary=redo_stack.pop_back()
	var layer_cells:Dictionary=cells[change["layer"]]
	var k:=key(change["cell"])
	if change["after"]==null:layer_cells.erase(k)
	else:layer_cells[k]=change["after"]
	cells[change["layer"]]=layer_cells
	undo_stack.append(change)
	status="Wiederholt."

func save_file()->bool:
	var payload={"schema":1,"tile_size":TILE,"camera":[camera_cell.x,camera_cell.y],"cells":cells}
	var file:=FileAccess.open(FILE_PATH,FileAccess.WRITE)
	if file==null:
		status="Export fehlgeschlagen."
		return false
	file.store_string(JSON.stringify(payload,"	"));file.flush()
	var ok:=file.get_error()==OK;file.close()
	status="Builder-Karte exportiert." if ok else "Export fehlgeschlagen."
	return ok

func load_file()->bool:
	if not FileAccess.file_exists(FILE_PATH):
		status="Noch keine Builder-Datei vorhanden."
		return false
	var parsed:Variant=JSON.parse_string(FileAccess.get_file_as_string(FILE_PATH))
	if not parsed is Dictionary or int(parsed.get("schema",0))!=1 or int(parsed.get("tile_size",0))!=TILE:
		status="Builder-Datei ungültig."
		return false
	var raw:Variant=parsed.get("cells",{})
	if not raw is Dictionary:
		status="Builder-Datei ohne Layer."
		return false
	for name in ["ground","walls","objects","triggers"]:
		var values:Variant=raw.get(name,{})
		cells[name]=values if values is Dictionary else {}
	var cam:Variant=parsed.get("camera",[0,0])
	if cam is Array and cam.size()>=2:camera_cell=Vector2i(int(cam[0]),int(cam[1]))
	undo_stack.clear();redo_stack.clear()
	status="Builder-Karte geladen."
	return true

func validate(g)->Array:
	validation.clear()
	var world_cells:=Vector2i(ceili(g.WORLD.x/TILE),ceili(g.WORLD.y/TILE))
	for layer_name in cells:
		var layer_cells:Dictionary=cells[layer_name]
		for raw_key in layer_cells:
			var c:=from_key(str(raw_key))
			if c.x<0 or c.y<0 or c.x>=world_cells.x or c.y>=world_cells.y:
				validation.append("%s außerhalb der Welt: %s"%[layer_name,str(c)])
	# Keep village gates and their approach corridors authorable but never wall-blocked.
	for gate in g.VILLAGE_GATES:
		var gc:=Vector2i(floori(gate.x/TILE),floori(gate.y/TILE))
		for dx in range(-5,6):
			for dy in range(-5,6):
				if abs(dx)>2 and abs(dy)>2:continue
				if cells["walls"].has(key(gc+Vector2i(dx,dy))):
					validation.append("Wand blockiert Dorf-Torbereich bei %s"%str(gc+Vector2i(dx,dy)))
	if validation.is_empty():status="MAP PRÜFEN: keine Builder-Fehler gefunden."
	else:status="MAP PRÜFEN: %d Problem(e)."%validation.size()
	return validation

func draw(g)->void:
	g.text_at(Vector2(165,120),"SONNENHAIN WORLD BUILDER",24,Color("ffe0a4"))
	g.text_at(Vector2(165,145),"32px · Boden · Wände · Objekte · Trigger · Undo/Redo · Export",11,Color("c7d7d2"))
	var layer_names={"ground":"BODEN","walls":"WÄNDE","objects":"OBJEKTE","triggers":"TRIGGER"}
	var lx:=165.0
	for name in ["ground","walls","objects","triggers"]:
		g.ui_button(Rect2(lx,170,105,34),layer_names[name],true,layer==name);lx+=112
	g.ui_box(CANVAS,Color("17282d"))
	for y in VIEW_CELLS.y:
		for x in VIEW_CELLS.x:
			var cell:=camera_cell+Vector2i(x,y)
			var r:=Rect2(CANVAS.position+Vector2(x,y)*TILE,Vector2(TILE,TILE))
			var ground_value:Variant=cells["ground"].get(key(cell),null)
			var base:=Palette.color(str(ground_value),2) if ground_value!=null else Color("263b35")
			g.draw_rect(r,base)
			g.draw_rect(r,Color("52645c",0.32),false,1)
			var wall_value:Variant=cells["walls"].get(key(cell),null)
			if wall_value!=null:
				g.draw_rect(r.grow(-3),Palette.color(str(wall_value),2))
				g.draw_rect(Rect2(r.position+Vector2(3,3),Vector2(TILE-6,5)),Palette.color(str(wall_value),4))
			if cells["objects"].has(key(cell)):
				g.draw_circle(r.get_center(),7,Color("d5ad68"))
			if cells["triggers"].has(key(cell)):
				g.draw_rect(r.grow(-8),Color("65bcd0"),false,2)
	# palette
	var ids:Array=Palette.ids(layer if layer in ["ground","walls"] else "ground")
	g.text_at(Vector2(165,225),"MATERIAL",13,Color("ffe4ad"))
	for i in mini(ids.size(),9):
		var id:=str(ids[i]);var y:=245+i*32
		g.draw_rect(Rect2(165,y,22,22),Palette.color(id,2))
		g.ui_button(Rect2(194,y-4,145,28),Palette.display_name(id),true,material_id==id)
	g.text_at(Vector2(165,548),"Kamera %d,%d · Layer %s"%[camera_cell.x,camera_cell.y,layer_names[layer]],11,Color("b7c8c3"))
	g.ui_button(Rect2(360,540,90,32),"UNDO",not undo_stack.is_empty())
	g.ui_button(Rect2(458,540,90,32),"REDO",not redo_stack.is_empty())
	g.ui_button(Rect2(556,540,110,32),"MAP PRÜFEN")
	g.ui_button(Rect2(674,540,90,32),"LADEN")
	g.ui_button(Rect2(772,540,90,32),"EXPORT")
	g.ui_button(Rect2(870,540,90,32),"FERTIG")
	g.text_at(Vector2(165,590),status,11,Color("ffe1a0"),HORIZONTAL_ALIGNMENT_LEFT,780)

func click(g,pos:Vector2)->bool:
	if CANVAS.has_point(pos):
		paint(screen_to_cell(pos));return true
	var lx:=165.0
	for name in ["ground","walls","objects","triggers"]:
		if Rect2(lx,170,105,34).has_point(pos):
			layer=name
			var ids:=Palette.ids(layer if layer in ["ground","walls"] else "ground")
			if not ids.is_empty():material_id=str(ids[0])
			return true
		lx+=112
	var ids:Array=Palette.ids(layer if layer in ["ground","walls"] else "ground")
	for i in mini(ids.size(),9):
		if Rect2(194,241+i*32,145,28).has_point(pos):
			material_id=str(ids[i]);return true
	if Rect2(360,540,90,32).has_point(pos):undo();return true
	if Rect2(458,540,90,32).has_point(pos):redo();return true
	if Rect2(556,540,110,32).has_point(pos):validate(g);return true
	if Rect2(674,540,90,32).has_point(pos):load_file();return true
	if Rect2(772,540,90,32).has_point(pos):save_file();return true
	if Rect2(870,540,90,32).has_point(pos):active=false;g.panel="settings";return true
	return false

func input(g,event:InputEvent)->bool:
	if not active:return false
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT]:
		if event.pressed and CANVAS.has_point(event.position):
			dragging=true;last_painted=Vector2i(-99999,-99999)
			if event.button_index==MOUSE_BUTTON_LEFT:paint(screen_to_cell(event.position))
			else:erase(screen_to_cell(event.position))
			g.queue_redraw();return true
		elif not event.pressed:dragging=false;last_painted=Vector2i(-99999,-99999)
	if event is InputEventMouseMotion and dragging and CANVAS.has_point(event.position):
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):paint(screen_to_cell(event.position))
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):erase(screen_to_cell(event.position))
		g.queue_redraw();return true
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				active=false
				g.panel="settings"
				return true
			KEY_Z:
				if event.ctrl_pressed:
					undo()
					return true
			KEY_Y:
				if event.ctrl_pressed:
					redo()
					return true
			KEY_LEFT:
				camera_cell.x=maxi(0,camera_cell.x-4)
				return true
			KEY_RIGHT:
				camera_cell.x+=4
				return true
			KEY_UP:
				camera_cell.y=maxi(0,camera_cell.y-4)
				return true
			KEY_DOWN:
				camera_cell.y+=4
				return true
	return false
