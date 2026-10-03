extends RefCounted
## Ingame 32px world authoring tool. Builder data is isolated from character saves.
const Palette=preload("res://components/world_material_palette_32.gd")
const TILE:=32
const FILE_PATH:="user://sonnenhain_world_builder.json"
const CANVAS:=Rect2(370,220,590,304)
const VIEW_CELLS:=Vector2i(18,9)
const LAYERS:=["ground","walls","objects","npcs","spawns","triggers","ambience"]
const LAYER_NAMES:={
	"ground":"BODEN","walls":"WÄNDE","objects":"OBJEKTE","npcs":"NPCS",
	"spawns":"SPAWNS","triggers":"TRIGGER","ambience":"AMBIENTE"
}
const PRESETS:={
	"objects":["tree","rock","barrel","lantern","chest","workbench","bed","hearth"],
	"npcs":["quest_npc","merchant","villager","guard"],
	"spawns":["mob_spawn","boss_spawn","resource_spawn"],
	"triggers":["interaction","door","quest","waystone","region_transition"],
	"ambience":["warm_lanterns","village_day","forest_wind","dungeon_cold","crystal_hum","hearth_room"]
}

var active:=false
var layer:="ground"
var selection_id:="grass_meadow"
var brush_size:=1
var camera_cell:=Vector2i.ZERO
var cells:Dictionary={}
var undo_stack:Array=[]
var redo_stack:Array=[]
var status:="32px-Raster · Builder-Daten sind vom Spielstand getrennt."
var validation:Array=[]
var dragging:=false
var erase_drag:=false
var last_painted:=Vector2i(-99999,-99999)

func _init()->void:
	reset_layers()

func reset_layers()->void:
	cells.clear()
	for name in LAYERS:cells[name]={}

func reset()->void:
	reset_layers()
	undo_stack.clear()
	redo_stack.clear()
	validation.clear()
	status="Neue Builder-Karte."

func key(cell:Vector2i)->String:
	return "%d,%d"%[cell.x,cell.y]

func from_key(value:String)->Vector2i:
	var p:PackedStringArray=value.split(",")
	return Vector2i(int(p[0]),int(p[1])) if p.size()==2 else Vector2i.ZERO

func screen_to_cell(pos:Vector2)->Vector2i:
	var local:Vector2=pos-CANVAS.position
	return camera_cell+Vector2i(floori(local.x/TILE),floori(local.y/TILE))

func cell_to_screen(cell:Vector2i)->Vector2:
	return CANVAS.position+Vector2(cell-camera_cell)*TILE

func choices()->Array:
	if layer in ["ground","walls"]:return Palette.ids(layer)
	return PRESETS.get(layer,[]).duplicate()

func select_default()->void:
	var options:Array=choices()
	if not options.is_empty():selection_id=str(options[0])

func snapshot_change(target_layer:String,cell:Vector2i,before:Variant,after:Variant)->void:
	undo_stack.append({"layer":target_layer,"cell":cell,"before":before,"after":after})
	if undo_stack.size()>240:undo_stack.pop_front()
	redo_stack.clear()

func set_cell(target_layer:String,cell:Vector2i,value:Variant)->void:
	if not cells.has(target_layer):return
	var layer_cells:Dictionary=cells[target_layer]
	var k:String=key(cell)
	var before:Variant=layer_cells.get(k,null)
	if before==value:return
	snapshot_change(target_layer,cell,before,value)
	if value==null:layer_cells.erase(k)
	else:layer_cells[k]=value
	cells[target_layer]=layer_cells

func entry_value()->Variant:
	match layer:
		"ground","walls":
			return selection_id
		"objects":
			return {"kind":selection_id,"variant":0}
		"npcs":
			return {"kind":selection_id,"name":"","role":""}
		"spawns":
			return {"kind":selection_id,"radius":160,"count":1}
		"triggers":
			return {"kind":selection_id,"radius":64,"target":""}
		"ambience":
			return {"kind":selection_id,"radius":256,"intensity":1.0}
	return selection_id

func brush_cells(center:Vector2i)->Array:
	var out:Array=[]
	var radius:int=int((brush_size-1)/2)
	for y in range(center.y-radius,center.y+radius+1):
		for x in range(center.x-radius,center.x+radius+1):
			out.append(Vector2i(x,y))
	return out

func paint(cell:Vector2i)->void:
	if cell==last_painted:return
	last_painted=cell
	var targets:Array=brush_cells(cell) if layer in ["ground","walls"] else [cell]
	var value:Variant=entry_value()
	for target in targets:set_cell(layer,target,value)

func erase(cell:Vector2i)->void:
	if cell==last_painted:return
	last_painted=cell
	var targets:Array=brush_cells(cell) if layer in ["ground","walls"] else [cell]
	for target in targets:set_cell(layer,target,null)

func apply_history(change:Dictionary,use_after:bool)->void:
	var target_layer:String=str(change.get("layer","ground"))
	var layer_cells:Dictionary=cells[target_layer]
	var k:String=key(Vector2i(change["cell"]))
	var value:Variant=change["after"] if use_after else change["before"]
	if value==null:layer_cells.erase(k)
	else:layer_cells[k]=value
	cells[target_layer]=layer_cells

