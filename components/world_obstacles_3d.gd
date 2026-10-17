extends RefCounted
## Echte Mesh-Körper auf stabilen Atlasseiten; ruhende Seiten werden wiederverwendet.
## Die 2D-Welt übernimmt nur Projektion und Tiefensortierung mit den Figuren.
## Keine vorgerenderten Sprites; Geometrie, Licht und Animation bleiben räumlich.
const Models=preload("res://components/world_obstacle_models_3d.gd")
const Geometry=preload("res://components/world_geometry.gd")
const AtlasSlots=preload("res://components/landscape_atlas_slots.gd")
const AtlasPage=preload("res://components/landscape_atlas_page.gd")
const ArchitectureKit=preload("res://components/architecture_kit.gd")
const CELL:=128
const UNITS:=3.7
const FOOT:=Vector2(.5,.66)
const PITCH:=.68
const PRIMARY=[[],[1,3,4,5],[1,4,5,6],[1,2,3,5],[1,2,4,5,6],[1,2,4,5],[1,2,3,4,6],[1,2,3,4,5],[1,5],[1,2,4,5],[1,2,4,5],[1,2,3,4,5],[1,2,4]]
const SOFT=[[],[2,6],[2,3],[4,5],[3],[3,6],[5],[6],[1,5],[3,6],[3,6],[6],[3,5,6]]
var viewport:SubViewport
var world:Node3D
var camera:Camera3D
var models:Dictionary={}
var specs:Dictionary={}
var instances:Dictionary={}
var rows:Array=[]
var signature:=""
var texture:Texture2D
var columns:=1
var grid_rows:=1
var collection_clock:=0.0
var atlas_slots:=AtlasSlots.new()
var atlas_pages:Array=[]
var collections:=0
var created_instances:=0
var collection_us:=0
var peak_collection_us:=0
var decoration_cells:Dictionary={}
const DECORATION_CACHE_LIMIT:=4096
const STATIC_RENDERS_PER_FRAME:=1
## Neue Modelle entstehen in GDScript (10–50 ms je Modell). Pro Bild nur so
## viele bauen, bis dieses Zeitbudget überschritten ist; mindestens eines.
const MODEL_BUILD_BUDGET_US:=6000
## Ein gemeinsamer Baumeister teilt erzeugte Materialtexturen zwischen Modellen.
var builder:=Models.new()
var pending_models:=0

## Rückfall (10.10.2026): Rendert der 3D-Viewport im Browser nichts (z. B. bei
## manchen Grafiktreibern), zeichnet das Spiel wieder die 2D-Landschaft. Einmal
## nach dem ersten Bild wird geprüft, ob im 3D-Bild überhaupt Pixel stehen.
static var active:=true
var probe_clock:=-1.0
var probe_done:=false
const PROBE_DELAY:=0.8
const PROBE_MIN_PIXELS:=40

static func replaces_static(zone:int)->bool:
	return active and zone>=1 and zone<=12

static func paint_ground(g,zone:int,key:int,point:Vector2,wet:bool)->void:
	# Kleine Bodenflecken und Wasserwellen gehören zum Gelände, nicht zu den Körpern.
	if not replaces_static(zone):return
	match zone:
		1:
			if key%3==0:g.draw_flower(point,key)
			else:g.draw_grass(point)
		2,4:g.draw_grass(point)
		3,5,7:g.draw_pebbles(point)
		6:
			if wet:g.draw_wave(point,key)
			elif key%3==0:g.draw_pebbles(point)
		_:
			if key%3==0:g.draw_flower(point,key)
			else:g.draw_grass(point)

static func primary_motif(zone:int,key:int)->int:
	if not replaces_static(zone):return 0
	var choices:Array=PRIMARY[zone]
	return int(choices[posmod(key/17,choices.size())])

static func model_id(zone:int,motif:int)->String:
	return "map%02d-obj%02d" % [zone,motif]

