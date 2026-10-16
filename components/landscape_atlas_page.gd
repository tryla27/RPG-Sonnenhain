extends RefCounted
## Feste GPU-Atlasseite. Ruhende Körper werden nur bei Änderungen gerendert.
const CELL:=128
const UNITS:=3.7
const PITCH:=.68
const FOOT:=Vector2(.5,.66)
var viewport:SubViewport
var world:Node3D
var camera:Camera3D
var bodies:Dictionary={}
var players:Dictionary={}
var shown:Dictionary={}
## Welche Körper beim letzten Seitenrender sichtbar waren und daher noch im
## Atlas stehen. Ausblenden braucht kein neues Bild; nur ein Wiedereinblenden
## nach einem Render ohne den Körper.
var painted:Dictionary={}
var dirty:=true
var was_playing:=false
var idle_clock:=0.0
var render_updates:=0
var columns:=8

func setup(g:Node,moving:bool,index:int)->void:
	columns=4 if moving else 8
	viewport=SubViewport.new();viewport.name="LandscapeAtlas_%d"%index
	viewport.own_world_3d=true;viewport.transparent_bg=true;viewport.gui_disable_input=true
	viewport.size=Vector2i.ONE*columns*CELL
	viewport.render_target_update_mode=SubViewport.UPDATE_DISABLED
	world=Node3D.new();viewport.add_child(world)
	camera=Camera3D.new();camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.current=true
	camera.near=.01;camera.far=1000;world.add_child(camera)
	camera.size=columns*UNITS
	var center:=Vector3(columns*UNITS*.5,0,columns*UNITS*.5/sin(PITCH))
	camera.position=center+Vector3(0,sin(PITCH),cos(PITCH))*60
	var env:=WorldEnvironment.new();var settings:=Environment.new()
	settings.background_mode=Environment.BG_COLOR;settings.background_color=Color(0,0,0,0)
	settings.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color=Color("dfe5d5");settings.ambient_light_energy=.72
	settings.tonemap_mode=Environment.TONE_MAPPER_LINEAR;env.environment=settings;world.add_child(env)
	var light:=DirectionalLight3D.new();light.rotation_degrees=Vector3(-55,-30,0)
	light.light_energy=.75;light.shadow_enabled=false;world.add_child(light)
	g.add_child(viewport)
	camera.look_at(center,Vector3.UP)

func add_body(key:String,body:Node3D,slot:int,row:Dictionary)->void:
	world.add_child(body);bodies[key]=body;shown[key]=true
	body.position=Vector3((slot%columns+FOOT.x)*UNITS,0,(slot/columns+FOOT.y)*UNITS/sin(PITCH))
	body.rotation.y=float(row.get("rotation",0.0))
	body.scale=Vector3(float(row.get("stretch_x",1.0)),float(row.get("stretch_y",1.0)),float(row.get("stretch_z",1.0)))
	if "countdown" in body:
		body.random.seed=hash(key);body.countdown=body.random.randf_range(body.idle_min,body.idle_max)
		# Seltene Ereignisse gemeinsam takten statt pro Objekt jeden Frame.
		body.set_process(false)
	var player:=body.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if player!=null:players[key]=player
	dirty=true

func set_visible_keys(wanted:Dictionary)->void:
	for key in bodies:
		var show:bool=wanted.has(key)
		if show==bool(shown.get(key,false)):continue
		shown[key]=show;bodies[key].visible=show
		bodies[key].process_mode=Node.PROCESS_MODE_INHERIT if show else Node.PROCESS_MODE_DISABLED
		# Der feste Atlasplatz behält sein Bild; nur fehlende Bilder nachzeichnen.
		if show and not bool(painted.get(key,false)):dirty=true

func remove_body(key:String)->void:
	if not bodies.has(key):return
	# Der Platz wird erst beim nächsten add_body neu belegt und dann gezeichnet.
	bodies[key].free();bodies.erase(key);shown.erase(key);painted.erase(key);players.erase(key)

## allow_static=false verschiebt ein reines Nachzeichnen ruhender Körper auf ein
## späteres Bild, damit nicht mehrere Seiten im selben Bild neu entstehen.
## Rückgabe: true, wenn dieses Bild ein solches Nachzeichnen ausgelöst hat.
func step(delta:float,allow_static:bool=true)->bool:
	idle_clock+=delta
	if idle_clock>=.25:
		for key in players:
			if bool(shown.get(key,false)):bodies[key].call("_process",idle_clock)
		idle_clock=0.0
	var playing:=false
	for key in players:
		if bool(shown.get(key,false)) and players[key].is_playing():playing=true;break
	var animating:=playing or was_playing
	was_playing=playing
	if not animating and (not dirty or not allow_static):return false
	viewport.render_target_update_mode=SubViewport.UPDATE_ONCE;render_updates+=1
	for key in bodies:painted[key]=bool(shown.get(key,false))
	var consumed:=dirty and not animating
	dirty=false
	return consumed

func suspend()->void:
	world.process_mode=Node.PROCESS_MODE_DISABLED
	viewport.render_target_update_mode=SubViewport.UPDATE_DISABLED