func undo()->void:
	if undo_stack.is_empty():return
	var change:Dictionary=undo_stack.pop_back()
	apply_history(change,false)
	redo_stack.append(change)
	status="Rückgängig."

func redo()->void:
	if redo_stack.is_empty():return
	var change:Dictionary=redo_stack.pop_back()
	apply_history(change,true)
	undo_stack.append(change)
	status="Wiederholt."

func save_file()->bool:
	var payload:Dictionary={"schema":2,"tile_size":TILE,"camera":[camera_cell.x,camera_cell.y],"cells":cells}
	var file:=FileAccess.open(FILE_PATH,FileAccess.WRITE)
	if file==null:
		status="Export fehlgeschlagen."
		return false
	file.store_string(JSON.stringify(payload,"	"))
	file.flush()
	var ok:bool=file.get_error()==OK
	file.close()
	status="Builder-Karte exportiert · %s"%FILE_PATH if ok else "Export fehlgeschlagen."
	return ok

func load_file()->bool:
	if not FileAccess.file_exists(FILE_PATH):
		status="Noch keine Builder-Datei vorhanden."
		return false
	var parsed:Variant=JSON.parse_string(FileAccess.get_file_as_string(FILE_PATH))
	if not parsed is Dictionary or int(parsed.get("schema",0)) not in [1,2] or int(parsed.get("tile_size",0))!=TILE:
		status="Builder-Datei ungültig."
		return false
	var raw:Variant=parsed.get("cells",{})
	if not raw is Dictionary:
		status="Builder-Datei ohne Layer."
		return false
	reset_layers()
	for name in LAYERS:
		var values:Variant=raw.get(name,{})
		cells[name]=values if values is Dictionary else {}
	var cam:Variant=parsed.get("camera",[0,0])
	if cam is Array and cam.size()>=2:camera_cell=Vector2i(int(cam[0]),int(cam[1]))
	undo_stack.clear()
	redo_stack.clear()
	status="Builder-Karte geladen."
	return true

func validate(g)->Array:
	validation.clear()
	var world_cells:=Vector2i(ceili(g.WORLD.x/TILE),ceili(g.WORLD.y/TILE))
	for layer_name in LAYERS:
		var layer_cells:Dictionary=cells[layer_name]
		for raw_key in layer_cells:
			var c:Vector2i=from_key(str(raw_key))
			if c.x<0 or c.y<0 or c.x>=world_cells.x or c.y>=world_cells.y:
				validation.append("%s außerhalb der Welt: %s"%[layer_name,str(c)])
	for gate in g.VILLAGE_GATES:
		var gc:=Vector2i(floori(gate.x/TILE),floori(gate.y/TILE))
		for dx in range(-5,6):
			for dy in range(-5,6):
				if abs(dx)>2 and abs(dy)>2:continue
				if cells["walls"].has(key(gc+Vector2i(dx,dy))):
					validation.append("Wand blockiert Dorf-Torbereich bei %s"%str(gc+Vector2i(dx,dy)))
	for raw_key in cells["spawns"]:
		var c:=from_key(str(raw_key))
		if cells["walls"].has(key(c)):validation.append("Spawn liegt in einer Wand: %s"%str(c))
	for raw_key in cells["npcs"]:
		var c:=from_key(str(raw_key))
		if cells["walls"].has(key(c)):validation.append("NPC liegt in einer Wand: %s"%str(c))
	if validation.is_empty():status="MAP PRÜFEN: keine Builder-Fehler gefunden."
	else:status="MAP PRÜFEN: %d Problem(e)."%validation.size()
	return validation

func layer_marker_color(name:String)->Color:
	match name:
		"objects":return Color("d5ad68")
		"npcs":return Color("8fe2bf")
		"spawns":return Color("ef8d73")
		"triggers":return Color("65bcd0")
		"ambience":return Color("9d82c4")
	return Color.WHITE