static func replaces_wall(start:Vector2,finish:Vector2)->bool:
	# Die beiden Dorfgrenzen gehören vollständig zur unveränderten Map 0.
	return active and not ((start.x==1780 and start.y==0) or (start.y==2600 and start.x==0))

## Zählt sichtbare Pixel im 3D-Bild (jedes 4. Pixel). 0 = nichts gerendert.
static func visible_pixels(image:Image)->int:
	if image==null or image.is_empty():return 0
	var count:=0
	for y in range(0,image.get_height(),4):
		for x in range(0,image.get_width(),4):
			if image.get_pixel(x,y).a>0.5:count+=1
	return count

## Nach dem ersten Bild einmal prüfen; leer → 2D-Landschaft zurück.
func probe(g,delta:float)->void:
	if probe_done or rows.is_empty() or not is_instance_valid(viewport):return
	if probe_clock<0.0:probe_clock=PROBE_DELAY
	probe_clock-=delta
	if probe_clock>0.0:return
	probe_done=true
	var pixels:=0
	# Die erste Seite kann nach einer Reise leer sein; alle aktiven Seiten prüfen.
	for page in atlas_pages:
		if not true in page.shown.values():continue
		var tex:Texture2D=page.viewport.get_texture()
		if tex!=null:pixels+=visible_pixels(tex.get_image())
		if pixels>=PROBE_MIN_PIXELS:break
	if g.has_method("report_3d_probe"):g.report_3d_probe(probe_report(pixels))
	if pixels>=PROBE_MIN_PIXELS:return
	active=false
	rows.clear();signature=""
	for page in atlas_pages:page.suspend()
	printerr("OBSTACLES_3D_FALLBACK pixels=%d – 3D-Landschaft bleibt leer, zeige 2D" % pixels)
	if g.has_method("invalidate_static_cache"):g.invalidate_static_cache()

## Was der Server über das 3D-Bild erfährt (zur Fehlersuche, ohne Namen):
## Pixel, Objektzahl, Bildgröße, Grafikkarte, Grafik-API, Browser.
func probe_report(pixels:int)->Dictionary:
	var agent:=""
	var brave:=false
	if OS.get_name()=="Web" and ClassDB.class_exists("JavaScriptBridge"):
		agent=str(JavaScriptBridge.eval("navigator.userAgent",true))
		brave=bool(JavaScriptBridge.eval("!!(navigator.brave)",true))
	return {"pixels":pixels,"rows":rows.size(),"size":[viewport.size.x,viewport.size.y] if is_instance_valid(viewport) else [0,0],
		"adapter":RenderingServer.get_video_adapter_name(),"vendor":RenderingServer.get_video_adapter_vendor(),
		"api":RenderingServer.get_video_adapter_api_version(),"agent":agent,"brave":brave,"os":OS.get_name()}

func ensure(g:Node)->void:
	if not specs.is_empty():return
	var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://components/world_obstacles_3d.json"))
	for spec in data["objects"]+data["common_objects"]:specs[str(spec["id"])]=spec

func animated_row(row:Dictionary)->bool:
	# Blender-Bauteile sind feste Körper ohne Idle-Animation.
	if ArchitectureKit.replaces(str(row["model"])):return false
	return int(specs[str(row["model"])]["animation"]["frames"])>1

func metrics_snapshot()->Dictionary:
	var updates:=0;var color_bytes:=0
	for page in atlas_pages:
		updates+=page.render_updates
		color_bytes+=page.viewport.size.x*page.viewport.size.y*4
	return {"collections":collections,"instances_created":created_instances,"resident_instances":instances.size(),"pages":atlas_pages.size(),"page_updates":updates,"atlas_color_bytes":color_bytes,"collection_us":collection_us,"peak_collection_us":peak_collection_us}

func enabled(g)->bool:
	return not g.dedicated_server_mode and DisplayServer.get_name()!="headless" and g.arena_mode=="" and g.interior_id<0 and g.dungeon_id<0 and not g.konflux.active and g.character_created and g.panel not in ["start","account_gate","account_login","account_register","account_migrate","creation","creation_review"]

func update(g,delta:float)->void:
	if not active:return
	probe(g,delta)
	if not enabled(g):
		rows.clear();signature=""
		for page in atlas_pages:page.suspend()
		return
	# Höchstens eine ruhende Seite pro Bild nachzeichnen; die vorgeladene
	# Randzone verdeckt die Verzögerung von wenigen Bildern.
	var static_budget:=STATIC_RENDERS_PER_FRAME
	for page in atlas_pages:
		page.world.process_mode=Node.PROCESS_MODE_INHERIT
		if page.step(delta,static_budget>0):static_budget-=1
	var bounds:Rect2=g.camera_world_rect().grow(160)
	var next_signature:="%s:%s" % [Vector2i(bounds.position/64),Vector2i(bounds.size)]
	collection_clock-=delta
	# Kameralauf umgeht die Pause nicht mehr; die vorgeladene Randzone deckt ihn ab.
	# Fehlen noch Modelle, im nächsten Bild weiterbauen statt 250 ms zu warten.
	if not signature.is_empty() and collection_clock>0 and pending_models==0:return
	collection_clock=.25;signature=next_signature
	var started:=Time.get_ticks_usec()
	rows=collect(g,bounds)
	ensure(g)
	var changes:Dictionary=atlas_slots.reconcile(rows,animated_row)
	for key in changes["removed"]:
		for page in atlas_pages:page.remove_body(key)
		instances.erase(key)
	while atlas_pages.size()<atlas_slots.pages.size():
		var page:=AtlasPage.new();var index:=atlas_pages.size()
		page.setup(g,bool(atlas_slots.pages[index]["animated"]),index);atlas_pages.append(page)
	var build_started:=Time.get_ticks_usec();var built:=0;pending_models=0
	for row in rows:
		var key:String=row["key"];var id:String=row["model"]
		var allocation:Dictionary=atlas_slots.entries[key]
		var page=atlas_pages[int(allocation["page"])]
		if not instances.has(key):
			if not models.has(id):
				# Budget erschöpft: Körper ohne Atlasbild bleibt bis zum Folgebild
				# unsichtbar; die vorgeladene Randzone verdeckt das meist.
				if built>0 and Time.get_ticks_usec()-build_started>MODEL_BUILD_BUDGET_US:
					pending_models+=1;continue
				var kit_scene:=ArchitectureKit.scene_for(id)
				if kit_scene!=null:models[id]=kit_scene
				else:
					var body:=builder.build(specs[id]);var scene:=PackedScene.new();scene.pack(body);body.free();models[id]=scene
				built+=1
			var instance:Node3D=models[id].instantiate()
			instance.name="Object_"+str(created_instances);instances[key]=instance;created_instances+=1
			page.add_body(key,instance,int(allocation["slot"]),row)
		row["source"]=atlas_slots.source(key,CELL)
		row["atlas_page"]=int(allocation["page"])
	for page in atlas_pages:page.set_visible_keys(changes["wanted"])
	if not atlas_pages.is_empty():
		viewport=atlas_pages[0].viewport;world=atlas_pages[0].world;camera=atlas_pages[0].camera;texture=viewport.get_texture()
	collections+=1;var duration:=Time.get_ticks_usec()-started
	collection_us+=duration;peak_collection_us=maxi(peak_collection_us,duration)