func draw(g)->void:
	g.text_at(Vector2(165,120),"SONNENHAIN WORLD BUILDER",24,Color("ffe0a4"))
	g.text_at(Vector2(165,145),"32px · Daten-Layer · Undo/Redo · Prüfung · Export",11,Color("c7d7d2"))
	for i in LAYERS.size():
		var col:int=i%4
		var row:int=int(i/4)
		g.ui_button(Rect2(370+col*147,165+row*38,138,32),str(LAYER_NAMES[LAYERS[i]]),true,layer==LAYERS[i])
	g.ui_box(CANVAS,Color("17282d"))
	for y in VIEW_CELLS.y:
		for x in VIEW_CELLS.x:
			var cell:=camera_cell+Vector2i(x,y)
			var r:=Rect2(CANVAS.position+Vector2(x,y)*TILE,Vector2(TILE,TILE))
			var ground_value:Variant=cells["ground"].get(key(cell),null)
			var base:Color=Palette.color(str(ground_value),2) if ground_value!=null else Color("263b35")
			g.draw_rect(r,base)
			g.draw_rect(r,Color("52645c",0.28),false,1)
			var wall_value:Variant=cells["walls"].get(key(cell),null)
			if wall_value!=null:
				g.draw_rect(r.grow(-3),Palette.color(str(wall_value),2))
				g.draw_rect(Rect2(r.position+Vector2(3,3),Vector2(TILE-6,5)),Palette.color(str(wall_value),4))
			for mark_layer in ["objects","npcs","spawns","triggers","ambience"]:
				if not cells[mark_layer].has(key(cell)):continue
				var mark:Color=layer_marker_color(mark_layer)
				var center:Vector2=r.get_center()
				if mark_layer=="ambience":g.draw_arc(center,10,0,TAU,16,mark,2)
				elif mark_layer=="triggers":g.draw_rect(r.grow(-8),mark,false,2)
				else:g.draw_circle(center,6,mark)
	g.text_at(Vector2(165,175),"AUSWAHL",13,Color("ffe4ad"))
	var options:Array=choices()
	for i in range(mini(options.size(),9)):
		var id:String=str(options[i])
		var y:float=198+i*31
		if layer in ["ground","walls"]:g.draw_rect(Rect2(165,y+3,20,20),Palette.color(id,2))
		else:g.draw_circle(Vector2(175,y+13),7,layer_marker_color(layer))
		g.ui_button(Rect2(192,y,158,27),Palette.display_name(id) if layer in ["ground","walls"] else id.to_upper(),true,selection_id==id)
	g.text_at(Vector2(165,492),"PINSEL",12,Color("ffe4ad"))
	for i in 3:g.ui_button(Rect2(165+i*62,505,55,28),str([1,3,5][i]),true,brush_size==[1,3,5][i])
	g.text_at(Vector2(165,548),"Kamera %d,%d · %s"%[camera_cell.x,camera_cell.y,str(LAYER_NAMES[layer])],11,Color("b7c8c3"))
	g.ui_button(Rect2(370,540,82,32),"UNDO",not undo_stack.is_empty())
	g.ui_button(Rect2(458,540,82,32),"REDO",not redo_stack.is_empty())
	g.ui_button(Rect2(546,540,112,32),"MAP PRÜFEN")
	g.ui_button(Rect2(664,540,82,32),"LADEN")
	g.ui_button(Rect2(752,540,94,32),"EXPORT")
	g.ui_button(Rect2(852,540,108,32),"FERTIG")
	g.text_at(Vector2(165,590),status,11,Color("ffe1a0"),HORIZONTAL_ALIGNMENT_LEFT,790)

func click(g,pos:Vector2)->bool:
	if CANVAS.has_point(pos):
		paint(screen_to_cell(pos))
		return true
	for i in LAYERS.size():
		var col:int=i%4
		var row:int=int(i/4)
		if Rect2(370+col*147,165+row*38,138,32).has_point(pos):
			layer=LAYERS[i]
			select_default()
			return true
	var options:Array=choices()
	for i in range(mini(options.size(),9)):
		if Rect2(192,198+i*31,158,27).has_point(pos):
			selection_id=str(options[i])
			return true
	for i in 3:
		if Rect2(165+i*62,505,55,28).has_point(pos):
			brush_size=[1,3,5][i]
			return true
	if Rect2(370,540,82,32).has_point(pos):undo();return true
	if Rect2(458,540,82,32).has_point(pos):redo();return true
	if Rect2(546,540,112,32).has_point(pos):validate(g);return true
	if Rect2(664,540,82,32).has_point(pos):load_file();return true
	if Rect2(752,540,94,32).has_point(pos):save_file();return true
	if Rect2(852,540,108,32).has_point(pos):active=false;g.panel="settings";return true
	return false

func input(g,event:InputEvent)->bool:
	if not active:return false
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT]:
		if event.pressed and CANVAS.has_point(event.position):
			dragging=true
			erase_drag=event.button_index==MOUSE_BUTTON_RIGHT
			last_painted=Vector2i(-99999,-99999)
			if erase_drag:erase(screen_to_cell(event.position))
			else:paint(screen_to_cell(event.position))
			g.queue_redraw()
			return true
		elif not event.pressed:
			dragging=false
			last_painted=Vector2i(-99999,-99999)
	if event is InputEventMouseMotion and dragging and CANVAS.has_point(event.position):
		if erase_drag:erase(screen_to_cell(event.position))
		else:paint(screen_to_cell(event.position))
		g.queue_redraw()
		return true
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				active=false;g.panel="settings";return true
			KEY_Z:
				if event.ctrl_pressed:undo();return true
			KEY_Y:
				if event.ctrl_pressed:redo();return true
			KEY_LEFT:
				camera_cell.x=maxi(0,camera_cell.x-4);return true
			KEY_RIGHT:
				camera_cell.x+=4;return true
			KEY_UP:
				camera_cell.y=maxi(0,camera_cell.y-4);return true
			KEY_DOWN:
				camera_cell.y+=4;return true
	return false