func collect(g,bounds:Rect2)->Array:
	var result:Array=[]
	for cx in range(maxi(0,floori(bounds.position.x/250)-1),ceili(bounds.end.x/250)+1):
		for cy in range(maxi(0,floori(bounds.position.y/250)-1),ceili(bounds.end.y/250)+1):
			var obstacle:Dictionary=g.obstacle_in_cell(cx,cy)
			if obstacle.is_empty():continue
			var zone:=int(obstacle["zone"]);var point:Vector2=obstacle["pos"]
			if not replaces_static(zone) or not bounds.has_point(point):continue
			var motif:=primary_motif(zone,int(obstacle["key"]))
			result.append(entry("obstacle:%d:%d"%[cx,cy],zone,motif,point,62.0))
	for tx in range(maxi(0,floori(bounds.position.x/64)-1),ceili(bounds.end.x/64)+1):
		for ty in range(maxi(0,floori(bounds.position.y/64)-1),ceili(bounds.end.y/64)+1):
			var cell:=Vector2i(tx,ty)
			# Veränderliche Baumzustände niemals im Geometriecache festhalten.
			if g.golem_world.tree_knocked(cell):continue
			if not decoration_cells.has(cell):
				if decoration_cells.size()>=DECORATION_CACHE_LIMIT:decoration_cells.erase(decoration_cells.keys()[0])
				decoration_cells[cell]=decoration_in_cell(g,tx,ty)
			var row:Dictionary=decoration_cells[cell]
			if not row.is_empty() and bounds.has_point(row["point"]):result.append(row.duplicate())
	collect_walls(g,bounds,result)
	return result

func decoration_in_cell(g,tx:int,ty:int)->Dictionary:
	var key:int=g.hash_cell(tx,ty)
	var zone:int=g.visual_region_at(Vector2(tx*64+32,ty*64+32))
	if not replaces_static(zone):return {}
	var tree:Dictionary=g.decorative_tree_in_cell(tx,ty)
	if not tree.is_empty():
		var motif:=1 if zone in [1,2] else (6 if zone==3 else 2)
		if zone==8:motif=int([2,3,4,6][posmod(key/13,4)])
		return entry("tree:%d:%d"%[tx,ty],zone,motif,tree["point"],39.0 if motif in [1,2,6] and zone!=8 else 30.0)
	if key%5!=0:return {}
	var point:=Vector2(tx*64+(key%23),ty*64+((key/23)%25))+Vector2(24,24)
	if not clear_decoration(g,point,zone):return {}
	var choices:Array=SOFT[zone];var motif:=int(choices[posmod(key/29,choices.size())])
	return entry("soft:%d:%d"%[tx,ty],zone,motif,point,31.0)

static func clear_decoration(g,p:Vector2,zone:int)->bool:
	if not Geometry.region_rect(zone).grow(-100).has_point(p):return false
	if g.distance_to_trail(p)<145 or g.class_boss_arena_index_at(p,100)>=0 or g.point_near_class_boss_house(p,120) or g.near_waystone_shrine(p,100):return false
	if zone==12 and p.distance_to(g.GolemBoss.ALTAR)<280:return false
	if zone==6 and p.y>6850+sin(p.x/220.0)*125:return false
	for landmark in g.LANDMARKS:
		if p.distance_to(landmark["pos"])<210:return false
	for portal in g.PORTALS:
		if p.distance_to(portal[0])<180 or p.distance_to(portal[1])<180:return false
	return true

static func entry(key:String,zone:int,motif:int,point:Vector2,pixels:float)->Dictionary:
	return {"kind":"obstacle_3d","key":key,"model":model_id(zone,motif),"point":point,"depth":point.y,"pixels":pixels,"map":zone,"motif":motif}

func collect_walls(g,bounds:Rect2,result:Array)->void:
	var walls:Array=[
		[Vector2(1780,2600),Vector2(1780,8500),Vector2(1780,6200)],
		[Vector2(1780,4200),Vector2(5000,4200),Vector2(2900,4200)],
		[Vector2(5000,0),Vector2(5000,4200),Vector2(5000,1250)],
		[Vector2(5000,4200),Vector2(5000,8500),Vector2(5000,6200)],
		[Vector2(5000,4200),Vector2(8500,4200),Vector2(6600,4200)],
		[Vector2(8500,0),Vector2(8500,4200),Vector2(8500,1900)],
		[Vector2(8500,4200),Vector2(8500,8500),Vector2(8500,6350)],
		[Vector2(8500,4200),Vector2(11000,4200),Vector2(9750,4200)]
	]
	for wall_index in walls.size():
		var wall:Array=walls[wall_index];var vertical:bool=wall[0].x==wall[1].x
		var first:float=wall[0].y if vertical else wall[0].x
		var last:float=wall[1].y if vertical else wall[1].x
		var gap:float=wall[2].y if vertical else wall[2].x
		for span in [Vector2(first,gap-g.GATE_HALF_WIDTH),Vector2(gap+g.GATE_HALF_WIDTH,last)]:
			var visible_first:=maxf(span.x,(bounds.position.y if vertical else bounds.position.x)-100)
			var visible_last:=minf(span.y,(bounds.end.y if vertical else bounds.end.x)+100)
			for segment in range(maxi(0,floori((visible_first-span.x)/64)),ceili((visible_last-span.x)/64)):
				var axis:float=span.x+segment*64
				var length:=minf(64,span.y-axis)
				if length<=0:continue
				var point:=Vector2(wall[0].x,axis+length*.5) if vertical else Vector2(axis+length*.5,wall[0].y)
				if not bounds.has_point(point):continue
				var row:=entry("wall:%d:%d:%d"%[wall_index,int(span.x),segment],3,1,point,60)
				row["model"]="common-wall-02" if vertical else "common-wall-01"
				row["stretch_x"]=92.0/18.0 if vertical else length/64.8
				row["stretch_z"]=length/(64.8*sin(PITCH)) if vertical else 92.0/(18.0*sin(PITCH))
				if segment==0 or axis+length>=span.y-.1:
					row["model"]="common-wall-05"
					row["rotation"]=PI*.5 if vertical else 0.0
					row["stretch_x"]=length/(.84*60.0*(sin(PITCH) if vertical else 1.0))
					row["stretch_z"]=92.0/(18.0*(1.0 if vertical else sin(PITCH)))
					row["render_point"]=point+(Vector2(0,-length/6.0) if vertical else Vector2(length/6.0,0))
				# Die breite Bodenfläche der bisherigen Mauer bleibt exakt 92 Pixel breit.
				result.append(row)
		for side in [-1,1]:
			var point:Vector2=wall[2]+(Vector2(0,side*g.GATE_HALF_WIDTH) if vertical else Vector2(side*g.GATE_HALF_WIDTH,0))
			if not bounds.has_point(point):continue
			var row:=entry("post:%d:%d"%[wall_index,side],3,1,point,180)
			row["model"]="common-wall-06";row["stretch_y"]=.55
			row["crop_side"]=0 if side<0 else 1
			row["render_point"]=point+Vector2(-side*.72*180,0)
			result.append(row)
	# Ecken als geschlossene Körper an den beiden großen Mauerverbindungen.
	for corner in [[Vector2(5000,4200),3],[Vector2(8500,4200),4]]:
		if bounds.has_point(corner[0]):
			var row:=entry("corner:%s"%corner[0],3,1,corner[0],60)
			row["model"]="common-wall-%02d"%corner[1];row["stretch_x"]=1.45;row["stretch_z"]=1.45
			result.append(row)
	# Breite Trennwände der fünf östlichen Karten folgen den vorhandenen Kurven.
	for axis in range(maxi(0,floori(bounds.position.y/64)),mini(150,ceili(bounds.end.y/64))):
		var point:=Vector2(11070,axis*64+32)
		if bounds.has_point(point):result.append(barrier("east:%d"%axis,point,true,145))
	for border in [1920,3840,5760,7680]:
		for axis in range(maxi(0,floori((bounds.position.x-11000)/64)),mini(79,ceili((bounds.end.x-11000)/64))):
			var x:float=11000+axis*64+32
			var point:=Vector2(x,float(border)+sin(x/350.0)*21+sin(x/97.0)*8)
			if bounds.has_point(point):result.append(barrier("border:%d:%d"%[border,axis],point,false,111))

static func barrier(key:String,point:Vector2,vertical:bool,width:float)->Dictionary:
	var row:=entry("wall:"+key,3,1,point,60)
	row["model"]="common-wall-02" if vertical else "common-wall-01"
	row["stretch_x"]=width/18 if vertical else 64.0/64.8
	row["stretch_z"]=64.0/(64.8*sin(PITCH)) if vertical else width/(18*sin(PITCH))
	return row

func append_entries(entries:Array)->void:
	for row in rows:
		if row.has("source"):entries.append(row)

func paint(g,row:Dictionary)->void:
	if texture==null or not is_instance_valid(viewport):return
	var page_texture:Texture2D=atlas_pages[int(row.get("atlas_page",0))].viewport.get_texture()
	var size:=UNITS*float(row["pixels"])
	var point:Vector2=row.get("render_point",row["point"])
	if not str(row["model"]).begins_with("common-wall-"):
		var is_arch:bool=(int(row["map"])==3 and int(row["motif"])==4) or (int(row["map"])==12 and int(row["motif"])==5)
		if is_arch:
			for side in [-1,1]:paint_shadow(g,point+Vector2(side*.53*float(row["pixels"]),0),Vector2(5,2))
		else:paint_shadow(g,point,Vector2(15,5)*float(row["pixels"])/45.0)
	var source:Rect2=row["source"]
	var destination:=Rect2(point-FOOT*size,Vector2.ONE*size)
	if row.has("crop_side"):
		source.position.x+=float(row["crop_side"])*CELL*.5;source.size.x*=.5
		destination.position.x+=float(row["crop_side"])*size*.5;destination.size.x*=.5
	# Auch die Projektion einer Außenmauer darf nicht in Dorfpixel hineinragen.
	for part in outside_village(destination):
		var ratio:=source.size/destination.size
		var cropped:=Rect2(source.position+(part.position-destination.position)*ratio,part.size*ratio)
		g.draw_texture_rect_region(page_texture,part,cropped)

static func outside_village(rect:Rect2)->Array:
	var village:=Geometry.region_rect(0)
	if not rect.intersects(village):return [rect]
	var overlap:=rect.intersection(village)
	var pieces:Array=[
		Rect2(rect.position,Vector2(rect.size.x,overlap.position.y-rect.position.y)),
		Rect2(Vector2(rect.position.x,overlap.end.y),Vector2(rect.size.x,rect.end.y-overlap.end.y)),
		Rect2(Vector2(rect.position.x,overlap.position.y),Vector2(overlap.position.x-rect.position.x,overlap.size.y)),
		Rect2(Vector2(overlap.end.x,overlap.position.y),Vector2(rect.end.x-overlap.end.x,overlap.size.y))
	]
	return pieces.filter(func(part:Rect2)->bool:return part.has_area())

static func paint_shadow(g,point:Vector2,radius:Vector2)->void:
	var outline:=PackedVector2Array()
	for vertex in 12:outline.append(point+Vector2(cos(vertex*TAU/12),sin(vertex*TAU/12))*radius)
	g.draw_colored_polygon(outline,Color("182b24",.12))

func foliage_near(g,point:Vector2)->bool:
	# Derselbe Modell- und Ortsplan wie die Darstellung, auch ohne Grafik nutzbar.
	var nearby:Array=rows if is_instance_valid(viewport) and g.camera_world_rect().grow(100).has_point(point) else collect(g,Rect2(point-Vector2(60,60),Vector2(120,120)))
	for row in nearby:
		if str(row["model"]).begins_with("common-wall-"):continue
		var family:String=Models.FAMILIES[int(row["map"])-1][int(row["motif"])-1]
		if family not in ["bush","fern","fern_roots"]:continue
		if point.distance_to(row["point"])<maxf(18.0,float(row["pixels"])*.45):return true
	return false
